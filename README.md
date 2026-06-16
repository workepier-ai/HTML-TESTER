# HTML-TESTER — Dealership VIN scanner → check-in PDF portal

Two static pages that share one Supabase table:

| Page | Runs on | Does |
|------|---------|------|
| `index.html` | phone (paddock) | Scan/enter vehicles, then **Send to PC** uploads them to Supabase |
| `portal.html` | the PC | Polls Supabase, fills the official **New-Vehicle check-in PDF** (`forms/new_vehicle.pdf`), and prints one form per vehicle on one tap |

The PDF is the user's existing fillable form with `m_*` (Mitsubishi) / `s_*` (Suzuki)
AcroForm fields; the portal fills the block matching each record's brand and ticks
`m_Checkbox` / `S_Checkbox`. Filling uses the same pdf-lib approach as the von Bibra
contract portal (`getTextField().setText()` → `flatten()` → merge → canvas + `window.print()`).

## Setup

1. **Create the Supabase table.** Run `supabase/migrations/20260616_vehicle_checkins.sql`
   in the Supabase SQL editor (or `supabase db push`). It creates `public.vehicle_checkins`
   with RLS allowing the publishable/anon key to insert, read, and mark-printed — matching
   the project's other internal tables. The Supabase URL + publishable key are already wired
   into both pages.

2. **Serve the files** from any static host (the same place the scanner is hosted is fine).
   Both Supabase fetches and the canvas print need an `http(s)` origin.

3. **On the PC**, open `portal.html` in Chrome and leave it on. New vehicles appear in the
   sidebar within ~5s of being sent. Click a vehicle (or **Print all pending**) → **Print**.

## Printing

- **One-tap (default):** clicking Print shows the normal print dialog.
- **Silent (optional):** launch Chrome with `--kiosk-printing` and toggle **Kiosk mode** in
  the portal header — forms then print to the default printer with no dialog.

## Flow

`paddock phone → Send to PC → Supabase (vehicle_checkins) → PC portal polls → fill PDF → print → mark printed`

Records are marked `sentAt` locally so re-tapping **Send to PC** only sends new ones
(idempotent server-side via `client_t`). The portal sets `printed_at` so nothing reprints.
