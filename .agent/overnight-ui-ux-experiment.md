# Plan opcional: experimento UI/UX nocturno — 2026-09-10

Estado: **solo plan**. Este documento no autoriza ejecución, creación de rama,
worktree ni lanzamiento de un worker. La activación requiere que Luis inicie
explícitamente el experimento y señale este plan.

## Contexto y objetivo
La app está en `0.1.0+2`, con Billing real implementado pero aún sin cerrar
B9; B4 (AdMob real) y B8 (UMP/privacy options) siguen abiertos. El checkpoint
de `RELEASE_CHECKLIST.md` del 2026-09-10 es la autoridad operativa. El intento
de galería del 2026-09-09 quedó colgado en `Test starting`; el APK normal sí
permitió inspeccionar Convert, Favorites y Charts en `Small_Screen_API_36`
(360×640), pero no demuestra una pasada completa light/dark ni con texto grande.
Este experimento no cierra ni reordena esos gates.

Objetivo: probar hasta tres mejoras pequeñas de presentación que hagan más
legible y coherente la interfaz en teléfonos compactos, conservando la
identidad Honest Fern: papel cálido, verde bosque, Manrope/Fraunces, superficies
suaves y jerarquía editorial. No se busca rediseño ni cambio de producto.

## Aislamiento y límites
- Al activarse, preparar una rama/worktree separado desde el estado confirmado
  por el agente principal; no crear ninguno ahora. No usar `git reset`, `clean`,
  borrar datos de app ni actualizar SDK global.
- Inspeccionar también Settings en ambos temas; sus hallazgos se informan sin
  editarla, por su proximidad a Billing/UMP.
- Alcance permitido: widgets y layout de presentación de Convert, Favorites y
  Charts; tests de widget necesarios para esos cambios; `.agent/.../REPORT.md`
  y capturas ignoradas en `.tmp`.
- Fuera de alcance: monetización, billing, ads, UMP, providers, controllers,
  datos, preferencias compartidas, dependencias, plataforma/versionado, site,
  store assets, release docs, assets/fuentes, tokens globales, textos localizados
  y cualquier backend o servicio de red nuevo. Una
  necesidad fuera de este perímetro se registra como **propuesta**, no se
  implementa.
- No restaurar el teaser “Subscription · Coming Soon” ni convertir widgets en
  tarjetas por preferencia estética. El render actual y el checkpoint tienen
  prioridad sobre planes históricos; las tarjetas existentes solo cambian si
  una medición muestra un problema concreto.
- Ejecutar con `release_safe`, `APP_DEV_MODE=false` y
  `ADMOB_USE_TEST_ADS=true`. No compras, ni siquiera de prueba; no interacciones
  reales con anuncios; no sembrar entitlements mediante compras falsas ni
  tocar monetización para obtener capturas.
- No usar `capture_site_screenshots.sh`: puede seleccionar `dev_coinpaprika` y
  escribir en el repo hermano. No usar la galería que siembra entitlements ni
  tomarla como prueba de la experiencia gratuita. No usar sin cambios
  `android_reinstall_build.sh`: su ruta por defecto puede desinstalar la app,
  también tras un fallo. Preferir un emulador de prueba desechable; si no está
  disponible, hacer solo auditoría manual/estática y dejar captura en
  `pending`. Cualquier build de depuración debe pasar explícitamente los defines
  seguros y no copiar claves de firma.
- El acceso “ilimitado” a Z.ai es información del usuario no verificada. No
  inventar un ID CLI de modelo ni lanzar el worker desde este documento.

## Preparar el worktree solo al activar

Ruta fuente: `/Users/luis/Niduna/apps/currency-converter`.
Ruta aislada propuesta: `/Users/luis/Niduna-worktrees/currency-converter-ui-ux-20260910`.
Rama propuesta: `codex/experiment-ui-ux-20260910`.

1. Leer `AGENTS.md`, `RELEASE_CHECKLIST.md` (checkpoint), `DESIGN.md`,
   `.agent/DESIGN_GUIDELINES.md` y las skills locales de small-screen y Flutter
   verification desde la fuente. El checkpoint actual prevalece sobre notas viejas.
2. Inspeccionar `git status --short`, `git log -3 --oneline` y `git worktree list`.
   Base comprobada al escribir este plan: `a4c7489`. Si cambió el código o hay
   código sin commit, no trasladarlo ni decidir una nueva base: terminar con
   informe de contexto pendiente. Los seis Markdown de handoff sin commit son
   esperados y deben preservarse.
