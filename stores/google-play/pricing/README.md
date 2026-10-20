# Estrategia de precios — Currency Converter

## Ampliación UE aplicada — 2026-10-20

Luis aprobó los 18 precios exactos de DK/SE/PL/CZ/HU/RO y se aplicaron por API.
La lectura independiente confirma 522 filas: **18 actualizadas y 504 conservadas**,
además de todos los demás campos del catálogo. Véanse
[la decisión y los importes](eu6-review-2026-10-20.md),
`eu6-policy.proposed.json` (estado `applied`), el CSV y `eu6-application.json`.
No se ha probado el checkout de cada país; puede haber demora de propagación.

La estrategia vigente combina dos políticas fechadas:

- `launch-policy.proposed.json`: EUR/CHF/USD, aplicada el 19 de octubre;
  recibo histórico `launch-application-2026-10-19.json`.
- `eu6-policy.proposed.json`: seis mercados UE sin euro, aplicada el 20 de octubre;
  recibo `eu6-application.json`, también reflejado en `last-application.json`.

Ambas conservan su nombre histórico `proposed`; su estado es `applied`.
Las políticas aplicadas son registros y no se deben volver a ejecutar sin una
nueva autorización y comparación. No se requiere otra AAB ni cambia la release.

## Política inicial y aplicación histórica — 2026-10-19

Fecha: 2026-10-19. **Precios aplicados y verificados por API.**
Tres compras únicas de por vida, sin suscripciones. Véase la
[investigación de mercado, fuentes y límites](research-2026-10-19.md).
El JSON conserva su nombre histórico `launch-policy.proposed.json`, ahora con
estado `applied`. El recibo histórico está en `launch-application-2026-10-19.json`. El CSV
conserva la comparación original aprobada, no representa cambios pendientes.
Se actualizaron 69 precios en 23 regiones. Lecturas independientes verifican
los 522 precios y todos los campos conservados. No se comprobó cada checkout
regional ni se hizo una compra; la propagación al teléfono puede demorarse.

## Catálogo anterior a la aplicación

Lectura autenticada con `monetization.onetimeproducts.list`: tres productos,
una opción de compra ACTIVE/legacyCompatible por producto, 174 regiones cada
uno y 65 monedas. Precio configurado no equivale a distribución de la app en
ese país. Snapshot fechado en `.tmp/play-pricing/20261019/catalog-snapshot.json`.

| Compra única | Suiza actual CHF | España actual EUR | EE. UU. actual USD |
| --- | ---: | ---: | ---: |
| Quitar anuncios | 2,00 | 2,59 | 2,49 |
| Charts Pro | 3,00 | 3,79 | 3,69 |
| Favorites Pro | 1,00 | 1,29 | 1,19 |

Los importes no son ingreso neto. El tratamiento fiscal y total de checkout
se verifican por mercado. Incluso dentro de EUR hay diferencias actuales:
quitar anuncios es 2,49 en Alemania/Francia y 2,59 en España.

## Precios aprobados y aplicados

| Compra única | CHF, CH y LI | EUR, mercados seleccionados | USD, solo US |
| --- | ---: | ---: | ---: |
| Quitar anuncios | 2,00 | 1,99 | 1,99 |
| Charts Pro | 3,00 | 2,99 | 2,99 |
| Favorites Pro | 1,00 | 0,99 | 0,99 |

Conservar los precios redondos suizos que Luis considera adecuados. Los ,99 en
EUR/USD son convenciones sencillas, no una garantía de más ventas. Las fuentes
Android encontradas publican quitar anuncios a 1,99–2,99 USD; un conversor iOS
lista Remove ads a 2,99 EUR. No es una media representativa ni prueba de precios
Android europeos. Charts y Favorites requieren juicio sobre nuestras funciones;
no se encontró un benchmark idéntico para esos dos desbloqueos separados.
La investigación explica estas diferencias y por qué se descartan suscripciones,
reseñas antiguas y desbloqueos completos caros como equivalentes directos.

Comprar las tres opciones suma 5,97 EUR/USD o 6 CHF de precio de catálogo.
La versión gratuita conserva su alcance actual. No se añade bundle ni se cambia
la aplicación. En España la propuesta baja los precios aproximadamente 21–23 %;
en EE. UU. 17–20 %. Suiza no cambia. No se presenta la rebaja como solo cosmética.

## Alcance exacto

- CHF: Suiza conserva 2/3/1 CHF; Liechtenstein se armoniza a esos importes
  (antes 2,10/3,20/1,10 CHF).
- EUR: AT, BE, BG, CY, DE, EE, ES, FI, FR, GR, HR, IE, IT, LT, LU, LV, MT,
  NL, PT, SI, SK. Las otras 12 regiones que cobran en EUR mantienen precios.
