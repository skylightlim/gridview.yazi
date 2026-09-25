# gridview.yazi

A thumbnail grid of the current folder for [yazi](https://github.com/sxyazi/yazi),
drawn by [swayimg](https://github.com/artemsen/swayimg).

Press `g v` and every image in the folder appears as a grid, floating over the
yazi window and starting on the image you were hovering. Pick one and yazi jumps
to it.

This is the yazi docs' [Grid view with Rofi](https://yazi-rs.github.io/docs/tips/#grid-view)
tip without rofi. swayimg is a small Wayland image viewer with a gallery mode,
scripted in Lua.

## Install

```sh
ya pkg add skylightlim/gridview
```

and swayimg 5.5 or newer, which gridview needs for its Lua API:

```sh
sudo pacman -S swayimg        # Arch
```

For other distros, [Repology](https://repology.org/project/swayimg/versions)
lists which version each one packages.

Then bind it in `~/.config/yazi/keymap.toml`:

```toml
[[mgr.prepend_keymap]]
on   = [ "g", "v" ]
run  = "plugin gridview"
desc = "Grid view"
```

`g v` is free in yazi's default keymap. Any key works.

## Keys in the grid

| Key | Action |
| --- | --- |
| `h` `j` `k` `l`, arrows | Move |
| `Enter`, click | Jump yazi to that image and close the grid |
| `Esc`, `q` | Close without moving |
| `Home` / `End`, `PgUp` / `PgDn` | First / last, page up / down |

swayimg's other gallery keys still work too, such as `+` / `-` for thumbnail size
and `f` for fullscreen.

## Configuration

Your own `~/.config/swayimg/init.lua` applies to the grid. It loads first, so its
colours, fonts and anything else carry over.

gridview then sets a few things itself: the overlay window, whole-image
thumbnails at 220px, file names under the grid, and the keys above. To change
those, pass extra swayimg Lua in `~/.config/yazi/init.lua`. It runs last, so it
wins:

```lua
require("gridview"):setup({
	swayimg = [[
swayimg.gallery.thumb_size = 300
swayimg.fullscreen = true        -- whole screen instead of over the yazi window
]],
})
```

The swayimg Lua API is documented in
[`extra/swayimg.lua`](https://github.com/artemsen/swayimg/blob/master/extra/swayimg.lua).

## How it works

`main.lua` starts `swayimg --gallery` on the current folder, with a short swayimg
script passed on the command line. When you choose an image, swayimg prints its
path and exits. The plugin reads that path and runs yazi's `reveal` on it. Nothing
else is installed, and the `ya` CLI is not involved.

Thumbnails are cached on disk by swayimg, so a folder opens instantly the second
time.

## Limits

- **Wayland only**, because swayimg is.
- **Floating over yazi needs Sway or Hyprland.** swayimg's overlay mode asks the
  compositor where the focused window is. Elsewhere the grid opens as an ordinary
  window.
- **Images only.** Folders and `..` don't appear in the grid, unlike the rofi
  version. Change folders in yazi.

## License

MIT
