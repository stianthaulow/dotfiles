-- Undo the last voxtype dictation (backspaces exactly what it typed). Pairs with F9 dictation.
-- Same setup as on B; the MacroPad's F10 key triggers this too when plugged in.
o.bind("F10", "Undo last dictation", "/home/stian/.local/bin/voxtype-undo")

-- F8 sends Enter (mirrors the MacroPad's Enter key; handy after a dictation).
o.bind("F8", "Send Enter", "wtype -k Return")

-- Macro pad dial (F16/F17/F18, see ~/.config/ch57x/macropad.yaml): turn to step
-- through open workspaces, press to toggle the scratchpad.
-- Bound by keycode: xkb names F16-F18 XF86Launch7-9, so "F16" never matches.
o.bind("code:194", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))  -- F16
o.bind("code:196", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))      -- F18
o.bind("code:195", "Toggle scratchpad", hl.dsp.workspace.toggle_special("scratchpad")) -- F17

-- Macro pad bottom row (F13/F14/F15): type commit, answer yes/no prompts.
o.bind("code:191", "Send commit + Enter", "wtype commit -k Return") -- F13
o.bind("code:192", "Send yes + Enter", "wtype yes -k Return") -- F14
o.bind("code:193", "Send no + Enter", "wtype no -k Return")   -- F15

-- Microsoft 365 PWAs, installed in the work Chromium profile (open or focus; window rules in hyprland.lua send Teams to 7, Outlook to 8).
-- Replaces the default SUPER+SHIFT+E and SUPER+SHIFT+ALT+E (HEY email / new email).
hl.unbind("SUPER + SHIFT + E")
o.bind("SUPER + SHIFT + E", "Outlook", o.launch_sole("chrome-faolnafnngnfdaknnbpnkhgohbobgegn-Profile_1", "chromium --profile-directory=\"Profile 1\" --app-id=faolnafnngnfdaknnbpnkhgohbobgegn"))
hl.unbind("SUPER + SHIFT + ALT + E")
o.bind("SUPER + SHIFT + ALT + E", "New email", "chromium --profile-directory=\"Profile 1\" --app-id=faolnafnngnfdaknnbpnkhgohbobgegn --app-launch-url-for-shortcuts-menu-item=https://outlook.office.com/mail/deeplink/compose")
o.bind("SUPER + SHIFT + T", "Teams", o.launch_sole("chrome-cifhbcnohmdccbgoicgdjpfamggdegmo-Profile_1", "chromium --profile-directory=\"Profile 1\" --app-id=cifhbcnohmdccbgoicgdjpfamggdegmo"))
-- Obsidian: the default binding's "^obsidian$" never matches the md.obsidian.Obsidian class, so it only launches.
hl.unbind("SUPER + SHIFT + O")
o.bind("SUPER + SHIFT + O", "Obsidian", o.launch_sole("md[.]obsidian[.]Obsidian", "obsidian"))
o.bind("SUPER + A", "T3 Code", o.launch_sole("com.t3tools.T3Code", "t3code"))

-- Chromium profiles (open or focus). Replaces the default SUPER+SHIFT+B (Browser).
-- "Default" = personal (gmail), "Profile 1" = work (malling.no).
hl.unbind("SUPER + SHIFT + B")
o.bind("SUPER + SHIFT + B", "Browser (personal)", "/home/stian/.local/bin/chromium-profile Default")
o.bind("SUPER + SHIFT + CTRL + B", "Browser (work)", "/home/stian/.local/bin/chromium-profile 'Profile 1'")

-- Screenshot on SUPER+SHIFT+S (the Keychron K3 has no PrtSc key). Replaces the default Google Maps webapp binding.
hl.unbind("SUPER + SHIFT + S")
o.bind("SUPER + SHIFT + S", "Screenshot", "omarchy-capture-screenshot")