- USD: solo US; las otras 74 regiones con precio en USD mantienen sus importes.
- Resultado del plan: **69 precios cambian en 23 regiones**. Las otras 453 filas
  (151 regiones por producto, incluida Suiza) conservaron entonces su precio;
  la ampliación del 20 de octubre modifica 18 de ellas.
- Preservar disponibilidad, países de distribución, IDs, compras anteriores,
  impuestos, ofertas y `newRegionsConfig`. Los precios de futuras regiones
  necesitan una decisión propia antes de futuras ampliaciones.

## Resto del mundo

No cambiar las 174 regiones a mano ni aplicar ,99 a todas las monedas.
Para los mercados fuera de las dos políticas aplicadas, conservar el resto de precios de Play.
Ya incluyen patrones locales derivados de la configuración anterior.
Después priorizar mercados con uso real y revisar poder adquisitivo, precio
local habitual y rendimiento; no usar solo cambio de moneda o idioma del móvil.

### Cómo priorizar sin estudiar 174 países

Decisión de alcance — 2026-10-19: los importes principales recomendados han
recibido la conformidad de Luis y se han aplicado a Play. Para el
resto conservar el catálogo regional existente como aproximación inicial.
Una conversión nueva, si se prepara más adelante, debe generar un plan separado;
no se presupone aprobada una actualización global de tipos de cambio.

La app tiene 34 monedas tradicionales y 11 criptomonedas (45 en total), según
`lib/src/core/currency/supported_currencies.dart`. No son 45 monedas nacionales.
No dividir el precio automáticamente entre «su moneda está / no está en la app».
Un residente puede usarla para viajar, y la moneda consultada no identifica la
región de facturación. La cobertura es una señal de utilidad, no una regla de precio.

Prioridad de revisión comercial, en este orden:

1. Países donde efectivamente se distribuye la app y mercados de lanzamiento
   deliberadamente elegidos; tener un precio configurado no prueba distribución.
2. Idiomas de la interfaz disponibles y casos de uso de viajes/conversión.
3. Después del lanzamiento, uso, compradores, ventas y devoluciones por mercado
   disponibles en Play, más comentarios de soporte. No añadir tracking a la app.
4. Cobertura de la moneda local como señal adicional. Si no está soportada,
   aclarar el alcance al usuario; un menor precio no corrige esa limitación.

Para los demás países, los precios generados por Google son una base operativa
razonable, no una optimización demostrada de poder adquisitivo. Su conversión
considera tipo de cambio y patrones de precio; no asumir que garantiza
asequibilidad local. No imponer ,99 en JPY o en todas las demás monedas, ni
aplicar descuentos arbitrarios por una clasificación general de países.

Revisar un grupo pequeño cuando exista una razón concreta. No hace falta un
estudio individual de todos los países antes del primer lanzamiento ni un
experimento A/B sin compradores suficientes.

