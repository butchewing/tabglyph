# tabglyph

**Put icons in your terminal tab titles — by name — and have them actually render in the macOS tab bar.**

```sh
tab fa-rocket Shipping      #  Shipping
tab md-pulse Pulse          # 󰐰 Pulse
tab oct-git_branch main     #  main
tab ghost Ghostty           # 👻 Ghostty
tab Deploying to prod       # plain text, no glyph
```

One `tab` command. ~10,000 searchable icons. Works in **Ghostty** tab labels on macOS — the place everyone says you can't theme.

<!-- Drop a screenshot at docs/demo.png and uncomment:
![tabglyph demo](docs/demo.png)
-->

---

## Why this exists

On macOS, terminal **tab labels are drawn by the OS in the system font**, which has no glyph at Font Awesome / Nerd Font Private-Use codepoints — so they render as tofu boxes (□). For a long time the accepted wisdom ([ghostty#5484](https://github.com/ghostty-org/ghostty/discussions/5484)) was that tab-title icons were impossible on macOS.

The breakthrough ([ghostty#9650](https://github.com/ghostty-org/ghostty/discussions/9650)): point Ghostty's **`window-title-font-family` at a single Nerd Font**. Because one Nerd Font file contains *both* the text letters *and* ~10k icons, the title renderer never has to cascade across fonts — and the glyphs render right in the tab labels.

tabglyph turns that into an ergonomic workflow: it reads the icon names baked into your installed Nerd Font and gives you a single `tab` command that takes icon names like `fa-rocket` or `md-pulse`.

## Requirements

- **macOS** with [Ghostty](https://ghostty.org) (the tab-label rendering trick is Ghostty + macOS).
- **zsh**
- A **[Nerd Font](https://www.nerdfonts.com)** installed (e.g. `0xProto Nerd Font`, `CommitMono Nerd Font`, `JetBrainsMono Nerd Font`).
- **python3** + **fonttools** (the installer handles fonttools for you).

> Font Awesome and emoji helpers are included too. Emoji also render in tab labels; Font Awesome Pro renders in *window* titles.

## Install

```sh
git clone https://github.com/butchewing/tabglyph.git ~/.tabglyph
~/.tabglyph/install.sh
```

The installer generates your icon tables, adds one `source` line to `~/.zshrc`, and prints the exact Nerd Font family name to use.

Then in your **Ghostty config** (`~/Library/Application Support/com.mitchellh.ghostty/config`):

```
window-title-font-family = 0xProto Nerd Font Propo   # use the name the installer printed
```

…and **fully quit & reopen Ghostty** (a config reload does not apply font changes). See [`examples/ghostty-config`](examples/ghostty-config).

### oh-my-zsh users

oh-my-zsh rewrites the tab title on every prompt, which clobbers your titles. Add this **above** `source $ZSH/oh-my-zsh.sh`:

```sh
DISABLE_AUTO_TITLE="true"
```

## Usage

### `tab` — the one command

```sh
tab <name> <label...>
```

If the first word is a known **Nerd Font** name (`fa-rocket`, `md-pulse`, `oct-git_branch`) or an **emoji** name (`ghost`, `rocket`), it becomes a leading glyph and the rest is the label. Otherwise the whole line is literal.

```sh
tab fa-server prod          #  prod
tab md-heart_pulse Pulse    # 󰗶 Pulse
tab tada Released           # 🎉 Released
tab Running tests           # literal text
tab "rocket science"        # quoted = forced literal (no emoji)
```

### Discovery

10k icons is a lot — search instead of memorizing:

```sh
nf-find pulse     # cod-pulse, fa-bed_pulse, md-heart_pulse, md-pulse, oct-pulse …
nf-find git       # every git-related glyph
em-find heart     # heart, heartbeat
```

### Glyph primitives

Print a single glyph (handy for prompts, scripts, or building titles by hand):

```sh
nf fa-rocket      # Nerd Font glyph (the set that renders in tab labels)
fa wave-pulse     # Font Awesome Pro glyph (window titles)
em ghost          # emoji
echo "$(nf oct-flame) build failed"
```

| Set | Glyph cmd | Search | Renders in tab labels? |
|-----|-----------|--------|------------------------|
| Nerd Font (~10k) | `nf` | `nf-find` | ✅ yes |
| Emoji (~50) | `em` | `em-find` | ✅ yes |
| Font Awesome Pro | `fa` | `fa-find` | ⚠️ window titles only |

## How it works

- **Icon names → codepoints.** Nerd Fonts name their glyphs meaningfully in the font's `cmap` (`fa-rocket`, `md-pulse`, `oct-git_branch`). `tabglyph-gen` reads those names straight from *your* installed font — no bundled icon database to drift out of date — and writes a zsh lookup table.
- **`tab` sets the title** with an `OSC 0` escape (`\033]0;…\007`).
- **Ghostty renders the title** using `window-title-font-family`; with a single Nerd Font there, the icon codepoints resolve and show in the tab strip.

### Regenerating after a font update

```sh
~/.tabglyph/bin/tabglyph-gen                       # auto-detect
~/.tabglyph/bin/tabglyph-gen --nerd-font CommitMono # pick a specific font
```

## The gotchas it solves

Hard-won during a very long debugging session:

1. The **title uses `window-title-font-family`**, not the terminal `font-family`.
2. A **single Nerd Font** is required — a multi-font fallback chain won't cascade Private-Use glyphs into macOS tab labels.
3. **Two things** overwrite titles each prompt: Ghostty's `shell-integration-features` `title` (set `no-title`) and oh-my-zsh's hook (`DISABLE_AUTO_TITLE="true"`).
4. Use **OSC 0**, not OSC 1.
5. Font changes need a **full app restart**, not a reload.

## Credits

- The macOS Nerd-Font-in-title insight: [ghostty#9650](https://github.com/ghostty-org/ghostty/discussions/9650) and [ghostty#5484](https://github.com/ghostty-org/ghostty/discussions/5484).
- [Nerd Fonts](https://www.nerdfonts.com) for patching thousands of icons into coding fonts.
- [Ghostty](https://ghostty.org) by Mitchell Hashimoto.

## License

MIT © Butch Ewing — see [LICENSE](LICENSE).
