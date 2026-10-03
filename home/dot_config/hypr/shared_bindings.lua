-- Bindings shared by every host (managed by chezmoi). Per-host bindings stay in
-- the untracked hypr/bindings.lua.

-- Dictation toggle, alongside Omarchy's F9 push-to-talk. A toggle, not push-to-talk:
-- with kanata home row mods, holding D turns it into Super, so D can't be held as the trigger.
if o.cmd_present("voxtype") then
  o.bind("SUPER + D", "Toggle dictation", "voxtype record toggle")
end
