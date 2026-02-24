# Theme System Refactor Design Doc

Date: 2026-02-19
Project: Wittle Widgets
Status: Active (Refactor in progress)

## 1. Purpose
Define the target architecture for the theme overhaul with three non-negotiables:
1. Runtime reads are always a single direct key lookup.
2. Themes are composable (base + overlays).
3. The built runtime theme is fully flat.

## 2. Core Goals
1. Component fetch is one direct `struct_get` from built theme.
2. Themes merge cleanly (`default + rounded + light/dark` etc.).
3. Live reload updates all non-user-overridden values.
4. Authoring moves toward a CSS-like workflow.
5. Determin/derivation can expand sparse inputs into full state sets.

## 3. Current Refactor Snapshot
Core scripts:
- `scripts/wwThemeDefault/wwThemeDefault.gml`
- `scripts/wwThemeLight/wwThemeLight.gml`
- `scripts/wwThemeDark/wwThemeDark.gml`
- `scripts/wwThemeMerge/wwThemeMerge.gml`
- `scripts/wwThemeBuild/wwThemeBuild.gml`
- `scripts/wwThemeSet/wwThemeSet.gml`
- `scripts/wwThemeGet/wwThemeGet.gml`

Implemented foundation:
- Compile/build pipeline exists.
- Flat runtime struct exists (`global.ww_theme_flat`).
- Merge presets/layers exist.
- Reload path exists.

Important note:
- Existing runtime code is transitional and not yet fully aligned with this final keyspace contract.

## 4. Authoritative Runtime Model
1. Built theme is a single flat struct map.
2. No nested theme structs in runtime fetch paths.
3. Components use key descriptors, not switch routing.
4. Fallbacks are explicit typed keys under `fallback.*`.

## 5. Keyspace Contract (v1)

### 5.1 Canonical Key Shape
`<component>.<type>.<piece>.<specifier>`

Examples:
- `button.sprite.main.hover`
- `button.color.main.hover`
- `button.alpha.main.hover`
- `checkbox.color.check.checked`
- `slider.sprite.track.normal`
- `text_input.color.caret.focused`

Global fallback keys:
- `fallback.sprite`
- `fallback.color`
- `fallback.alpha`
- `fallback.font`
- `fallback.icon`

### 5.2 Segment Meaning
1. `component`
- Component domain (`button`, `checkbox`, `slider`, `dropdown`, `text_input`, `text_renderer`, etc.)

2. `type`
- Value class (`sprite`, `color`, `alpha`, `font`, `icon`, `size`, `bool`, `number`, `string`)

3. `piece`
- Sub-part being styled (`main`, `text`, `track`, `thumb`, `fill`, `check`, `caret`, `selection`, `underline`, etc.)

4. `specifier`
- State or variant (`normal`, `hover`, `active`, `focused`, `disabled`, `checked`, `unchecked`, `warning`, `error`, etc.)

## 6. Resolution Contract (v1)
Given a requested key:
1. Use explicit user-set value if present.
2. Else fetch exact theme key.
3. Else use typed fallback `fallback.<type>`.
4. Optionally log missing key in debug mode.

This is the default behavior target for sprites, colors, alpha, icons, and fonts.

### 6.1 Fallback Guarantees (Required)
The build output must always contain these keys:
- `fallback.sprite`
- `fallback.color`
- `fallback.alpha`
- `fallback.icon`
- `fallback.font`

Build contract:
1. If any required fallback key is missing in source layers, builder injects a safe default.
2. Builder emits a warning for each injected fallback key.
3. In strict mode, missing required fallback keys are build errors instead of warnings.

Runtime contract:
1. `wwThemeGet<Type>(...)` with no arguments returns `fallback.<type>`.
2. `wwThemeGet<Type>(...)` with unresolved arguments returns `fallback.<type>`.
3. Fallback keys are never optional at runtime.

Emergency defaults (builder-owned):
- `fallback.sprite`: obvious missing-debug sprite
- `fallback.color`: obvious missing-debug color (high contrast)
- `fallback.alpha`: `1`
- `fallback.icon`: obvious missing-debug icon token
- `fallback.font`: default UI font asset

