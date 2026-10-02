import os

from gi import require_version

require_version("Gtk", "4.0")
require_version("Nautilus", "4.1")

from gi.repository import GLib, GObject, Gio, Gtk, Nautilus

# Nautilus gives non-XDG bookmarks a hardcoded folder-symbolic. Swap it for
# folder-<name>-symbolic (e.g. ~/Work -> folder-work-symbolic) when the icon theme has one.
# Rows are rebuilt on every sidebar refresh and re-synced from their bookmark, so watch both.


def themed_icon(row):
    uri = row.get_property("uri")
    if not uri or not uri.startswith("file://"):
        return None
    path = Gio.File.new_for_uri(uri).get_path()
    if not path or os.path.dirname(path) != GLib.get_home_dir():
        return None
    name = f"folder-{os.path.basename(path).lower()}-symbolic"
    theme = Gtk.IconTheme.get_for_display(row.get_display())
    return Gio.ThemedIcon.new(name) if theme.has_icon(name) else None


def fix_row(row, *_):
    icon = row.get_property("start-icon")
    if not isinstance(icon, Gio.ThemedIcon) or "folder-symbolic" not in icon.get_names():
        return
    new = themed_icon(row)
    if new:
        row.set_property("start-icon", new)


def watch_row(row):
    if getattr(row, "_sidebar_icons", False):
        return
    row._sidebar_icons = True
    row.connect("notify::start-icon", fix_row)
    fix_row(row)


def watch_list(listbox):
    children = listbox.observe_children()

    def changed(model, *_):
        for i in range(model.get_n_items()):
            child = model.get_item(i)
            if GObject.type_name(child) == "NautilusSidebarRow":
                watch_row(child)

    children.connect("items-changed", changed)
    changed(children)
    listbox._sidebar_icons_model = children


def find_sidebars(widget):
    if GObject.type_name(widget) == "NautilusSidebar":
        yield widget
        return
    child = widget.get_first_child()
    while child:
        yield from find_sidebars(child)
        child = child.get_next_sibling()


def find_listbox(widget):
    if isinstance(widget, Gtk.ListBox):
        return widget
    child = widget.get_first_child()
    while child:
        found = find_listbox(child)
        if found:
            return found
        child = child.get_next_sibling()
    return None


def scan_windows(*_):
    toplevels = Gtk.Window.get_toplevels()
    for i in range(toplevels.get_n_items()):
        for sidebar in find_sidebars(toplevels.get_item(i)):
            listbox = find_listbox(sidebar)
            if listbox and not hasattr(listbox, "_sidebar_icons_model"):
                watch_list(listbox)
    return GLib.SOURCE_REMOVE


class SidebarIcons(GObject.GObject, Nautilus.MenuProvider):
    def __init__(self):
        super().__init__()
        self._toplevels = Gtk.Window.get_toplevels()
        # Sidebars are built after the window is added, so scan once idle
        self._toplevels.connect("items-changed", lambda *_: GLib.idle_add(scan_windows))
        GLib.idle_add(scan_windows)
