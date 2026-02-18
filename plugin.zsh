# commander - ZSH AI command widget
# Press Ctrl+G to get an inline prompt, type a natural language request,
# and get an AI-generated shell command inserted into your command line.

: ${COMMANDER_MODEL:="llama-3.3-70b-versatile"}

log_error() {
  print "$1" >&2
}

if [[ -z "$GROQ_API_KEY" ]]; then
  log_error "GROQ_API_KEY is not set. The widget will be disabled."
fi

if ! command -v curl &>/dev/null; then
  log_error "curl is required but not found."
fi

if ! command -v jq &>/dev/null; then
  log_error "jq is required but not found."
fi

if ! command -v gum &>/dev/null; then
  log_error "gum is required but not found."
fi

# Detect useful CLI tools available in the user's environment.
# Runs once at plugin load time (once per ZSH session).
_commander_tools=(
  rg fd bat eza fzf zoxide sd delta hyperfine
  tldr dust duf procs btm tokei xh
)

_COMMANDER_AVAILABLE_TOOLS=""
for _cmd in "${_commander_tools[@]}"; do
  if command -v "$_cmd" &>/dev/null; then
    if [[ -n "$_COMMANDER_AVAILABLE_TOOLS" ]]; then
      _COMMANDER_AVAILABLE_TOOLS+=", $_cmd"
    else
      _COMMANDER_AVAILABLE_TOOLS="$_cmd"
    fi
  fi
done
unset _cmd _commander_tools

_commander_query() {
  local user_input="$1"

  local escaped_input
  escaped_input=$(printf '%s' "$user_input" | jq -Rs '.')

  local payload
  payload=$(cat <<EOF
{
  "model": "${COMMANDER_MODEL}",
  "messages": [
    {
      "role": "system",
      "content": "You are a shell command generator. Given a natural language description, output ONLY the shell command - no explanation, no markdown, no code fences. The user's shell is ${SHELL##*/} on $(uname -s).${_COMMANDER_AVAILABLE_TOOLS:+ Prefer these available tools when relevant: ${_COMMANDER_AVAILABLE_TOOLS}.}"
    },
    {
      "role": "user",
      "content": ${escaped_input}
    }
  ],
  "max_completion_tokens": 256
}
EOF
)

  local response
  response=$(curl -sS "https://api.groq.com/openai/v1/chat/completions" \
    -H "Authorization: Bearer ${GROQ_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "$payload" 2>&1)

  if [[ $? -ne 0 ]]; then
    printf '%s' "$response"
    return 1
  fi

  local error
  error=$(printf '%s' "$response" | jq -r '.error // empty')
  if [[ -n "$error" ]]; then
    local error_msg
    error_msg=$(printf '%s' "$response" | jq -r '.error.message // "Unknown API error"')
    print -r -- "${error_msg}"
    return 1
  fi

  printf '%s' "$response" | jq -r '.choices[0].message.content'
}

_commander_widget() {
  if [[ -z "$GROQ_API_KEY" ]]; then
    zle -M "commander: GROQ_API_KEY is not set"
    return
  fi

  if ! command -v curl &>/dev/null; then
    zle -M "commander: curl is required but not found"
    return
  fi

  if ! command -v jq &>/dev/null; then
    zle -M "commander: jq is required but not found"
    return
  fi

  if ! command -v gum &>/dev/null; then
    zle -M "commander: gum is required but not found"
    return
  fi

  zle -I

  local saved_buffer="$BUFFER"
  local saved_cursor="$CURSOR"

  local input
  input=$(gum input --prompt "ai> " --placeholder "describe a command..." --width 0 --no-show-help)

  if [[ $? -ne 0 || -z "$input" ]]; then
    BUFFER="$saved_buffer"
    CURSOR="$saved_cursor"
    zle reset-prompt
    return
  fi

  print -n "ai> generating..."

  local result
  result=$(_commander_query "$input")

  if [[ $? -ne 0 ]]; then
    BUFFER="$saved_buffer"
    CURSOR="$saved_cursor"
    zle reset-prompt
    zle -M "commander: ${result}"
    return
  fi

  BUFFER="$result"
  CURSOR=${#BUFFER}
  zle reset-prompt
}

zle -N commander _commander_widget
bindkey '^g' commander
