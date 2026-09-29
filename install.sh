#!/bin/sh
# Install Sluurp: one binary, put in ~/.sluurp/bin.
#
#   curl -fsSL https://raw.githubusercontent.com/SluurpHQ/releases/main/install.sh | sh
#
# SLUURP_VERSION=v0.2.0 picks a release (the latest by default);
# SLUURP_INSTALL=/some/dir picks where it goes.
set -eu

repo="SluurpHQ/releases"
version="${SLUURP_VERSION:-latest}"
dir="${SLUURP_INSTALL:-$HOME/.sluurp}/bin"

case "$(uname -s)" in
  Linux) os="unknown-linux-gnu" ;;
  Darwin) os="apple-darwin" ;;
  *) echo "sluurp: $(uname -s) is not Linux or macOS; on Windows, use install.ps1" >&2; exit 1 ;;
esac
case "$(uname -m)" in
  x86_64 | amd64) arch="x86_64" ;;
  arm64 | aarch64) arch="aarch64" ;;
  *) echo "sluurp: no build for $(uname -m)" >&2; exit 1 ;;
esac
target="$arch-$os"

if [ "$version" = latest ]; then
  url="https://github.com/$repo/releases/latest/download/sluurp-$target.tar.gz"
else
  url="https://github.com/$repo/releases/download/$version/sluurp-$target.tar.gz"
fi

echo "Downloading sluurp for $target"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$url" -o "$tmp/sluurp.tar.gz"
else
  wget -qO "$tmp/sluurp.tar.gz" "$url"
fi
tar xzf "$tmp/sluurp.tar.gz" -C "$tmp"
mkdir -p "$dir"
mv "$tmp/sluurp" "$dir/sluurp"
chmod +x "$dir/sluurp"

echo "Installed $dir/sluurp"
case ":$PATH:" in
  *":$dir:"*) ;;
  *)
    echo
    echo "Add it to your PATH, in ~/.profile or your shell's own file:"
    echo "  export PATH=\"$dir:\$PATH\""
    ;;
esac
echo
echo "Then: sluurp serve --public ./my-app"
