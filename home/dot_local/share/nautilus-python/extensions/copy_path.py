import shutil

from gi import require_version

require_version("Nautilus", "4.1")

from gi.repository import GObject, Gio, Nautilus


class CopyPathAction(GObject.GObject, Nautilus.MenuProvider):
    def _copy(self, text):
        wl_copy = shutil.which("wl-copy")
        if not wl_copy:
            return

        process = Gio.Subprocess.new(
            [wl_copy, "--", text],
            Gio.SubprocessFlags.STDOUT_SILENCE | Gio.SubprocessFlags.STDERR_SILENCE,
        )
        process.wait_async(None, None, None)

    def _selected_paths(self, files):
        paths = []

        for file in files:
            location = file.get_location()
            if not location:
                continue

            path = location.get_path()
            if path and path not in paths:
                paths.append(path)

        return paths

    def _make_item(self, name, paths):
        label = "Copy Path" if len(paths) == 1 else "Copy Paths"
        item = Nautilus.MenuItem(
            name=f"CopyPathNautilus::{name}",
            label=label,
            icon="edit-copy",
        )
        item.connect("activate", self._on_activate, paths)
        return item

    def _on_activate(self, _menu, paths):
        self._copy("\n".join(paths))

    def get_file_items(self, *args):
        files = args[0] if len(args) == 1 else args[1]
        paths = self._selected_paths(files)

        if not paths:
            return []

        return [self._make_item("copy_path", paths)]

    def get_background_items(self, *args):
        folder = args[0] if len(args) == 1 else args[1]
        paths = self._selected_paths([folder])

        if not paths:
            return []

        return [self._make_item("copy_folder_path", paths)]
