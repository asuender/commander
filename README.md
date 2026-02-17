# commander

A minimal ZSH widget that lets you press **Ctrl+G**, type a natural language request, and get an AI-generated shell command inserted directly into your command line. Pure ZSH + curl + jq + gum, powered by Groq.

## Prerequisites

- `zsh`
- `curl`
- `jq`
- [`gum`](https://github.com/charmbracelet/gum)
- A [Groq API key](https://console.groq.com/)

## Installation

1. Clone the repository:
   ```sh
   git clone https://github.com/your-user/commander.git ~/.commander
   ```

2. Add to your `.zshrc`:
   ```sh
   export GROQ_API_KEY="your-api-key-here"
   source ~/.commander/plugin.zsh
   ```

3. Reload your shell:
   ```sh
   source ~/.zshrc
   ```

## Usage

1. Press **Ctrl+G** - an `ai> ` prompt appears below your current prompt
2. Type a natural language request (e.g. "find all TODO comments in this directory")
3. Press **Enter** to submit - the AI-generated command is placed into your buffer
4. Press **Ctrl+C** or **Ctrl+G** to abort
5. Review the command, edit if needed, then press **Enter** to execute

The input prompt is powered by [gum](https://github.com/charmbracelet/gum), so it renders cleanly below your shell prompt without interfering with ZSH syntax highlighting or autosuggestions.

## Configuration

| Variable          | Default                    | Description          |
|-------------------|----------------------------|----------------------|
| `GROQ_API_KEY`    | (required)                 | Your Groq API key    |
| `COMMANDER_MODEL` | `llama-3.3-70b-versatile`  | Model ID to use      |

Example:
```sh
export COMMANDER_MODEL="llama-3.1-8b-instant"
```
