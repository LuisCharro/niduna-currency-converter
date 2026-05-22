---
version: alpha
name: Niduna Currency Converter
description: Privacy-first fiat currency converter for mobile. Warm, editorial, iOS-native feel with Niduna brand identity.
colors:
  bg: "#F6F8EF"
  text: "#171D14"
  muted: "#5F6A58"
  subtle: "#66745B"
  card: "#FFFFFF"
  container: "#FFF9EC"
  containerHigh: "#F5EDEE"
  border: "rgba(40,95,59,0.14)"
  primary: "#285F3B"
  trendUp: "#6F8C49"
  trendDown: "#DC6543"
  greenBadge: "#EDF5EB"
  greenBadgeText: "#3D6E2C"
typography:
  display:
    fontSize: 32px
    fontWeight: 800
    lineHeight: 1.2
    letterSpacing: -0.5px
  heading:
    fontSize: 22px
    fontWeight: 700
    lineHeight: 1.25
  body:
    fontSize: 16px
    fontWeight: 500
    lineHeight: 1.4
  caption:
    fontSize: 12px
    fontWeight: 500
    lineHeight: 1.3
  micro:
    fontSize: 10px
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: 0.5px
  serif:
    fontFamily: "Fraunces"
    fallback: ["Georgia", "serif"]
rounded:
    sm: "12px"
  md: "16px"
  lg: "20px"
  full: "9999px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "16px"
  lg: "24px"
  xl: "32px"
  hero: "40px"
typography_v2:
  heroAmount: "50px / 800 Manrope (40px compact at text scale ≥1.3×)"
  pairTitleFraunces: "30px / 800 Fraunces"
  metricValue: "20px / 700 Manrope"
  sectionLabel: "11px / 700 Manrope uppercase rails"
surfaces_v2:
  instrumentPanel: "containerHigh fill + 1px instrumentBorder"
  canvasGradient: "bg → #FAFBF4 → #FFF9EC (bottom-weighted)"
  coralCta: "#FDF0EC / #B54E48 Remove Ads"
components:
  pill-button:
    backgroundColor: "{colors.primary}"
    textColor: "#FFFFFF"
    rounded: "{rounded.lg}"
    padding: "14px"
  chip-selected:
    backgroundColor: "{colors.card}"
    borderColor: "transparent"
    rounded: "{rounded.lg}"
    boxShadow: "0 2px 10px rgba(40,95,59,0.08)"
  chip-unselected:
    backgroundColor: "transparent"
    borderColor: "transparent"
    rounded: "{rounded.lg}"
  rate-row-divider:
    color: "{colors.border}"
    thickness: "0.5px"
    opacity: "0.15"
  green-badge:
    backgroundColor: "{colors.greenBadge}"
    textColor: "{colors.greenBadgeText}"
    rounded: "{rounded.full}"
  floating-nav:
    backgroundColor: "{colors.container}"
    rounded: "{rounded.lg}"
    shadowColor: "rgba(40,95,59,0.08)"
  amber-pill:
    backgroundColor: "#FBF3DB"
    textColor: "#7A6232"
  coral-button:
    backgroundColor: "#FDF0EC"
    textColor: "#B54E48"
---

# Overview

Privacy-first currency converter with a **warm, editorial aesthetic** rooted in the Niduna brand. The UI prioritizes **clarity and warmth** — information density without visual noise, without the cold clinical feel of generic utility apps.

## Current Redesign Direction

The active direction is **Niduna hybrid**:

- preserve the Niduna warm paper surface, forest green interaction color, and editorial typography
- borrow the competitor's useful discipline: strong hierarchy, thin dividers, compact list rows, pill values, full-width charts, and confident touch targets
- avoid copying the competitor's pure-white/iOS-blue style wholesale
- use generated imagery only for icons, store assets, or empty states; do not add decorative backgrounds to the core product UI

Target audience: travelers, expats, freelancers who need fast, reliable rates without accounts or tracking.

Emotional response: **warm, trustworthy, crafted**. The app should feel like a precision tool made by people who care about design, not a factory-default utility.

