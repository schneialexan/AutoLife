# Changelog

## 0.1.0

Initial AutoLife design system package.

- Design tokens (`AutoLifeColors`, `AutoLifeSpacing`, `AutoLifeTypography`, `AutoLifeRadii`, `AutoLifeShadows`) and `AutoLifeTokens` `ThemeExtension`.
- Light/dark `AutoLifeTheme` factories with Material 3 surfaces.
- `MemberPalette` for deterministic family-member accents.
- Shared widgets: buttons, surface card, app bar, bottom-nav shell, omnibar (`AutoOmnibar`), member avatar/badge, empty state, skeleton.
- Widgetbook gallery under `example/` (`melos run gallery`).
- Widget tests; golden snapshots tagged `golden` (run `flutter test --tags golden`, ideally on Linux CI).

### Token hygiene check

Design tokens should live only under `lib/src/tokens/` (colors) or named token classes. To spot stray hex colors in widgets:

```bash
rg "Color\(0x" packages/autolife-ui/lib/src/widgets
```

This should return no matches.
