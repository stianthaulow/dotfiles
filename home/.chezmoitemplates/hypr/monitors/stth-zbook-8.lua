-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 2
local omarchy_monitor_scale = "auto"

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })
-- Laptop panel a bit smaller than 2x (2560x1600 / 1.6 = 1600x1000).
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x440", scale = 1.6 })
-- Desk ultrawide sits right of the laptop with bottom edges aligned (1440 - 1000 = 440).
hl.monitor({ output = "desc:Samsung Electric Company LS34A650U H4ZT200409", mode = "preferred", position = "1600x0", scale = 1 })

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })

-- While the laptop panel plus exactly one external ultrawide (aspect >= 2.2,
-- e.g. 3440x1440) are active, pin the laptop workspaces to the laptop panel
-- and the ultrawide ones to the ultrawide. Any other setup leaves them unpinned.
-- The workspace lists come from .chezmoidata/workspaces.toml.
local laptop = "eDP-1"
local laptop_workspaces = {{ includeTemplate "hypr/lua-list" .pins.laptop }}
local ultrawide_workspaces = {{ includeTemplate "hypr/lua-list" .pins.ultrawide }}

local laptop_rules = {}
for _, ws in ipairs(laptop_workspaces) do
  laptop_rules[ws] = hl.workspace_rule({ workspace = ws, monitor = laptop, enabled = false })
end
-- The ultrawide's output name depends on the port, so its rules are created per
-- output on first use: ultrawide_rules[output][ws].
local ultrawide_rules = {}

local function docked_ultrawide(ignore)
  local has_laptop, externals = false, {}
  -- Numeric loop, not ipairs: omarchy-menu-keybindings runs this config with a
  -- stub hl whose catch-all tables would make ipairs spin forever.
  local monitors = hl.get_monitors() or {}
  for i = 1, #monitors do
    local m = monitors[i]
    if m.name ~= ignore and not m.is_mirror then
      if m.name == laptop then
        has_laptop = true
      else
        table.insert(externals, m)
      end
    end
  end
  if has_laptop and #externals == 1 and externals[1].width / externals[1].height >= 2.2 then
    return externals[1].name
  end
end

-- Rules only affect new workspaces, so move ones that already exist.
local function move_if_elsewhere(ws, output)
  local w = hl.get_workspace(ws)
  if w and w.monitor and w.monitor.name ~= output then
    hl.dispatch(hl.dsp.workspace.move({ workspace = ws, monitor = output }))
  end
end

local function apply_pins(ignore)
  local ultrawide = docked_ultrawide(ignore)

  for ws, rule in pairs(laptop_rules) do
    rule:set_enabled(ultrawide ~= nil)
    if ultrawide then move_if_elsewhere(ws, laptop) end
  end

  for _, rules in pairs(ultrawide_rules) do
    for _, rule in pairs(rules) do rule:set_enabled(false) end
  end
  if ultrawide then
    ultrawide_rules[ultrawide] = ultrawide_rules[ultrawide] or {}
    for _, ws in ipairs(ultrawide_workspaces) do
      local rule = ultrawide_rules[ultrawide][ws]
      if rule then
        rule:set_enabled(true)
      else
        ultrawide_rules[ultrawide][ws] = hl.workspace_rule({ workspace = ws, monitor = ultrawide })
      end
      move_if_elsewhere(ws, ultrawide)
    end
  end
end

apply_pins()
hl.on("monitor.added", function() apply_pins() end)
-- The removed monitor may still be listed while this fires, so skip it explicitly.
hl.on("monitor.removed", function(m) apply_pins(m.name) end)
