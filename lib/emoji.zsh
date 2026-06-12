# tabglyph — curated emoji map.
# Defined by codepoint escapes so this file stays pure ASCII (no mojibake).
# Emoji render in the macOS native tab strip via the system-font cascade,
# which is why they work where Font Awesome Private-Use glyphs do not.
typeset -gA EMOJI
EMOJI=(
  rocket $'\U0001F680'     fire $'\U0001F525'        sparkles $'✨'
  bug $'\U0001F41B'        wrench $'\U0001F527'       hammer $'\U0001F528'
  gear $'⚙️'     package $'\U0001F4E6'      lock $'\U0001F512'
  key $'\U0001F511'        check $'✅'            x $'❌'
  warning $'⚠️'  stop $'\U0001F6D1'         heart $'\U0001FAC0'
  heartbeat $'\U0001F493'  pulse $'\U0001FAC0'        star $'⭐'
  zap $'⚡'            cloud $'☁️'      disk $'\U0001F4BE'
  computer $'\U0001F4BB'   keyboard $'⌨️'   globe $'\U0001F310'
  link $'\U0001F517'       search $'\U0001F50D'       books $'\U0001F4DA'
  memo $'\U0001F4DD'       pin $'\U0001F4CC'          calendar $'\U0001F4C5'
  clock $'\U0001F550'      hourglass $'⏳'        green $'\U0001F7E2'
  red $'\U0001F534'        yellow $'\U0001F7E1'       ghost $'\U0001F47B'
  skull $'\U0001F480'      robot $'\U0001F916'        eyes $'\U0001F440'
  tada $'\U0001F389'       construction $'\U0001F6A7' money $'\U0001F4B0'
  chart $'\U0001F4C8'      test $'\U0001F9EA'         brain $'\U0001F9E0'
  snake $'\U0001F40D'      coffee $'☕'           bell $'\U0001F514'
  flag $'\U0001F6A9'       folder $'\U0001F4C1'       recycle $'♻️'
)
