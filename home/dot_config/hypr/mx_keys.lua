-- Logitech MX Keys for Mac bindings (b only). The keys are remapped per device in
-- /etc/udev/hwdb.d/90-mx-keys-mac.hwdb (chezmoi: .chezmoitemplates/mx-keys-mac.hwdb),
-- so these keysyms only come from that keyboard.

-- Calculator key: launch or focus omacalc instead of opening a new one each press.
hl.unbind("XF86Calculator")
o.bind("XF86Calculator", "Calculator", 'omarchy-launch-or-focus "^omacalc$" "uwsm-app -- omacalc"')

-- F19, remapped to Screen Lock.
o.bind("XF86ScreenSaver", "Lock system", "omarchy-system-lock")
