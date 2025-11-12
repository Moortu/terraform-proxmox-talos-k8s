#!/bin/bash
set -e

echo "=========================================="
echo "Terramate Installation Script"
echo "=========================================="
echo ""

# Detect OS
OS="$(uname -s)"
ARCH="$(uname -m)"

echo "Detected OS: $OS"
echo "Detected Architecture: $ARCH"
echo ""

# Map architecture
case "$ARCH" in
    x86_64)
        ARCH="amd64"
        ;;
    aarch64|arm64)
        ARCH="arm64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Map OS
case "$OS" in
    Linux)
        OS="linux"
        ;;
    Darwin)
        OS="darwin"
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# Get latest version
echo "Fetching latest Terramate version..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/terramate-io/terramate/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')

if [ -z "$LATEST_VERSION" ]; then
    echo "Failed to fetch latest version"
    exit 1
fi

echo "Latest version: v$LATEST_VERSION"
echo ""

# Download URL
DOWNLOAD_URL="https://github.com/terramate-io/terramate/releases/download/v${LATEST_VERSION}/terramate_${LATEST_VERSION}_${OS}_${ARCH}.tar.gz"

echo "Downloading from: $DOWNLOAD_URL"
echo ""

# Create temp directory
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

# Download
curl -L -o terramate.tar.gz "$DOWNLOAD_URL"

# Extract
tar -xzf terramate.tar.gz

# Install
INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"

mv terramate "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/terramate"

# Cleanup
cd -
rm -rf "$TMP_DIR"

echo "=========================================="
echo "✓ Terramate installed successfully!"
echo "=========================================="
echo ""
echo "Installation location: $INSTALL_DIR/terramate"
echo ""

# Check if in PATH
if echo "$PATH" | grep -q "$INSTALL_DIR"; then
    echo "✓ $INSTALL_DIR is in your PATH"
else
    echo "⚠ $INSTALL_DIR is NOT in your PATH"
    echo ""
    echo "Add the following to your ~/.bashrc or ~/.zshrc:"
    echo ""
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
fi

# Verify installation
if command -v terramate &> /dev/null; then
    echo "Terramate version:"
    terramate version
else
    echo "Please add $INSTALL_DIR to your PATH and restart your shell"
    echo "Then run: terramate version"
fi

echo ""
echo "=========================================="
echo "Next steps:"
echo "=========================================="
echo ""
echo "1. Verify installation:"
echo "   $ terramate version"
echo ""
echo "2. Generate Terramate code:"
echo "   $ terramate generate"
echo ""
echo "3. Deploy your infrastructure:"
echo "   $ cd stacks/production/cluster"
echo "   $ terraform init"
echo "   $ terraform apply"
echo ""
echo "See QUICKSTART.md for detailed instructions"
echo ""
