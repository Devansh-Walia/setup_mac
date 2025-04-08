#!/bin/bash
#
# Mac Development Environment Setup Script
# =======================================
# This script automates the setup of a new Mac for development work.
# It installs essential developer tools, applications, and configurations.
#

# Exit on error
set -e

echo "
🚀 ====================================== 🚀
      Setting up your Mac for development
🚀 ====================================== 🚀
"

# =============================================
# HELPER FUNCTIONS
# =============================================

# Function to install CLI tools if not already installed
install_package_if_missing() {
  if ! command -v "$1" &>/dev/null; then
    echo "  ➡️  Installing $1..."
    brew install "$1"
  else
    echo "  ✅ $1 already installed"
  fi
}

# Function to install cask apps if not already installed
install_cask_if_missing() {
  if ! brew list --cask "$1" &>/dev/null; then
    echo "  ➡️  Installing $1..."
    brew install --cask "$1"
  else
    echo "  ✅ $1 already installed"
  fi
}

# =============================================
# 1. XCODE COMMAND LINE TOOLS
# =============================================
echo "
📦 STEP 1: Installing Xcode Command Line Tools
---------------------------------------------"

if ! xcode-select -p &>/dev/null; then
  echo "  ➡️  Installing Xcode Command Line Tools..."
  xcode-select --install
else
  echo "  ✅ Xcode Command Line Tools already installed"
fi

# =============================================
# 2. HOMEBREW
# =============================================
echo "
🍺 STEP 2: Setting up Homebrew
---------------------------------------------"

if ! command -v brew &>/dev/null; then
  echo "  ➡️  Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add to shell (Apple Silicon default)
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "  ✅ Homebrew already installed"
fi

echo "  📦 Updating Homebrew..."
brew update

# =============================================
# 3. CLI DEVELOPER TOOLS
# =============================================
echo "
⚙️  STEP 3: Installing CLI Developer Tools
---------------------------------------------"

cli_tools=(
  git
  zsh
  node
  python
  rust
  postgresql
  zsh-autosuggestions
  zsh-syntax-highlighting
)

for tool in "${cli_tools[@]}"; do
  install_package_if_missing "$tool"
done

# Enable PostgreSQL
echo "  🚀 Starting PostgreSQL service..."
brew services start postgresql

# =============================================
# 4. GUI APPLICATIONS
# =============================================
echo "
🖥️  STEP 4: Installing GUI Applications
---------------------------------------------"

cask_apps=(
  iterm2          # Better terminal
  raycast         # Spotlight replacement
  1password       # Password manager
  visual-studio-code  # Code editor
  docker          # Containerization
  slack           # Team communication
  postman         # API testing
  ngrok           # Local tunneling
  android-studio  # Android development
  tableplus       # Database GUI
  zoom            # Video conferencing
  arc             # Browser
  notion          # Notes and organization
  todoist         # Task management
)

for app in "${cask_apps[@]}"; do
  install_cask_if_missing "$app"
done

# =============================================
# 5. SHELL SETUP (ZSH + OH MY ZSH)
# =============================================
echo "
🐚 STEP 5: Setting up ZSH and Oh My Zsh
---------------------------------------------"

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "  ➡️  Installing Oh My Zsh..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "  ✅ Oh My Zsh already installed"
fi

# Configure zsh plugins
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

echo "  🔗 Configuring zsh plugins..."
# Ensure plugin sourcing exists in .zshrc
if ! grep -q "zsh-autosuggestions" "$HOME/.zshrc"; then
  echo "source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> "$HOME/.zshrc"
fi

if ! grep -q "zsh-syntax-highlighting" "$HOME/.zshrc"; then
  echo "source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> "$HOME/.zshrc"
fi

echo "  🔧 Adding custom aliases and paths to .zshrc..."

# Add custom aliases
cat << 'EOT' >> "$HOME/.zshrc"

# Custom aliases
alias dev-chrome='open -n -a /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --args --user-data-dir="/tmp/chrome_dev_test" --disable-web-security'
alias edit="code  ~/.zshrc"
alias gs="git status"
alias ga="git add ."
alias gc="git commit -m"
alias push="git push origin"
alias pull="git pull origin"
alias switch="git checkout"
alias stash="git stash"
alias pop="git stash pop"
alias stash-p="git checkout -- ."
alias shake="adb shell input keyevent 82"
alias simulator="open -a Simulator"
alias simulator-root='open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app'
alias c="cursor"
alias w="windsurf"

