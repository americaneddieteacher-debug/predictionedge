// ibookk "Ledger Modern" — Tailwind theme extension.
// Merge into tailwind.config.ts: theme.extend = { ...ledgerModern }
// Colors reference the CSS variables from tokens.css so light/dark
// switching stays token-level (never restyle components per theme).

export const ledgerModern = {
  colors: {
    paper: 'var(--paper)',
    panel: { DEFAULT: 'var(--panel)', 2: 'var(--panel-2)' },
    ink: { DEFAULT: 'var(--ink)', 2: 'var(--ink-2)', 3: 'var(--ink-3)' },
    line: { DEFAULT: 'var(--line)', 2: 'var(--line-2)' },
    brand: { DEFAULT: 'var(--brand)', ink: 'var(--brand-ink)', soft: 'var(--brand-soft)', on: 'var(--on-brand)' },
    ai: { DEFAULT: 'var(--ai)', soft: 'var(--ai-soft)' },
    good: { DEFAULT: 'var(--good)', soft: 'var(--good-soft)' },
    warn: { DEFAULT: 'var(--warn)', soft: 'var(--warn-soft)' },
    crit: { DEFAULT: 'var(--crit)', soft: 'var(--crit-soft)' },
  },
  fontFamily: {
    sans: ['Public Sans', '-apple-system', 'Segoe UI', 'sans-serif'],
    mono: ['IBM Plex Mono', 'ui-monospace', 'SF Mono', 'Menlo', 'monospace'],
  },
  borderRadius: { card: '10px' },
  boxShadow: { card: 'var(--shadow)' },
} as const;

// Fonts (self-hosted; do NOT use a font CDN):
//   pnpm add @fontsource/public-sans @fontsource/ibm-plex-mono
// In the root layout:
//   import '@fontsource/public-sans/400.css'
//   import '@fontsource/public-sans/600.css'
//   import '@fontsource/public-sans/700.css'
//   import '@fontsource/ibm-plex-mono/400.css'
//   import '@fontsource/ibm-plex-mono/600.css'