## 7. Runtime Schema Example (Component-First)
```json
{
  "fallback.sprite": "spr_ww_missing_sprite",
  "fallback.color": 16711935,
  "fallback.alpha": 1,

  "button.sprite.main.normal": "spr_ww_rr9_r4_all",
  "button.sprite.main.hover": "spr_ww_rr9_r4_all",
  "button.sprite.main.active": "spr_ww_rr9_r4_all",
  "button.sprite.main.disabled": "spr_ww_rr9_r4_all",
  "button.color.main.normal": 2434341,
  "button.alpha.main.normal": 1,
  "button.color.main.hover": 2960685,
  "button.alpha.main.hover": 1,
  "button.color.main.active": 2105376,
  "button.alpha.main.active": 1,
  "button.color.text.normal": 16777215,
  "button.alpha.text.normal": 1,

  "checkbox.sprite.main.normal": "spr_ww_checkbox",
  "checkbox.sprite.check.checked": "spr_ww_checkbox_check",
  "checkbox.sprite.check.unchecked": "spr_ww_checkbox_uncheck",
  "checkbox.color.check.checked": 16777215,
  "checkbox.alpha.check.checked": 1,

  "slider.sprite.track.normal": "spr_ww_slider_background",
  "slider.sprite.fill.normal": "spr_ww_slider_bar",
  "slider.sprite.thumb.normal": "spr_ww_slider_thumb",
  "slider.color.fill.normal": 4491519,
  "slider.alpha.fill.normal": 1,

  "text_input.color.text.normal": 14540253,
  "text_input.alpha.text.normal": 1,
  "text_input.color.caret.focused": 16777215,
  "text_input.color.selection.focused": 6840536,

  "text_renderer.sprite.underline.warning": "spr_ww_underline_warning",
  "text_renderer.sprite.underline.error": "spr_ww_underline_error",
  "text_renderer.size.underline.normal": 1,
  "text_renderer.color.text.warning": 16766720,
  "text_renderer.alpha.text.warning": 1,
  "text_renderer.font.main.normal": "fnt_ww_default_small_msdf"
}
```

## 8. Component Descriptor Pattern
Target component-level descriptors:
```gml
__theme_keys__ = {
  spr_main_normal: "button.sprite.main.normal",
  spr_main_hover: "button.sprite.main.hover",
  col_main_normal: "button.color.main.normal",
  alp_main_normal: "button.alpha.main.normal",
  col_text_normal: "button.color.text.normal",
  alp_text_normal: "button.alpha.text.normal"
};
```

Direct runtime fetch:
```gml
var _spr = variable_struct_get(global.ww_theme_flat, __theme_keys__.spr_main_normal);
```

No switch routing is needed when key descriptors are complete.

## 9. Build Pipeline (Current + Target)
Current build phases in `wwThemeBuild`:
1. Compose layers
2. Clone/normalize
3. Derive missing colors
4. Resolve references
5. Compile lookup map
6. Optional strict validation

Target enhancement:
1. Compile all component/type/piece/specifier keys.
2. Expand sparse declarations into full state keys (determin).
3. Emit warnings/errors for unknown keys or invalid types.
4. Guarantee required `fallback.<type>` keys exist.
5. Inject emergency fallback defaults when absent.

## 10. CSS-Style Authoring Direction
Proposed style:
- Component blocks
- Shorthand with deterministic expansion
- Optional per-state overrides

Conceptual examples:
```css
button.sprite.main: spr_ww_rr9_r4_all;
button.color.main: #252A32;
button.color.main.hover: #2D3340;
button.color.text: #FFFFFF;

checkbox.sprite.check.checked: spr_ww_checkbox_check;
checkbox.sprite.check.unchecked: spr_ww_checkbox_uncheck;

text_input.color.caret.focused: #FFFFFF;
text_renderer.color.text.warning: #FFD166;
```

## 11. Constraints
1. Runtime reads should be one direct key lookup in hot paths.
2. User explicit values always win.
3. Reload must not wipe explicit overrides.
4. Fallback visuals must be intentionally obvious.
5. Key naming must stay canonical with no parallel schemas.

## 12. Decisions Locked
These items are resolved and no longer considered open concerns:
1. Runtime theme is fully flat and fetched by direct key.
2. Canonical key format is `<component>.<type>.<piece>.<specifier>`.
3. Fallbacks are typed global keys under `fallback.*`.
4. Runtime resolution order is explicit value -> exact key -> `fallback.<type>`.
5. Typed getters are vararg fallback-order APIs (`wwThemeGetColor/Sprite/Icon/Alpha`).
6. Required fallback keys are build-enforced (inject + warn, strict-mode error).
7. Component-owned key descriptors replace switch-based theme routing.

## 13. Remaining Design Gaps
1. Required-vs-derivable key matrix per component.
2. Non-fallback validator policy:
- unknown key behavior
- type mismatch behavior
- strict vs non-strict error thresholds
3. CSS-like DSL grammar and compile rules.
4. Old-key migration mapping and deprecation policy.

## 14. Acceptance Criteria
1. All component theme reads use canonical flat keys.
2. All visual datatypes have valid `fallback.<type>` keys.
3. Builder enforces required fallback keys (inject + warn, or fail in strict mode).
4. No switch-based theme-kind fetch logic remains.
5. Determin can derive complete state maps from sparse author inputs.
6. Exported built theme is easy to inspect in text editor.

## 15. Practical Notes
1. Refactor is ongoing; implementation and design are intentionally moving in phases.
2. Existing code may temporarily diverge from this target while migration completes.
3. This document is the source-of-truth for target architecture.
