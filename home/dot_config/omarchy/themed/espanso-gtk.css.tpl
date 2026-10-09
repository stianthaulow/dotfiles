/* GTK3 theme for espanso's search bar and forms, loaded via GTK_THEME=omarchy-espanso */
@import url("resource:///org/gtk/libgtk/theme/Adwaita/gtk-contained-dark.css");

@define-color theme_bg_color {{ background }};
@define-color theme_fg_color {{ foreground }};
@define-color theme_base_color {{ background }};
@define-color theme_text_color {{ foreground }};
@define-color theme_selected_bg_color {{ accent }};
@define-color theme_selected_fg_color {{ background }};
@define-color borders {{ color8 }};

window, window.background, frame, scrolledwindow, viewport, list, .view {
  background-color: {{ background }};
  color: {{ foreground }};
}

label {
  color: {{ foreground }};
}

entry, textview, textview text {
  background-color: {{ mix background foreground 6% }};
  color: {{ foreground }};
  caret-color: {{ cursor }};
  border-color: {{ color8 }};
  box-shadow: none;
}

entry:focus {
  border-color: {{ accent }};
  box-shadow: inset 0 0 0 1px {{ accent }};
}

selection, entry selection, textview text selection {
  background-color: {{ selection_background }};
  color: {{ selection_foreground }};
}

button {
  background-image: none;
  background-color: {{ mix background foreground 10% }};
  color: {{ foreground }};
  border-color: {{ color8 }};
  box-shadow: none;
}

button:hover {
  background-color: {{ accent }};
  color: {{ background }};
}

checkbutton check:checked, radiobutton radio:checked {
  background-image: none;
  background-color: {{ accent }};
  border-color: {{ accent }};
  color: {{ background }};
}
