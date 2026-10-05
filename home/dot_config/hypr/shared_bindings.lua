-- Bindings shared by every host (managed by chezmoi). Per-host bindings live in
-- hypr/bindings.lua (.chezmoitemplates/hypr/bindings/<hostname>.lua).

-- Dictation toggle, alongside Omarchy's F9 push-to-talk. A toggle, not push-to-talk:
-- with kanata home row mods, holding D turns it into Super, so D can't be held as the trigger.
if o.cmd_present("voxtype") then
  o.bind("SUPER + D", "Toggle dictation", "voxtype record toggle")
end

-- Home row mods cheat sheet (toggle).
if o.cmd_present("kanata") then
  o.bind("SUPER + H", "Home row mods cheat sheet", "hrm-cheatsheet")
end
