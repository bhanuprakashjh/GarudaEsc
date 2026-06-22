# GarudaESE / EV60Y51A — Developer Bring-Up Plan

A staged procedure for a developer bringing this firmware up on the **EV60Y51A
V1.0** board for the first time. It complements the spreadsheet
`ESC_BringUp_Checklist_16_june_2026.xlsx` (P0–P11) with the firmware-specific
detail. Read `GarudaESE_Port_Reference.md` first.

> **The firmware is validated only at compile/flash + schematic-review level.
> No stage past S1 has been run on hardware. Treat every "expected" below as a
> hypothesis to confirm, not a guarantee.**

---

## 0. Safety rules (non-negotiable)

1. **Bench DC supply in constant-current (CC) mode is your primary protection.**
   Until the current-sense chain is calibrated (S5), the software/ATA current
   limits are *uncalibrated*. Start every powered stage with a **hard CC limit
   (2–3 A)** and **low Vbus (6–12 V)**. **Never use a battery before S6.**
2. **25 V / 6S is the hard bus ceiling** for this board/campaign.
3. **No propeller** until S6 on a secured test stand. Use a small unloaded motor
   for S3–S5.
4. **Gates are SPI-gated**: they cannot switch until firmware sets DOPM=Normal +
   GDU Normal. If the ATA SPI handshake fails, `g_ataReady` stays false and the
   firmware refuses to drive — that is the intended behaviour, not a bug.
5. Inline fuse / e-stop on the supply. Thermal camera or finger-near-but-not-on
   the FETs for the first spins.

## Equipment
Current-limited DC supply 0–30 V ≥5 A · 4-ch scope + diff probe + current probe ·
DMM · PICkit/ICD · small unloaded BLDC motor · USB-serial for GSP (broker/Studio)
· (later) USB-CAN, DShot source, electronic load, heatsink, final motor+prop.

---

## S0 — Visual & power (unpowered, then logic-only)

- Inspect assembly: shunts (R46/47/48/57 = 2 mΩ), MOSFETs, ATA6847, dsPIC, no
  bridged pins. No DNP parts in V1.0.
- Power the **logic only** (or very low Vbus with the bridge unable to conduct):
  confirm the ATA LDOs come up — **VDD1 = 5.0 V, VDD2/VVIO = 3.3 V**.
- Confirm 3.3 V rail, MCLR, and that the programmer sees the device ID
  (it is **dsPIC33AK256MC506-E/M7**; ignore any "MC505" label on the sheet).

**Pass:** rails correct, device detected. **Stop if** any rail is wrong.

---

## S1 — Flash, comms, sensors (no bridge drive)  ✅ partially done

1. Build (`make CONF=default`) and flash. Board boots **disarmed**, LED idle, no
   gate switching.
2. Bring up **GSP** over the debug UART (RD7/RD8) via the broker / Garuda Studio.
   Confirm the INFO frame + live snapshot decode.
3. Read telemetry at rest (bridge off):
   - **Vbus** reads correctly (≈ supply × 97.5 counts/V; e.g. 12 V → ~1170).
   - **Iu, Iv, Iw, Ibus** all read near their rest bias and are *stable* (this is
     the first proof the dsPIC OA1/OA2 + ATA CSA2/CSA3 sense chains work on this
     board). Note the rest bias of each — you'll need it for S5.
   - TEMP reads a plausible value (NTC).
4. **ATA SPI handshake** — the decisive SPI-direction check:
   - Confirm `EnterGduNormal()` **returns success** (`g_ataReady == true`). The
     driver instruments GDUCR1/DOPMCR readback over the GSP/UART hex path.
   - Read back a known ATA register (DOPMCR should reflect Normal). Garbage / all-
     0xFF ⇒ SPI mis-wired or mode wrong → **do not proceed**.

**Pass:** GSP live, all four currents + Vbus + temp sane, `g_ataReady` true,
ATA registers read back correctly.
**Common failure:** ATA reads 0xFF / no response ⇒ re-check SPI2 PPS
(RB11=SDO2 out, RC9=SDI2 in, RB10=SCK, RC8=nCS) and mode (CKP=0/CKE=0/SMP=1).

