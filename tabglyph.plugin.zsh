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
# Resolve a Nerd Font name to its codepoint, tolerating Font Awesome's hyphen
# style: Nerd Fonts name multi-word icons with underscores (fa-wave_square),
# so if an exact match fails we retry with inner hyphens -> underscores.
_tabglyph_nf_cp() {
  (( ${+NF_ICONS[$1]} )) && { print -r -- $NF_ICONS[$1]; return 0 }
  if [[ $1 == *-*-* ]]; then
    local alt="${1%%-*}-${${1#*-}//-/_}"
    (( ${+NF_ICONS[$alt]} )) && { print -r -- $NF_ICONS[$alt]; return 0 }
  fi
  return 1
}

# Nerd Font set prefixes — used to spot "you meant an icon" misses.
typeset -g _TABGLYPH_PREFIXES='alpha|cod|custom|dev|extra|fa|fae|iec|indent|linux|md|oct|ple|pl|pom|seti|weather'

tab() {
  emulate -L zsh
  local glyph="" cp
  if cp=$(_tabglyph_nf_cp $1); then
    glyph="${(#):-0x$cp}"; shift
  elif (( ${+EMOJI[$1]} )); then
    glyph="$EMOJI[$1]"; shift
  elif [[ $1 =~ "^(${_TABGLYPH_PREFIXES})-" ]]; then
    print -ru2 -- "tab: '$1' not in this Nerd Font — Nerd Fonts bundle Font Awesome *free* (not Pro), and use underscores. Try: nf-find ${1##*-}"
  fi
  printf '\033]0;%s\007' "${glyph:+$glyph }$*"
}

# --- glyph primitives -----------------------------------------------------
# nf/fa print a glyph by codepoint; em prints a stored emoji string.
nf() {
  emulate -L zsh
  local cp
  cp=$(_tabglyph_nf_cp $1) || { print -ru2 -- "nf: unknown icon '$1'  (try: nf-find ${1##*-})"; return 1 }
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

# --- maintenance ----------------------------------------------------------
# `tabglyph-gen` works regardless of install method (no PATH setup needed).
tabglyph-gen() { python3 "$TABGLYPH_DIR/bin/tabglyph-gen" "$@" }

# First-run nudge: if no Nerd Font table was loaded, tell the user how to build it.
if [[ -o interactive ]] && (( ${#NF_ICONS} == 0 )); then
  print -ru2 -- "tabglyph: no icon tables yet — run 'tabglyph-gen' to build them from your installed fonts."
fi