# Custom functions
tree() {
  find . -maxdepth "$1" -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'
}

# Windsurf
export PATH="$HOME/.codeium/windsurf/bin:$PATH"
EOT

# Add npm completion if it doesn't exist
if ! grep -q "npm-completion" "$HOME/.zshrc"; then
  echo "  📦 Adding npm completion to .zshrc..."
  cat << 'EOT' >> "$HOME/.zshrc"

###-begin-npm-completion-###
#
# npm command completion script
#
if type complete &>/dev/null; then
  _npm_completion () {
    local words cword
    if type _get_comp_words_by_ref &>/dev/null; then
      _get_comp_words_by_ref -n = -n @ -n : -w words -i cword
    else
      cword="$COMP_CWORD"
      words=("${COMP_WORDS[@]}")
    fi

    local si="$IFS"
    if ! IFS=$'\n' COMPREPLY=($(COMP_CWORD="$cword" \
                           COMP_LINE="$COMP_LINE" \
                           COMP_POINT="$COMP_POINT" \
                           npm completion -- "${words[@]}" \
                           2>/dev/null)); then
      local ret=$?
      IFS="$si"
      return $ret
    fi
    IFS="$si"
    if type __ltrim_colon_completions &>/dev/null; then
      __ltrim_colon_completions "${words[cword]}"
    fi
  }
  complete -o default -F _npm_completion npm
elif type compdef &>/dev/null; then
  _npm_completion() {
    local si=$IFS
    compadd -- $(COMP_CWORD=$((CURRENT-1)) \
                 COMP_LINE=$BUFFER \
                 COMP_POINT=0 \
                 npm completion -- "${words[@]}" \
                 2>/dev/null)
    IFS=$si
  }
  compdef _npm_completion npm
elif type compctl &>/dev/null; then
  _npm_completion () {
    local cword line point words si
    read -Ac words
    read -cn cword
    let cword-=1
    read -l line
    read -ln point
    si="$IFS"
    if ! IFS=$'\n' reply=($(COMP_CWORD="$cword" \
                       COMP_LINE="$line" \
                       COMP_POINT="$point" \
                       npm completion -- "${words[@]}" \
                       2>/dev/null)); then

      local ret=$?
      IFS="$si"
      return $ret
    fi
    IFS="$si"
  }
  compctl -K _npm_completion npm
fi
###-end-npm-completion-###
EOT
fi

# Set zsh as the default shell
if [ "$SHELL" != "/bin/zsh" ]; then
  echo "  🔄 Setting zsh as default shell..."
  chsh -s /bin/zsh
fi

# =============================================
# 6. VS CODE EXTENSIONS
# =============================================
echo "
🧩 STEP 6: Installing VS Code Extensions
---------------------------------------------"

if ! command -v code &>/dev/null; then
  echo "  ⚠️  VS Code 'code' command not found in PATH."
  echo "      Open VS Code, press ⇧⌘P, and run: 'Shell Command: Install code command in PATH'"
