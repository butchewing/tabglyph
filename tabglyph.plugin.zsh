# tabglyph — set terminal tab/window titles with icon glyphs, by name.
# https://github.com/butchewing/tabglyph
#
# Provides:
#   tab [name] <label...>   set the tab/window title (auto-detects icon/emoji)
#   nf <name>   nf-find <q> Nerd Font glyph + search (renders in macOS tabs)
#   fa <name>   fa-find <q> Font Awesome Pro glyph + search (window titles)
#   em <name>   em-find <q> emoji glyph + search
#
# Icon tables (NF_ICONS / FA_ICONS) are generated from YOUR installed fonts by
# `tabglyph-gen` and written to $TABGLYPH_DATA. EMOJI ships with the plugin.

# --- locations ------------------------------------------------------------
typeset -g TABGLYPH_DIR=${0:A:h}
typeset -g TABGLYPH_DATA=${TABGLYPH_DATA:-${XDG_CACHE_HOME:-$HOME/.cache}/tabglyph}

# --- data -----------------------------------------------------------------
[[ -r $TABGLYPH_DATA/nf-icons.zsh ]] && source $TABGLYPH_DATA/nf-icons.zsh
[[ -r $TABGLYPH_DATA/fa-icons.zsh ]] && source $TABGLYPH_DATA/fa-icons.zsh
[[ -r $TABGLYPH_DIR/lib/emoji.zsh ]] && source $TABGLYPH_DIR/lib/emoji.zsh

# Ensure the arrays exist even if a table is missing (keeps `nounset` happy).
(( ${+NF_ICONS} )) || typeset -gA NF_ICONS
(( ${+FA_ICONS} )) || typeset -gA FA_ICONS
(( ${+EMOJI} ))    || typeset -gA EMOJI

# --- core -----------------------------------------------------------------
# tab [name] <label...>  -> set the tab/window title via OSC 0.
#   tab Deploying...          plain text
#   tab fa-rocket Shipping    Nerd Font icon  (renders in macOS tab labels)
#   tab md-pulse Pulse        any of ~10k names from `nf-find`
#   tab ghost Ghostty         emoji name      (also renders in tab labels)
# If the first word is a known Nerd Font or emoji name it becomes a leading
# glyph; otherwise the whole line is literal. Quote to force literal text:
#   tab "rocket science"      -> literal, no glyph
tab() {
  emulate -L zsh
  local glyph=""
  if (( ${+NF_ICONS[$1]} )); then
    glyph="${(#):-0x$NF_ICONS[$1]}"; shift
  elif (( ${+EMOJI[$1]} )); then
    glyph="$EMOJI[$1]"; shift
  fi
  printf '\033]0;%s\007' "${glyph:+$glyph }$*"
}

# --- glyph primitives -----------------------------------------------------
# nf/fa print a glyph by codepoint; em prints a stored emoji string.
nf() {
  emulate -L zsh
  local cp=$NF_ICONS[$1]
  [[ -z $cp ]] && { print -ru2 -- "nf: unknown icon '$1'  (try: nf-find ${1:-search})"; return 1 }
  printf '%s' "${(#):-0x$cp}"
}
fa() {
  emulate -L zsh
  local cp=$FA_ICONS[$1]
  [[ -z $cp ]] && { print -ru2 -- "fa: unknown icon '$1'  (try: fa-find ${1:-search})"; return 1 }
  printf '%s' "${(#):-0x$cp}"
}
em() {
  emulate -L zsh
  local e=$EMOJI[$1]
  [[ -z $e ]] && { print -ru2 -- "em: unknown emoji '$1'  (try: em-find ${1:-search})"; return 1 }
  printf '%s' "$e"
}

# --- discovery ------------------------------------------------------------
nf-find() { print -l -- ${(ok)NF_ICONS} | grep -i -- "$1" }
fa-find() { print -l -- ${(ok)FA_ICONS} | grep -i -- "$1" }
em-find() { for k in ${(ok)EMOJI}; do print -- "$k $EMOJI[$k]"; done | grep -i -- "$1" }
