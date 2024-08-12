local wezterm = require 'wezterm'
local config = {}

config.default_prog = { 'pwsh.exe', '-NoLogo' }

config.color_scheme = 'Vs Code Dark+ (Gogh)'
config.font = wezterm.font({ family = 'JetBrainsMono Nerd Font Mono' })
config.window_decorations = 'RESIZE'

return config