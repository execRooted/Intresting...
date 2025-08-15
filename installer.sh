#!/bin/bash
set -e
clear

echo "=== Hello Installer ==="

# Detect Linux family
detect_linux() {
    if command -v pacman &> /dev/null; then
        echo "Arch"
    elif command -v apt &> /dev/null; then
        echo "Debian"
    elif command -v dnf &> /dev/null; then
        echo "Fedora"
    elif command -v zypper &> /dev/null; then
        echo "Opensuse"
    else
        echo "Unsupported OS"
        exit 1
    fi
}

LINUX_FAMILY=$(detect_linux)
echo "Detected Linux family: $LINUX_FAMILY"

# Install dependencies: .NET SDK, curl, mpg123
install_packages() {
    case "$LINUX_FAMILY" in
        Arch)
            sudo pacman -Sy --noconfirm dotnet-sdk curl mpg123
            ;;
        Debian)
            sudo apt update
            sudo apt install -y apt-transport-https curl mpg123 dotnet-sdk-7.0
            ;;
        Fedora)
            sudo dnf install -y dotnet-sdk-7.0 curl mpg123
            ;;
        Opensuse)
            sudo zypper install -y dotnet-sdk-7.0 curl mpg123
            ;;
    esac
}

echo "Installing required packages..."
install_packages

# Check dotnet
if ! command -v dotnet &> /dev/null; then
    echo "Error: .NET SDK could not be installed."
    exit 1
else
    echo "Dotnet SDK found: $(dotnet --version)"
fi

# Build and publish the app
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Publishing Hello..."
dotnet publish -c Release -r linux-x64 --self-contained true -o ./publish /p:PublishSingleFile=true

EXE_PATH=$(find ./publish -maxdepth 1 -type f -executable | head -n 1)
if [ -z "$EXE_PATH" ]; then
    echo "Error: Published executable not found!"
    exit 1
fi

# Install executable
sudo mkdir -p /usr/local/bin/hello
sudo cp "$EXE_PATH" /usr/local/bin/hello/hello
sudo chmod +x /usr/local/bin/hello/hello

# Remove old hi symlink/directory if exists
if [ -e /usr/local/bin/hi ]; then
    echo "Removing existing /usr/local/bin/hi..."
    sudo rm -rf /usr/local/bin/hi
fi

# Create symlink
sudo ln -sf /usr/local/bin/hello/hello /usr/local/bin/hi

echo "=== Installation complete! ==="
echo "You can now run 'hi' from anywhere."
echo "Executable is located in /usr/local/bin/hello/"
