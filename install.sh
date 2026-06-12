#!/usr/bin/env bash
# tabglyph installer — generates icon tables, wires up zsh, prints next steps.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSHRC="${ZDOTDIR:-$HOME}/.zshrc"
SOURCE_LINE="source \"$REPO_DIR/tabglyph.plugin.zsh\""

echo "tabglyph: installing from $REPO_DIR"

# 1. Dependency check.
if ! command -v python3 >/dev/null 2>&1; then
  echo "  ! python3 is required" >&2; exit 1
fi
if ! python3 -c "import fontTools" >/dev/null 2>&1; then
  echo "  installing fonttools (pip --user)…"
  python3 -m pip install --user fonttools >/dev/null
fi

# 2. Build the icon tables from your installed fonts.
echo "  generating icon tables…"
python3 "$REPO_DIR/bin/tabglyph-gen"

# 3. Wire into ~/.zshrc (idempotent).
if [ -f "$ZSHRC" ] && grep -qF "tabglyph.plugin.zsh" "$ZSHRC"; then
  echo "  ~/.zshrc already sources tabglyph — leaving it alone"
else
  {
    echo ""
    echo "# tabglyph — terminal tab titles with icon glyphs"
    echo "$SOURCE_LINE"
  } >> "$ZSHRC"
  echo "  added source line to $ZSHRC"
fi

cat <<'EOF'

Done. Two more steps:

  1. Set your terminal's title font to the Nerd Font printed above.
     Ghostty:  window-title-font-family = <Nerd Font name>
     Then FULLY quit & reopen Ghostty (a config reload is not enough).

  2. If you use oh-my-zsh, stop it from overwriting titles every prompt —
     add this ABOVE `source $ZSH/oh-my-zsh.sh` in ~/.zshrc:
         DISABLE_AUTO_TITLE="true"

Then open a new shell and try:   tab fa-rocket Shipping
Discover icons with:            nf-find pulse
EOF
