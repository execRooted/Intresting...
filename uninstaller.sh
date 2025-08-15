#!/bin/bash
set -e
clear

echo "=== Hello Uninstaller ==="

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

# Remove hello executable
if [ -f /usr/local/bin/hello/hello ]; then
    echo "Removing /usr/local/bin/hello/hello..."
    sudo rm /usr/local/bin/hello/hello
    echo "Hello executable removed."
else
    echo "Hello executable not found in /usr/local/bin/hello."
fi

# Remove symlink
if [ -L /usr/local/bin/hi ]; then
    echo "Removing /usr/local/bin/hi symlink..."
    sudo rm /usr/local/bin/hi
    echo "Symlink removed."
elif [ -e /usr/local/bin/hi ]; then
    echo "Removing existing /usr/local/bin/hi file/directory..."
    sudo rm -rf /usr/local/bin/hi
fi

# Ask to remove .NET SDK, curl, mpg123
if command -v dotnet &> /dev/null; then
    read -p "Do you want to remove the .NET SDK, curl, and mpg123? [y/N]: " REMOVE_ALL
    if [[ "$REMOVE_ALL" =~ ^[Yy]$ ]]; then
        case "$LINUX_FAMILY" in
            Arch)
                sudo pacman -Rns --noconfirm dotnet-sdk curl mpg123
                ;;
            Debian)
                sudo apt remove --purge -y dotnet-sdk-7.0 curl mpg123
                sudo apt autoremove -y
                ;;
            Fedora)
                sudo dnf remove -y dotnet-sdk-7.0 curl mpg123
                ;;
            Opensuse)
                sudo zypper remove -y dotnet-sdk-7.0 curl mpg123
                ;;
        esac
        echo ".NET SDK, curl, and mpg123 removed."
    else
        echo "Skipped removing packages."
    fi
else
    echo ".NET SDK not found, nothing to remove."
fi

# Remove hello directory if empty
if [ -d /usr/local/bin/hello ]; then
    if [ -z "$(ls -A /usr/local/bin/hello)" ]; then
        sudo rmdir /usr/local/bin/hello
        echo "Removed empty /usr/local/bin/hello directory."
    else
        echo "/usr/local/bin/hello directory not empty, left intact."
    fi
fi

echo "=== Hello uninstallation complete ==="
