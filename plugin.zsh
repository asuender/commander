# commander - ZSH AI command widget
# Press Ctrl+G to get an inline prompt, type a natural language request,
# and get an AI-generated shell command inserted into your command line.

: ${COMMANDER_MODEL:="llama-3.3-70b-versatile"}

if [[ -z "$GROQ_API_KEY" ]]; then
  print -P "GROQ_API_KEY is not set. The widget will be disabled." >&2
fi

if ! command -v curl &>/dev/null; then
  print -P "curl is required but not found." >&2
fi

if ! command -v jq &>/dev/null; then
  print -P "jq is required but not found." >&2
fi

if ! command -v gum &>/dev/null; then
  print -P "gum is required but not found." >&2
fi

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
      "content": "You are a shell command generator. Given a natural language description, output ONLY the shell command - no explanation, no markdown, no code fences. The user's shell is zsh on linux."
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
  response=$(curl -s "https://api.groq.com/openai/v1/chat/completions" \
    -H "Authorization: Bearer ${GROQ_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "$payload" 2>/dev/null)

  local error
  error=$(printf '%s' "$response" | jq -r '.error // empty')
  if [[ -n "$error" ]]; then
    local error_msg
    error_msg=$(printf '%s' "$response" | jq -r '.error.message // "Unknown API error"')
    print -r -- "ERROR: ${error_msg}"
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

  local saved_buffer="$BUFFER"
  local saved_cursor="$CURSOR"

  zle -I

  local input
  input=$(gum input --prompt "ai> " --placeholder "describe a command..." --width 0)

  if [[ $? -ne 0 || -z "$input" ]]; then
    BUFFER="$saved_buffer"
    CURSOR="$saved_cursor"
    zle reset-prompt
    return
  fi

  print -n "ai> generating..."

  local result
  result=$(_commander_query "$input")

  if [[ $? -ne 0 || "$result" == ERROR:* ]]; then
    local err_msg="${result#ERROR: }"
    print "\rai> error: ${err_msg}"
    sleep 2
    BUFFER="$saved_buffer"
    CURSOR="$saved_cursor"
    zle reset-prompt
    return
  fi

  BUFFER="$result"
  CURSOR=${#BUFFER}
  zle reset-prompt
}

zle -N commander _commander_widget
bindkey '^g' commander
