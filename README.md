# Mac Development Environment Setup

This repository contains a script to automate the setup of a new Mac for development work. The script installs essential developer tools, applications, and configurations to get you up and running quickly.

## What This Script Does

The setup script automates the following tasks:

1. **Xcode Command Line Tools** - Installs the essential developer tools from Apple
2. **Homebrew** - Sets up the package manager for macOS
3. **CLI Developer Tools** - Installs command-line tools including:
   - Git, Zsh
   - Node.js, Python, Rust
   - PostgreSQL
   - Zsh plugins (autosuggestions, syntax highlighting)
4. **GUI Applications** - Installs applications via Homebrew Cask:
   - iTerm2, Raycast
   - Visual Studio Code
   - Docker
   - Slack, Zoom
   - 1Password
   - And many more developer tools
5. **Shell Setup** - Configures Zsh with Oh My Zsh:
   - Installs Oh My Zsh
   - Adds useful plugins
   - Sets up custom aliases and functions
   - Configures npm completion
6. **VS Code Extensions** - Installs a curated set of extensions for:
   - JavaScript/TypeScript development
   - React and Svelte
   - Python and data science
   - Git integration
   - AI tools (GitHub Copilot, Claude)
   - And many more productivity boosters
7. **Development Environments** - Sets up:
   - NVM (Node Version Manager)
   - Java Development Kit
   - Android SDK paths
   - Ruby environment (rbenv)
8. **Mobile Development** - Configures:
   - iOS Simulator
   - Android Emulator

## Prerequisites

- A Mac running macOS (works on both Intel and Apple Silicon)
- Administrator access to install software
- Internet connection

## How to Run

1. Clone this repository or download the script:

   ```
   git clone https://github.com/yourusername/setup_mac.git
   cd setup_mac
   ```

2. Make the script executable:

   ```
   chmod +x setup_mac.sh
   ```

3. Run the script:

   ```
   ./setup_mac.sh
   ```

4. Follow any prompts during execution (the script will ask for confirmation before setting up mobile development simulators)

## After Running the Script

After the script completes, you should:

1. Restart your terminal or run `source ~/.zshrc` to apply the changes
2. Open the installed applications and complete any first-time setup
3. Configure Docker resources (CPU, RAM) from its settings if needed
4. For mobile development:
   - Open Xcode and run the "iPhone 14 (Setup)" simulator
   - Open Android Studio and run the "Pixel_6_API_33" emulator

## Customization

You can customize the script before running it:

- Edit the `cli_tools` array to add/remove command-line tools
- Edit the `cask_apps` array to add/remove GUI applications
- Edit the `VSCODE_EXTENSIONS` array to add/remove VS Code extensions

## Troubleshooting

- If you encounter any issues, try running the script again - it's designed to be idempotent
- For VS Code extensions, ensure the 'code' command is in your PATH
- For mobile development simulators, make sure Xcode and Android Studio are fully installed

## License

This script is provided as-is under the MIT License.