3. Comprobar que rama y destino no existen. Si existen, no sobrescribirlos ni
   reutilizar trabajo desconocido. Solo tras la activación, crear:

   ```bash
   git -C /Users/luis/Niduna/apps/currency-converter worktree add -b codex/experiment-ui-ux-20260910 /Users/luis/Niduna-worktrees/currency-converter-ui-ux-20260910 a4c7489
   ```

4. Un worktree parte de un commit: **no hereda cambios sin commit ni ignorados**.
   Copiar desde la fuente al destino, conservando rutas, únicamente este plan,
   `AGENTS.md`, `README.md`, `PLAN.md`, `ROADMAP.md`, `RELEASE_CHECKLIST.md` y
   `docs/release-prep/play-store-listing.md`. Son contexto, no resultados del
   experimento. Copiar también `.agent-local/skills/` si existe (bundle ignorado);
   si falta una skill necesaria, registrar el impedimento, sin instalar nada.
   No copiar `.env`, keystores, `key.properties`, `local.properties`, caches,
   `build/`, credenciales ni el directorio `.git`.
5. Desde el destino, registrar estado y diff inicial de los Markdown copiados
   en `.tmp/experiments/overnight-ui-ux-2026-09-10/context-before.patch`.
   No editarlos después ni mezclarlos con el diff de UI. Todas las escrituras,
   builds, tests y capturas deben hacerse en el destino, nunca en la fuente.
6. Trabajar solo con un emulador desechable dedicado al experimento, sin cuenta
   personal ni instalación que se deba conservar. Se permite crear uno local
   usando una imagen Android ya instalada; no descargar SDKs ni borrar AVDs.
   No usar el móvil del trabajo ni modificar otros emuladores. Si no puede
   aislarse el dispositivo, terminar como auditoría sin implementación.
7. Construir baseline debug (los scripts `build_apk.sh`/`build_appbundle.sh`
   generan release, no son la orden apropiada para este experimento):

   ```bash
   flutter build apk --debug --dart-define=PROVIDER_PROFILE=release_safe --dart-define=APP_DEV_MODE=false --dart-define=ADMOB_USE_TEST_ADS=true
   ```

   Registrar SDK/lockfile. Si `pub get` cambia dependencias, parar antes de editar
   UI y documentar la diferencia; no adoptar upgrades. Instalar el APK solo en
   el emulador dedicado. Usar sus controles normales para preparar datos gratis,
   temas y favoritos; no falsear precios, propiedad ni estado de consentimiento.

## Candidatos condicionados a evidencia
Cada candidato tiene como máximo dos rondas: una implementación pequeña y una
corrección posterior si la verificación revela regresión. Se implementa solo
si el baseline reproduce el problema en al menos un dispositivo/escala y el
cambio tiene una comparación before/after clara.

### C1 — Convert: cantidad y fila de resultado legibles
**Inspeccionar:** `amount_panel.dart`, `amount_value_row.dart`,
`amount_status_bar.dart`, `convert_content.dart` y tokens existentes de `AppTheme` (solo lectura).

**Hipótesis:** en 360×640 y escala 1.3×/2.0×, la cantidad, moneda, estado y
acciones compiten verticalmente o fuerzan clipping; la jerarquía puede
conservarse con espaciado responsivo y el estilo compacto ya definido.

**Cambio posible:** ajustar únicamente constraints, gaps y reflujo de texto
sin truncar importes, monedas ni acciones y tamaños ya tokenizados; mantener objetivo táctil mínimo 48×48 dp,
cantidad primero y texto auxiliar corto. No cambiar cálculo, estado ni copy
de negocio.

**Aceptación:** sin overflow/clipping ni `RenderFlex` errors en 360×640 y
teléfono estándar, light/dark, escalas 1.0/1.3/2.0; el importe y el CTA siguen
siendo el foco; color/contraste provienen de `AppTheme`.

### C2 — Charts: rail de rango y selector de par
**Inspeccionar:** `chart_metric_rail.dart`, `range_selector.dart`,
`chart_pair_strip.dart`, `pair_selector.dart`, `charts_chart_section.dart`.

**Hipótesis:** el rail o los pares pierden legibilidad, se comprimen o
desbordan en ancho pequeño y con texto grande; la relación visual entre
headline, plot y rango puede ser más clara sin cambiar datos.

**Cambio posible:** usar el patrón existente de rail desplazable/segmentado,
limitar labels secundarios y ajustar separación para conservar el gráfico
full-bleed y la selección visible. No añadir rangos, desbloqueos, CTAs ni
monetización nuevos.