else
  VSCODE_EXTENSIONS=(
    # Svelte
    1yib.svelte-bundle
    ardenivanov.svelte-intellisense
    fivethree.vscode-svelte-snippets
    svelte.svelte-vscode
    
    # React & JavaScript
    dsznajder.es7-react-js-snippets
    christian-kohler.npm-intellisense
    msjsdiag.vscode-react-native
    
    # Tailwind & CSS
    bradlc.vscode-tailwindcss
    csstools.postcss
    mrmlnc.vscode-scss
    naumovs.color-highlight
    
    # Code Quality & Formatting
    aaron-bond.better-comments
    dbaeumer.vscode-eslint
    esbenp.prettier-vscode
    streetsidesoftware.code-spell-checker
    usernamehw.errorlens
    yoavbls.pretty-ts-errors
    
    # Git & GitHub
    eamodio.gitlens
    github.vscode-github-actions
    github.vscode-pull-request-github
    waderyan.gitblame
    
    # AI & Copilot
    github.copilot
    github.copilot-chat
    visualstudioexptteam.intellicode-api-usage-examples
    visualstudioexptteam.vscodeintellicode
    saoudrizwan.claude-dev
    
    # Python & Data Science
    ms-python.debugpy
    ms-python.isort
    ms-python.python
    ms-python.vscode-pylance
    ms-toolsai.jupyter
    ms-toolsai.jupyter-keymap
    ms-toolsai.jupyter-renderers
    ms-toolsai.vscode-jupyter-cell-tags
    ms-toolsai.vscode-jupyter-slideshow
    
    # Docker & Remote Development
    ms-azuretools.vscode-docker
    ms-vscode-remote.remote-containers
    ms-vsliveshare.vsliveshare
    
    # Database & Data
    grapecity.gc-excelviewer
    mechatroner.rainbow-csv

    # GraphQL & API
    graphql.vscode-graphql
    graphql.vscode-graphql-syntax
  
    # UI & Design
    figma.figma-vscode-extension
    pkief.material-icon-theme
    zhuangtongfa.material-theme
    
    # YAML & Configuration
    redhat.vscode-yaml
    
    # Utilities
    formulahendry.auto-rename-tag
    ritwickdey.liveserver
    expo.vscode-expo-tools
  )

  for extension in "${VSCODE_EXTENSIONS[@]}"; do
    if ! code --list-extensions | grep -q "$extension"; then
      echo "  📎 Installing $extension..."
      code --install-extension "$extension"
    else
      echo "  ✅ VS Code extension already installed: $extension"
    fi
  done
fi

# =============================================
# 7. DEVELOPMENT ENVIRONMENTS
# =============================================
echo "
🛠️  STEP 7: Setting up Development Environments
---------------------------------------------"

# NVM (Node Version Manager)
echo "  📦 Setting up NVM (Node Version Manager)..."
if [ ! -d "$HOME/.nvm" ]; then
  echo "  ➡️  Installing NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
  
  # Add NVM to .zshrc if not already there
  if ! grep -q "NVM_DIR" "$HOME/.zshrc"; then
    cat << 'EOT' >> "$HOME/.zshrc"

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
EOT
  fi
else
  echo "  ✅ NVM already installed"
fi

# Java
echo "  ☕ Setting up Java..."
if ! command -v java &>/dev/null; then
  echo "  ➡️  Installing Java JDK 17..."
  brew install --cask zulu17
  
  # Add Java to .zshrc if not already there
  if ! grep -q "JAVA_HOME" "$HOME/.zshrc"; then
    cat << 'EOT' >> "$HOME/.zshrc"

# Java
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home
export PATH="$JAVA_HOME/bin:$PATH"
EOT
  fi
else
  echo "  ✅ Java already installed"
fi

# Android SDK paths
if [ -d "$HOME/Library/Android/sdk" ] && ! grep -q "ANDROID_HOME" "$HOME/.zshrc"; then
  echo "  🤖 Adding Android SDK paths to .zshrc..."
  cat << 'EOT' >> "$HOME/.zshrc"

# Android SDK
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
EOT
fi

# Library paths
if ! grep -q "LIBRARY_PATH" "$HOME/.zshrc"; then
  echo "  📚 Adding library paths to .zshrc..."
  cat << 'EOT' >> "$HOME/.zshrc"

# Library paths
export PATH="$PATH:/usr/local/lib:/opt/homebrew/lib"
export LIBRARY_PATH=$LIBRARY_PATH:/opt/homebrew/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/homebrew/lib
EOT
fi

# rbenv for Ruby
echo "  💎 Setting up rbenv for Ruby..."
if ! command -v rbenv &>/dev/null; then
  echo "  ➡️  Installing rbenv..."
  brew install rbenv ruby-build
  
  # Initialize rbenv
  if ! grep -q "rbenv init" "$HOME/.zshrc"; then
    echo 'eval "$(rbenv init - zsh)"' >> "$HOME/.zshrc"
  fi
else
  echo "  ✅ rbenv already installed"
fi

# =============================================
# 8. MOBILE DEVELOPMENT SIMULATORS
# =============================================
echo "
📱 STEP 8: Setting up Mobile Development Simulators
---------------------------------------------"

# Ask for confirmation before proceeding
read -p "Do you want to set up mobile development simulators? (y/n): " confirm
if [[ $confirm != [yY] && $confirm != [yY][eE][sS] ]]; then
  echo "  ⏭️  Skipping mobile development simulators setup..."
  echo ""
  echo "  You can run this step later by reinstalling this script."
  echo ""
