# Build status

**✅ Builds via the MPLAB X toolchain** (`make CONF=default`) for the dsPIC33AK256MC506
— 0 errors, 0 implicit-declaration warnings, full `.elf` → `.hex`.

| | |
|---|---|
| Toolchain | MPLAB XC-DSC v3.30 (elf-gcc 8.3.1) |
| Device pack | dsPIC33AK-MC_DFP 1.4.172 |
| Device | dsPIC33AK256MC506 |
| Build | `make CONF=default` (MPLAB makefiles committed; IDE Build also works) |
| Source files | 52 `.c` compiled, 0 failures |
| Link | OK → `.elf` / `.hex` |
| Program memory | 67,844 B (**25%**) |
| Data memory | 6,602 B (**10%**) |
| ISRs resolved | `__AD1CH0Interrupt` (ADC), `__T1Interrupt`, traps |

Build config: `FEATURE_ADC_CMP_ZC=0` (software ZC), `FEATURE_HW_OVERCURRENT=0`
(ATA6847 SCPCR/ILIM handle protection), FOC dormant.

**To build:** open `garuda_ese.X` in MPLAB X and Build, **or** headless:
```
cd garuda_ese.X && make CONF=default   # XC-DSC v3.30 on PATH
```

## Device-port fixes applied (AK128MC106 → AK256MC506)
- **ADC**: 5-core model — channel config `ADnCHxCON1` (was single `ADnCHxCON`), `FRAC` (was `LEFT`); dedicated BEMF channels on AD1/AD2/AD3/AD5.
- **PWM**: split registers `PGxIOCON1/2`, `PGxEVT1/2`, `PGxCLPCI1/2`, `PGxSPCI1/2`; no `FPCI` on the 506 (dsPIC PWM fault-PCI disabled — the ATA6847 handles faults); fault field `FLT1ACT`.
- **Op-amps**: AMP register has no `OMONEN` on the 506 (removed).
- **SPI2** (not SPI1) to the ATA6847.
- Feature-gated struct members (`hwzc`, `ibusRaw`) guarded; `hal_comparator.c` (CMP3-OC) excluded.

## Commutation IOCON + POLH  ✅ DONE
- **Commutation IOCON encoding**: `pgIoconWord()`/`PG_IOCON_*` re-mapped to the 506's
  `IOCON2` override-field positions (`OVRENH=bit21`, `OVRENL=bit20`, `OVRDAT=bits[13:12]`);
  PENH/PENL moved to where they belong (`IOCON1`, set once at init). Was "writes IOCON2 to
  compile" — now the **bit pattern is correct**.
- `hal_pwm.c`: high-side **POLH=1** (active-LOW for the ATA6847 INH) on PG1/2/3, POLL=0.
  POLH inverts only the final H pin after the override mux, so the override encoding is
  unchanged — matches the bench-proven `garuda-ak-ata-esc` ATA6847 driver.
- **Dead-time kept, not zeroed** — the proven ATA reference runs ~100 ns MCU dead-time
  *alongside* the ATA internal dead-time, and `MIN_DUTY = 2×DEADTIME_COUNTS` needs it.

## Remaining for bring-up (electrical correctness, not compile) — see `garuda_ese.X/INTEGRATION_TODO.md`
- Scope the H/L pins per sector vs the commutation table; confirm `ChargeBootstrapCapacitors()`
  is appropriate (ATA may use an internal HS charge pump → bootstrap pre-charge may be moot).
- Verify clock/PLL and the `_AD1CH0Interrupt` cadence on hardware.
- The build validates compilation/link + register encoding — **not** yet verified on silicon.