**Brand DNA (from niduna-site):**
- Warm paper canvas (`#F6F8EF`) instead of stark white
- Forest leaf green (`#285F3B`) as primary accent instead of iOS blue
- Moss/amber secondary palette for organic warmth
- Manrope body font + Fraunces serif for editorial headings
- Subtle noise texture on backgrounds (web only; approximated in mobile via warm gradients)

**Design principles:**
- **Warmth over clinical precision** — the app should feel inviting to touch, not sterile
- Dividers, not cards — rows separated by thin lines, not boxed containers
- Color as information — moss/coral for trends, leaf for interaction, sage for hierarchy
- Full-bleed content — no card wrappers around charts or lists
- Typography as structure — weight and size create hierarchy, serif headings for editorial warmth
- Floating navigation — bottom nav floats above content, paper-warm background
- **Niduna differentiation** — same structural quality as competitor apps but visually distinct through warmth and brand personality

## Colors

The palette is rooted in the **Niduna brand** (from niduna-site) with warm, organic tones:

- **Background (#F6F8EF):** Warm paper canvas. Not pure white — reduces eye strain, adds premium feel. Slightly warmer at bottom via gradient.
- **Text (#171D14):** Dark forest ink. Softer than pure #000 for reduced eye strain. Reads as near-black but warmer.
- **Muted (#5F6A58):** Sage olive. Secondary text, timestamps, metadata. Warmer than iOS gray.
- **Subtle (#66745B):** Tertiary text, placeholders, disabled states. Harmonious with warm palette.
- **Container (#FFF9EC):** Paper-warm. Used for nav bar, section backgrounds, floating nav. Cozy, not cold.
- **ContainerHigh (#F5EDEE):** Secondary containers, filled inputs, active states.
- **Border (rgba(40,95,59,0.14)):** Green-tinted separator. Blends into warm canvas naturally.
- **Primary (#285F3B):** Forest leaf green. Used for active nav items, links, primary buttons, active states. The signature Niduna color — replaces iOS blue.
- **Trend Up (#6F8C49):** Moss green. Positive changes, success states, value badges. Warmer and more organic than iOS green.
- **Trend Down (#DC6543):** Coral. Negative changes, error states, destructive actions. Warmer and less alarming than iOS red.

**Dark mode:** Inverts to dark forest ink (`#171D14`) background with adjusted warm surfaces. Primary shifts to lighter moss (`#6F8C49`). Text becomes warm paper (`#F6F8EF`).

## Typography

Dual-font system for **editorial warmth + readability**:

**Manrope (body font)** — Clean modern sans-serif for all UI text:
- **Display (32/800):** Chart header values ("USD per 1 EUR"). Extra bold for impact.
- **Heading (22/700):** Screen titles, section headers. Bold but approachable.
- **Body (16/500):** Default reading text. Currency names, rate values, settings labels. Medium weight for presence.
- **Caption (12/500):** Secondary info — timestamps, change percentages, hints.
- **Micro (10/600):** Badges, tags, tiny labels. Uppercase-style spacing.

**Fraunces (serif display font)** — For editorial warmth on key headings only:
- Use for: "Currency" screen title, chart pair headline ("USD per 1 EUR"), major section headers
- Do NOT use for: body text, captions, micro labels, code/currency codes
- Creates instant brand differentiation from apps using only sans-serif

Single font fallback chain: `["Fraunces", "Georgia", "serif"]`

## Layout

**Single-column mobile layout** with generous safe area padding on warm paper canvas:

- Standard horizontal padding: **20px** (`AppTheme.pagePadding`)
- Section spacing: **24px** vertical between major groups
- Row height: **52-56px** for tappable rate rows
- Bottom chrome uses shared metrics instead of per-screen guesses:
  - floating nav height: **64px**
  - floating nav dock offset: **0px** above the safe-area bottom
  - bottom dock gap above nav: **8px**
- Max nesting depth: **3 levels** (Screen → List → Row → Content)

Spacing follows an **8px base scale** with 4px half-steps for micro-adjustments.

Subtle background gradient (bottom 30% of screen): `#F6F8EF → #FBFCF6 → #FFF9EC` — creates depth without being decorative.

## Elevation & Depth

**Minimal elevation** — flat design with extremely subtle depth cues:

- Floating nav: single subtle shadow (`rgba(40,95,59,0.08)`)
- Selected chips: same subtle shadow for lift from container
- No shadows on cards, rows, or list items
- Depth conveyed through **background color contrast** (warm white on paper) rather than shadows

## Shapes

**Rounded-soft language** matching Niduna brand conventions:

- **Pill radius (20px):** Buttons, chips, badges, nav container — the dominant shape
- **Card radius (16px):** Large containers, modals, sheets
- **Standard radius (12px):** Inputs, small containers, toggle tracks
- **Full round (9999px):** Badge pills, avatar circles, circular buttons (swap icon)

Consistent rounding within each screen — do not mix sharp corners with rounded ones in the same view.

## Components

### Rate Rows (Convert screen)
- **No card, no border, no shadow** — just InkWell + Padding on warm paper
- Separated by **0.5px green-tinted divider** (border color at 15% opacity)
- Flag icon (32px circle) on left
- Currency name bold (16/w600), code gray (13/w500)
- Rate value on right inside **moss-green pill badge** (#EDF5EB bg, #3D6E2C text)
- Swap icon appears only on the active/tapped row

### Amount Input
- Large input field (40px font, w800)
- Pill-shaped currency button (flag + code) attached to right of input
- Active state: **leaf green tint** or warm container bg (not cold gray)
- Timestamp shown top-right in muted caption text
- No card wrapper — input sits directly on warm paper background

### Range Selector (Charts)
- Horizontal scrollable row of chips inside rounded **paper-warm** container
- Selected chip: **white bg** + subtle green-tinted shadow
- Unselected: transparent on warm bg
- Locked ranges: lock icon + muted text, tap shows SnackBar explanation

### Pair Selector (Charts)
- Large pill buttons (radius 24) with flag + currency code
- Circular swap button between base and quote selectors
- Shadow on selected state

### Floating Pill Navigation
- Rounded container (radius 28) with **paper-warm** background
- Three tabs: Convert / Charts / Settings
- Material Symbols Rounded icons
- Active tab = **leaf green** icon+text; inactive = **sage muted**
- Positioned at bottom, centered, flush to the safe area with no extra dock offset
- Shadow: green-tinted (`rgba(40,95,59,0.08)`)

### Bottom Chrome System
- All screens should clear the floating nav through shared constants, not local magic numbers
- `BottomTabFrame` owns the bottom inset for all tab screens
- Screens with ad banner + remove-ads CTA reuse the same `AdSupportShelf` component
- The bottom frame computes clearance from nav height + safe area + shared gap, so tab screens do not carry their own bottom math
- If the nav is moved, update these metrics together in code and in this document

### Settings Tiles
- Leading icon or widget, title + subtitle, trailing value or switch
- Divider between tiles (not full-width cards)
- Sections grouped by `SectionHeader` (uppercase, **moss green** color)
- Toggle switches: **leaf green** when active

### CTA / Action Buttons
- **Remove Ads:** coral-tinted button (`#FDF0EC` bg, `#B54E48` text) — stands out without being aggressive
- **Buy/Upgrade:** primary leaf green button
- **Destructive:** coral red button only
- **Secondary:** paper-warm background with ink text

## Do's and Don'ts

- DO use **warm paper background** (#F6F8EF) — never stark white
- DO use **leaf green (#285F3B)** as primary interactive color — never iOS blue
- DO use **Fraunces serif** for major headings ("Currency", chart titles) — adds editorial warmth
- DO use dividers between rows — never wrap individual rows in cards
- DO use moss/coral ONLY for trend/information — never for decoration
- DO maintain **100px bottom padding** for floating nav clearance
- DO keep the overall structure clean and minimal — warmth comes from palette, not decoration
- DON'T use iOS blue (#007AFF) anywhere in this app
- DON'T use stark white (#FFFFFF) as background
- DON'T add cold grays to text hierarchy — use sage/ink/muted from brand palette
- DON'T wrap charts or lists in card containers — full-bleed content only
- DON'T mix Fraunces into body text or captions — headings only
- DON'T add branding chrome (logos, taglines) to content screens
