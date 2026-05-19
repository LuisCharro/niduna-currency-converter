# Plan: Integración API Crypto — Currency Converter

> Revisado por GLM 5.1 | 2026-05-19

## Estado actual

- **Frankfurter API** → único cliente de tasas (`RatesClient`)
- **Arquitectura limpia**: `RatesClient` (interfaz) → `RatesService` → `RatesCache` (SharedPreferences)
- **16 monedas fiat**, sin crypto
- **Dependencias**: `http: ^1.6.0` ✅ ya disponible para llamadas HTTP

---

## Decisión arquitectónica clave

No se toca `RatesService` ni el `RatesCache` existente. Se crea un **cliente adicional** que coexiste con Frankfurter.

**Patrón: Composite/Merging Client**

```
RatesClient (interfaz, existente)
  ├── FrankfurterClient (fiat, existente)
  └── CoinLoreClient   (crypto, nuevo)
        ↓
  AggregatingRatesClient (merge resultados)
        ↓
  RatesService (sin cambios)
        ↓
  RatesCache (sin cambios)
```

Esto evita tocar código funcionando y aísla el dominio crypto.

---

## Impactos sobre la app existente

| Área | Impacto | Severidad |
|------|---------|-----------|
| RatesService | Ninguno — interfaz no cambia | ✅ N/A |
| RatesCache | Ninguno — mismo formato Snapshot | ✅ N/A |
| FrankfurterClient | Ninguno — sigue funcionando solo | ✅ N/A |
| SharedPreferences | Bajo — más datos en caché | 🟡 Bajo |
| UI existing | Ninguno — BTC/ETH aparecen en picker | ✅ N/A |
| Tests existing | Ninguno — no se tocan | ✅ N/A |
| App startup | Mínimo — doble llamada HTTP en init | 🟡 Bajo |
|离线功能 | Funciona con last cached rates | ✅ OK |

---

## Pasos de implementación

### Fase 1 — Scaffolding (no rompe nada)

1. **Añadir crypto a `supported_currencies.dart`**
   ```dart
   SupportedCurrency(code: 'BTC', name: 'Bitcoin', symbol: '₿'),
   SupportedCurrency(code: 'ETH', name: 'Ethereum', symbol: 'Ξ'),
   ```

2. **Crear `coinlore_client.dart`**
   - Ubicación: `lib/src/core/rates/clients/coinlore_client.dart`
   - Implementa `RatesClient`
   - `fetchLatest` → `https://api.coinlore.com/api/price/?fsym=BTC&tsyms=EUR,USD`
   - `fetchHistorical` → stub que lance `UnimplementedError` (Phase 3)
   - Timeout: 10s, retry 1x
   - Lanza `RatesClientException` en error

3. **Crear `aggregating_rates_client.dart`**
   - Ubicación: `lib/src/core/rates/clients/aggregating_rates_client.dart`
   - Recibe `FrankfurterClient` + `CoinLoreClient`
   - `fetchLatest`: llamadas paralelas con `Future.wait`
   - Merge: `{...fiatRates, ...cryptoRates}`
   - `fetchHistorical`: solo delega a Frankfurter
   - **Graceful degradation**: si CoinLore falla, continúa solo con fiat
   - Timeout global: 15s para el conjunto

4. **Actualizar `main.dart` / `src/app.dart`**
   - Crear `CoinLoreClient()`
   - Crear `AggregatingRatesClient(FrankfurterClient(), CoinLoreClient())`
   - Pasar al `RatesService` como antes

### Fase 2 — Validación

5. **Test manual:**
   - EUR base, BTC quote → tasa BTC/EUR
   - AdMob/ads siguen funcionando (no rompe monetization)
   - Caché SharedPreferences guarda `latest_rates_EUR` con BTC

6. **Test de error:**
   - Simular CoinLore caído → app funciona solo con fiat
   - Probar sin conexión → usa last cached rates

### Fase 3 — Charts crypto (opcional Phase 3)

7. **Implementar `fetchHistorical` en CoinLoreClient**
   - Endpoint: `/api/coin/price?symbol=BTC&date=YYYY-MM-DD`
   - O migrar a CoinGecko para mejor historical
   - Añadir a `AggregatingRatesClient.fetchHistorical`

---

## Normalización de datos

### CoinLore API → RatesSnapshot

CoinLore endpoints libres:
```
GET https://api.coinlore.com/api/ticker/?id=90      → BTC
GET https://api.coinlore.com/api/ticker/?id=80      → ETH
GET https://api.coinlore.com/api/price/?fsym=BTC&tsyms=EUR,USD  → BTC/EUR, BTC/USD
```

**Mapeo:** `RatesSnapshot` espera `{ "BTC": 62100.0, "ETH": 3400.0, ... }`

CoinLore devuelve `price` como float — mapeo directo al `Map<String, double>` existente. Sin cambios en el modelo.

### Decimales
- Crypto: 2-8 decimales significativos según valor
- Fiat: 4 decimales (Frankfurter ya normaliza)
- Conversión: la UI decide decimales según tipo (fiat vs crypto)

