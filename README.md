# 🗂️ Navigate - Interactive Folder Navigator

An interactive zsh script for macOS that allows you to navigate through your folder system with ease and style.

## ✨ Features

- 📁 Lists only folders in the current directory
- 🎯 Intuitive navigation with numbered options
- 🔙 Easy parent directory navigation with `0`
- 🚪 Clean exit with `q`
- 🛡️ Protection against system root access
- 🎨 Clean visual interface with emojis and colors
- 🔧 Handles folder names with spaces correctly
- 🌍 International support (English interface)

## 🚀 Usage

### Option 1: Run from current directory
```bash
./navigate.sh
```

### Option 2: Specify a starting directory
```bash
./navigate.sh /path/to/directory
```

### Option 3: Use with source (recommended)
```bash
source navigate.sh
```

## 🎮 Controls

- **Numbers (1, 2, 3...)**: Enter the corresponding folder
- **0**: Go up to parent directory
- **q**: Exit the script

## 📋 Example Usage

```
🗂️  Folder Navigator v1.0.0
==========================
📍 Current directory: /Users/username/Documents

📁 Current directory: /Users/username/Documents
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📂 Available folders:

  1) Projects
  2) Images
  3) Videos

🔧 Options:
  0) 🔙 Go up one level
  q) 🚪 Exit

👉 Choose an option: 1

✅ Entered: Projects
```

## 🔧 Installation

1. Download the `navigate.sh` script
2. Make it executable:
   ```bash
   chmod +x navigate.sh
   ```
3. Ready to use!

### Global Installation (Optional)

To use the script from anywhere:

```bash
# Copy to your PATH
sudo cp navigate.sh /usr/local/bin/navigate
sudo chmod +x /usr/local/bin/navigate

# Now you can use it globally
navigate
```

### Create an Alias (Recommended)

Add to your `~/.zshrc` file:

```bash
# Add this line to your ~/.zshrc
alias nav="source /path/to/navigate.sh"

# Reload your shell
source ~/.zshrc

# Now you can use it with:
nav
```

## 🔄 Execution Methods

### Using `source` (Recommended)
```bash
source navigate.sh
```
**Benefits:**
- Directory changes persist in your current terminal session
- You stay in the folder where you finish navigating
- Perfect for quick navigation

### Using `./` (Standard execution)
```bash
./navigate.sh
```
**Benefits:**
- Runs in a separate subprocess
- Doesn't affect your current terminal session
- Safer for testing

## 📝 Technical Notes

- **Platform**: Designed specifically for **macOS** with **zsh**
- **Display**: Shows only folders, not files
- **Safety**: Includes protection to prevent navigation to system directories
- **Error Handling**: Gracefully handles permission errors and invalid folders
- **Array Technology**: Uses associative arrays for accurate folder mapping

## 🛠️ Requirements

- macOS
- zsh (default shell on macOS)
- Basic terminal permissions

## 🎯 Use Cases

Perfect for:
- **Quick project navigation**: Jump between development folders
- **File organization**: Navigate through complex directory structures
- **Daily workflow**: Replace `cd` commands with visual navigation
- **Learning**: Great for users new to command line navigation

## 🔍 Troubleshooting

### Script doesn't start
- Check execute permissions: `chmod +x navigate.sh`
- Verify you're using zsh: `echo $SHELL`

### Folders not showing correctly
- Ensure you have read permissions for the directory
- Check for hidden folders with `ls -la`

### Numbers don't match folders
- This should be fixed in v2.0 with associative arrays
- Try running the script fresh

## 🤝 Contributing

Feel free to suggest improvements or report issues!

## 📄 License

[Apache License](LICENSE)

---

**Arturo Carretero Calvo - 2025**