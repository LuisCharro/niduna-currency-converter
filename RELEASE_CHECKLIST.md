# Release Checklist — Path to Google Play Store

## Live status confirmed — 2026-10-21

Read-only inspection of the authenticated Chrome Play Console confirms:

- **Production access is granted.** Submission **7**, Production **1.0.0 (11)**,
  submitted **20 October 2026, 11:31 am** (Console displayed time), remains
  **In review**. No rejection was displayed.
- Publishing overview shows **Changes in review** for exactly the code-11
  full rollout and addition of **28 countries/regions (EU27 + Switzerland)**.
  Managed publishing is **off**: approval can publish automatically.
  Public availability has not been established.
- Submission **6**, Closed testing / Alpha 11, and submission **5**, Store
  Listing / App Content, are **Published**. Those are separate from Production.

### What the Dashboard progress counters mean

- **Create and publish a release — 4 of 5 complete:** selecting countries,
  creating the release, previewing/confirming it and sending it for review
  are complete. The remaining task is **Publish your app on Google Play**.
  The current Production release is awaiting Google review; do not infer from
  the remaining task that it must be recreated or resubmitted.
- **Let anyone sign up to test your app on Google Play — 1 of 4 complete:**
  this is the separate, **optional Open testing** workflow. Country selection
  is complete; creating, confirming and submitting an Open release are not.
  Open testing is not a missing prerequisite for this Production submission.
  Do not create an Open release merely to complete the counter.
- Dashboard showed **Not yet sent for review** alongside **Production Active**
  during this inspection. Publishing overview and submission history both
  explicitly confirmed submission 7 **In review**. Use those detailed records
  to resolve the ambiguous Dashboard summary; neither Active nor device counts
  establish public availability.

### AdMob email and next action

The **21 October** Google AdMob email, **Congratulations: Your ads are live!**,
reports that users are seeing ads in the publisher's app(s). This is an
advertising milestone, not Play Production approval or proof of public launch.
Existing tester usage could explain it; that attribution was not verified.
The email does not establish app-specific AdMob readiness approval, lifted ad
serving limits, earnings or completion of the store-link/app-ads.txt review.
Check AdMob directly for those states when the public listing is available.

**Next:** await Google's decision; no missing action or rejection was shown
for this submission. Do not cancel, resubmit, rebuild or change tracks merely
because of these counters. Google documents processing of a few hours to seven
days, sometimes longer; this is guidance, not a promised approval date.
Address any actual review request if one arrives. After approval, verify the
listing and installation for a non-tester in a selected market, then perform
the separately authorized website S2 launch update. Keep Coming Soon until then.
Paid-feature reviewer-access uncertainty remains unresolved; this status check
is not policy clearance. No Play/AdMob settings, releases or website changed.

Sources checked 2026-10-21:

- [Live submission activity](https://play.google.com/console/u/0/developers/6219086036817053258/app/4973875544480645622/publishing/submission-activity)
- [Live Publishing overview](https://play.google.com/console/u/0/developers/6219086036817053258/app/4973875544480645622/publishing)
- [Google publishing/review guidance](https://support.google.com/googleplay/android-developer/answer/9859654?hl=en)
- [Google testing tracks](https://support.google.com/googleplay/android-developer/answer/9845334?hl=en)
- [AdMob app readiness](https://support.google.com/admob/answer/10564477?hl=en)

Earlier dated checkpoints below are historical; this checkpoint supersedes
older saved/not-submitted and empty-Production descriptions for current action.

## Production 11 submitted — 2026-10-20

Luis authorized sending the existing version **1.0.0 (11)** for public release
in **EU27 + Switzerland**. The exact bundle SHA-256 and release notes were
verified against `production-release-plan.json`; the API country set matched
all 28 approved countries with no rest-of-world targeting. No rebuild/upload.

The Console Send dialog closed twice without creating a submission: Publishing
overview still listed two unsubmitted changes and submission history had no new
entry. No policy rejection/error was displayed. A reload confirmed that state;
the cause of that UI behavior is unknown. A temporary API read/validation edit
was accepted and deleted. The authorized fallback then preserved the exact
existing Production track body, validated and committed once with
`changesInReviewBehavior=ERROR_IF_IN_REVIEW` and no automatic write retries.

After the API commit, refreshed Console confirms **Changes in review** for
exactly Production 11 / Start full rollout and Add 28 countries/regions. Quick
checks finished; the Console history/details confirm **Submission 7**, source
API, **In review**, submitted Oct 20, 2026, 11:31 am (Console displayed time). **Managed publishing is off**:
Google approval may make the app public automatically. This is submission,
not proof of approval or public availability. Do not resubmit or cancel review.

Prices for the six non-euro EU markets were applied and independently verified
before submission. Reviewer-access declarations were not altered or falsely
attested; Google may request corrections during review. Keep website Coming Soon
until actual Production publication is verified, then perform website step S2.

Evidence: ignored `.tmp/play-production-submission-20261020/` contains API
validation/commit receipts, exact artifact/country reads and Console
`in-review.txt` / `in-review.png` and `submission-7.txt` / `submission-7.png`.
See the machine-readable release plan.
Earlier saved/not-submitted checkpoints below are historical.

## Six EU local price update verified — 2026-10-20

Luis approved the exact DK/SE/PL/CZ/HU/RO prices. The existing API script
applied 18 prices and an independent read verified all 522 rows and preserved
fields (504 prices unchanged). See `stores/google-play/pricing/eu6-review-2026-10-20.md`
and `eu6-application.json` in that directory. No new binary, release submission,
website deployment or distribution change occurred. Regional checkouts and
phone propagation were not verified. Production 11 remains prepared, not submitted
by this operation.

## EU + Switzerland preparation saved — 2026-10-20

This checkpoint supersedes the earlier ES/CH-only decision below. Luis explicitly
approved preparing **all 27 EU countries plus Switzerland**. Console now saves
exactly 28 country rows: AT, BE, BG, HR, CY, CZ, DK, EE, FI, FR, DE, GR, HU,
IE, IT, LV, LT, LU, MT, NL, PL, PT, RO, SK, SI, ES, SE and CH.

- Publishing overview confirms exactly **two changes not yet submitted for
  review**: Production `1.0.0 (11)` / Start full rollout, and Add 28 countries/regions.
- Open testing shares Production country targeting. Closed Alpha is not listed
  as affected. No new binary, prices, listing or website deployment changed.
- Managed publishing is **off**. A future authorized submission may make the
  app public automatically after Google approves it. Nothing was submitted here.
- The generic EU geo-blocking notice remains visible. EU-wide selection avoids
  relying on an unconfirmed exception for this utility; it is not legal clearance.
  Sources and Google territory groupings: [EU distribution review](docs/release-prep/eu-distribution-review-2026-10-20.md).
- The track summary can say **Active**, `1.0.0 (11)` and 28 countries while the
  batch is still unsubmitted. Use Publishing overview and actual public
  availability to establish publication, not that summary or API `completed`.
- Reviewer-access navigation remains a local draft; no false free-access
  attestation was saved. Support did not pre-clear reviewer purchases. This
  uncertainty is not a confirmed rejection or a reason to wait indefinitely
  for another support reply; Google may request corrections during review.
- Next: inspect the full pending batch and obtain the separate instruction to
  submit Production. Do not create another release or change the accepted AAB.
- Evidence: ignored `.tmp/play-production-draft-20261020/eu28-release-pending.png`
  and `.txt`; country checkbox inspection confirmed exactly the 28 rows above.

## Historical ES/CH preparation (superseded by EU + CH above) — 2026-10-20

- Luis explicitly confirmed **Spain and Switzerland only**. Selected and saved
  exactly ES/CH in Production. Country change is saved for review, not yet
  published. Console notes Open testing shares Production country targeting;
  Closed Alpha is not listed as affected.
- Reopened the existing code-11 release preview: **Ready to release**, with
  the missing-country error gone and no other displayed validation errors.
  Saved the preview to Publishing overview; no Send/Submit review action taken.
- Publishing overview now has exactly two changes not yet submitted: Production
  `1.0.0 (11)` / Start full rollout, and Add 2 countries: Spain, Switzerland.
  Quick checks are running. Managed publishing remains **off**, so a later
  authorized review submission may publish automatically after approval.
- Console displays an informational EU geo-blocking notice. Google's linked
  distribution guidance says unjustified EU geo-blocking should be avoided and
  gives EU-wide access as the general example, subject to laws/exceptions.
  The applicability of an ES-only initial EU launch to this utility has NOT
  been resolved by the error-free preview. Review that scope before submission;
  do not silently expand the approved country set or claim legal clearance.
  Source: https://support.google.com/googleplay/android-developer/answer/6223646?hl=en
  The linked Commission page returned HTTP 429 during this check.
- Reviewer-access navigation text remains a local draft; no free-access
  attestation or app bypass was saved. Country approval is not Production
  publication approval. Next: resolve those review questions, inspect the
  whole pending batch and obtain a separate instruction before sending it.
- Evidence: ignored `.tmp/play-production-draft-20261020/ready-after-countries.txt`,
  `countries-and-release-pending.txt` and `.png`.

## Historical Production draft preparation — 2026-10-20

- Saved a **draft** Production release named `1.0.0 (11)` with the existing
  Play library artifact code 11 and en-GB first-public-release notes. No new
  upload/build and no review submission or rollout.
- Draft: `tracks/4697764149398062380/releases/1/prepare`. Track remains Inactive.
  Preview shows one blocking error: no countries/regions selected. Production
  now has this draft; earlier API snapshots showing no releases are historical.
- ES/CH selection is awaiting Luis's confirmation via the current question.
  No country settings have been saved. Do not infer confirmation from waiting.
- `docs/release-prep/production-release-plan.json` records the exact artifact,
  notes, proposed countries and pending gates. It is not an API request body.
- Factual reviewer-navigation wording is prepared in
  `docs/release-prep/reviewer-access-instructions.draft.md`. It does not provide
  free access to unowned paid features and was not saved/attested in Console.
- After country selection, recheck the preview and the whole Publishing overview
  batch. Final Production sending/publishing still requires a separate owner
  instruction; with managed publishing off, approval can make the app public.
- Evidence: ignored `.tmp/play-production-draft-20261020/`. No website deploy,
  price change, app edit or public release occurred in this preparation.

## Latest readiness/support checkpoint — 2026-10-20

Fresh API reads confirm Alpha 11, Internal 7, empty Production, the unchanged
code-11 AAB hash and correct ES/CH prices. Refreshed Chrome Console confirms
**Published** for submission 6 (Closed Alpha 11) and submission 5 (description
and Data safety). These reviews have finished; Production is not public.
Google Support replied in case **0-9999000042207**: no pre-compliance checks or
confirmation of reviewer sandbox purchases. Its instruction to await review
preceded the now-confirmed publication; do not keep a stale review-wait blocker.
Next: country decision, accurate reviewer-access instructions and separately
authorized Production submission. No new binary or duplicate support ticket.
Details: `docs/release-prep/play-console-final-review-2026-10-20.md`.

## Pasos para el primer lanzamiento público — 2026-10-20

Guía para Luis: **configurar → promover la versión 11 → enviar a revisión →
aprobación/publicación → activar el enlace en la web**.

Luis confirmó después **UE (27 países) más Suiza** y esa selección está guardada
junto con la versión 11, pendiente de enviar a revisión. La incertidumbre sobre
el acceso de revisores queda documentada; Google puede pedir correcciones.
Esta documentación no autoriza el envío a Producción.

### Qué significa el acceso a Producción ya concedido

Google nos permite solicitar un lanzamiento público. Eso no significa que
la app ya esté publicada ni que podamos omitir la revisión del lanzamiento.
La versión candidata es `1.0.0+11`, que Luis ha instalado desde cero y probado
en su Android físico. El artefacto exacto y su hash figuran más abajo.

### 1. Preparar el lanzamiento

- [ ] Revisar las instrucciones de acceso sin afirmar acceso gratuito no probado.
  Google no confirmó compras sandbox ni ofrece validación previa. Conservar la
  incertidumbre y atender cualquier petición de la revisión de Producción;
  la aprobación de Closed 11 no valida por separado ese mecanismo.
- [x] Confirmar con Luis **UE (27 países) más Suiza** y guardar su selección en Producción.
- [ ] Comprobar en Console la ficha, fotos, Data safety, clasificación, precios,
  declaraciones e instrucciones de revisión, incluido el estado de los cambios
  de descripción/Data safety ya enviados. No volver a enviarlos a ciegas.
- [x] Preparar el borrador con el **mismo AAB de la versión 11** desde Closed Alpha
  a Producción. Mover el mismo artefacto entre tracks no requiere recompilar ni
  incrementar la versión. Si hace falta cambiar la app, usar un nuevo código.

### 2. Enviar el lanzamiento a Google

- [ ] Revisar el resumen completo de cambios y la configuración de publicación.
  **Publicación gestionada estaba desactivada en la última comprobación.**
  Verificarlo de nuevo justo antes de enviar: la app podría hacerse pública
  automáticamente después de aprobarse. No prometer un botón manual posterior.
- [x] Obtener la autorización de Luis para enviar este lanzamiento a Producción,
  indicando versión, países y comportamiento de publicación.
- [x] Enviar a revisión (envío 7 confirmado). Google puede aprobar o solicitar correcciones. Las
  revisiones pueden tardar unas horas, hasta siete días o excepcionalmente más;
  no comprometer una fecha de disponibilidad.
- [ ] Verificar aprobación y disponibilidad pública real en Console y Play Store.
  Un estado API `completed` o una instalación de tester no bastan para probarlo.

### 3. Cuando esté pública

- [ ] Comprobar la ficha y la posibilidad de instalación pública sin ser tester
  para cuentas de Google Play de los mercados seleccionados (UE más Suiza).
- [ ] Cambiar la web de **Coming soon** a **Disponible en Google Play** y añadir
  el botón/enlace de descarga, siguiendo el paso S2 del plan de la web y su
  flujo de despliegue separado. Verificar el resultado público.

La distribución por países depende del **país de la cuenta de Google Play**,
no de la ubicación física momentánea. Los precios configurados para un país
no habilitan por sí solos la distribución de la app en ese país.

### Referencias oficiales consultadas el 20 de octubre

- [Publicar una app y estados de publicación](https://support.google.com/googleplay/android-developer/answer/9859751?hl=en)
- [Preparar y lanzar una versión](https://support.google.com/googleplay/android-developer/answer/9859348?hl=en)
- [Revisión y publicación gestionada](https://support.google.com/googleplay/android-developer/answer/9859654?hl=en)
- [Distribución por países](https://support.google.com/googleplay/android-developer/answer/7550024?hl=en)

## Owner phone acceptance — 2026-10-20, build 11

Luis reports uninstalling build 10, installing build 11 on his physical Android
phone, and that everything works well. Record build 11 as owner-accepted for
general use after a fresh installation. This is a direct owner report, not an
independently captured device log or a new automated test run. No itemized
repeat of all three purchases/Restore was stated for build 11; the explicit
Billing/Restore evidence remains the successful build-10 test record.

Preserve the exact code-11 AAB. Reviewer-access support response, current
Console review state and Production country selection remain separate items;
this acceptance does not authorize Production publication.

## Current candidate checkpoint — 2026-10-20, build 11

- Current app source is `1.0.0+11`. The recorded Closed Alpha upload succeeded;
  local and Play SHA-256 match. The saved post-upload API receipt lists Alpha
  code 11, Internal code 7 and no Production release. A subsequent refreshed
  Console check confirms submission 6 / Closed code 11 Published; API completed
  alone would not have established that result.
- Candidate source: `e7caca6`. Exact signed artifact:
  `.tmp/play-candidate/20261020-build11b/artifacts/app-release.aab`;
  SHA-256 `c39022153281a229e0faa0bc73fd786c3393967a99f6e22a78396bc892c5a98c`.
  Upload details are in the runbook's **Closed submission — build 11** section.
- Build 11 simplifies the Sources page in five languages and includes updated
  test expectations. The previous session recorded 476 passing tests and clean
  analysis. No tests/builds were rerun for this documentation reconciliation.
- Luis subsequently accepted build 11 after uninstalling 10 and installing 11
  on his physical Android; see the owner acceptance checkpoint above. Preserve
  its exact AAB; changed binaries require an unused higher version code.
- Recorded website deployment is `e181347` on 20 October, including the shorter
  headline/provider text, updated OG image and new terms page. Its deployment
  session recorded HTTPS and byte comparisons. Keep Coming Soon until Production
  is public; later docs-only pushes do not deploy the website.
- The description/Data safety submission and reviewer-access support ticket
  below remain historical evidence, not a fresh live review-state check.
  Recheck Publishing overview after the build-11 upload. Support has replied;
  see the latest readiness checkpoint above. Do not duplicate the ticket. Production countries
  still need an owner decision (initial ES/CH recommended).
- Luis chose to retain exchange-api without contacting its maintainer; the
  reasoning/evidence and future paid-provider plan are in `docs/providers/fawazahmed0.md`.
  This reconciliation records that decision without reopening or certifying it.
- Release tooling improvements remain plans, not implemented utilities:
  `docs/superpowers/plans/2026-10-20-release-tooling-friction-plan.md` and the
  sibling site's `docs/2026-10-20-release-tooling-plan.md`.

## Historical support ticket and metadata submission confirmed — 2026-10-20

- Luis approved sending the English reviewer-access question. Submitted through
  Console Help → Create support ticket → Google Play policies → App → policy
  question, scoped to Currency Converter Honest Fern. Console confirmed
  **Ticket submitted**, status **Pending**, **Case ID pending**. Replies go by
  email; the UI estimates two working days, sometimes longer. Do not create a
  duplicate ticket because an ID is not yet assigned.
- Console initially generated an AI recommendation suggesting promo codes,
  bypass/demo access. This is **not a human support determination**. Requested
  a support specialist to clarify native Play Billing test purchases and how
  single-use codes would satisfy reusable review access. No bypass, credential,
  promo code or app change was implemented. Wait for the actual support reply.
- The two metadata changes were still unsubmitted after the original quick
  checks. Rechecked the exact batch after checks finished, then submitted the
  en-GB description and Data safety only. Console now explicitly says
  **Changes in review** and **2 changes sent for review**. It shows another
  quick-check pass in the accepted submission flow. Do not submit again or
  cancel review; approval/public visibility is not yet confirmed.
- Production was not promoted or published. Build 10, website, prices and
  country settings were not changed. Reviewer access and Production country
  selection remain open. The earlier unconfirmed/unsent notes below are history.
- Evidence (ignored): `.tmp/play-support-20261020/submitted.txt`,
  `submitted.png`, `approved-request.txt`, `automated-suggestion.txt`;
  `.tmp/play-final-corrections-20261020/submission-confirmed.txt` / `.png`.

## Console corrections — 2026-10-20

- Luis asked to finish the remaining Console configuration and preserve a
  durable handoff. Using the owner Console, saved exactly two changes:
  en-GB full description and Data safety purposes. No app/web source, AAB,
  prices, Production track, countries or security settings changed.
- Description replaces the two ECB/daily-refresh sentences with: “Reference
  exchange rates and crypto prices are fetched online. The app shows the
  source date.” This correction is in **Google Play**, not another app edit.
- Data safety now maps the four existing SDK data types to analytics,
  advertising/marketing and fraud/security/compliance for collection/sharing.
  Removed developer communications/account management from Device IDs; added
  analytics to collected approximate location and advertising to diagnostics.
  Preview verified all eight purpose groups before saving. Other answers retained.
- Publishing overview showed exactly these two items. Clicked Submit 2 changes
  and confirmed Send changes for review. The immediate post-action view still
  showed quick checks and “Changes not yet submitted”; Submission activity had
  no new entry yet. **Do not claim review started or public text changed until
  live Console confirms it.** Recheck after quick checks; do not blindly resubmit.
- Reviewer access is still open. Console explicitly says reviewers cannot use
  personal accounts to make purchases. The Add details modal requires an
  attestation of full access including paid content. Explored Yes/Add details,
  then discarded all unsaved access changes; current saved answer remains No.
  No credentials, unlock code, free-purchase claim or access attestation supplied.
  Owner Billing tests passed; they do not prove Google reviewer access.
- A support question is drafted in the audit report. Permission to send a
  narrow clarification was requested; no support message has been sent.
- Countries remain unselected in Production. ES/CH recommended, owner selection
  pending. Production remains a separate explicit release instruction.
- Detailed audit and source links:
  `docs/release-prep/play-console-final-review-2026-10-20.md`.
  Evidence: ignored `.tmp/play-final-corrections-20261020/`.

## Historical final Console review — 2026-10-20

Read-only API/Chrome audit completed; see
[`play-console-final-review-2026-10-20.md`](docs/release-prep/play-console-final-review-2026-10-20.md).
Build 10 remains available in Closed and Production remains empty. All six
current gallery images match the reviewed manifest. No external changes were
saved/submitted during this audit. Before Production: correct Data safety
purposes, resolve reliable free access to paid features for Google reviewers
(current Sign-in details incorrectly says no restrictions), submit the prepared
listing wording correction, and select countries. ES/CH is recommended for
initial launch, awaiting owner decision. Keep existing source/privacy adequacy
questions open; Console’s no-issues status does not close them.

## Real-device acceptance — 2026-10-19, Closed build 10

- Console was subsequently checked: Closed Alpha `1.0.0 (10)` is **Available
  to selected testers**, released 19 Oct at 14:42. The earlier in-review
  snapshots below are historical. No Production promotion has occurred.
- Luis initially used the Internal link and saw old fixed CHF labels. After
  reinstalling from the Closed link he confirmed **2/3/1 CHF** in Settings and
  the same correct Google Play checkout price. His licence-test account showed
  the free test payment instrument. Do not count the Internal install as code-10 QA.
- Luis reports completing all requested real-phone checks successfully: three
  test purchases and their feature unlocks, relaunch persistence, reinstall and
  Restore, normal conversions/favorites/Charts including landscape, offline use
  after loading rates, and privacy links/controls. This is owner-reported manual
  acceptance, not an automated test run or an independently captured device log.
- Specifically, after uninstall/reinstall ads returned initially. Pressing
  **Restore purchases** recovered all three purchases and removed the ads again.
  Manual restoration passed; do not claim purchases auto-restored on reinstall.
- Keep the exact signed code-10 AAB/hash below. These results require no binary
  changes or rebuild. Final Console declarations/configuration and the open
  source/privacy adequacy findings still need review before the separately
  authorized Production promotion. Website S2 activation follows public availability.

## Original Closed submission — 2026-10-19, build 10

- Luis authorized submitting **1.0.0 (10)** to Closed Alpha (`alpha`) as the
  next public-release candidate. Upload, matching Google/local hash and fresh
  track verification succeeded. Console shows **Changes in review**, with
  quick checks running for code 10 / Start full rollout. No unrelated changes
  were pending before upload. Production is empty; Internal remains code 7.
- Source commit: `b28e9e67f6d50d0fa4d60c331a8c6aede3b280bf`. Signed AAB:
  `.tmp/play-candidate/20261019-build10/artifacts/app-release.aab` (54,683,454 bytes).
  SHA-256: `5ffcc01c221571ba55b20015fe0f3cbcfa5c27297b4db46bca3b34d66db98988`.
  Built on clean main with release_safe, developer mode false, real approved
  Android AdMob IDs and test ads false. Package/name/code, non-debuggable
  manifest, AdMob app ID and expected upload certificate verified.
- Includes the layered privacy/source help below and localized Play product
  prices. Settings queries the three existing products on entry/resume,
  hides stale prices while refreshing and shows descriptions alone if prices
  cannot be fetched. Purchase, entitlement and Restore flows are unchanged.
- Flutter analysis and signed AAB build passed. No automated tests ran for
  this preparation. The emulator still has the earlier test-ad preview;
  it is not evidence for this exact Play artifact or the localized price UI.
- Luis should update through the existing Closed link after approval:
  https://play.google.com/apps/testing/com.honestfern.currency_converter
  Until approval/propagation it can still serve code 9. Accept build 10 on the
  real Play device, including Settings prices, privacy links, Charts and normal
  use. Use the approved licence-test account for any Billing verification.
- If accepted, promote **this exact AAB** to Production with separate approval;
  no rebuild/version bump is needed. The approved regional pricing policy has been applied and verified
  (69 prices in 23 regions); see `stores/google-play/pricing/last-application.json`. Any binary correction instead needs a new unused version code.
- Website policies/images are already public from site revision `12d3cb8`.
  Keep Coming Soon until Production is public, then execute the site's S2
  download-link/availability change. Data-source/controller adequacy questions
  in the disclosure review remain open; this upload is not legal clearance.
- Receipts, provenance, manifest/signature and logs are in the ignored candidate
  directory above; `play-review.png` records the Console review state. Upload
  succeeded on the first attempt; no manual retry or review restart was needed.

## Historical local layered-help preview — 2026-10-19, build 10

- Luis approved concise, layered Data & privacy help and website policies.
  `pubspec.yaml` is now `1.0.0+10`; code 10 is a local candidate, not uploaded.
  Code 9 remains the Play-distributed Closed build. Luis reports installing
  the latest build; Console and Chrome storefront checks confirmed the new
  phone screenshots live. Production has no release at the latest API read.
- Data & privacy is two brief paragraphs and accessible Sources/policy/UMP
  links. Sources stay available in the app without network; project links open
  externally. The original direct policy and UMP Settings controls remain.
- History limits and mixed-chart weekend notes moved to chart-header help.
  No provider selection, SDK, permission, purchase or consent behavior changed.
- Five locales regenerated; Flutter analysis clean and normal release APK
  compiled with test ads for local preview. Evidence is under ignored
  `.tmp/privacy-layered-preview-20261019/`. No automated tests were run in this
  editorial/UI pass; exact Play acceptance will be needed for any new upload.
- Spanish Data & privacy was rendered using an isolated local entrypoint and
  visually checked (`app-data-summary-es.png`). Afterwards the normal app APK
  was restored on Medium_Phone; no app data was erased. This emulator already
  used the Android debug certificate, so separate device-preview copies were
  signed with that same local debug key. They are not Play upload artifacts.
  The canonical normal preview APK retains the ordinary release upload signing.
  The isolated renderer does not initialize UMP; the screenshot does not prove
  live consent behavior. Source review confirms the original UMP access stays.
- Website draft removes repetitive paragraphs and future hypothetical products
  while retaining the documented privacy facts and source/terms links.
  No website deployment, Play upload or Production promotion occurred.
- Provider terms were rechecked in the disclosure review: Frankfurter blended
  commercial use/cache have explicit support; direct ECB reuse is conditional;
  exchange-api's upstream crypto provenance remains unverified. No mail sent.

## Previously submitted Closed candidate — 2026-10-19, build 9

- Luis authorized preparing and submitting the latest app as the intended final
  candidate to **Closed Alpha**, not Production. Version is `1.0.0+9`.
- Source commit: `ca24985` (includes the five-language copy/privacy changes in
  `6990795`). Signed AAB: `.tmp/play-candidate/20261019-build9/artifacts/app-release.aab`.
  SHA-256: `d9c1d88199bffd892214e1cdb0ec2e9534c945179b54017717d98ad9488b39a2`.
- Built with `release_safe`, `APP_DEV_MODE=false`, real approved AdMob IDs and
  `ADMOB_USE_TEST_ADS=false`. Bundle manifest confirms package, name and code;
  signature verified and upload certificate matches the accepted code-8 bundle.
- Flutter analysis: no issues. Release AAB compiled successfully. Automated
  tests were not run in this preparation; prior QA does not establish code-9
  Play-device acceptance. Luis will install via the existing Closed link.
- Publisher API upload/hash comparison/commit/fresh-track verification passed.
  Console explicitly shows **Release 1.0.0 (9) in review**. Code 8 was confirmed
  Available to selected testers before submission. Until code 9 is approved and
  propagated, the tester link may still serve code 8. Internal remains 7 and
  Production is empty.
- Publishing overview shows the code-9 rollout and refreshed en-GB phone
  screenshots together under Changes in review (quick checks running).
  No separate review restart was performed. Evidence: `play-review.png` in
  the ignored candidate directory.
- Closed tester link (freshly checked in Console):
  https://play.google.com/apps/testing/com.honestfern.currency_converter
  The selected Closed list currently contains 22 entries; list size is not
  evidence of actual opt-ins. No tester selection was changed.
- Upload tooling now uses Google's HTTP transport to handle resumable HTTP 308
  correctly. A later transient 503 was followed by a fresh unused-code check;
  the successful transfer used the exact same AAB. Evidence is under the ignored
  candidate directory (`candidate.json`, `manifest.xml`, analysis/build/plan/upload logs).
- Public release, real-device acceptance and pending website copy deployment
  remain separate steps. The earlier code-8 checkpoint below is historical.

## Release checkpoint — 2026-10-19

- **Unreleased copy preview:** main now has shorter rate/data help and qualified
  privacy text in all five languages. These edits are not in the uploaded
  code-8 artifact. Any APK built from this working source for emulator review
  is a local test-ad preview, not a Play upload candidate. Assign the next
  unused version code when preparing the eventual new binary.

- Final data/disclosure recheck:
  `docs/release-prep/data-licensing-and-disclosure-review-2026-10-19.md`.
  Commercial-use evidence is recorded with its limits; do not treat old
  provider “safe/clean” labels as an unconditional legal clearance.

- Version `1.0.0+8` is uploaded to Closed testing → Alpha. The API reports
  release `1.0.0 (8)` with status `completed`; fresh status read confirms
  Internal remains at `1.0.0 (7)` and Production is empty.
  Console Publishing overview shows code 8 **in review**; last publication was
  2026-09-30 (code 7). API `completed` is not proof of tester availability.
- Six current-main portrait screenshots were saved to the en-GB listing on
  2026-10-19, with the Charts expand button visible. See the runbook for
  their current submission state and the versioned screenshot manifest.
- Candidate source commit: `e5df688`. AAB SHA-256:
  `ed492e6efcf32b7c0c7fb2ec983434a9bb8911a4a29a1d80315a66c0b1c11a87`.
- Production access was granted by Google, but no Production release has been
  created. Continue closed-track testing and app polishing before deciding on
  a Production candidate.
- The 2026-10-14 development checkpoint below is historical; code 8 is no
  longer only a local candidate.

## Historical development checkpoint — 2026-10-14

- Local candidate `1.0.0+8` on `codex/convert-currency-selection` preserves the
  Convert collection and last base, limits the top picker to saved currencies,
  locks Android phones to portrait, and aligns swipe actions and removal Undo
  across Convert and Favorites. `DESIGN.md` records the approved behavior.
- Release APK code 8 was built and exercised on the Pixel 7 emulator, including
  restart persistence, removal/Undo, portrait rotation and both swipe trays.
- Read-only Console verification: latest uploaded bundle is still code 7;
  Internal and Closed Alpha both serve `1.0.0 (7)`. Code 8 is not uploaded.
- Dashboard reports 12 testers opted in for 13 continuous days; production
  access application remains disabled. Recheck Console before applying;
  14 days is an eligibility threshold, not an automatic end or publication.
- Next release steps: review/merge the development branch, prepare and verify
  the signed AAB, then upload to the selected track with Luis's authorization.
  Keep testers opted in while awaiting eligibility and production-access review.

## Resume checkpoint — 2026-09-30

### Latest operational truth — 2026-09-30

- **Closed testing – Alpha is live:** Console shows Active and “Available to
  selected testers”, release `1.0.0 (7)`, released 30 September at 19:31.
  All 13 setup/listing/declaration/release changes were submitted with Luis's
  approval and subsequently published. Earlier “not submitted”, “in review”,
  “1/5 setup” and “no Closed release” snapshots are historical, not open gates.
- Internal also contains code 7. The accepted AAB came from `c21561d` with
  version bump `71f1d1a`; SHA-256:
  `1d8de98cecad06b16d5a5109eef6c4d7c365e5129043b8c35edbb627f448b1bf`.
  Closed reused the existing AAB from Play's library; no new binary was needed.
- Closed countries are Spain and Switzerland. Check the tester's Play account
  country, not only physical location, when diagnosing eligibility.
- **Closed list selection verified by navigating Console:**
  `Testers for Closed Test` (20 emails) selected; `Internal test email list`
  (2 emails) unselected. List names are user-defined; a list called “Closed”
  can also be used in Internal. Selection is separate for each track and for
  Licence testing. Multiple selected lists allow their combined accounts;
  duplicate emails do not represent additional testers.
- Luis reports two accounts previously joined Internal. He subsequently
  reports joining Closed and installing/using the app on a work Android phone.
  This is user-reported device evidence, not a verified Console cohort count.
  The latest actual Closed opt-in count and eligibility dates remain to check.
- **Next owner step: send invitations on 2026-10-01 (planned, not sent).**
  Give all authorized testers the Closed web opt-in URL below, ask them to
  accept with the listed Google account, install/update, use the app and send
  feedback. Play does not send these invitations merely because emails were added.
- Only `Billing test - work account` (1 account) is selected in account-level
  **Settings → Licence testing**. Console confirms changes saved, with
  `RESPOND_NORMALLY`. The 2- and 20-email lists are unselected there; ordinary
  Closed testers must not assume their purchases are free.
- **Billing verification remains open:** after this setting was saved, Luis
  still saw the real Visa checkout. No successful test-card purchase on that
  account has been verified. Test ads do not prove test billing. Do not confirm
  a real payment method for a no-charge test; use the troubleshooting steps
  in the publishing runbook. Private account details belong in ignored local notes.
- Six refreshed `1350×2400` phone screenshots were included in the published
  `en-GB` listing changes. API asset validation returned HTTP 403; the owner
  Console selected/saved them. Keep the publisher service account app-scoped.
- Website screenshots are deployed at `https://honestfern.com/`; capture waits
  for Favorites flags. Site stays Coming Soon until Production is publicly
  available. Closed availability does not authorize the public-site launch.
- No Production release or production-access approval is recorded. At least
  12 testers must remain opted in to Closed continuously for the preceding
  14 days, with real testing and feedback, before applying for access.

### Links and next-session checklist

| Purpose | Verified URL |
| --- | --- |
| Closed acceptance (send this to testers, also works on Android) | https://play.google.com/apps/testing/com.honestfern.currency_converter |
| Google Play installation/store page (“Join on Android”) | https://play.google.com/store/apps/details?id=com.honestfern.currency_converter |
| Internal acceptance/exit | https://play.google.com/apps/internaltest/4701596695392061996 |

The web link is app-specific because it includes the package name. Accept
Closed explicitly before following its installation link. Internal is optional;
do not send new Closed testers through Internal first. Existing Internal
participants must leave Internal and then accept Closed with the same account.

- [x] Closed Alpha release 7 live; Spain/Switzerland and selected 20-email list verified.
- [x] Separate one-account billing-test list saved in Licence testing.
- [ ] Verify test notice and test payment instrument on the work phone;
      test the three IAPs, relaunch and Restore without a real charge.
- [ ] Luis sends Closed opt-in invitations; verify every recipient is in a
      selected Closed list and uses that same Google account.
- [ ] Check Dashboard actual opt-ins and eligibility dates; record dated count.
- [ ] Gather real feedback, review crashes/pre-launch reports and fix regressions.
- [ ] Reach at least 12 continuously opted-in testers for 14 days, then apply
      for production access with truthful recruitment/feedback/change evidence.
- [ ] After access approval and Luis's explicit release instruction, verify
      production ads/UMP/Billing and the final artifact; submit Production.
      Do not assume the test-ad candidate is the final production configuration.
- [ ] After approved Production becomes publicly reachable, perform the site's
      S2 launch batch from `niduna-site/RELEASE_PLAN.md` with deployment approval.

## Historical checkpoint — 2026-09-14

### Latest operational truth — 2026-09-14

- Signed build `1.0.0` (`versionCode 6`) is published on the **Internal
  testing** track from commit `aad8249`. It keeps the provider-coverage/POL
  repair and adds the approved fresh-install defaults (EUR, GBP, JPY, BTC), no
  automatic extra crypto quotes, crypto-capable temporary Convert bases, and
  consistently collapsed currency groups.
- The upload was committed and verified through a fresh Android Publisher API
  edit on 2026-09-14. Release notes are “Refined default currency selection
  and crypto pickers.” and the AAB SHA-256 is
  `9f6c0464046b636fe0a3f66b74afa58217696e269477366a0f35addf51f5ed96`.
- Install and accept the exact Play-distributed `versionCode 6` before Closed
  testing. Do **not** promote superseded code 5. The provider remediation
  record remains `.agent/provider-coverage-remediation-plan-2026-09-12.md`.
- The default Play listing is `en-GB`. The new Honest Fern icon and six
  `1350×2400` phone screenshots are saved in the Play asset library and are
  selected in the default listing draft; the old selected icon/screenshots
  were removed. The listing changes are saved in Publishing overview but are
  not yet sent for review.
- The Play Publisher service account is app-scoped. Its API can commit the
  bundle/track update; Store presence edits were completed through the owner
  Console session because the API commit path returned `403` even after the
  app-level production-release permission was granted. Do not broaden access
  account-wide.
- The next operational step is to install and accept the exact Play-distributed
  `versionCode 6` on a real Android device. Do not rebuild it merely to change
  `versionName` later.
- A personal developer account still needs at least 12 continuously opted-in
  Closed-testers for 14 days before the production-access application; target
  14–16 testers for margin. Internal testing does not start that clock.

### Console checkpoint — 2026-09-10 (draft only)

- App repo HEAD: `4b3a544`; site repo HEAD: `9bc59bf`; root docs HEAD before this update: `ad79404`.
- Play Console draft `Currency Converter Honest Fern` has the final Honest Fern listing assets. The dashboard reports **10/11 setup tasks complete**; Data Safety and Advertising ID changes are saved but remain in Publishing overview until Luis explicitly sends them for review.
- Saved declarations: ads = yes, no restricted sign-in, content rating complete, government/financial/health declarations complete, category Tools, public contact `support@honestfern.com`, website `https://honestfern.com`.
- Data Safety now discloses the four AdMob SDK categories sent off-device: approximate location, app interactions, diagnostics, and device/other IDs. Advertising ID is declared **Yes**. This reflects third-party SDK behavior; Honest Fern has no first-party accounts or analytics.
- Target audience decision: **13+** (13–15, 16–17, and 18+; no under-13 group). Saved in Play Console as a draft on 2026-09-10. AdMob does not require an 18+ gate.
- AdMob is approved, real ad units are configured, and `https://honestfern.com/app-ads.txt` returns HTTP 200. No Play review, rollout, or release submission has been sent.
- Next gates: Data Safety, Advertising ID, and target age 13+ are saved in Publishing overview but not submitted. Play now exposes the real blocker: closed testing is 0/5 tasks.
- **Sequencing decision — 2026-09-12:** finish and merge the approved UI/asset
  branch first; refresh the current Play listing images; publish the resulting
  `1.0.0+4` candidate to **Internal testing**; and let Luis accept that
  Play-distributed build before creating the closed-test release and recruiting
  14 opted-in testers. This is an internal/closed-test preparation sequence,
  not public-production approval or a `1.0.0` version decision.
- Console navigation verified: **Testing → Closed testing - Alpha → Testers**. The existing `Internal test email list` contains 1 user; it is not selected for the closed track yet. The closed-track page can reuse that list or create a separate list, but every tester must opt in through the closed-track link.

**Read the latest operational truth above first. It supersedes contradictory
historical status and change-log entries below. Closed is now live; no
Production release is recorded.**

### Current evidence

- App `main` documentation baseline `78bffda`; real Billing commit `09f1166`.
  `pubspec.yaml` is **0.1.0+2**. Root/site/app were clean before the current
  documentation-only handoff; check all three repositories when resuming.
- `./scripts/check.sh` re-run 2026-09-10: **247 tests, clean analysis**, no
  lockfile mutation. The earlier lockfile drift is no longer an open change.
- Luis's update and the committed Console record say the billing-enabled
  **AAB 0.1.0+2 is published to internal testing**, with all three one-time
  products active. This audit did not independently inspect Console or match
  uploaded bytes to a local artifact. Do not recreate the app/products.
- Identity/device verification, app creation and merchant setup are recorded
  complete (E2/E3/E4/E8). Title: **Currency Converter Honest Fern**;
  Android ID `com.honestfern.currency_converter`; Console app ID
  `4973875544480645622`.
- Products: `remove_ads_lifetime` 1.99 CHF, `charts_pro_lifetime` 2.99 CHF,
  `favorites_pro_lifetime` 0.99 CHF, with regional prices in Console.
- AdMob E5/E5b completed in the console on 2026-09-10: Android app
  **Currency Converter Honest Fern**, App ID
  `ca-app-pub-1525645598421616~2391849252`, publisher ID
  `pub-1525645598421616`, Banner unit
  `ca-app-pub-1525645598421616/6412809148`, Rewarded unit
  `ca-app-pub-1525645598421616/7452604243`. European message **Honest Fern
  Europe Consent** is published with the public privacy URL and Consent,
  Manage options and Do not consent enabled. The AdMob payment profile is now
  complete, and AdMob reports the account approved with ad serving enabled.
- Diagnostic release APK/AAB builds succeeded on 2026-09-09. APK v2 signature
  and AAB JAR verification passed. These were pre-Billing diagnostic artifacts;
  never confuse them with the uploaded Billing artifact or a final candidate.
- Fresh-install smoke test on the release APK completed 2026-09-10 on
  `emulator-5554`: UMP consent, Manage options/Data preferences, Accept all,
  Settings Privacy options, base currency USD→CHF→USD, refresh, Favorites,
  Charts ranges, and light/dark mode all worked. The emulator was left in
  light mode with USD as the base currency. This does not replace Play Billing
  purchase/restore acceptance on the internal-testing track.
- This audit's visual evidence: normal release APK launched on
  `Small_Screen_API_36` (360x640 logical pixels); light Convert/Favorites/Charts
  inspected, daily text visible, test banner present. Captures in
  `.tmp/release-audit-20260909/`. Automated gallery stalled at Test starting.
  Complete four-tab light/dark, enlarged-text, offline and final Billing UI
  acceptance is **still pending**, despite older blanket pass claims below.

### Historical next action and ordered remaining work

The detailed bounded execution plan is `.agent/release-next-steps.md`. It
separates work Codex can execute locally from Play/AdMob actions that require
Luis and keeps upload/version/deploy gates explicit.

1. **Close this branch, then merge to `main`.** The approved UI/UX, chart,
   badge and trend-cache work belongs in the next internal candidate. Review
   the final diff and merge; do not add optional B7 product work to this batch.
2. **Regenerate the Play listing assets from merged current source.** The
   existing screenshots predate visible Chart/UI and badge changes. Capture the
   final approved Convert, Favorites and Chart surfaces at Play dimensions,
   select the canonical 2–8 PNGs, and replace the Console listing images. Keep
   the approved Honest Fern feature graphic unless a visible mismatch is found.
3. **Build and upload one new Internal-testing candidate.** Confirm code `3`
   is unused, set the internal candidate to `0.1.0+3`, run the official signed
   AAB build, record its SHA-256 and install/inspect that exact artifact. Upload
   it only to the existing Internal testing track; do not create a public or
   closed-test release yet.
4. **Luis's internal acceptance on the Play-distributed `0.1.0+3`.** Verify
   the refreshed UI/assets, UMP/privacy options, ad/no-ad behavior, the three
   one-time products and Restore on the actual opt-in build. Record device,
   account and artifact. If a release-blocking fault appears, return to this
   branch/main for a focused repair before any tester recruitment.
5. **Create the closed-test release from the accepted artifact, then recruit.**
   Choose countries and create/select the closed tester list, publish the
   accepted AAB to the closed track, obtain its opt-in link, and recruit at
   least 14 testers (target 15–16 for margin). Each person must opt in and stay
   enrolled for the required continuous period; internal testers do not count.
6. **Keep public launch separate.** Before production access/review, recheck
   live Play requirements and complete the remaining public-release acceptance
   (including Data Safety/Advertising ID publishing status and the final
   accessibility/offline/no-fill evidence). Site S2 still waits for a public
   Play URL.

### Version, authority and scope

Code 2 has already been uploaded. **A new binary needs an unused code >= 3**.
The first public version name is `1.0.0` only after validation: use `1.0.0+3` if 3
is still unused; otherwise the next available higher code. Interim diagnostics
may stay 0.x. The old `1.0.0+2` target is superseded. Track promotion of the same
artifact is separate from uploading a new binary.

Current authorization: The Internal candidate has already been uploaded. Any
new version bump, Closed-test submission, review submission or production
publication still requires a concrete artifact review and explicit approval.
Preserve Honest Fern public branding; legacy Niduna folder/repo/keystore names
are technical, not grounds for a wholesale rename. No backend, accounts,
first-party analytics, OXR/VPS service, CoinGecko, subscriptions or iOS release.

Older tables and change logs are history where they disagree with this checkpoint.

## Brand migration boundary

The repository-side migration is complete for the active app surfaces:

- Android namespace/application ID: `com.honestfern.currency_converter`
- iOS Runner bundle ID: `com.honestfern.currencyConverter`
- iOS App Group: `group.com.honestfern.currencyConverter`
- Widget target/type names: `HonestFernWidget`, `HonestFernCurrencyWidget`,
  and `HonestFernAppWidgetProvider`

The following are later console or credential operations, not local renames:

- Register the new Android application ID and iOS bundle/App Group IDs in the
  relevant store/developer consoles, then issue matching signing/provisioning
  resources.
- Recheck AdMob/Firebase/Play Billing configuration against the real external
  records before release. The existing Firebase project
  `currency-converter-by-niduna` and existing signing keystore/alias names are
  intentionally preserved until an authorized external migration exists.
>
> **~~Open decision~~ RESOLVED (2026-07-16): "Coming Soon" subscription teasers removed** — the Settings "Subscription · Coming Soon" tile, the Charts locked intraday chips (1H/6H/1D + premium snackbar), and the Convert info-sheet "faster updates / future Premium subscription" line are gone from the UI on all platforms (no platform gating). Entitlement plumbing kept for Phase 2. Verified on emulator light+dark, 239 tests pass.
> **Historical 2026-06-02 note:** iOS widget code was merged while simulator
> installation was blocked by the Xcode 26 simctl issue. The current checkout
> has the renamed target and embed phase wired; real-device verification still
> requires signing. See "Blocker Summary" below.
> **2026-06-01 update:** Backend work deferred until post-publish. Code-only path: see "Code-Only Pre-Flight" below. Full detail in `docs/superpowers/plans/2026-06-01-post-phase-ad-next-steps.md`.
> **2026-06-02 review:** see `docs/REVIEW-2026-06-01.md` for the full audit.

---

## Phase 0 — Release re-entry and toolchain preflight

This phase was added after the project had been idle for more than a month.
It prevents a broad SDK/package upgrade from being mixed with the release
implementation and records the current environment before external work starts.

- [x] **Repository baseline** — before this documentation update, both
  release repos were clean on `main` and synchronized with `origin/main`
  (verified 2026-08-28). The current working-tree changes are the intentional
  plan updates from this review.
- [x] **Toolchain audit** — Flutter `3.41.7` / Dart `3.11.5`, Android SDK 35,
  Java 21, Xcode 26.6 and CocoaPods 1.17 are installed and `flutter doctor -v`
  reports no issues. Flutter `3.47.2` is available, but is not a release
  prerequisite.
- [x] **Dependency audit** — the locked baseline resolves; conservative and
  major upgrade dry-runs were inspected without changing `pubspec.yaml`.
  Do not run `flutter upgrade` or a global `pub upgrade --major-versions` as
  part of the release.
- [x] **Dart verification** — `flutter analyze` and `flutter test` pass with
  239 tests (verified 2026-08-28).
- [x] **Android release-build revalidation** — `./scripts/build_appbundle.sh
  --verbose` completed successfully on 2026-08-28 after Gradle repopulated its
  local dependency cache. The diagnostic AAB is signed and verifies, but is not
  publishable because it still uses test AdMob IDs and the purchase stub.

### Dependency policy for this release

- Keep Flutter `3.41.7` and the current lockfile as the working baseline unless
  a controlled compatibility test justifies an isolated SDK upgrade.
- Update packages selectively, in the task that needs them, with tests and a
  native build afterward. B8 may update `google_mobile_ads` if the UMP API or
  native SDK requires it; B9 adds the official `in_app_purchase` dependency.
- Minor or transitive updates are optional and must not be bundled into the
  release without a clear reason and fresh verification.
- Do not regenerate iOS Pods or release binaries merely because time passed.
  Regenerate native dependencies after relevant dependency changes, and build
  the final AAB only after B4/B8/B9, key rotation and the versionCode bump.

---

## Historical Code-Only Pre-Flight (reference only)

This section is the agent's agreed order. The rest of this file is the human-paced release flow (external steps + content steps + final upload).

| # | Item | Sub-item | Status | Commit |
|---|---|---|---|---|
| 1 | Fix 10 pre-existing test failures | — | ✅ Done | `6ac7c8e` (setUp fixes), `4a45cc4` (widget) |
| 2 | Visual verify Phase A-D | — | ✅ Done | `5491ea7` (range selector polish) + `1328338` (8 screenshots) |
| 3 | Dark mode audit | — | ✅ Done | `5491ea7` (decimal places dark contrast) |
| 4 | Release keystore trio | B1: generate keystore | ✅ Done | `200c888` |
| 4 | Release keystore trio | B2: `android/key.properties` | ✅ Done | `200c888` |
| 4 | Release keystore trio | B3: `build.gradle.kts` release signing | ✅ Done | `200c888` |
| 5 | Phase 1.x chart tests | crypto/crypto + fiat/crypto formulas | ✅ Done | `8a76058` (4 new tests) + `f65ef5e` (real logic fix) |
| 6 | Privacy link in Settings | B5: new row in Settings widget | ✅ Implemented locally 2026-08-30 — `url_launcher` opens `https://honestfern.com/currency-converter/privacy/` | Pending commit/release candidate |
| 7 | Build signed AAB | B6: `./scripts/build_appbundle.sh` smoke | ✅ Done | AAB at `build/app/outputs/bundle/release/app-release.aab` (53.4 MB, signed and verified 2026-08-30) |
| 8 | UI Polish cycle (Phase 6) | open | ✅ Done (range selector + decimal places) | `5491ea7` |

**Historical note:** this table predates B8/B9 and must not be used as the
current release order. Open release work is listed at the top of this file.

**Branch:** All this work is on `main` (merged from `release-prep` in commit `19f68b3`). The `release-prep` branch is kept around as a reference.

---

## Single Source of Truth Index

| Document | Purpose | Status |
|----------|---------|--------|
| **This file** | **Consolidated release checklist — start here** | — |
| `../../niduna-site/RELEASE_PLAN.md` | Site-only subplan; must agree with this file | Active |
| `docs/release-prep/play-store-listing.md` | Reviewable English listing draft | Active |
| `docs/RELEASE_COMMANDS.md` | Commands only; not an ordering source | Active |
| `docs/providers/frankfurter.md` | Fiat provider: license, endpoints, refresh cadence | Done |
| `docs/providers/fawazahmed0.md` | Crypto provider: license, CDN, history approach | Done |
| `docs/providers/coinpaprika.md` | Dev-only provider: why it's blocked for production | Done |
| `.plan/PLAY_STORE_PUBLISH_CHECKLIST.md` | Detailed Play Console field-by-field reference | Done (may need minor updates below) |
| `.plan/APP_STORE_PUBLISH_CHECKLIST.md` | App Store checklist (deferred — Android first) | Deferred |

---

## Current external references — re-check on execution day

Store and SDK requirements change. These primary sources support the current
ordering and declarations in this checklist:

- [Production access for new personal accounts](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en)
  — closed-test eligibility, tester count and duration.
- [Create and set up the store listing](https://support.google.com/googleplay/android-developer/answer/9859152?hl=en-EN)
  — listing fields, limits and translations.
- [Data Safety guidance](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en)
  and [Google Mobile Ads SDK disclosure](https://developers.google.com/admob/android/privacy/play-data-disclosure)
  — declarations must include SDK behavior.
- [UMP for Flutter](https://developers.google.com/admob/flutter/privacy) —
  consent refresh, `canRequestAds` gating and privacy-options entry point.
- [Payments profile](https://support.google.com/googleplay/android-developer/answer/7161426?hl=en)
  and [one-time products](https://support.google.com/googleplay/android-developer/answer/1153481?hl=en)
  — catalog setup, immutable IDs, pricing and Billing permission.

If Play Console shows a stricter or account-specific task, follow the Console
and update this checklist before proceeding.

---

## Release reference tables — dated evidence and remaining Production gates

The 2026-09-30 checkpoint above controls execution. Historical dated notes
are not instructions to recreate accepted resources; verify still-open
Production/device/security tasks separately before a public release.

### External Steps (you do these outside the codebase)

| # | Task | URL / Notes | Status |
|---|------|-------------|--------|
| E1 | Register Google Play Developer account ($25 one-time) | https://play.google.com/console | ✅ Paid and onboarding started 2026-08-30 |
| E2 | Verify developer identity (required since 2026) | In Play Console | ✅ **Complete (verified 2026-09-09); a real Android device is also verified with the account** |
| E3 | Set up the payments/merchant profile — **launch-critical since 2026-07-16** (required before E8 in-app products can be created; needs bank details for payouts) | Play Console > Setup > Payments profile | ✅ **Done 2026-09-09** — merchant profile completed (Individual, legal name, `honestfern.com`, `support@honestfern.com`, statement name "Honest Fern", category Computer Software), IBAN payout method added, and the "Honest Fern" account group created for the 15% service-fee tier (accept the tier T&C when Console prompts it) |
| E4 | Create app in Play Console (draft mode) | ✅ **Done 2026-09-09** — app created as "Currency Converter Honest Fern" (title per C2); Play Console app ID `4973875544480645622`; application ID `com.honestfern.currency_converter`. Draft publishes nothing. Unblocks E6 and E8. | ✅ |
| E5 | Register AdMob account + create ad units | https://admob.google.com | ✅ **Done 2026-09-10** |
| E5b | AdMob → Privacy & messaging → create the GDPR consent message (required for EEA/UK/CH ads; pairs with code step B8) | In AdMob console, after E5 | ✅ **Done 2026-09-10** |
| E5c | Publish `app-ads.txt` on honestfern.com with the AdMob publisher ID from E5 | Site-side step — `niduna-site/RELEASE_PLAN.md` § S1.5 | ✅ **Deployed 2026-09-10** — Hostinger release `77ac413b590e07768b2e4a3fb8858fe101afecba`; public URL returns HTTP 200. AdMob crawl remains pending. |
| E6 | Complete the trader-status / verified-public-contact task shown by Play Console for EU distribution. Use truthful personal details and review exactly what Play says will be public before submitting. | Play Console → App content, after E4 | ❌ |
| E7 | Closed test: at least 12 continuously opted in for 14 days, real usage/feedback, then production-access application | Dashboard eligibility; E7 playbook below | 🟡 Closed release live; invitations planned 2026-10-01, cohort count/duration not yet verified |
| E8 | **Finalize IDs, create and activate three one-time products in Play Console** — Remove Ads 1.99 CHF, Charts Pro 2.99 CHF, Favorites Pro 0.99 CHF. IDs cannot be changed/reused, so decide them before B9; suggested: `remove_ads_lifetime`, `charts_pro_lifetime`, `favorites_pro_lifetime`. Requires E3/E4. If Console does not expose product creation yet, implement B9 with those final IDs and upload the billing-enabled bundle to internal testing first; then create/activate the products before purchase testing or the closed track. | Play Console → Monetize with Play → Products → One-time products | ✅ **Done 2026-09-09** — all three products created and ACTIVE with the exact planned IDs (Digital app sales tax category, All ages, all regions priced via bulk edit from CHF base). Unlocked after the `0.1.0+2` billing-enabled AAB was published to internal testing. |

> **Publishing identity (decided 2026-07-11 — "Pegolandia model", see
> `Niduna/docs/strategy/Honest_Fern_Company_Options_CH_vs_US.md` Option 0 and
> `Reprocess_deprecated/Pegolandia_Style_Brand_First_App_Portfolio_Plan.md`):**
> publish as an **individual**, no company registered. "Honest Fern" is the
> brand (app names, icons, website, © notice); the verified **legal
> name** is what Google shows in "About the developer" for personal
> accounts created after Nov 2023 — plus address/email/phone in the EU
> via E6. Expect the store listing to show the personal name, exactly
> like the reference developer's Apple listing does. Guardrails from the
> strategy doc: never claim GmbH/LLC/Inc., never fake an address, keep
> store/payment identity truthful; the *website* stays brand-first. The
> site's privacy page (Contact & controller section, 2026-07-11) states
> the individual-developer status and defers the publishing name to the
> store listing.

### Code / Build Steps (agent can do these)

| # | Task | File(s) | Effort | Status | Commit / Note |
|---|------|--------|--------|--------|---|
| B1 | Generate release keystore | N/A (external file) | ~10 min | ✅ **Done** | `200c888` — at `android/app/niduna-upload.jks` (RSA 2048, 10000-day, valid until 2053) |
| B2 | Create `android/key.properties` (gitignored) | `android/key.properties` | ~5 min | ✅ **Done** | `200c888` — ⚠️ **password is TEMP, must be rotated before publish** (see Keystore note below) |
| B3 | Update `build.gradle.kts` release signing config | `android/app/build.gradle.kts` line ~37 | ~10 min | ✅ **Done** | `200c888` + local 2026-08-30 hardening — release build now fails closed if `key.properties` or the keystore is missing |
| B4 | Replace AdMob test unit IDs with real ones | `lib/src/core/ads/ad_helper.dart`, `android/app/build.gradle.kts`, `ios/Runner/Info.plist` | ~15 min | 🟡 **Production build ready; Play store link/app review open** | Real Android IDs are available through the existing release env path; development defaults remain Google's test IDs. AdMob approval and ad serving are enabled, but AdMob still shows `Requires review` / `Add store to lift limit` until the app has a linkable Play store listing. |
| B5 | Add privacy policy link in Settings screen | Settings widget (natural spot: the merged "Data & privacy" page) | ~30 min | ✅ **Implemented and committed 2026-08-30** | Commit `7aed7b1`; `url_launcher` opens `https://honestfern.com/currency-converter/privacy/`. Needs inclusion in the next release candidate. See `niduna-site/RELEASE_PLAN.md` § S1. |
| B6 | Final signed AAB | `scripts/build_appbundle.sh` | — | Code 7 serves Closed; final Production configuration still to verify | Preserve the accepted hash above. Any changed binary needs the next unused code (8 or higher), QA and approval. |
| B7 | Upload/promote AAB | Play Console / Publisher API | — | Internal and Closed code 7 complete | Closed live 2026-09-30; Production is still pending and needs approval. |
| B8 | **UMP consent flow + privacy options** | Ads init path (`lib/src/core/ads/`), uses `ConsentInformation`/`ConsentForm` from `google_mobile_ads` | ~2-3 hr | 🟡 **Implemented; production-device verification open** | `AdConsentManager` requests consent on launch, shows the published form when required, gates banner/rewarded requests on `canRequestAds`, and exposes Privacy options in Settings. The internal-test device loaded a confirmed AdMob test banner; the production-ID build still needs a Play-distributed device check. |
| B9 | Real Play Billing/restore | `play_purchase_service.dart`, purchase UI, settings | — | **Implemented and device-accepted; final edge cases open** | Internal-test account purchased all three active products, verified each entitlement, relaunched the app, and ran Restore without an error. Reinstall/restore and cancel/pending edge cases remain optional final checks. |

> **⚠️ Keystore password rotation (NEW — 2026-06-02):**
> The keystore was generated with a temporary password for this dev cycle.
> **Before publishing**, rotate the password:
> ```bash
> keytool -storepasswd -keystore android/app/niduna-upload.jks
> keytool -keypasswd -keystore android/app/niduna-upload.jks -alias niduna_currency_converter_upload
> ```
> Then update `android/key.properties` with the new passwords, and delete
> `/tmp/niduna_temp_keystore_pwd.txt` (the temp password file).
> See `docs/RELEASE_COMMANDS.md` § "Keystore management" for full steps.
>
> **⚠️ Keystore BACKUP (added 2026-07-11 — do right after rotation):**
> `android/app/niduna-upload.jks` and `key.properties` are gitignored and exist on
> ONE machine only. After rotating: store a copy of the .jks + both
> passwords in a password manager, plus a second copy off-machine
> (encrypted USB / private cloud). Losing the upload key doesn't kill
> the app (Play App Signing can reset upload keys) but costs days of
> support friction; losing it before first upload costs nothing to
> prevent now.

### Content / Metadata Steps

| # | Task | Specs | Effort | Status |
|---|------|-------|--------|--------|
| C1 | Write & host privacy policy page | Page is built, deployed and GDPR-prepared. The app-specific policy at `https://honestfern.com/currency-converter/privacy/` is live on the Hostinger production host; the general portfolio policy remains at `/privacy/`. The same URL was saved in Play Console App content on 2026-09-10; the review changes published with Closed on 2026-09-30. See `niduna-site/RELEASE_PLAN.md` § S1. | — | ✅ Done |
| C2 | App title (max 30 chars) | Note: Play does NOT require unique titles (Apple does) — the brand suffix is for identity and future-Apple reuse, not Play uniqueness | ~10 min | ✅ **Decided 2026-09-09 and entered in Console: `Currency Converter Honest Fern` (30/30)** — product-first/brand-last (the "Kids Memory Pegolandia" pattern); same title planned for the future App Store release. Full rationale in `docs/release-prep/play-store-listing.md` § 1. |
| C3 | Short description (max 80 chars) | Example: *"45 currencies & crypto. Private, offline, no account."* (the app supports exactly 45 — do NOT claim 170+) | ~15 min | ✅ Included in published setup/listing changes 2026-09-30 |
| C4 | Full description (max 4000 chars) | Features, privacy notes, Honest Fern differentiator | ~45 min | ✅ Included in published setup/listing changes 2026-09-30 |
| C5 | Phone screenshots (min 2, max 8) | Six refreshed 1350×2400 copies from 2026-09-30 captures, selected in en-GB | — | ✅ Included in published listing changes |
| C6 | Feature graphic (1024x500) | `docs/release-prep/feature-graphic.png` | — | ✅ Honest Fern graphic approved for listing preparation | Replaced the obsolete NIDUNA / Coming to Android / No tracking / 100% Offline graphic. Product UI remains represented by the separate store screenshots. |
| C7 | Content rating questionnaire (IARC/CERT) | In Play Console > Policy > App content | ~15 min | ✅ Included in published setup/listing changes 2026-09-30 |
| C7b | **Target audience declaration — declare 13+** (added 2026-07-11) | Separate from C7! In App content → Target audience. Declaring ANY under-13 age group triggers the Families Policy (certified ad SDKs only, ad limits, stricter review) — wrong fit for an AdMob-funded utility. Content rating "Everyone" (C7) and target audience "13+" are compatible and both correct here. | ~5 min | ✅ Included in published setup/listing changes 2026-09-30 |
| C8 | Data Safety form | Match actual behavior: HTTPS calls, local storage, zero PII collected by us — **but the AdMob SDK must be declared** (device/advertising identifiers, ad interaction data; see the "Third-party SDKs" table below). Align answers with the consent setup from B8/E5b. | ~30 min | ✅ Included in published setup/listing changes 2026-09-30 |
| C9 | Category selection | Tools app | ~2 min | ✅ Published with Closed setup 2026-09-30 |
| C10 | Contact email + website + privacy URL | Required fields in Console listing. `support@honestfern.com` receives and sends mail — email setup is `niduna-site/RELEASE_PLAN.md` § S1.4 | ~10 min | ✅ Included in published setup/listing changes 2026-09-30 |
| C11 | Localized listings (DE, ES, IT, FR) | Optional post-launch optimization; Play can serve the default English listing/automatic translation | ~1 hr | ⏸ Optional |

---

## Implementation Notes — exact clues per open step (2026-07-08)

### B4 — Real AdMob IDs (mostly env vars, almost no code)
The IDs flow through the build, not the source:
- **Ad unit IDs** are read via `String.fromEnvironment` in
  `lib/src/core/ads/ad_helper.dart` and injected as `--dart-define`s by
  `flutter_app_define_args` in `scripts/common.sh:93`. Set env vars
  `ADMOB_ANDROID_BANNER_AD_UNIT_ID` + `ADMOB_ANDROID_REWARDED_AD_UNIT_ID`
  when running `./scripts/build_appbundle.sh`.
- **`ADMOB_USE_TEST_ADS` defaults to `true`** (`scripts/common.sh:96`,
  `ad_helper.dart:6-9`) — the release build command MUST set
  `ADMOB_USE_TEST_ADS=false` or real IDs are ignored.
- **Android app ID**: env var `ADMOB_ANDROID_APP_ID` →
  `android/app/build.gradle.kts:43-45` (manifest placeholder; falls back
  to Google's test app ID `~3347511713`).
- **iOS app ID**: hardcoded test ID at `ios/Runner/Info.plist:28`
  (`GADApplicationIdentifier`) — only matters for the deferred iOS release.
- **Android production values recorded 2026-09-10:** app ID
  `ca-app-pub-1525645598421616~2391849252`, banner
  `ca-app-pub-1525645598421616/6412809148`, rewarded
  `ca-app-pub-1525645598421616/7452604243`. They are intentionally passed at
  release-build time; source and development builds keep Google's test IDs.
- Suggested: keep the real values in a gitignored `.env.release` sourced
  by the build scripts, and document the final command in
  `docs/RELEASE_COMMANDS.md`.

### B5 — In-app privacy link
- Implemented locally on 2026-08-30: `url_launcher` is now a direct
  dependency and Settings exposes a "Privacy" row in the merged Data section.
- The row opens
  `https://honestfern.com/currency-converter/privacy/` with
  `launchUrl(..., mode: LaunchMode.externalApplication)`.
- The link has a widget presence test. Final wording/Data Safety alignment
  remains part of the B8 AdMob/UMP pass.

### B8 — UMP consent flow (after E5b creates the console message)
- Implemented 2026-09-10 in `lib/src/core/ads/ad_consent_manager.dart`.
  `AppShell` starts the UMP sequence in the background; the manager calls
  `ConsentInformation.requestConsentInfoUpdate(...)`, loads and shows the
  form when required, initializes Mobile Ads only after `canRequestAds`, and
  exposes `showPrivacyOptions()` through the Settings Data & privacy page.
  Banner and rewarded requests both await the same gate. Desktop/widget-test
  platforms skip the mobile channel so the test suite remains deterministic.
- **Decision resolved:** both banner and rewarded code already use
  `AdRequest(nonPersonalizedAds: true)`. Keep that behavior. UMP is still
  required, and the app must expose a privacy-options entry point when
  `getPrivacyOptionsRequirementStatus()` says it is required.
- Test with UMP debug geography = EEA on the emulator/device
  (`ConsentDebugSettings(debugGeography: DebugGeography.debugGeographyEea,
  testIdentifiers: [...])`) before trusting it.

### B9 — Real Play Billing: implemented and internal-device acceptance recorded

`09f1166` adds `in_app_purchase`, injects `PlayPurchaseService` into AppShell,
uses the three active non-consumable IDs, listens for purchase/restore events,
and applies local entitlements. Settings now requests restore from Play.
The production AppShell no longer uses the default stub.

Do not redo the implementation or product setup. The Play-distributed internal
build was installed on the Android work phone with the configured licence-test
account. `remove_ads_lifetime`, `charts_pro_lifetime`, and
`favorites_pro_lifetime` all completed successfully and their entitlements
were verified. The app was relaunched and Restore purchases completed without
an error; the benefits remained available. Reinstall/restore and cancel,
pending, and error paths remain useful final edge-case checks.

### E7 — Closed-testing playbook (12 testers / 14 days)

At least 12 testers must have been continuously opted in to Closed for the
14 days preceding a production-access application. Email-list size, Internal
installs and release publication time do not establish this requirement.
Use Dashboard eligibility, not a guessed date. Additional people can join
while the test runs; their own uninterrupted period begins at opt-in. Adding
people does not erase existing participants' history, but a late replacement
cannot supply another person's missing days.

For this app, preparation and publication are complete; use the latest
checkpoint above rather than creating another track/release. For future apps:
configure declarations/listing, selected tester lists and Play-account countries,
promote the accepted artifact, submit required review changes with approval,
and verify “Available to selected testers” before distributing the opt-in URL.

Send the web acceptance link to genuine testers; they use the authorized
Google account, accept, then install from Play. Existing Internal participants
must leave Internal first. Invite more than 12 for margin. Ask people to use
Convert, Favorites, Charts and Settings and report problems; passive installation
alone is not adequate evidence of engagement. No specific daily-use quota is
promised by this guide. Do not count extra devices as extra genuine people.

Monitor dated opt-in counts and feedback, crashes and pre-launch reports.
If fixes are needed, use a higher unused version code on the same Closed track
with normal QA/release approval. Use Licence testers for no-charge IAP QA;
never tell all Closed testers their purchases are automatically free.

Once eligible, apply for production access and answer the testing/readiness
questions accurately. Google may request more testing; access is not automatic
and does not itself publish the app. Production submission/review and the
public website launch remain later gates with explicit approval.

Sources checked 2026-09-30:
[testing requirements](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en),
[test-track setup](https://support.google.com/googleplay/android-developer/answer/9845334?hl=en).

### Keystore rotation — commands are in the callout above; afterwards
re-run `./scripts/build_appbundle.sh` (B6) and confirm the AAB signature
with `jarsigner -verify` or `apksigner`.

### C2-C4 — Default English listing copy
- Use `docs/release-prep/play-store-listing.md` as the reviewable master
  before pasting into Console. DE/ES/IT/FR listings are optional after launch;
  the app ARB files are the vocabulary reference if they are added.
- Facts to respect: **45 currencies (34 fiat + 11 crypto)** — count is
  from `lib/src/core/currency/supported_currencies.dart`; rates update
  once daily; free = full converter + charts, one-time IAPs remove
  ads/unlock extras. Trust line from `docs/FEATURE_IDEAS.md`: "One
  purchase, forever. No subscription. No account."

### C7-C10 — Console forms (click-paths)
- **C7 rating**: Console → Policy → App content → Content rating
  questionnaire. Utility/finance answers: no violence, no UGC, no data
  sharing between users → expect Everyone/3+.
- **C8 Data Safety**: answers pre-written in this file § "Privacy
  Policy — What To Disclose" + § "Data Refresh Cadence". Plus AdMob:
  declare "Device or other IDs" (advertising ID), purpose Advertising,
  collected-not-shared-by-us, per the consent setup chosen in B8.
- **C9**: Category = Finance (no financial-features declaration needed —
  see § "Financial Features Declaration").
- **C10 values**: verified email `support@honestfern.com` (site plan S1.4),
  website `https://honestfern.com`, privacy
  `https://honestfern.com/currency-converter/privacy/`, marketing URL
  `https://honestfern.com/currency-converter/`.

---

## Already Done ✅ (no action needed)

### Provider licensing — current evidence and limits (2026-10-19)

Read `docs/release-prep/data-licensing-and-disclosure-review-2026-10-19.md`
before a public readiness claim. Current software/data terms are separate;
CC0 does not clear unknown upstream third-party rights. 2026-10-20 owner
decision: exchange-api stays; legal exposure low (vendor terms bind the
maintainer, not us), material risk is crypto data availability. See
`docs/providers/fawazahmed0.md`. Privacy copy also needs
qualified local-storage language and concrete controller/SDK disclosures.
The old blanket “clean” label is superseded by the dated review.


| Provider | Role in release builds | License | Commercial OK? |
|----------|----------------------|---------|---------------|
| **Frankfurter** | Blended fiat latest/history | MIT software; underlying data terms separate | Official FAQ permits blended commercial use/cache; see review |
| **fawazahmed0** | Crypto latest/history | Published CC0-1.0 | Yes for our use; upstream likely CMC paid API (maintainer's contract). Risk = availability, accepted 2026-10-20 |
| CoinPaprika | Dev/emulator builds only | Proprietary (commercial forbidden) | **NO — not shipped** |

Release build profile (`release_safe`) uses only Frankfurter + fawazahmed0.
Build-time guard crashes if release build attempts non-safe profile.
See `docs/providers/*.md` for full per-provider details.

### Code Complete

| Item | Evidence |
|------|----------|
| All 34 fiat currencies + 11 crypto | `supported_currencies.dart`, multi-provider repo |
| Client-side conversion (`amount × rate`) | Convert controller |
| Historical charts (fiat 2Y, crypto 1Y) | Charts controller + fawazahmed0 date-file client |
| Favorites (max 3, local storage) | FavoritesStore wired |
| Offline mode / cache persistence | Cache per base/range; stale fallback works |
| Dark mode (system-follow + toggle) | AppTheme + Settings |
| Real AdMob SDK (`google_mobile_ads`) | BannerAd + RewardedAd integrated; test-mode only until real IDs |
| IAP purchase UI + entitlement system (⚠️ payment itself is STUBBED — real billing is open step B9, added 2026-07-16) | PurchaseServiceStub, IapPurchasePlayer |
| i18n (EN, DE, ES, IT, FR) | ARB files + generated localizations |
| Branded app name ("Currency Converter") | Committed `bade57e` |
| iOS deployment target 15.0 | Committed `bade57e` |
| Release APK + App Bundle builds | `scripts/build_apk.sh`, `scripts/build_appbundle.sh`; AAB smoke revalidated 2026-08-30, final build remains gated on release-code changes |
| Firebase hosting deploy pipeline | `scripts/firebase_hosting_*.sh` |
| Latest direct verification | 247 tests, clean analysis, `./scripts/check.sh`, and a signed 54.1 MB local test-ad AAB (`0.1.0+2`) on 2026-09-10; final AAB still follows real-ID wiring, device UMP/Billing acceptance, key rotation and versionCode bump |

### Provider Profile System — Correctly Segregated

| Profile | Used by | Crypto Latest | Crypto History | Shipped in stores? |
|---------|----------|--------------|---------------|------------------|
| `release_safe` | Release APK/AAB, Firebase hosting | **fawazahmed0 only** | **fawazahmed0 only** | **YES** |
| `dev_coinpaprika` | Emulator, debug builds | CoinPaprika → fawazahmed0 fallback | **CoinPaprika** | NO (dev only) |

Controlled via `PROVIDER_PROFILE` dart-define. Default is `release_safe`.
Dev scripts (`.devtools/*.sh`) override to `dev_coinpaprika`.

---

## Home-screen Widgets — Current State

### Android widget — ✅ Redesigned, wired, and verified

The Android home-screen widget has been completely redesigned from a
single-pair placeholder to a 3-pair icon-led medium widget.

- **Layout:** header (amount + freshness) + 3 rows (currency symbol
  in circle + code + value + trend), thin dividers, warm paper surface
- **Implementation:** `AppWidgetProvider` + `RemoteViews` (not Glance)
- **Files:** `HonestFernAppWidgetProvider.kt`, `widget_layout.xml`,
  `widget_background.xml`, `widget_icon_circle.xml`
- **Data bridge:** Dart `HomeWidgetProvider.pushData()` pushes 3 pairs
  (code, symbol, value, trend, changePercent per row) after rates load
- **Favorites-driven:** shows top 3 favorites; fallback to
  EUR/GBP/BTC when favorites are empty
- **Starter favorites:** seeds USD-EUR, USD-GBP, USD-BTC on first run
- **Placeholder state:** shows "Honest Fern · Open to load" when no data
  pushed yet (widget added before app first opened)
- **Design spec:** `docs/superpowers/specs/2026-06-13-widget-redesign-design.md`
- **Verification:** ✅ runtime-verified on Pixel 7 emulator — 3 pairs
  render correctly, tap opens Convert, placeholder shows when no data

### iOS widget — ⚠️ Code complete and wired, sim install may be blocked

The iOS widget (WidgetKit) code is complete and the Xcode project
target and `Embed App Extensions` phase are wired up. Some iOS 26 / Xcode 26
simulator installs fail with `Invalid placeholder attributes` for any widget
extension; this is an environment issue, not a local brand-migration step.

- **Files:** `ios/Runner/Widgets/HonestFernWidget/HonestFernWidget.swift`,
  `Info.plist`, `HonestFernWidget.entitlements`, `Assets.xcassets/`
- **Data bridge:** App Group `group.com.honestfern.currencyConverter` —
  main app writes via `UserDefaults(suiteName: ...)` from Dart
  through the home_widget plugin; widget reads from the same suite
- **Verification:** ✅ build succeeds, `.appex` is correctly
  produced, and the embed phase is correctly placed; ❌ an affected iOS sim
  install can fail before the app launches
- **Real-device path:** run `cd ios && GEM_HOME=/opt/homebrew/Cellar/cocoapods/1.16.2_2/libexec ruby scripts/add_widget_target.rb`
  (idempotent), then build and run on a real iPhone via Xcode with valid Apple
  signing resources
- **Code quality:** follows iOS 17+ WidgetKit conventions
  (`@main WidgetBundle`, `TimelineProvider`, `UserDefaults(suiteName:)`)
- **Full report:** `docs/release-prep/README.md` (Android + iOS widget
  history), `docs/REVIEW-2026-06-01.md` § "P3-2 iOS widget extension"

For the short current-truth summary covering Favorites nav visibility,
widgets, trend arrows, and chart-comparison deferral, see
`docs/superpowers/plans/2026-06-13-local-feature-status-harmonization.md`.

---

## Execution Order (phase reference; current resume order above)

Start at the dated resume checkpoint above; completed foundations below must not
be repeated. The site repo contains implementation detail for
its own steps, but it does not redefine this sequence.

### Phase 0 — Re-entry and toolchain preflight

0a. Complete the Phase 0 checklist above. Do not make a global Flutter or
dependency upgrade part of the release by default.

0b. Resolve and re-run the Android release-build smoke test. A successful
`flutter analyze`/`flutter test` run is not sufficient to mark B6 complete.

### Phase 1 — Foundations (site and accounts can run in parallel)

1. **Hostinger static migration and domain cutover — complete.** Vercel remains
   rollback; the VPS security/staging gates passed and the public site is live.
   See `../../niduna-site/docs/hostinger-static-migration.md` and
   `../../niduna-site/RELEASE_PLAN.md` S1.0.
2. Domain registration, apex DNS, HTTPS, public-path verification and
   production metadata are complete. [site S1.1-S1.3]
3. Create `support@honestfern.com`, publish MX/SPF/DKIM, and prove mail works in
   both directions. [site S1.4 — complete 2026-08-29; verified]
4. In parallel, create the **personal** Play account, complete identity,
   contact and real-Android-device verification, create/verify the merchant
   payments profile, and create the app draft. [E1-E4]
5. Create the AdMob app, Android banner/rewarded units and European regulations
   message. Finalize the three immutable one-time-product IDs and prices;
   create them now if Console permits. [E5, E5b, E8]

### Phase 2 — Build a policy-safe release candidate

6. Publish `app-ads.txt` with the exact AdMob snippet and keep `honestfern.com` as
   the developer website in Play. [E5c / site S1.5]
7. Implement real Android AdMob IDs, UMP consent + required privacy-options
   entry point, in-app privacy URL, real Play Billing and Restore purchases
   using E8's finalized IDs. [B4, B5, B8, B9]
8. Rotate the temporary upload-key password, delete the temporary password
   file, and store encrypted on-machine/off-machine backups.
9. Run `./scripts/check.sh`; verify release-safe providers, no dev UI, real
   billing failure/cancel/restore paths and non-personalised ad requests. Build
   the signed AAB with a fresh `+N` versionCode. [B6]
10. Upload to **internal testing** for a small smoke pass before the reviewable
    closed track. If E8 was unavailable earlier, create/activate the products
    after this billing-enabled upload. Verify product lookup, successful and
    cancelled purchases, acknowledgement, relaunch persistence and Restore.
    Internal testing does not count toward the 12/14-day production gate.

### Phase 3 — Finish Play setup, then start the fixed clock

11. Finalize the default English listing from
    `docs/release-prep/play-store-listing.md`, upload the ready screenshots and
    feature graphic, and use Android application ID
    `com.honestfern.currency_converter` everywhere. [C2-C6, C9-C10]
12. Complete all App content declarations shown in Console: ads, content
    rating, 13+ target audience, Data Safety based on the **final** AdMob/UMP
    build, financial-features declaration, and trader/public-contact task.
    [C7, C7b, C8, E6]
13. Create the closed track, select every tester's country, upload the release
    candidate only after all three products are active, and recruit 15-16
    people so at least 12 remain opted in for 14 continuous days. [E7]
14. During the window, monitor the count, gather real feedback, test purchases
    and restore with license testers, review crashes/pre-launch findings, and
    upload fixes to the same track with higher versionCodes.

### Phase 4 — Production and public-site switch

15. When the gate is satisfied, apply for production access and answer the
    testing questionnaire with real recruitment/feedback/change details.
16. After access is granted, upload/promote the final verified build, review
    the pre-launch report and submit for production review.
17. Wait until the production Play listing is publicly reachable. Then execute
    the site's S2 batch: correct Play URL, Available badge, release metadata,
    trust line, deploy and click-test.
18. Add DE/ES/IT/FR store listings later if wanted; they are not a launch gate.

The fixed critical path is therefore:

`Hostinger security/staging + domain/email + accounts → release candidate + Console
setup → closed test (12/14 days) → production-access review → app review →
public listing → site launch batch`.

---

## Data Refresh Cadence (for privacy policy + data safety form)

| Data type | Source | Frequency | How users see it |
|-----------|--------|-----------|-----------------|
| Fiat rates | Frankfurter v2 blended central-bank sources | App checks automatically once per local calendar day; manual refresh is available | Combined freshness label uses the oldest source date + `(i)` tooltip |
| Crypto prices | fawazahmed0 CDN | **Once per day** (static JSON update) | Same freshness indicator |
| Chart history | Frankfurter (fiat) / fawazahmed0 (crypto) | Cached persistently; refetched on gap or staleness | Date range shown on chart header |

**Key phrase for policy:** *"The app checks exchange rates once daily from public central-bank and open-data sources. Source publication times differ. No real-time or intraday data."*

When fiat and crypto sources report different dates, the Convert freshness
indicator shows the older date. This is deliberately conservative because a
cross-provider conversion cannot be fresher than its oldest component.

---

## Privacy Policy — What To Disclose

### Data this app collects

| Type | Collected? | Detail |
|------|-----------|--------|
| Personal name, email, phone | **NO** | No accounts, no login |
| Location | No GPS permission; SDK processing differs | AdMob may derive approximate location from IP; account for this in declarations |
| Device ID / advertising ID | **BY US: NO — but YES via the AdMob SDK once real ads are live (B4)** | No analytics SDK of our own; the Data Safety form counts SDK collection, so declare AdMob (see C8 note + § Third-party SDKs below). Corrected 2026-07-16 — do NOT answer "no" from this row. |
| Financial info | **NO** | Display-only; no transactions, no wallet |
| Health / fitness | **NO** | N/A |

### Data this app transmits

| Type | To whom | When |
|------|---------|------|
| IP address | Frankfurter, jsdelivr, Cloudflare CDNs | On each rate fetch (HTTPS, unavoidable) |
| Ad request signals (IP, advertising ID, device info) | Google (AdMob) | When ads load for free users (once B4 real IDs are live; per the B8 consent/NPA setup) — none after Remove Ads |
| (nothing else by us) | — | No API keys, no user IDs, no custom headers |

### Local storage

| Data | Where | Purpose |
|------|-------|---------|
| Favorite pairs | SharedPreferences | User's saved currency pairs (max 3) |
| App settings | SharedPreferences | Base currency, decimals, theme, refresh preference |
| Rate cache | SharedPreferences | Last known fiat + crypto rates (offline use) |
| Chart cache | SharedPreferences | Historical data for displayed pairs |
| IAP state | Platform purchase receipt store + local entitlement cache | Remove Ads / Charts Pro / Favorites Pro ownership after B9 |
| Temp unlocks | SharedPreferences | 24h chart-pair unlock TTLs |

All local storage is cleared on app uninstall. Users can clear cache via Settings.

### Third-party SDKs (Phase 1)

| SDK | Purpose | Data it may collect | Our mitigation |
|-----|---------|-------------------|---------------|
| Google Mobile Ads | Banner ads, rewarded ads | Device signals for ad targeting | Will disclose in Data Safety form when live |
| (none others) | — | — | — |

---

## Financial Features Declaration (Play Console)

Google requires every app to declare financial features. Correct answers:

| Feature | This app? |
|---------|----------|
| Cryptocurrency wallet | **NO** |
| Cryptocurrency exchange | **NO** |
| Tokenized digital asset (NFT) | **NO** |
| Stock trading / portfolio management | **NO** |
| Mobile payments / digital wallets | **NO** |
| Banking / loans | **NO** |
| Insurance | **NO** |

**Declaration:** *"My app doesn't provide any financial features."*

A currency converter that displays exchange rates is NOT a financial service. It does not hold funds, execute trades, facilitate transactions, or manage wallets.

---

## Post-Submission (Not Blocking)

These can ship in v0.2.0+ updates:

| Item | Priority | Notes |
|------|----------|-------|
| Crash reporting (Crashlytics) | Low | Post-MVP |
| First-party analytics | None per AGENTS.md | AdMob SDK collection/sharing is disclosed separately |
| Promo video | Nice-to-have | Increases conversion |
| Tablet screenshots | Optional | Phone-first MVP |
| Long-press context menu on rows | Low priority | Swipe already covers Pin/Swap |
| App Store (iOS) submission | Deferred | $99/year fee; Android first |

---

## Change Log (this file)

- **2026-09-10 (B8 implementation + B4 release wiring)** — Added the shared
  UMP consent gate and Settings privacy-options entry point. Banner and
  rewarded ads now request only after `canRequestAds`; the production Android
  AdMob IDs are recorded for the release command while test IDs remain the
  development default. `flutter analyze`, all **247 tests**, and a local
  signed test-ad AAB (`0.1.0+2`, 54.1 MB) pass. Device consent/ad behavior,
  AdMob account verification, B9 purchase/restore acceptance, key rotation,
  screenshots, and the final version bump remain open.

- **2026-09-10 (fresh-install emulator smoke)** — Removed and reinstalled the
  release APK on `emulator-5554`, then verified consent and Manage options,
  Settings Privacy options, base-currency switching, refresh, Favorites,
  Charts, and light/dark mode. No source changes were needed; the next
  acceptance gate is real Play Billing purchase/restore on internal testing.

- **2026-09-10 (UI/UX experiment run, then SHELVED for 1.0.0)** — The
  overnight UI/UX experiment (`.agent/overnight-ui-ux-experiment.md`) was
  activated and completed in an isolated worktree (branch
  `codex/experiment-ui-ux-20260910`, base `a4c7489`; main untouched). Three
  candidate fixes were implemented and verified at font scales 1.0/1.3/2.0
  on 360×640dp and standard screens, light+dark: nav pill collapses to
  icons at large text, hero amount/freshness line stop truncating
  (TextPainter now measures with the system `textScaler` — Android 14+
  scales non-linearly), Charts switches to a scrollable layout with a
  bounded 240dp chart, and favorite pair titles use `FittedBox` instead of
  ellipsis. Full report with before/after evidence:
  `/Users/luis/Niduna-worktrees/currency-converter-ui-ux-20260910/.agent/experiments/overnight-ui-ux-2026-09-10/REPORT.md`.
  **Decision (Luis, 2026-09-10): do NOT advance these UI changes for
  1.0.0** — large font scale on the small test device is not a convincing
  combination to ship now. The worktree/branch are preserved for review;
  revisiting after launch (v1.1) would reuse the same diff. Useful
  technical learning kept in `CODE_PATTERNS.md`
  ("Text measurement with user font scaling"). No release gate changed:
  B4 (real AdMob IDs), B8 (UMP) and the on-device purchase/restore test
  against the active one-time products remain the open pre-RC work.
- **2026-09-09 (Console session + B9 implemented)** — Luis created the Play
  Console app draft ("Currency Converter Honest Fern", app ID
  `4973875544480645622`), completed the merchant payments profile (E3 ✅:
  Individual + IBAN payouts + Honest Fern account group for the 15% fee
  tier), and the app title decision was locked (`Currency Converter Honest
  Fern`, 30/30) and recorded in the listing doc. Console revealed the
  documented alternate branch: one-time product creation stays locked until
  an APK/AAB carrying the BILLING permission is uploaded — so **B9 was
  implemented immediately**: `in_app_purchase` wired end-to-end
  (`PlayPurchaseService`, stream handling, restore replaces the "coming
  soon" snackbar, entitlements via `applyLifetimeEntitlement`), 247 tests
  green, versionCode bumped to `0.1.0+2` and a billing-enabled diagnostic
  AAB built for the internal-testing upload that unlocks E8. B8 (UMP) and
  B4 (real AdMob IDs) remain the open code blockers.
- **2026-09-09 (E8 closed)** — Internal-testing release "0.1.0+2 billing
  diagnostic" published (no review needed, as expected), and all three
  one-time products created and ACTIVATED with the exact planned IDs:
  `remove_ads_lifetime` 1.99 CHF, `charts_pro_lifetime` 2.99 CHF,
  `favorites_pro_lifetime` 0.99 CHF (Digital app sales tax, All ages,
  all regions priced via bulk edit from the CHF base; Google's FX-converted
  regional prices kept for launch — regional .99 price tuning deferred to
  v1.1 with price templates). Remaining before real purchase testing: add
  internal testers, install from the opt-in link, configure license
  testing, then exercise buy/cancel/restore on device.

- **2026-09-09 (full pre-Play audit + plan sync)** — Independent audit before
  creating the Console draft: `./scripts/check.sh` passes (242 tests, clean
  analysis); fresh small-screen emulator pass (`Small_Screen_API_36`,
  light+dark) found no new UI issues and confirms the daily-rates messaging;
  site privacy page verified live and accurate (no Niduna/OXR references;
  `app-ads.txt` correctly still 404 until E5). Status updates from the audit:
  E2 identity verification COMPLETE; E4 marked as the current next action
  (safe — drafts publish nothing); C5 repo screenshots re-marked OPEN because
  the 2026-07-08 set predates the daily-rates copy/header-share/trend badges
  (site screenshots from 2026-08-30 verified current); version target
  recorded as `1.0.0+2` for the first public release, applied only at the RC
  step; noted uncommitted local `pubspec.lock` drift (`meta` 1.17.0,
  `test_api` 0.7.10) that must be resolved before any release build.
  B4/B8/B9 remain the open code blockers, unchanged.

- **2026-08-30 (correction batch)** — Added the in-app privacy link, removed
  crypto from base-currency selection until crypto-base rates are supported,
  made cached chart timestamps truthful, gated Dev Sandbox to debug builds,
  and made release signing fail closed. `./scripts/check.sh` passes (239
  tests); a sequential 53.4 MB diagnostic AAB was built and signature-verified.
- **2026-08-30 (quality batch)** — Localized remaining visible error/share/
  picker/product-status copy, wired screen-reader currency-row and section
  header actions, hardened narrow quote layouts, contained unexpected chart
  repository failures, rejected future-dated crypto payloads, removed the
  Android lock-screen widget category, and restricted local secret files to
  owner-only permissions. `./scripts/check.sh` passes (241 tests); the fresh
  53.4 MB diagnostic AAB is signed and verified. AdMob and real billing remain
  intentionally deferred.
- **2026-08-30 (UX pass)** — Audited the main tabs and picker sheets on the
  Android emulator, including 1.3x text scale. Aligned the Charts picker
  surface with Convert, kept Chart pair codes on one line at large text,
  reduced date-label density to prevent overlap, and added a regression test.
  `./scripts/check.sh` passes with 242 tests. No new release blocker was found;
  physical-device TalkBack and final offline/monetization QA remain pending.
- **2026-08-30 (visual polish pass)** — Reduced secondary visual weight on
  Convert, standardized repeated actions on rounded Material icons, reviewed
  the app icon/splash on the small Android emulator, and normalized the PLN/THB
  currency assets to real PNG files without changing their artwork. The
  automated Android gallery produced reviewed captures for Convert, Favorites,
  Chart, and Settings. No new release blocker was found.
- **2026-08-28 (release re-entry audit)** — Added Phase 0 for resuming the
  release after a pause. Flutter 3.41.7/Dart 3.11.5, the Android/iOS
  toolchain, dependency resolution, `flutter analyze`, and 239 tests were
  re-verified. No global SDK or dependency upgrade is required. The first
  `--no-pub` AAB attempt exposed a stale development plugin registrant; the
  normal release command regenerated the release-filtered registrant and
  produced a signed 51 MB diagnostic AAB. B6 is technically revalidated, but
  the final AAB remains gated on B4/B5/B8/B9, key rotation, and a new
  versionCode.
- **2026-07-16 (teaser removal implemented)** — The "Coming Soon"
  open decision is resolved and DONE: removed the Settings
  Subscription tile (+ its 3 l10n keys from all 5 ARBs), the locked
  1H/6H/1D chart range chips with their premium snackbar, and the
  Convert info-sheet "faster updates" subscription line. No platform
  gating — removed everywhere. Entitlement plumbing
  (`canUseIntradayRanges`, `ProductType.subscription`, dev panel)
  kept as the Phase 2 seam. Verified: 239 tests pass, emulator
  screenshots light+dark (Settings premium section, charts range
  row, info sheet) all clean.
- **2026-07-16 (third-pass consistency review)** — Swept both plans for
  statements contradicting the corrected closed-test gate and for stale
  premises. Fixed: (1) E7 blocker row still said the closed track "can
  run in parallel with the listing work" — listing/forms now correctly
  precede it; (2) Execution Order intro gained the corrected critical
  path; (3) "Rule of thumb" still cited the stale SSO-gate premise —
  the real blocker is that `honestfern.com` isn't bought; (4) **Data Safety
  trap:** the "What To Disclose" tables still said advertising ID "NO /
  no tracking SDK", contradicting the C8 AdMob declaration — corrected
  so nobody answers the form wrong from this file; AdMob added to the
  transmits table. Site plan: master-order pointer made layout-neutral
  (old `apps/...` path), dependency summary gained the E7 forms-gate
  line.
- **2026-07-16 (second-pass review)** — Re-verified the full order
  against how Play Console actually gates a first-time publisher.
  Corrections: (1) **the closed test cannot start "early"** — the
  Console blocks publishing a closed track until the "Set up your app"
  dashboard tasks are complete (App content declarations AND the store
  listing); only internal testing skips the forms, but internal does
  not count toward the E7 12-tester/14-day gate. Header list
  renumbered (listing/content forms now item 3, before the closed
  test); Step 2c gained the GATE note; Phase 3 reframed as a final
  review pass. (2) **E3 corrected** — payments/merchant profile
  (Setup → Payments profile), launch-critical for E8/B9, not "later";
  the old "Setup > License" path was wrong. (3) **versionCode rule
  added to B6** — every Play upload needs a bumped `+N` build number
  in pubspec, closed-track updates included. (4) **E7 playbook** —
  the track's country availability must include every tester's
  country, or they cannot opt in.
- **2026-07-16 (payments review)** — Goal confirmed: launch on Google
  Play with **working payments + ads**. Review found the plan had NO
  step to replace the Phase-1 IAP stub: the app ships a fake purchase
  flow ("Processing payment…" always succeeds —
  `purchase_service_stub.dart`; no billing package in `pubspec.yaml`),
  a Play payments-policy rejection risk that also gives every
  entitlement away free. Added **E8** (create the 3 in-app products in
  Play Console) and **B9** (real Play Billing implementation, full
  clues in Implementation Notes § B9), inserted as Steps 3c / 8b; B6's
  final AAB now also waits on B9. Email provider decided: **Zoho Mail**
  (site plan S1.4 updated). New open decision recorded in the header:
  remove/hide the "Coming Soon" subscription teasers (Settings tile +
  Charts intraday snackbar) before the final AAB.
- **2026-07-11 (publishing-identity review)** — Adopted the
  "Pegolandia model": publish as an individual, no company; brand
  stays website/app-facing, legal identity lives in store
  verification (guardrails from the strategy docs recorded above the
  External Steps table). Two NEW external gates found missing: **E6**
  EU DSA trader declaration (monetized app ⇒ verified contact details
  publicly shown on EU listings, mandatory for EU distribution) and
  **E7** the 12-tester/14-day closed-testing requirement for personal
  accounts created after Nov 2023 — E7 is timeline-critical, so the
  historical execution order placed closed-track preparation early while
  still gating submission (Step 15b). The current order keeps the closed
  track after the new re-entry Phase 0 and all Play setup gates. Site-side
  GDPR work landed the
  same day (fonts self-hosted, privacy page website + controller
  sections — `niduna-site/RELEASE_PLAN.md` § S0).
- **2026-07-08 (plan review)** — Full review of both release plans found
  4 gaps, now fixed: (1) **B8 NEW** — no UMP/GDPR consent flow exists in
  the app; required for EEA/UK/CH ad serving, pairs with new E5b (AdMob
  consent message) — and the site privacy page's "non-personalised ads"
  claim must be aligned when implementing it; (2) **E5c NEW** —
  `app-ads.txt` on honestfern.com (site plan S1.5); (3) B6 status corrected
  from Done to "must re-run" — the final AAB needs real ad IDs, privacy
  link, consent flow, and the rotated keystore; (4) C3's example claimed
  "170+ currencies" — the app supports exactly 45. C8 now explicitly
  requires declaring the AdMob SDK.
- **2026-07-08 (later)** — Rewrote the Execution Order as a cross-repo
  master order (Phases 0-5) covering this repo + `niduna-site`
  (`niduna-site/RELEASE_PLAN.md` created the same day). Key correction:
  C1's privacy *page* already exists on the site; the real blocker is
  the domain purchase (Vercel SSO gate), which also blocks B5/C10.
  Screenshots C5 re-captured post-polish. Header short list reordered
  by dependency.
- **2026-07-08** — Refreshed header with a consolidated "Remaining before
  submission" short list (accounts → AdMob IDs → privacy policy → keystore
  rotation → listing content → upload). Noted the 2026-06-16 accessibility
  pass and that main is pushed/in sync with origin. No blocker statuses
  changed — E1–E5, B4, B5, B7, C1–C4, C7–C11 all still open.
- **2026-06-13** — Marked C5 (screenshots) and C6 (feature graphic) as ✅
  Done. 6 final store screenshots at 1080×2400 captured on the new
  `Pixel7_EN` AVD (Convert / Chart with data point tooltip / Favorites
  × light + dark), all in `docs/release-prep/screenshots/`. Feature
  graphic at `docs/release-prep/feature-graphic.png` (1024×500).
  Capture infra added: `integration_test/screenshot_gallery_test.dart`,
  `.devtools/sample_seed_data.dart` (rewritten for real SharedPreferences
  keys), `.devtools/generate_sample_prefs.dart` (`--free-user` /
  `--no-favorites` flags). Note: swiftshader GPU required for icon
  rendering on emulator. OG social image refreshed on Vercel site
  (1200×630).
- **2026-06-02** — Updated Blocker Summary statuses to reflect actual
  state: B1–B3, B6 are ✅ Done (not ❌ as previously marked). Added
  keystore password rotation callout. Added "Home-screen Widgets —
  Current State" section. Added link to `docs/REVIEW-2026-06-01.md`
  in header. Status header now reflects "code complete, external
  work remaining."
- **2026-06-01** — Added code-only pre-flight section; refreshed
  header to point at `docs/superpowers/plans/2026-06-01-post-phase-ad-next-steps.md`.
- **2026-05-31** — Initial version.
