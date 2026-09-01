# Miles-HUB v6 — Design Doc (V1)

> Status: DESAIN DISETUJUI — siap implementasi
> Target: Grow a Chicken Fighter, executor Delta (cloud phone), loadstring dari GitHub

## Pemahaman

- Script auto-grind penuh (idle) yang aman dari kick, dimuat via `loadstring(game:HttpGet(...))`.
- V1 = loop inti dengan remote asli. V2 = inventory-based (select egg/chicken dari data pemain).
- GUI parent langsung ke PlayerGui (terbukti berfungsi di Delta). Pure ASCII (emoji/unicode rusak file di cloud phone).

## Fitur per Tab (V1)

| Tab | Fitur |
|---|---|
| **Egg** | Auto Collect egg map · Auto Claim Incubator · Auto Hatch (egg selector statis + HatchDelay slider) · Auto Sell After Hatch · Auto Fuse + Fuse Now |
| **Farm** | Auto Buy/Upgrade Coop · Feeder · Recycler |
| **Tower** | Auto Tower Grind + Target Floor slider · Feed Before Fight · Auto Rebirth (scrap→recycler→rebirth) + Rebirth manual |
| **Event** | Auto Join Events + 4 toggle (Hot Eggs, UFO Invasion, Golden Goose, Chicken Boss) |
| **Setting** | FPS Booster · Anti-AFK · Rejoin on Disconnect · Inf Jump · WalkSpeed · JumpPower |
| **Debug** | Daftar remote asli (ReplicatedStorage + PlayerScripts) · Refresh · Status tiap loop |

## Arsitektur

- 1 manager `Loops`, tiap fitur = 1 loop function, dijalankan `task.spawn` (TANPA RunService — sumber kick).
- Semua aksi lewat gateway `Fire(name, ...)`:
  - Cek remote benar-benar ada; tidak ada → jangan fire, log ke Debug tab.
  - Delay acak 100–400ms sebelum fire.
  - Dibungkus pcall.
- Loop hanya jalan saat toggle ON. Status per loop tampil di Debug tab.

## Interval Loop (±30% random)

| Fitur | Interval |
|---|---|
| Hatch + Sell | 0.5–2s (HatchDelay) |
| Collect egg / incubator | 1.5s |
| Fuse | 3–5s |
| Upgrade farm | 4–8s |
| Tower grind + feed | 1–2s |
| Event join | 5–10s |
| Rebirth | sesuai target floor |

## Non-goal V1 (YAGNI)

- NoClip & Speed **di-drop** (anti-cheat risk, tidak terkait auto-grind). Inf Jump dipertahankan (terbukti aman).
- Select-by-inventory (jarum = kategori per egg, fuse selectable) → V2 setelah deteksi data.

## Decision Log

1. **V1 dulu, V2 menyusul** — fitur inventory-based butuh deteksi struktur data; loop inti lebih dulu agar ada nilai pakai. (opsi: semua sekaligus, scan-dulu → ditolak)
2. **Tab Debug di GUI** — user tidak bisa buka console F9 di cloud phone; nama remote dibaca langsung dari GUI. (alternatif: auto-guess banyak nama → rapuh/risiko kick; print console → tidak terlihat)
3. **Paduan waktu lambat & random** — menghindari pola spam yang terdeteksi anti-cheat.
4. **Layout 6 tab** — reorganisasi dari layout lama yang campur aduk; emoji dihapus (rusak encoding).

## Open Question

- V2: sumber data inventory (folder data clone di PlayerGui/PlayerScripts?) — ditentukan saat scan Debug.