**Aceptación:** ningún overflow; rango seleccionado y pares son distinguibles
en 360×640 y teléfono estándar, light/dark, 1.0/1.3/2.0; el gráfico sigue
siendo el contenido principal y todos los controles conservan accesibilidad.

### C3 — Favorites: estado y filas con densidad útil
**Inspeccionar:** `favorites_screen.dart`, `favorites_list.dart`,
`favorite_pair_row.dart`,
`favorites_empty_state.dart` y `favorites_hidden_note.dart`.

**Hipótesis:** el estado vacío o la cabecera consumen altura que desplaza las
primeras parejas; filas largas o notas repetidas reducen el acceso rápido en
360×640, especialmente a 1.3×/2.0×.

**Cambio posible:** reducir espacio redundante y
agrupar la información secundaria y preservar filas de una línea cuando sea
posible; mantener el gesto y los objetivos táctiles existentes. No cambiar el
límite de favoritos, seeds, almacenamiento, rewards ni entitlement logic.

**Aceptación:** primera acción/pareja visible sin scroll innecesario; estado
vacío sigue siendo comprensible; sin clipping, overflow o contraste light/dark
fallido en ambos dispositivos, ambos temas y las tres escalas.

## Procedimiento al activar

1. Registrar commit base, `git status`, Flutter/toolchain y las rutas exactas
   tocadas. Construir un baseline visual con los mismos datos, dispositivo,
   tema y escalas que el after. Ejecutar `./scripts/check.sh` en baseline;
   si falla, registrar el fallo previo y terminar sin ampliar el experimento.
2. Elegir por impacto reproducido, hasta tres candidatos. Si un candidato no
   reproduce el problema, marcarlo `inspected` y no modificarlo. Mantener cada
   ronda pequeña y reversible; tope total aproximado: 3 horas, nunca trabajar
   toda la noche solo para consumir cuota.
3. Obtener e inspeccionar capturas de baseline antes de editar. Preferir captura
   manual con adb en el emulador dedicado: los helpers de galería conocidos
   modifican entitlements y no son adecuados. Si falla el método de captura,
   como máximo un intento de diagnóstico acotado; después, auditoría sin cambios.
   Tras editar, ejecutar `./scripts/check.sh`, reconstruir el mismo APK debug e
   inspeccionar after. Si se pierde verificación, dejar el cambio explícitamente
   no validado y no recomendar su integración. No maquillar el resultado.
4. Revisar en el emulador dedicado un tamaño equivalente a
   `Small_Screen_API_36` (360×640) y a un teléfono estándar,
   light/dark, escalas 1.0/1.3/2.0; no bajar la escala para ocultar problemas.
   Guardar solo evidencia ignorada bajo
   `.tmp/experiments/overnight-ui-ux-2026-09-10/`.
5. Emitir `.agent/experiments/overnight-ui-ux-2026-09-10/REPORT.md` con cada
   candidato en estado `inspected`, `implemented`, `verified` o `pending`,
   before/after, archivos, comandos, resultados, limitaciones y recomendación
   de diff. La recomendación no equivale a merge.

6. Guardar también el diff de UI/tests (excluyendo los Markdown heredados),
   commit base y lista de procesos/AVD iniciados. Conservar worktree y evidencia
   para revisión. Apagar solo el emulador/procesos propios al terminar, sin
   borrar sus datos ni cerrar servicios ajenos. Nada de commits, pushes, merges,
   deploys, publicación, compras, otros agentes o bucles automáticos nocturnos.

## Prompt de lanzamiento (usar solo con activación explícita)

> Lee y sigue `/Users/luis/Niduna/apps/currency-converter/.agent/overnight-ui-ux-experiment.md`.
> Activo este experimento: prepara el worktree y el contexto según el documento,
> y trabaja únicamente dentro de esa carpeta aislada,
> respetando su perímetro, sus dos rondas máximas, el tope de 3 horas y la
> matriz de verificación. Usa el modelo Z.ai indicado por el operador solo si
> su acceso e ID están confirmados en el entorno; no los inventes. Devuelve la
> ruta absoluta del worktree, REPORT.md y el diff recomendado; no hagas commit, push, merge, deploy,
> compra, publicación ni cambios de monetización.

## Decisión de salida

Recomendar el diff solo cuando `check.sh` pasa y la matriz visual/manual aporta
evidencia suficiente. Si no hay captura fiable, recomendar únicamente una
auditoría pendiente. El experimento puede quedar `pending` sin alterar la
release candidate; B4, B8 y B9 siguen siendo trabajo independiente.