### Timestamp
- `savedAt`: timestamp del fetch (no del dato CoinLore, que puede ser ligeramente delayed)
- `date`: `null` para crypto (CoinLore no garantiza fecha del precio)

### Conflictos de nomenclatura
- CoinLore usa `BTC` como symbol → mismo código en `SupportedCurrency`
- Sin conflictos con fiat existentes

---

## Caché

### Estrategia: TTL separado por tipo de activo

| Tipo | TTL (`maxAge`) | Rationale |
|------|---------------|-----------|
| Fiat | 1h (no cambia) | Mercados fiat son estables |
| Crypto | 5 min | Alta volatilidad — 1h es inaceptable |

### Implementación
- `RatesService.getLatestRates` recibe `maxAge` por llamada
- La UI pasa `maxAge` diferente según el par seleccionado
- `SharedPreferencesRatesCache` no cambia — mismo formato

### Claves de caché
- Fiat: `latest_rates_EUR`, `latest_rates_USD` (no cambia)
- Crypto: mergeado en la misma clave — `latest_rates_EUR` contiene BTC/ETH
- Historical: igual que antes, sin cambios

### Invalidación
- Clear cache manual → también limpia crypto
- Auto-invalidate on network error (RatesService ya lo hace)

---

## Resolución de conflictos entre proveedores

### Escenario: BTC/EUR
- **Frankfurter**: no ofrece BTC (solo fiat) → no entra en conflicto
- **CoinLore**: ofrece BTC/EUR directo → fuente primaria para crypto

### Escenario: EUR base + BTC quote
- `AggregatingRatesClient` obtiene:
  - Fiat de Frankfurter: `{ "USD": 1.08, "GBP": 0.85, ... }`
  - Crypto de CoinLore: `{ "BTC": 62100.0, "ETH": 3400.0 }` (precios absolutos en EUR)
- Merge: `{...fiat, ...crypto}`
- Conversión: UI calcula `BTC/EUR = snapshot.rates["BTC"]` directamente

### Regla de precedencia
```
Si el código existe en Frankfurter Y en CoinLore → usar Frankfurter (fuente fiat canonical)
Si el código solo existe en CoinLore → usar CoinLore
```
Esto evita duplicados y mantiene a Frankfurter como fuente canonical del mundo fiat.

### Código冲突检测:
```dart
// En AggregatingRatesClient.fetchLatest
if (_frankfurterCodes.contains(code) && _coinloreCodes.contains(code)) {
  // Code aparece en ambos — conflicto potencial
  // Resolution: Frankfurter wins para fiat, CoinLore wins para crypto (sin overlap real)
}
```

---

## Errores y timeouts

### Timeouts
| Llamada | Timeout | Retry |
|---------|---------|-------|
| Frankfurter latest | 10s | 1x |
| CoinLore latest | 10s | 1x |
| Aggregate total | 15s | — |
| Historical | 15s | 1x |

### Estrategia de errores
```
CoinLore falla → continuar con Frankfurter solo (graceful degradation)
Frankfurter falla → error con cached fallback (RatesService ya lo hace)
Ambos fallan → error con cached fallback
```

### Manejo en AggregatingRatesClient
```dart
Future<RatesSnapshot> fetchLatest(String base) async {
  final results = await Future.wait([
    _frankfurter.fetchLatest(base).catchError((_) => null),
    _coinlore.fetchLatest(base).catchError((_) => null),
  ]);
  final fiat = results[0];
  final crypto = results[1];
  // Merge con null-safety
}
```

### Casos de error suave
- CoinLore down → mostrar toast "Precios crypto no disponibles"
- Ambas APIs down → mostrar cached rates con banner "Usando datos en caché"

---

## Feature flag

### Decisión: overkill para 2 cryptos

Un feature flag dedicado añade complejidad de configuración (SharedPreferences, Firebase Remote Config) sin beneficio claro para 2 activos fijos.

**Alternativa práctica:** crear un `CryptoAssets` config iterable:

```dart
// lib/src/core/currency/supported_cryptocurrencies.dart
const List<SupportedCurrency> supportedCryptos = [
  SupportedCurrency(code: 'BTC', name: 'Bitcoin', symbol: '₿'),
  SupportedCurrency(code: 'ETH', name: 'Ethereum', symbol: 'Ξ'),
];

// En CoinLoreClient — leer de esta lista, no hardcodear
```

Para Phase 3 con más cryptos, esto escala sin cambiar código del cliente.

**Cuándo usar feature flag real:**
- Si se quiere ability de disable crypto sin deploy nuevo
- Si hay múltiples API providers (CoinLore vs CoinGecko)
- Si A/B testing de providers

**Veredicto GLM 5.1:** no feature flag por ahora — overkill.

---

## Pruebas

### Tests mínimos requeridos

1. **Unit tests — CoinLoreClient**
   - `fetchLatest` → parse correcto del JSON de CoinLore
   - `fetchLatest` → lanza `RatesClientException` en error 500
   - `fetchLatest` → lanza en JSON inválido
   - Timeout: lanza después de 10s

