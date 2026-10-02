-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })

-- Bind workspaces to monitors (lists come from .chezmoidata/workspaces.toml).
-- The first workspace on each monitor is the one it shows by default.
local pins = {
{{- range $output, $list := .pins }}
  [{{ $output | quote }}] = {{ includeTemplate "hypr/lua-list" $list }},
{{- end }}
}
for output, workspaces in pairs(pins) do
  for i, ws in ipairs(workspaces) do
    hl.workspace_rule({ workspace = ws, monitor = output, default = (i == 1) })
  end
end
