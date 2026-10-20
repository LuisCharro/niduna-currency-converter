# EU distribution decision — 2026-10-20

## Decision and saved state

Luis approved preparing EU27 + Switzerland after reviewing the Console notice.
This supersedes the earlier Spain/Switzerland-only decision. The selected ISO
codes are in `production-release-plan.json`. All 28 country rows were checked;
all other rows, including UK, Norway, Iceland, Liechtenstein and Rest of world,
were unchecked. Publishing overview confirms release 11 and Add 28 countries,
**not yet submitted for review**. Managed publishing is off.

Google's country grouping also includes associated territories:

| Selected country | Included locations shown in Console |
| --- | --- |
| Denmark | Faroe Islands (FO), Greenland (GL) |
| Finland | Åland Islands (AX) |
| France | French Guiana (GF), French Polynesia (PF), Guadeloupe (GP), Martinique (MQ), Mayotte (YT), New Caledonia (NC), Réunion (RE), St Barthélemy (BL), St Martin (MF), St Pierre & Miquelon (PM), Wallis & Futuna (WF) |

These are Google's parent-country groups, not 14 additional selected country
rows. Do not describe this as strictly geographic EU territory only.
Open testing shares Production targeting; Closed Alpha is not listed as affected.

## Why the recommendation changed

The Console banner links to [Google's country distribution requirements](https://support.google.com/googleplay/android-developer/answer/6223646?hl=en).
Google describes avoiding unjustified EU geo-blocking and gives EU-wide access
as its general example, subject to laws and exceptions. The banner is an
informational notice, not a validation error that proves an infringement.

The [Commission's explanation of ten key features](https://digital-strategy.ec.europa.eu/en/news/10-key-features-geo-blocking-regulation)
distinguishes online-interface access rules from the equal-sales-condition
rules and their copyright-content exceptions, including software. See also
the [Commission's current policy overview](https://digital-strategy.ec.europa.eu/en/policies/geoblocking)
and [Regulation (EU) 2018/302, especially Article 4(1)(b)](https://eur-lex.europa.eu/legal-content/EN/TXT/?qid=1570639511434&uri=CELEX%3A32018R0302).

It would be too broad to conclude either that all software is exempt from every
rule or that this currency utility must legally distribute in every EU state.
We did not establish the relevant exception for this particular app. The
practical recommendation, accepted by Luis, was EU-wide distribution plus
Switzerland instead of relying on that unconfirmed exception. This record is
an operating decision, not a formal legal opinion or general compliance sign-off.
Some direct EC fetches returned HTTP 429 and EUR-Lex returned an anti-bot page;
indexed official source text was consulted. Do not bypass those protections.

## Tooling lesson and next action

Production's track summary displayed Active and 28 countries immediately after
saving, while Publishing overview still explicitly listed both changes as not
yet submitted. Never use the summary or an API completed status alone to claim
public availability. Evidence is under ignored
`.tmp/play-production-draft-20261020/eu28-release-pending.*`.

Next is a separately authorized submission of the whole pending batch. With
managed publishing off, approval may automatically make the release public.
No new app version, upload, price update or website deployment was performed.
