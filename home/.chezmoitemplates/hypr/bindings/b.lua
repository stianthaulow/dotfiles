-- Undo the last voxtype dictation (backspaces exactly what it typed). Pairs with F9 dictation.
o.bind("F10", "Undo last dictation", "/home/stian/.local/bin/voxtype-undo")

-- MX Master 3S gesture (thumb) button -> toggle fullscreen. Button emits BTN_FORWARD (mouse:277).
o.bind("mouse:277", "Toggle fullscreen (MX gesture button)", hl.dsp.window.fullscreen({ mode = "fullscreen" }), { mouse = true })

-- T3 Code: launch or focus.
o.bind("SUPER + A", "T3 Code", 'omarchy-launch-or-focus T3Code "uwsm-app -- t3code"')
-- ChatGPT: the default binding only launches; its title-based focus misses since the title becomes the chat name, so match the class.
hl.unbind("SUPER + SHIFT + A")
o.bind("SUPER + SHIFT + A", "ChatGPT", o.launch_sole("chrome-chatgpt[.]com__-Default", "omarchy-launch-webapp https://chatgpt.com"))

-- Gmail (personal "Profile 1") instead of HEY for email: launch or focus, and compose in its own window.
hl.unbind("SUPER + SHIFT + E")
o.bind("SUPER + SHIFT + E", "Gmail", o.launch_sole("chrome-mail.google.com__-Profile_1", "chromium --profile-directory=\"Profile 1\" --app=https://mail.google.com/"))
hl.unbind("SUPER + SHIFT + ALT + E")
o.bind("SUPER + SHIFT + ALT + E", "New email", "chromium --profile-directory=\"Profile 1\" --app=\"https://mail.google.com/mail/?view=cm&fs=1\"")

-- Teams PWA: launch or focus (class matches the workspace 8 rule).
o.bind("SUPER + SHIFT + T", "Teams", 'omarchy-launch-or-focus chrome-cifhbcnohmdccbgoicgdjpfamggdegmo-Default "uwsm-app -- chromium --profile-directory=Default --app-id=cifhbcnohmdccbgoicgdjpfamggdegmo"')

-- Chromium profiles: launch or focus. Private = "Profile 1" (Stian), Work = "Default" (Malling).
hl.unbind("SUPER + SHIFT + B")
o.bind("SUPER + SHIFT + B", "Browser (Stian)", '/home/stian/.local/bin/chromium-profile-focus "Profile 1" private')
o.bind("SUPER + SHIFT + CTRL + B", "Browser (Work)", '/home/stian/.local/bin/chromium-profile-focus "Default" work')

-- Obsidian: launch or focus. Default pattern "^obsidian$" never matches the real class (md.obsidian.Obsidian).
hl.unbind("SUPER + SHIFT + O")
o.bind("SUPER + SHIFT + O", "Obsidian", 'omarchy-launch-or-focus md.obsidian.Obsidian "uwsm-app -- obsidian"')
