# Custom Base16 Themes

This directory contains custom Base16 theme definitions for use with Stylix.

## Usage

To use a custom theme from this directory, update the `base16Theme` variable in `flake.nix`:

```nix
base16Theme = ./themes/custom-gruvbox-example.yaml;
```

Then rebuild your system:

```bash
# For NixOS system changes
sudo nixos-rebuild switch --flake .#<host>-nixos

# For home-manager changes
nix run home-manager/master -- switch --flake .#fortydeux@<host>-nixos
```

## Creating Custom Themes

Base16 themes are YAML files with 16 color definitions (base00-base0F). Each color is defined as a 6-character hex code (without the `#` prefix).

### Color Roles

- **base00**: Default Background
- **base01**: Lighter Background (status bars, line numbers)
- **base02**: Selection Background
- **base03**: Comments, Invisibles, Line Highlighting
- **base04**: Dark Foreground (status bars)
- **base05**: Default Foreground, Caret, Delimiters, Operators
- **base06**: Light Foreground (rarely used)
- **base07**: Light Background (rarely used)
- **base08**: Variables, XML Tags, Markup Link Text, Diff Deleted (Red)
- **base09**: Integers, Boolean, Constants, Markup Link Url (Orange)
- **base0A**: Classes, Markup Bold, Search Text Background (Yellow)
- **base0B**: Strings, Markup Code, Diff Inserted (Green)
- **base0C**: Support, Regular Expressions, Escape Characters (Cyan)
- **base0D**: Functions, Methods, Attribute IDs, Headings (Blue)
- **base0E**: Keywords, Storage, Markup Italic, Diff Changed (Purple)
- **base0F**: Deprecated, Embedded Language Tags (Brown)

### Template

```yaml
scheme: "Your Theme Name"
author: "Your Name"
base00: "282828"
base01: "3c3836"
base02: "504945"
base03: "665c54"
base04: "bdae93"
base05: "d5c4a1"
base06: "ebdbb2"
base07: "fbf1c7"
base08: "fb4934"
base09: "fe8019"
base0A: "fabd2f"
base0B: "b8bb26"
base0C: "8ec07c"
base0D: "83a598"
base0E: "d3869b"
base0F: "d65d0e"
```

## Resources

- [Base16 Gallery](https://tinted-theming.github.io/tinted-gallery/) - Browse existing themes for inspiration
- [Base16 Styling Guidelines](https://github.com/chriskempson/base16/blob/main/styling.md) - Official color usage guidelines
- [Stylix Documentation](https://github.com/danth/stylix) - Theme application details
