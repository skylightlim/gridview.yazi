--- gridview.yazi — a thumbnail grid of the current folder, drawn by swayimg.
---
--- Opens swayimg's gallery over the yazi window, starting on the hovered image.
--- Enter or a click jumps yazi to the chosen image; Esc or q closes the grid.
---
---   plugin gridview

-- Runs inside swayimg (LuaJIT) after the user's own swayimg config, so these
-- settings and bindings win. The chosen path comes back on stdout after the
-- "gridview:" marker, which keeps it apart from anything else swayimg prints.
local SCRIPT = [[
swayimg.overlay = true
swayimg.gallery.pstore = true
swayimg.gallery.aspect = "fit"
swayimg.gallery.thumb_size = 220
-- Replaces the gallery's default corners ("File:\t{name}", "{list.index} of {list.total}").
-- Only the corners named here change; the rest keep swayimg's defaults.
swayimg.gallery.text = { topleft = { "{name}" }, topright = { "{list.index}/{list.total}" } }

local function reveal()
  local img = swayimg.gallery.get_image()
  if img then
    io.stdout:write("gridview:", img.path, "\n")
    io.stdout:flush()
  end
  swayimg.exit()
end

swayimg.gallery.on_key("Return", reveal)
swayimg.gallery.on_key("q", function() swayimg.exit() end)
for key, dir in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  swayimg.gallery.on_key(key, function() swayimg.gallery.select(dir) end)
end
swayimg.gallery.on_mouse("MouseLeft", function()
  local pos = swayimg.get_mouse_pos()
  swayimg.gallery.select_at(pos.x, pos.y)
  reveal()
end)
]]

local function notify(content, level)
	ya.notify { title = "Grid view", content = content, level = level or "info", timeout = 5 }
end

local current = ya.sync(function(st)
	local folder = cx.active.current
	return tostring(folder.cwd), folder.hovered and tostring(folder.hovered.url), st.swayimg
end)

return {
	-- `swayimg` is extra swayimg Lua, run last so it can override anything above.
	setup = function(st, opts) st.swayimg = opts and opts.swayimg end,

	entry = function()
		local cwd, hovered, extra = current()
		local script = SCRIPT
		if hovered then
			script = script
				.. string.format("swayimg.on_initialized(function() swayimg.gallery.select_path(%q) end)\n", hovered)
		end
		script = script .. (extra or "")

		local out, err = Command("swayimg"):arg({ "--gallery", "--execute", script, cwd }):output()
		if not out then
			return notify("Could not run swayimg: " .. tostring(err), "error")
		end

		local path = out.stdout:match(".*gridview:([^\n]+)")
		if path then
			ya.emit("reveal", { Url(path) })
		elseif out.stderr:find("Image list is empty", 1, true) then
			notify("No images in this folder")
		elseif not out.status.success then
			local msg = out.stderr:gsub("%s+$", "")
			notify(msg ~= "" and msg or "swayimg exited with an error", "error")
		end
	end,
}
