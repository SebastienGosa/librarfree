# Design Previews — UX Redesign V1

This folder holds AIDesigner artifacts (HTML), rendered PNG previews, and
Z-Library audit screenshots for the V1 editorial redesign.

## Status (2026-04-18)

- **AIDesigner artifacts** — not yet generated. OAuth on the
  `aidesigner` MCP server was required and no interactive session was
  available during the autonomous run. The two prompts are ready to use
  and live in `docs/UX_REDESIGN_V1.md` section "AIDesigner Prompts".
- **Z-Library audit screenshots** — the live `z-library.sk` host failed
  TLS name validation and WebArchive + direct hosts were blocked from
  the fetch environment. The textual audit in `UX_REDESIGN_V1.md` uses
  published reference material (Wikipedia, external UX reviews) plus
  deductions from the project brief. Re-capture with Playwright when
  a valid network path is available.
- **Librarfree preview PNGs** — once artifacts are generated and ported,
  capture full-page screenshots of the running homepage (desktop +
  mobile) and drop them here as `homepage-desktop.png`,
  `homepage-mobile.png`, `featured-detail.png`, etc.

## How to generate the artifacts

1. Authenticate the MCP server in your Claude Code client:
   - Call `mcp__aidesigner__authenticate`
   - Open the returned OAuth URL, sign in, approve
2. Copy prompt 1 from `docs/UX_REDESIGN_V1.md` → call
   `generate_design` with it
3. Save the returned HTML as `homepage-artifact.html` in this folder
4. Repeat with prompt 2 → `search-reader-artifact.html`
5. Render previews locally: open the HTML files in a browser and
   screenshot, or run
   `npx -y @aidesigner/agent-skills capture --html-file apps/web/public/design-previews/homepage-artifact.html`

## Budget

Target: ≤ 6 AIDesigner credits total for V1.
- Artifact 1 (homepage + book detail): ~3 credits
- Artifact 2 (search + reader + mobile): ~2-3 credits
- Buffer: 1 refine pass if needed

Stop and report if a single generation or refine would push total > 6.
