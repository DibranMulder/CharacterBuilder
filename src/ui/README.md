# Chronicle UI

Visual source: `designs/ui-system-board.png`. The reusable module lives outside
the training prototype so future game menus can use it unchanged.

Attach `preload("res://src/ui/chronicle_theme.gd").create()` to a parent Control's
`theme`. Ordinary Godot Buttons inherit the secondary navy treatment. Set
`theme_type_variation` to `PrimaryButton`, `QuietButton`, `DangerButton`, or
`ToggleButton` for the semantic role. Toggles also need `toggle_mode = true`.
Use `ChronicleHeading` on Labels; `InkPanel` and `ParchmentPanel` on Panels.
All states—including disabled and the transparent cyan focus ring—are shared.
Keep native Button input/signals; screens do not draw their own button frames.

The board's palette, notched brass frames, inset bevels, warm type, grain and
botanical panel corners are implemented as scalable drawing instructions.
Fonts request Alegreya SC / Alegreya Sans with Georgia / Helvetica fallbacks;
the Alegreya font files are not bundled, so exact typography is not guaranteed.
Use at least 48px button height for touch-first layouts. Do not change the cached
theme per screen; choose a variation or add a semantic variation here instead.

`chronicle_frame.gd` is private drawing implementation; consumers use the theme.
`godot --path . --script src/ui/preview.gd` renders all supported states into
`artifacts/chronicle_ui.png`. This is a visual check, not a gameplay screen.
