# Navigate - Interactive Folder Navigator

Interactive `zsh` folder navigator for macOS. It is designed to be sourced from your shell so the final directory persists after you exit.

## Features

- Lists folders with numeric shortcuts.
- Keeps your final directory when used with `source`.
- Supports folder names with spaces.
- Filters folders with `/text`.
- Searches folders recursively using `s`, without external dependencies.
- Jumps to favorite directories.
- Toggles hidden folders.
- Goes up, goes back, opens Finder, and opens your editor.
- Uses a cleaner colored terminal interface.
- Handles directories with no folders without `zsh` glob errors.

## Recommended Setup

Add this to your `~/.zshrc`:

```zsh
alias nav="source /path/to/navigate.sh"
```

Then reload your shell:

```zsh
source ~/.zshrc
```

Use it from anywhere:

```zsh
nav
nav ~/Downloads/Proyectos
```

## Controls

| Input | Action |
| --- | --- |
| `Up` / `Down` | Move through the folder list |
| `Enter` | Enter the highlighted folder |
| `1`, `2`, `3` | Enter the selected folder |
| `0` or `..` | Go up one level |
| `-` | Go back to the previous directory |
| `/text` | Filter visible folders by text |
| `/` | Clear the current filter |
| `s` | Search folders recursively |
| `h` | Toggle hidden folders |
| `f` | Show favorites |
| `o` | Open current folder in Finder |
| `e` | Open current folder in your configured editor |
| `.` | Stay in current folder and exit |
| `q` | Exit |

## Configuration

Configure behavior with environment variables in your `~/.zshrc`.

```zsh
export NAV_FAVORITES="$HOME/Downloads/Proyectos:$HOME/Desktop:$HOME/Documents:$HOME"
export NAV_EDITOR="code"
export NAV_SHOW_HIDDEN=0
export NAV_CLEAR=1
export NAV_SEARCH_LIMIT=30
```

Available options:

| Variable | Default | Description |
| --- | --- | --- |
| `NAV_FAVORITES` | `~/Downloads/Proyectos:~/Documents:~/Desktop:~` | Colon-separated favorite folders |
| `NAV_EDITOR` | `$VISUAL` or `$EDITOR` | Command used by the `e` shortcut |
| `NAV_SHOW_HIDDEN` | `0` | Set to `1` to show hidden folders by default |
| `NAV_CLEAR` | `1` | Set to `0` to keep previous menus on screen |
| `NAV_SEARCH_LIMIT` | `30` | Maximum recursive search results shown |

## Recursive Search

The `s` shortcut searches folders below the current directory using only `zsh`.

Press `s`, type part of a folder name, then choose one of the numbered results.

Use `/text` when you only want to filter the folders visible in the current directory.

## Usage Examples

Start in the current folder:

```zsh
nav
```

Start in your projects folder:

```zsh
nav ~/Downloads/Proyectos
```

Filter folders containing `api`:

```text
Choose an option: /api
```

Search recursively:

```text
Choose > s
Search > api
```

Jump to a favorite:

```text
Choose an option: f
```

Open the current folder in your editor:

```text
Choose an option: e
```

## Source vs Direct Execution

Recommended:

```zsh
source navigate.sh
```

This changes the directory in your current terminal session.

Direct execution also works:

```zsh
./navigate.sh
```

However, direct execution runs in a subprocess, so your terminal returns to the previous directory when the script exits.

## Help

```zsh
source navigate.sh --help
```

## Requirements

- macOS
- `zsh`

## License

[Apache License](LICENSE)

---

Arturo Carretero Calvo - 2026