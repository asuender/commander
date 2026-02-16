# commander

A minimal ZSH widget that lets you press **Ctrl+G**, type a natural language request, and get an AI-generated shell command inserted directly into your command line. Pure ZSH + curl + jq, powered by Groq.

## Prerequisites

- `zsh`
- `curl`
- `jq`
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

The input prompt is a full ZLE recursive edit session, so all your usual ZSH line editing keybindings work (arrow keys, word movement, etc.). Syntax highlighting and autosuggestions are temporarily disabled during input.

## Configuration

| Variable          | Default                    | Description          |
|-------------------|----------------------------|----------------------|
| `GROQ_API_KEY`    | (required)                 | Your Groq API key    |
| `COMMANDER_MODEL` | `llama-3.3-70b-versatile`  | Model ID to use      |

Example:
```sh
export COMMANDER_MODEL="llama-3.1-8b-instant"
```
