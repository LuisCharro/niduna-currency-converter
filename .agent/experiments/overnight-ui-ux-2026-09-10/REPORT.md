# REPORT — Experimento UI/UX nocturno (2026-09-10)

- **Rama:** `codex/experiment-ui-ux-20260910`
- **Worktree:** `/Users/luis/Niduna-worktrees/currency-converter-ui-ux-20260910`
- **Commit base:** `a4c7489` — sin commits nuevos en la rama (diff sin commit,
  según plan)
- **Diff de UI/tests:** `.tmp/experiments/overnight-ui-ux-2026-09-10/ui-changes.diff`
  (8 ficheros en `lib/` + 1 test nuevo; los Markdown de contexto quedan fuera)
- **Estado de `check.sh`:** ✅ 248 tests pasando + analyze limpio (247 previos
  + `amount_editing_field_scale_test.dart` nuevo)
- **Fuera de alcance, intacto:** billing, ads, UMP, providers, controllers de
  datos, dependencias, versionado, textos localizados (se añadió solo una
  clave l10n ya existente… no: no se añadió ninguna), assets, tokens globales.

## Cómo se verificó

- Emulador desechable `exp_night_36` (nuevo, Pixel 5, API 36), GPU
  swiftshader para que rendericen las banderas. `wm size/density` alterno:
  **small = 720×1280 @ 320dpi → 360×640 dp**; **standard = 1080×2340 @ 420**
  (reset). Escalas de fuente 1.0 / 1.3 / 2.0 (system font_scale). Temas vía
  `cmd uimode` + toggle interno de Settings (nota: tras un fresh install la
  app arranca en claro aunque `night yes` esté activo antes del primer
  arranque; ver Limitaciones).
- APK debug con `PROVIDER_PROFILE=release_safe`, `APP_DEV_MODE=false`,
  `ADMOB_USE_TEST_ADS=true` (anuncios de test visibles = usuario gratuito).
- Matriz completa: baseline 48 capturas + after 48 capturas
  (`.tmp/experiments/overnight-ui-ux-2026-09-10/baseline|after/{small,standard}/…`).

## Hallazgos del baseline (por qué se eligió cada candidato)

| # | Dónde | Evidencia baseline |
|---|-------|--------------------|
| C1 | Convert + nav compartida | `small/light-2.0/convert.png`: importe recortado a "100.0", fecha de frescura elipsada, nav con labels truncados ("Con/Favo/Chart/Setti") + "BOTTOM OVERFLOWED BY 1.00 PIXEL". En 1.3 ya se pierde "Updated Sep 9". |
| C2 | Charts | `small/light-2.0/charts.png`: "RIGHT OVERFLOWED BY 39 PIXELS" en fila rate+badge, "BOTTOM OVERFLOWED BY 12 PIXELS" en el rail, High/Low/Change ellipsizados (desde 1.3 en High), y **el gráfico desaparece bajo el fold**. |
| C3 | Favorites | `small/light-1.3/favorites.png`: título del par truncado a "USD → E…" (a 2.0 queda "U…"). Es el dato primario de la fila. |

## Resultados por candidato

### C1 — Convert + navegación: `verified` ✅
Cambios (4 ficheros):
- `amount_editing_field.dart`, `amount_value_row.dart`,
  `amount_display_text.dart`: la medición de `TextPainter` ahora pasa
  `textScaler` (antes medía sin escala y el render escalado reventaba el
  ancho → "100.0"). El fallo original era **doble escalado** al hornear el
  scaler en el estilo (detectado con `debugPrint` + widget test): el patrón
  correcto es medir con `textScaler: scaler` y renderizar con el estilo
  sin escala, dejando que el `Text` aplique el scaler del sistema (que en
  Android 14+ es **no lineal**: s(1)=2.0 pero s(40)≈1.39×40).
- `floating_pill_nav_item.dart`: a escala >1.5× la nav colapsa a iconos
  (Sin overflow; `Semantics(label:)` conserva el nombre para lectores de
  pantalla).
- `amount_status_bar.dart`: a escala >1.5× la línea de frescura pasa a
  2 líneas → la fecha "Updated Sep 9" ya no se pierde.
Verificación: `after/small/{light,dark}-2.0/convert.png` — "100.00"
completo, fecha visible, nav limpia. También en standard.
Test nuevo: `test/amount_editing_field_scale_test.dart`.

### C2 — Charts: `verified` ✅ (2 rondas)
Cambios (2 ficheros):
- `chart_header.dart`: fila rate+badge → `Flexible` (ronda 1: mató el
  overflow de 39px; ronda 2: `FittedBox` en el rate para que se vea
  entero reducido en vez de elipsado).
- `charts_tab_body.dart`: a escala ≥1.3 el tab pasa a layout scrollable con
  **altura fija de 240dp para la sección del gráfico** (antes el `Expanded`
  la aplastaba a ~0 → overflow de 12px y gráfico invisible).
Verificación: `after/small/dark-2.0/charts.png` y
`after/standard/light-2.0/charts.png` — cero overflows, gráfico grande y
visible, rate y badge completos, rail scrollable (2Y fuera de vista =
scrollable, correcto).
Nota: High "0.86…" puede seguir elipsando a 1.3 en el rail de métricas
(aceptable: es un resumen; el dato completo está en el tooltip/gráfico).

### C3 — Favorites: `verified` ✅
Cambios (1 fichero):
- `favorite_pair_row.dart`: el título del par usa `FittedBox(scaleDown)`
  en vez de ellipsis → "USD → EUR" se muestra completo (reducido) a 1.3
  y 2.0. Verificación: `after/small/light-2.0/favorites.png`.
No se tocó límite de favoritos, seeds, rewards ni entitlements.

## Observaciones registradas (sin implementar — propuestas)

1. **Convert rate rows a 2.0:** los nombres largos ("British Pound")
   ellipsan y el código puede quedar bajo el fold por altura de fila;
   mismo patrón FittedBox del título de Favorites sería la cura si se
   quiere (propuesta, no bloqueante).
2. **Fresh install ignora `uimode night yes` previo al primer arranque:**
   la app escribe su preferencia de tema (claro) en el primer arranque en
   vez de seguir al sistema; el toggle interno funciona. Vale revisarlo
   fuera del experimento (¿bug menor de first-run?).
3. **Los nombres de ficheros de los candidatos en el plan** eran mayormente
   inventados; se mapearon a los reales (`amount_input_header`,
   `rate_chart`, `favorites_list`, etc.).

## Limitaciones

- No se probó TalkBack real (solo Semantics revisado en código) ni
  dispositivo físico.
- La matriz standard con reset de `wm size` reusa el mismo AVD (pixel_5);
  no se probó tablet.
- `high/low/change` del rail mantiene ellipsis a 1.3 en valores largos.
- El dark-after de la primera matriz quedó en claro por el orden
  fresh-install/uimode; el set oscuro definitivo se recapturó con el
  toggle interno (convert/favorites/charts/settings a 2.0).

## Recomendación

**Integrar los 3 cambios** (diff recomendado:
`.tmp/experiments/overnight-ui-ux-2026-09-10/ui-changes.diff`): son
pequeños, reversibles, no tocan producto ni monetización, y convierten
pérdidas de datos visibles (importe, fecha, título de par, gráfico) en
render completo a escalas de accesibilidad. Antes de subir al closed test
aplicaría también la propuesta 1 (misma técnica, fila de rates de Convert)
si se aprueba este lote.
