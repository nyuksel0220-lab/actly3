# Actly Design System

## Design thesis

Actly treats a behavior plan as an engineered operating system, not a wellness mood board. The interface borrows from technical drawings, instrument panels, wiring diagrams, and blueprint notation while remaining readable on a small phone.

## Palette

| Token | Hex | Role |
|---|---|---|
| Ink Navy | `#071827` | App background |
| Blueprint Blue | `#0D3150` | Diagram nodes and primary technical surfaces |
| Panel Blue | `#102B42` | Cards and sheets |
| Signal Cyan | `#38BDF8` | Active controls and full-plan success |
| Rescue Amber | `#F2B84B` | Backup route, caution, and rescue success |
| Paper Blue | `#EAF3F8` | Primary text |
| Muted Steel | `#89A3B5` | Secondary text and inactive states |
| Fault Red | `#D45B62` | Destructive actions only |
| Grid Line | `#174360` | Blueprint background grid |

Signal Cyan and Rescue Amber are not a good/bad pair. Both represent valid completion routes. Red is reserved for irreversible deletion and storage failure recovery.

## Typography

- **Display:** `Roboto Condensed`, with platform condensed fallbacks. Used for page statements and section headlines.
- **Body:** `Roboto`, with platform system sans-serif fallbacks. Used for instructions and controls.
- **Data:** platform monospace with tabular figures, preferring `Roboto Mono` or `Menlo`. Used for confidence, percentages, counts, and technical labels.

No remote font download is required. The application remains fully offline.

## Signature component

The reusable `IfThenDiagram` is the identity anchor:

```text
IF [recurring real-life trigger]  - - - ->  THEN [observable action]
```

It appears in plan creation, the home screen, the reminder card, and plan editing. Dashed connectors, node coordinates, square-ended gauges, and compact technical labels make screenshots identifiable without relying on decorative illustration.

## Shape and elevation

- 6–8 px corner radius, never oversized pills.
- Opaque surfaces, one-pixel technical borders.
- No glass blur, gradient blobs, or pervasive drop shadows.
- Motion is limited to the confidence sweep and reminder-card transition, and both respect reduced-motion settings.

## Copy rules

- Plain, concise, and specific.
- No exclamation marks in product feedback.
- No moral judgment, streak guilt, or motivational clichés.
- A backup completion is described as a rescue, not a lesser success.
- Buttons use an explicit verb: `Save plan`, `Start now`, `Use backup plan`, `Export my data`.