---

## S2 — Scope the bridge (current-limited, low Vbus, motor leads OPEN)

PSU at **6–12 V, CC ~1 A**. Motor disconnected (or leads open). Command
START → ALIGN (GSP `START_MOTOR`, or RD5 arm). With overrides released into ALIGN:

- **Scope each phase H/L** against the commutation table. Confirm:
  - High-side drive is **active-LOW** at the ATA input (H pin low = HS on).
  - The 6 commutation states match the table (one phase driven high-PWM, one
    pulled low, one floating), rotating correctly.
  - **Dead-time** present between H and L; **no shoot-through**.
  - **Switching frequency = 45 kHz** on a phase node (validates the
    MCLKSEL=1 / 400 MHz PWM-clock path — do *not* "fix" MCLKSEL to match the
    AK128 reference, that would halve Fsw).
- Confirm the **ADC trigger** sits in the PWM-ON window of the floating phase (so
  the duty-proportional ZC neutral is sampled at the right instant).

**Pass:** correct active-low 6-step pattern, dead-time present, 45 kHz, no
shoot-through. **This is the decisive proof that POLH=1 + the IOCON2 override
rework are electrically right.**

---

## S3 — First motor spin (current-limited PSU, low Vbus)

**PSU: CC hard limit 2–3 A, Vbus 6–12 V. Small unloaded motor.**

**Three ways to arm + set speed (use whichever suits the bench):**
- **Pot (default):** turn the TP5/RA6 knob — but set it to **0 before arming**
  (a floating/non-zero pot blocks arming and is itself the throttle).
- **Hardware ARM switch (RD4/J1, active-low toggle):** flip to **armed** (→GND)
  to arm; flip to **open** to **kill** the bridge at any time. A handy bench
  e-stop. Pair with the pot or GUI for speed.
- **GUI / GSP, no pot needed:** `SET_THROTTLE_SRC(GSP)` → `START_MOTOR` →
  `SET_THROTTLE(n)` to ramp → `STOP_MOTOR`. `SET_THROTTLE_SRC(ADC)` returns the
  knob. The GUI can arm and ramp entirely on its own.

1. Soften startup for an unknown motor: in `gsp_params.c` profile-2 slot
   temporarily `alignDutyPct 3→2`, `rampDutyPct 8→4`. Confirm the EEPROM CRC
   forces fresh defaults (or set `FEATURE_PARAMS_FORCE_DEFAULTS=1`).
2. Command align → ramp → closed-loop. Watch the PSU clamp and the GSP current
   telemetry (Iu/Iv/Iw/Ibus).
3. Expect an inrush at the OL→CL hand-off (`MIN_DUTY ≈ 5.4 %`). If the PSU folds
   back hard, **lower duty further — do not raise the current limit.**

**Pass:** motor spins up, commutation locks, PSU stays within the CC limit.
**Watch for:** desync (rough running, current spikes), a fault latch (LED), and
the bus current trend. If it faults immediately, check `faultCode` and
`g_ataDiag` over GSP.

---

## S4 — Closed loop, low speed

Small GSP throttle steps. Confirm ZC lock and clean commutation at low eRPM,
smooth acceleration/deceleration, no desync. Try the **ZC neutral models**
(`ZC_NEUTRAL_MODEL`) if the default duty-proportional model struggles on this
motor: `ZC_NEUTRAL_COMPUTED` ((Vu+Vv+Vw)/3) is now available (simultaneous phase
sampling); `ZC_NEUTRAL_VBUS_HALF` and `ZC_NEUTRAL_EXTERNAL` (BEMF_N) are also
selectable. `FEATURE_HWZC_FILTER_COMP` composes with any.

**Pass:** stable closed loop across a low-speed throttle sweep, sync maintained
both directions.

---

## S5 — Calibrate current sense & protection (CRITICAL before raising Vbus)

The current readings are uncalibrated until this step.