Referencias: [conversión regional de Google](https://developers.google.com/android-publisher/api-ref/rest/v3/monetization/convertRegionPrices)
y [experimentos de precio/poder adquisitivo](https://google.play/business/price-experiments/).
La primera ofrece una base calculada; la segunda ayuda a aprender de resultados
cuando hay datos suficientes. Son funciones distintas.

Para una revisión global futura:

1. Obtener catálogo y conversión de referencia actualizados.
2. Fijar una base de referencia **sin impuestos** para `convertRegionPrices`;
   no introducir allí 1,99 CHF como si fuese automáticamente el precio final
   suizo. Conservar categoría fiscal real y revisar la salida.
3. Elegir niveles por mercado/moneda. Monedas como JPY requieren importes
   enteros; otras pueden usar finales distintos de ,99.
4. Validar mínimos/máximos admitidos por Google, costes, impuestos y coherencia
   entre productos. Evitar inventar un modelo de poder adquisitivo sin datos.
5. Generar comparación completa, aprobarla y aplicar solo las filas decididas.

No programar una actualización diaria por tipo de cambio. Mantener estabilidad
y revisar manualmente tras el lanzamiento o ante cambios materiales. Un botón
«actualizar tipos de cambio» puede sobrescribir decisiones regionales: exportar
y comparar antes de usarlo.

## Ficheros y herramientas

- `launch-policy.proposed.json`: importes y alcance propuestos, legibles por script.
- `launch-plan-reviewed-2026-10-19.csv`: comparación completa de las 522 filas, con país,
  moneda, precio actual/propuesto, variación porcentual y disponibilidad.
- Snapshot completo y plan JSON ignorados en `.tmp/play-pricing/20261019/`.
  Son evidencia fechada; hay que releer Play antes de una futura modificación.

```bash
# Lectura real; no crea un edit ni modifica catálogo o releases.
GOOGLE_APPLICATION_CREDENTIALS=/path/to/existing-key.json \
  ./.devtools/google_play.sh pricing catalog --output .tmp/catalog-new.json

# Comparación offline; no necesita credenciales.
./.devtools/google_play.sh pricing plan \
  --catalog .tmp/catalog-new.json \
  --policy stores/google-play/pricing/launch-policy.proposed.json \
  --output .tmp/pricing-plan-new.json --csv-output .tmp/pricing-plan-new.csv
```

Los destinos deben ser nuevos y sus carpetas existir. Los comandos reutilizan
el entorno Python existente y no añaden dependencias. `catalog` y `plan` no
escriben en Play; `apply` sí requiere autorización explícita de los importes.
El plan detecta cambios en IDs/opciones/estado y usa Decimal para los importes.
No valida precios contra Google ni constituye un payload de actualización.
La lectura, el plan y la aplicación se ejecutaron con el catálogo real; no se
añadió ni ejecutó una suite automática. No se tocaron app, web ni AAB 10.

## Aplicación por API

La API moderna ya permite cambiar estos productos. No hace falta automatizar
clics ni migrar/recrear IDs: el catálogo actual ya expone las opciones modernas.
Antes de escribir:

1. Aprobar el JSON y el CSV exactos; guardar snapshot original completo.
2. Releer y abortar si precios/opciones/configuración cambiaron desde el plan.
3. Confirmar la máscara admitida para actualización de la lista de opciones;
   no asumir que una ruta dentro de arrays repetidos es válida. Conservar
   opciones, regiones no afectadas, compatibilidad legacy y configuración futura.
4. Usar patch/batchUpdate con máscara explícita, `regionsVersion` vigente y
   creación desactivada (`allowMissing=false`). No usar PUT legacy de reemplazo
   ni activar/desactivar productos. No tratar catálogo como un release edit.
5. Guardar respuesta por producto, releer y comparar precios y campos conservados.
   Una operación parcial requiere reconciliar el estado; no repetirla a ciegas.
6. Verificar Console y checkout con la cuenta de licence testing. La propagación
   no es instantánea y no prometemos un plazo numérico.

La escritura funcionó con los permisos existentes. `pricing apply` usa la
máscara terminal `purchaseOptions`, envía la lista completa conservada y omite
`state` de salida. El parámetro Python es `regionsVersion_version`; la biblioteca
lo serializa como query `regionsVersion.version`. No pasar la clave REST con
punto directamente a la función Python: produjo un TypeError local en el primer
intento, sin cambios en Play. Se releyó el catálogo antes del segundo intento.

Para una futura política aprobada, establecer `status: approved-for-application`,
generar un snapshot/plan nuevos y ejecutar, con autorización de Luis:

```bash
./.devtools/google_play.sh pricing apply \
  --catalog .tmp/catalog-new.json \
  --policy stores/google-play/pricing/launch-policy.proposed.json \
  --plan .tmp/pricing-plan-new.json \
  --receipt-dir .tmp/pricing-receipts-new \
  --confirm-package com.honestfern.currency_converter
```

El directorio de recibos debe ser nuevo y su padre existir. Se validan hashes
del snapshot/política y filas del plan; se bloquea el proceso local, se relee
el catálogo y cada producto, y se aborta ante cambios u ofertas vinculadas.
Las solicitudes no se reintentan automáticamente. Se guardan intentos,
respuestas y lecturas completas antes/después; cualquier error requiere
reconciliar el estado antes de repetir. No hay precondición remota ETag: evitar
ediciones concurrentes desde Console/otra máquina. El rollback sería otra
modificación explícita desde el snapshot, no una reversión atómica garantizada.

La versión 10 consulta `ProductDetails.price`; cambiar precios de catálogo no
requiere recompilarla. Conservar el mismo AAB para la candidatura pública.

## Fuentes oficiales para no volver a buscarlas

Consultadas el 2026-10-19:

- [Precios, divisas y patrones locales](https://support.google.com/googleplay/android-developer/answer/6334373?hl=en).
- [Modelo de productos de compra única](https://support.google.com/googleplay/android-developer/answer/16430488?hl=en).
- [Catálogo y opciones regionales](https://developers.google.com/android-publisher/api-ref/rest/v3/monetization.onetimeproducts).
- [Patch y máscara/versionado de regiones](https://developers.google.com/android-publisher/api-ref/rest/v3/monetization.onetimeproducts/patch).
- [Actualización por lotes](https://developers.google.com/android-publisher/api-ref/rest/v3/monetization.onetimeproducts/batchUpdate).
- [Conversión regional de referencia](https://developers.google.com/android-publisher/api-ref/rest/v3/monetization/convertRegionPrices).
- [Catálogo desde Billing](https://developer.android.com/google/play/billing/integrate).

- [BCE: Bulgaria y los 21 miembros de la zona euro en 2026](https://www.ecb.europa.eu/press/pr/date/2026/html/ecb.pr260101~c830245e42.es.html).
