---
version: alpha
name: Niduna Currency Converter
description: Privacy-first fiat currency converter for mobile. Clean, professional, iOS-native feel with minimal chrome.
colors:
  bg: "#FFFFFF"
  text: "#1A1A1A"
  muted: "#8E8E93"
  subtle: "#AEAEB2"
  card: "#FFFFFF"
  container: "#F2F2F7"
  containerHigh: "#E5E5EA"
  border: "#C6C6C8"
  primary: "#007AFF"
  trendUp: "#34C759"
  trendDown: "#FF3B30"
typography:
  display:
    fontSize: 32px
    fontWeight: 800
    lineHeight: 1.2
    letterSpacing: -0.5em
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
    letterSpacing: 0.5em
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
    boxShadow: "0 2px 10px rgba(0,0,0,0.05)"
  chip-unselected:
    backgroundColor: "transparent"
    borderColor: "transparent"
    rounded: "{rounded.lg}"
  rate-row-divider:
    color: "{colors.border}"
    thickness: "0.5px"
    opacity: "0.5"
  green-badge:
    backgroundColor: "#E8F5E9"
    textColor: "{colors.trendUp}"
    rounded: "{rounded.full}"
  floating-nav:
    backgroundColor: "{colors.container}"
    rounded: "{rounded.lg}"
    shadowColor: "rgba(0,0,0,0.08)"
---

# Overview

Privacy-first currency converter with a **clean, professional, iOS-native aesthetic**. The UI prioritizes **clarity over decoration** — information density without visual noise. Every pixel serves the primary user job: convert currencies instantly.

Target audience: travelers, expats, freelancers who need fast, reliable rates without accounts or tracking.

Emotional response: **trustworthy, instant, uncluttered**. The app should feel like a precision tool — not a social feed or dashboard.

**Design principles:**
- Dividers, not cards — rows separated by thin lines, not boxed containers
- Color as information — green/red for trends, blue for interaction, gray for hierarchy
- Full-bleed content — no card wrappers around charts or lists
- Typography as structure — weight and size create hierarchy, not borders or backgrounds
- Floating navigation — bottom nav floats above content, not pushing it up

## Colors

The palette is rooted in **iOS system colors** with a single blue accent. High contrast for readability in any lighting.

- **Background (#FFFFFF):** Pure white canvas. No tinting, no gradients. Maximum clarity.
- **Text (#1A1A1A):** Near-black for body text. Softer than pure #000 for reduced eye strain.
- **Muted (#8E8E93):** iOS secondary label color. Used for secondary text, timestamps, metadata.
- **Subtle (#AEAEB2):** Tertiary text, placeholders, disabled states.
- **Container (#F2F2F7):** iOS grouped background. Used for nav bar, section backgrounds.
- **ContainerHigh (#E5E5EA):** Secondary containers, filled backgrounds.
- **Border (#C6C6C8):** iOS separator color. Thin dividers between rows.
- **Primary (#007AFF):** iOS system blue. Used for active nav items, links, interactive elements. Never for body text.
- **Trend Up (#34C759):** iOS green. Positive changes, "up" indicators, success states.
- **Trend Down (#FF3B30):** iOS red. Negative changes, "down" indicators, error states.

**Dark mode:** Inverts to pure black (#000000) background with adjusted surface colors. Primary shifts to lighter blue (#4A9EFF). Text becomes warm white (#F5F5F5).

## Typography

Single font family: **Inter**. Weight and size carry all hierarchy — no font mixing.

- **Display (32/800):** Chart header values ("USD per 1 EUR"). Extra bold for impact at chart top.
- **Heading (22/700):** Screen titles, section headers. Bold but not overwhelming.
- **Body (16/500):** Default reading text. Currency names, rate values, settings labels. Medium weight for presence without heaviness.
- **Caption (12/500):** Secondary info — timestamps, change percentages, hints. Smaller but still readable.
- **Micro (10/600):** Badges, tags, tiny labels. Uppercase-style spacing for compact display.

## Layout

**Single-column mobile layout** with generous safe area padding. Content stretches edge-to-edge; padding is applied per-section, not via wrapper cards.

- Standard horizontal padding: **16px**
- Section spacing: **24px** vertical between major groups
- Row height: **52-56px** for tappable rate rows
- Bottom padding: **100px** to clear floating navigation pill
- Max nesting depth: **3 levels** (Screen → List → Row → Content)

Spacing follows an **8px base scale** with 4px half-steps for micro-adjustments.

## Elevation & Depth

**Minimal elevation** — flat design with extremely subtle depth cues only where needed for layer separation.

- Floating nav: single subtle shadow (`0 2px 10px rgba(0,0,0,0.08)`)
- Selected chips: same subtle shadow for lift from container
- No shadows on cards, rows, or list items
- No drop shadows on text
- Depth conveyed through **background color contrast** (white on light-gray) rather than shadows

## Shapes

**Rounded-soft language** matching iOS design conventions:

- **Pill radius (20px):** Buttons, chips, badges, nav container — the dominant shape
- **Card radius (16px):** Large containers, modals, sheets
- **Standard radius (12px):** Inputs, small containers, toggle tracks
- **Full round (9999px):** Badge pills, avatar circles, circular buttons (swap icon)

Consistent rounding within each screen — do not mix sharp corners with rounded ones in the same view.

## Components

### Rate Rows (Convert screen)
- **No card, no border, no shadow** — just InkWell + Padding
- Separated by **0.5px divider** (border color at 50% opacity)
- Flag icon (32px circle) on left
- Currency name bold (16/w600), code gray (13/w500)
- Rate value on right; active row gets **green pill badge** (#E8F5E9 bg, #34C759 text)
- Swap icon appears only on the active/tapped row

### Amount Input
- Large input field (40px font, w800)
- Pill-shaped currency button (flag + code) attached to right of input
- Timestamp shown top-right in muted caption text
- No card wrapper — input sits directly on white background

### Range Selector (Charts)
- Horizontal scrollable row of chips inside rounded gray container
- Selected chip: white bg + subtle shadow
- Unselected: transparent
- Locked ranges: lock icon + muted text, tap shows SnackBar explanation

### Pair Selector (Charts)
- Large pill buttons (radius 24) with flag + currency code
- Circular swap button between base and quote selectors
- Shadow on selected state

### Floating Pill Navigation
- Rounded container (radius 28) with subtle shadow
- Three tabs: Convert / Charts / Settings
- Material Symbols Rounded icons
- Active tab = primary color; inactive = muted
- Positioned at bottom, centered, with margin from edges

### Settings Tiles
- Leading icon or widget, title + subtitle, trailing value or switch
- Divider between tiles (not full-width cards)
- Sections grouped by `SectionHeader` (uppercase, spaced)

## Do's and Don'ts

- DO use dividers between rows — never wrap individual rows in cards
- DO use green/red ONLY for trend/information — never for decoration
- DO keep the primary blue (#007AFF) for interactive elements only — never for body text
- DO use Inter exclusively — no font mixing within a screen
- DO maintain 100px bottom padding for floating nav clearance
- DON'T add shadows to list rows, cards, or content areas
- DON'T use more than 2 font weights on a single screen (display+body, or heading+caption)
- DON'T mix sharp corners with rounded corners in the same view
- DON'T use colored backgrounds for the main canvas — always pure white (or pure black in dark mode)
- DON'T add branding chrome (logos, taglines, "by Niduna") to content screens
- DON'T wrap charts or lists in card containers — full-bleed content only