1. **Current scaling.** Drive a **known current** (CC source / electronic load /
   calibrated ammeter) through each phase and the bus. Record ADC counts vs amps
   for **Iu/Iv (dsPIC OA gain)** and **Iw/Ibus (ATA gain ≈16, 2 mΩ)** — they are
   **different** scales. Derive counts/amp for each.
2. **Software OC thresholds.** Set `SW_PHASE_OC_TRIP_COUNTS` (phase) and
   `SW_BUS_OC_TRIP_COUNTS` (bus) to your desired trip amps using the measured
   counts/amp. Note the phase threshold is shared across Iu/Iv/Iw which have
   *different* gains — if that asymmetry matters, split it (dsPIC vs ATA channels).
3. **ATA ILIM / SCPCR.** Re-derive `ILIM_DAC` (cycle-by-cycle chop), `SCTHSEL`
   and `SCFLT` (VDS short) for the 2 mΩ shunt + BSC028N06 + your Vbus. The
   carried-over values are for a different board.
4. Verify each trip **actually fires** at the intended level (ramp current into
   the limit on the bench) and latches `ESC_FAULT` + kills the bridge.
5. Confirm the **nIRQ** path: provoke an ATA fault and confirm it latches; decide
   whether to classify/clear/debounce (see Port Reference §12.8).

**Pass:** measured counts/amp recorded; phase + bus OC trip at the set amps;
ATA ILIM caps current; nIRQ latches a fault.

---

## S6 — Raise toward 6S (only after S5)

Before any battery / unlimited supply:
1. **Set the real motor profile** (pole pairs, λ, align/ramp) — profile 2 is the
   2810 bench motor.
2. **Raise Vbus UV** to ~17–18 V (1660–1755 counts) for 6S.
3. Confirm OV (2730 ≈ 28 V), regen-brake (2535/2400) and emergency-hold
   (2660/2560) thresholds behave on a rising/falling bus — they are now scaled to
   this divider and ordered below OV.
4. Step Vbus up gradually (12 V → 18 V → 24 V → 25 V), re-checking current,
   temperature, and sync at each step. Add a heatsink before sustained load.

**Pass:** stable operation to 25 V on the bench with calibrated protection.

---

## S7 — Loaded / propeller (secured stand) + DShot (optional)

Only after S6. Secured stand, prop, thermal monitoring, e-stop. If DShot/RX
throttle is wanted, wire the input and select it at runtime via `SET_THROTTLE_SRC`
(RX is compiled in but not the boot default).

---

## Quick reference — what protects the board at each stage

| Stage | Primary protection |
|---|---|
| S2–S4 | **Bench PSU CC limit** (current sense uncalibrated) |
| S5 | PSU + the trips you are calibrating |
| S6+ | Calibrated SW OC (phase + bus) + ATA ILIM/SCPCR + Vbus OV/UV + nIRQ + `g_ataReady` gate |

## Fault triage (read over GSP: `faultCode`, `g_ataDiag`, currents, Vbus)

| Symptom | Likely cause | Action |
|---|---|---|
| Won't drive, no switching | `g_ataReady` false (ATA SPI/GDU failed) | re-check SPI2 wiring/mode (S1) |
| Immediate OVERVOLTAGE | Vbus OV miscal / regen | check Vbus counts vs 97.5/V |
| Immediate UNDERVOLTAGE | UV too high for bench Vbus | UV is ~5 V default; raise only for battery |
| Immediate OVERCURRENT | OC threshold too low / bias not captured | confirm disarmed bias capture; raise threshold; check counts/amp |
| BOARD_PCI fault | ATA nIRQ asserted (UV/OT/VDS) | read `g_ataDiag`; check SCPCR threshold |
| Rough running / desync | ZC neutral model / blanking / startup duty | try `ZC_NEUTRAL_*`; soften align/ramp |
| Half speed / capped eRPM | ATA ILIM chopping (`ILIM_DAC` too low) | raise ILIM_DAC after S5 |

---

*Keep `gsp_params.c` profile edits and any threshold changes under version
control; record the per-channel counts/amp from S5 in the board's bring-up sheet.*