2. **Unit tests — AggregatingRatesClient**
   - Fiat + crypto merge correct
   - Graceful degradation: CoinLore falla, fiat presente
   - Graceful degradation: Frankfurter falla, crypto presente
   - Ambos fallan → `RatesClientException`

3. **Contract tests**
   - Mock CoinLore responses según formato real
   - Verificar que el merged `RatesSnapshot` tiene la estructura correcta

4. **Tests de integración (manual)**
   - device/testing: EUR → BTC → valor real shown
   - Sin conexión: cached rates displayed correctly
   - Ad monetization: sigue funcionando

### Tests existentes — no tocar
- FrankfurterClient tests ✅ siguen pasando
- RatesService tests ✅ siguen pasando
- UI tests ✅ siguen pasando

---

## Despliegue gradual

### Estrategia: silent rollout + monitoring

**Por qué no feature flag:**
- Solo 2 cryptos fijas
- Si rompe, el impacto es visible inmediatamente

**Pasos de deploy:**

1. **Pull request** → review + CI pasa
2. **Internal testing** → 3-5 devices internos
3. **Beta/Firebase App Distribution** → testers externos
   - Monitorizar: crashlytics, performance, rates errors
4. **Producción** → 100% rollout
   - Flags: crashlytics, Firebase Analytics (rates_success, rates_error, crypto_fetched)

### Rollback
- Si crashlytics reporta spike en `RatesClientException` →
  - Disable via Firebase Remote Config (si se quiere) o
  - Revert merge commit en `AggregatingRatesClient`

### Qué monitorizar
| Métrica | Warning | Critical |
|---------|---------|----------|
| `crypto_fetch_error_rate` | >5% | >15% |
| `crypto_fetch_duration` | >8s | >12s |
| `cache_hit_rate` | — | Baja anormal |
| Crashlytics: CoinLoreClient | >0 | >0 |

---

## Monitoreo y telemetria

### Eventos a trackear

```dart
// En AggregatingRatesClient
analytics.logEvent('rates_fetch', {
  'provider': 'coinlore',
  'success': true,
  'duration_ms': duration.inMilliseconds,
});

analytics.logEvent('rates_error', {
  'provider': 'coinlore',
  'error': e.toString(),
});
```

### En producción
- **Crashlytics** — crashes de CoinLoreClient
- **Firebase Analytics** — tasas de error crypto vs fiat
- **Performance Monitoring** — duración de fetching
- **User feedback** — si usuarios reportan "precios raros" en crypto

### Dashboard key metrics
- % de запросы que usan crypto (pair selection)
- Error rate por proveedor
- Avg fetch duration crypto vs fiat

---

## Cumplimiento y licencia del proveedor

### CoinLore — evaluación

| Aspecto | Detalle |
|---------|---------|
| Licencia API | Attribution required, no redistribution |
| Uso comercial | Permitido con atribución |
| atribución | Mostrar "Data: CoinLore" en settings/about |

### Requisito de atribución
Añadir en `settings_screen.dart` o `about.dart`:
```
Cryptocurrency data provided by CoinLore
```

### Riesgos legales
- **Redistribución**: la app no redistribuye datos — solo consume API para uso propio ✅
- **Almacenamiento**: SharedPreferences cache es local ✅
- **Tracking**: sin Google Analytics para crypto (solo analytics basicos) ✅
- **Fiat**: Frankfurter es MIT ✅

### Si se cambia a CoinGecko en Phase 3
- CoinGecko free tier: attribution requerida
- Para uso comercial alto:需要升级付费
- Evaluar antes de Phase 3

---

## No se toca

- `RatesService` ✅
- `RatesCache` / `SharedPreferencesRatesCache` ✅
- `FrankfurterClient` ✅
- `HistoricalSnapshot` ✅ ( salvo extensión en Phase 3)
- Tests existing ✅
- Monetization / ads ✅

---

## Tracking

- [ ] Añadir BTC, ETH a `supported_currencies.dart`
- [ ] Crear `supported_cryptocurrencies.dart` iterable
- [ ] Crear `coinlore_client.dart` (fetchLatest, fetchHistorical stub)
- [ ] Crear `aggregating_rates_client.dart`
- [ ] Integrar en `main.dart`/`app.dart`
- [ ] Unit tests CoinLoreClient
- [ ] Unit tests AggregatingRatesClient
- [ ] Contract tests con mocks
- [ ] Probar conversión BTC/EUR (manual)
- [ ] Verificar caché SharedPreferences
- [ ] Añadir atribución CoinLore en settings/about
- [ ] Plan Phase 3: charts crypto + CoinGecko

---

## Referencias API

- CoinLore free API docs: `https://api.coinlore.com/api/ticker/?id=90` → BTC
- CoinLore price endpoint: `https://api.coinlore.com/api/price/?fsym=BTC&tsyms=EUR,USD`
- FrankfurterClient patrón → seguir mismo en CoinLoreClient
- CoinGecko (Phase 3 backup): `https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=eur`