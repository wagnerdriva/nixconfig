{ ... }:
let
  syntax = color: {
    inherit color;
    font_style = null;
    font_weight = null;
  };
in {
  home.file.".config/zed/settings.json" = {
    force = true;
    text = builtins.toJSON {
      theme = "Broken Pine Theme";
      icon_theme = "Zed (Default)";
      buffer_font_family = "JetBrainsMono Nerd Font";
      ui_font_family = "Inter";
      feature_flags = {
        notebooks = "on";
        "tabular-data-preview" = "on";
      };
    };
  };

  home.file.".config/zed/themes/broken-pine.json" = {
    force = true;
    text = builtins.toJSON {
      name = "Broken Pine";
      author = "Etienne Lacoursiere";
      themes = [
        {
          name = "Broken Pine Theme";
          appearance = "dark";
          style = {
          border = "#423f55ff";
          "border.variant" = "#232132ff";
          "border.focused" = "#435255ff";
          "border.selected" = "#435255ff";
          "border.transparent" = "#00000000";
          "border.disabled" = "#353347ff";
          "elevated_surface.background" = "#17181a";
          "surface.background" = "#17181a";
          background = "#111215";
          "element.background" = "#17181a";
          "element.hover" = "#232132ff";
          "element.active" = "#403e53ff";
          "element.selected" = "#403e53ff";
          "element.disabled" = "#17181a";
          "drop_target.background" = "#74708d80";
          "ghost_element.background" = "#00000000";
          "ghost_element.hover" = "#232132ff";
          "ghost_element.active" = "#403e53ff";
          "ghost_element.selected" = "#403e53ff";
          "ghost_element.disabled" = "#17181a";
          text = "#D7D7FF";
          "text.muted" = "#8787AF";
          "text.placeholder" = "#2f2b43ff";
          "text.disabled" = "#6e6a86ff";
          "text.accent" = "#9bced6ff";
          icon = "#e0def4ff";
          "icon.muted" = "#74708dff";
          "icon.disabled" = "#2f2b43ff";
          "icon.placeholder" = "#74708dff";
          "icon.accent" = "#9bced6ff";
          "status_bar.background" = "#111215";
          "title_bar.background" = "#111215";
          "toolbar.background" = "#111215";
          "tab_bar.background" = "#111215";
          "tab.inactive_background" = "#111215";
          "tab.active_background" = "#111215";
          "search.match_background" = "#57949f66";
          "panel.background" = "#111215";
          "panel.focused_border" = null;
          "pane.focused_border" = null;
          "scrollbar.thumb.background" = "#e0def44c";
          "scrollbar.thumb.hover_background" = "#232132ff";
          "scrollbar.thumb.border" = "#232132ff";
          "scrollbar.track.background" = "#00000000";
          "scrollbar.track.border" = "#1b1a29ff";
          "editor.foreground" = "#D7D7FF";
          "editor.background" = "#111215";
          "editor.gutter.background" = "#111215";
          "editor.subheader.background" = "#17181a";
          "editor.active_line.background" = "#17181a";
          "editor.highlighted_line.background" = "#17181a";
          "editor.line_number" = "#8787AF";
          "editor.active_line_number" = "#e0def4ff";
          "editor.invisible" = "#28253cff";
          "editor.wrap_guide" = "#e0def40d";
          "editor.active_wrap_guide" = "#e0def41a";
          "editor.document_highlight.read_background" = "#9bced61a";
          "editor.document_highlight.write_background" = "#28253c66";
          "terminal.background" = "#111215";
          "terminal.foreground" = "#e0def4ff";
          "terminal.bright_foreground" = "#e0def4ff";
          "terminal.dim_foreground" = "#111215";
          "terminal.ansi.black" = "#111215";
          "terminal.ansi.bright_black" = "#403d55ff";
          "terminal.ansi.dim_black" = "#e0def4ff";
          "terminal.ansi.red" = "#ea6e92ff";
          "terminal.ansi.bright_red" = "#7e3647ff";
          "terminal.ansi.dim_red" = "#fab9c6ff";
          "terminal.ansi.green" = "#5cc1a3ff";
          "terminal.ansi.bright_green" = "#31614fff";
          "terminal.ansi.dim_green" = "#b3e1d1ff";
          "terminal.ansi.yellow" = "#f5c177ff";
          "terminal.ansi.bright_yellow" = "#8a643aff";
          "terminal.ansi.dim_yellow" = "#fedfbbff";
          "terminal.ansi.blue" = "#9bced6ff";
          "terminal.ansi.bright_blue" = "#566b70ff";
          "terminal.ansi.dim_blue" = "#cfe7ebff";
          "terminal.ansi.magenta" = "#9d7591ff";
          "terminal.ansi.bright_magenta" = "#4c3b47ff";
          "terminal.ansi.dim_magenta" = "#ceb9c7ff";
          "terminal.ansi.cyan" = "#31738fff";
          "terminal.ansi.bright_cyan" = "#203a46ff";
          "terminal.ansi.dim_cyan" = "#9cb7c6ff";
          "terminal.ansi.white" = "#e0def4ff";
          "terminal.ansi.bright_white" = "#e0def4ff";
          "terminal.ansi.dim_white" = "#514e68ff";
          "link_text.hover" = "#9bced6ff";
          conflict = "#f5c177ff";
          "conflict.background" = "#50331aff";
          "conflict.border" = "#6d4d2bff";
          created = "#5cc1a3ff";
          "created.background" = "#182d23ff";
          "created.border" = "#254839ff";
          deleted = "#ea6e92ff";
          "deleted.background" = "#431720ff";
          "deleted.border" = "#612834ff";
          error = "#ea6e92ff";
          "error.background" = "#431720ff";
          "error.border" = "#612834ff";
          hidden = "#2f2b43ff";
          "hidden.background" = "#292738ff";
          "hidden.border" = "#353347ff";
          hint = "#5e768cff";
          "hint.background" = "#2f3639ff";
          "hint.border" = "#435255ff";
          ignored = "#74708dff";
          "ignored.background" = "#292738ff";
          "ignored.border" = "#423f55ff";
          info = "#9bced6ff";
          "info.background" = "#2f3639ff";
          "info.border" = "#435255ff";
          modified = "#FFAF87";
          "modified.background" = "#50331aff";
          "modified.border" = "#6d4d2bff";
          predictive = "#556b81ff";
          "predictive.background" = "#182d23ff";
          "predictive.border" = "#254839ff";
          renamed = "#9bced6ff";
          "renamed.background" = "#2f3639ff";
          "renamed.border" = "#435255ff";
          success = "#5cc1a3ff";
          "success.background" = "#182d23ff";
          "success.border" = "#254839ff";
          unreachable = "#74708dff";
          "unreachable.background" = "#292738ff";
          "unreachable.border" = "#423f55ff";
          warning = "#f5c177ff";
          "warning.background" = "#50331aff";
          "warning.border" = "#6d4d2bff";
          players = [
            { cursor = "#9bced6ff"; background = "#9bced6ff"; selection = "#9bced63d"; }
            { cursor = "#9d7591ff"; background = "#9d7591ff"; selection = "#9d75913d"; }
            { cursor = "#c4a7e6ff"; background = "#c4a7e6ff"; selection = "#c4a7e63d"; }
            { cursor = "#31738fff"; background = "#31738fff"; selection = "#31738f3d"; }
            { cursor = "#ea6e92ff"; background = "#ea6e92ff"; selection = "#ea6e923d"; }
            { cursor = "#f5c177ff"; background = "#f5c177ff"; selection = "#f5c1773d"; }
            { cursor = "#5cc1a3ff"; background = "#5cc1a3ff"; selection = "#5cc1a33d"; }
          ];
          syntax = {
            attribute = syntax "#D7AFD7";
            boolean = syntax "#FFAFAF";
            comment = syntax "#6e6a86ff";
            "comment.doc" = syntax "#76728fff";
            constant = syntax "#FFAF87";
            constructor = syntax "#FFAF87";
            embedded = syntax "#D7D7FF";
            emphasis = syntax "#ea6e92";
            "emphasis.strong" = (syntax "#ea6e92") // { font_weight = 700; };
            enum = syntax "#FFAF87";
            function = syntax "#FFAFAF";
            hint = (syntax "#5e768cff") // { font_weight = 700; };
            keyword = syntax "#5F8787";
            label = syntax "#ea6e92";
            link_text = (syntax "#9bced6ff") // { font_style = "italic"; };
            link_uri = syntax "#9bced6ff";
            number = syntax "#FFAF87";
            operator = syntax "#8787AF";
            predictive = (syntax "#556b81ff") // { font_style = "italic"; };
            preproc = syntax "#5F8787";
            primary = syntax "#D7D7FF";
            property = (syntax "#AFD7D7") // { font_style = "italic"; };
            punctuation = syntax "#8787AF";
            "punctuation.bracket" = syntax "#8787AF";
            "punctuation.delimiter" = syntax "#8787AF";
            "punctuation.list_marker" = syntax "#ea6e92";
            "punctuation.special" = syntax "#D7D7FF";
            string = syntax "#FFAF87";
            "string.escape" = syntax "#5F8787";
            "string.regex" = syntax "#ea6e92";
            "string.special" = syntax "#FFAF87";
            "string.special.symbol" = syntax "#D7D7FF";
            tag = syntax "#AFD7D7";
            "text.literal" = syntax "#FFAF87";
            title = (syntax "#D7D7FF") // { font_weight = 700; };
            type = syntax "#AFD7D7";
            variable = syntax "#D7D7FF";
            variant = syntax "#FFAF87";
          };
          };
        }
      ];
    };
  };
}