else

  # iOS Simulator (Xcode)
  echo "  🍎 Setting up iOS Simulator..."
if command -v xcrun &>/dev/null; then
  # Check if any simulators are already installed
  if ! xcrun simctl list devices | grep -q "iPhone"; then
    echo "  ➡️  Installing iOS Simulator (iPhone 14 with latest iOS)..."
    # Create a new simulator for iPhone 14 with the latest iOS
    LATEST_IOS=$(xcrun simctl list runtimes | grep iOS | tail -1 | awk '{print $NF}')
    DEVICE_TYPE=$(xcrun simctl list devicetypes | grep "iPhone 14" | head -1 | awk -F '[()]' '{print $2}')
    
    if [ -n "$LATEST_IOS" ] && [ -n "$DEVICE_TYPE" ]; then
      xcrun simctl create "iPhone 14 (Setup)" "$DEVICE_TYPE" "$LATEST_IOS"
      echo "  ✅ iOS Simulator created: iPhone 14 with $LATEST_IOS"
    else
      echo "  ⚠️  Could not determine latest iOS version or iPhone 14 device type."
      echo "      Please open Xcode and create a simulator manually."
    fi
  else
    echo "  ✅ iOS Simulator already installed"
  fi
else
  echo "  ⚠️  Xcode command line tools not fully installed."
  echo "      Please open Xcode at least once to complete installation, then run this script again."
fi

  # Android Emulator
  echo "  🤖 Setting up Android Emulator..."
if [ -d "$HOME/Library/Android/sdk" ]; then
  ANDROID_SDK="$HOME/Library/Android/sdk"
  ANDROID_AVD_HOME="$HOME/.android/avd"
  
  # Create a Pixel 6 AVD if it doesn't exist
  if [ ! -d "$ANDROID_AVD_HOME/Pixel_6_API_33.avd" ]; then
    echo "  ➡️  Creating Android Virtual Device (Pixel 6 with API 33)..."
    
    # Ensure Android SDK tools are installed
    if [ ! -f "$ANDROID_SDK/cmdline-tools/latest/bin/sdkmanager" ]; then
      echo "  ➡️  Installing Android SDK Command-line tools..."
      brew install --cask android-commandlinetools
    fi
    
    # Accept licenses
    yes | "$ANDROID_SDK/cmdline-tools/latest/bin/sdkmanager" --licenses > /dev/null 2>&1 || true
    
    # Install necessary packages
    "$ANDROID_SDK/cmdline-tools/latest/bin/sdkmanager" "platform-tools" "platforms;android-33" "system-images;android-33;google_apis;x86_64" > /dev/null 2>&1
    
    # Create the AVD
    echo "no" | "$ANDROID_SDK/cmdline-tools/latest/bin/avdmanager" create avd \
      --name "Pixel_6_API_33" \
      --package "system-images;android-33;google_apis;x86_64" \
      --device "pixel_6" > /dev/null 2>&1
    
    echo "  ✅ Android Virtual Device created: Pixel 6 with API 33"
  else
    echo "  ✅ Android Virtual Device already installed"
  fi
else
  echo "  ⚠️  Android SDK not found."
  echo "      Please open Android Studio at least once and install the SDK, then run this script again."
fi

fi

# =============================================
# 9. CLEANUP
# =============================================
echo "
🧹 STEP 9: Cleaning Up
---------------------------------------------"
brew cleanup

# =============================================
# COMPLETION
# =============================================
echo "
✅ ====================================== ✅
      Mac Development Setup Complete!
✅ ====================================== ✅

📋 Next Steps:
-------------
1. Restart your terminal OR run:
   $ source ~/.zshrc

2. Use Raycast (or Spotlight ⌘+Space) to open apps like VS Code, Docker, etc.

3. Customize your ZSH theme:
   Visit https://ohmyz.sh/ for themes (e.g. Powerlevel10k)

4. PostgreSQL is running. Connect using:
   $ psql postgres

5. Configure Docker resources (CPU, RAM) from its settings

6. Mobile Development:
   - iOS: Open Xcode and run the "iPhone 14 Setup" simulator
   - Android: Open Android Studio and run the "Pixel_6_API_33" emulator
"
