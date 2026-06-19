# Build status

**✅ Compiles and links** for the dsPIC33AK256MC506.

| | |
|---|---|
| Toolchain | MPLAB XC-DSC v3.30 (elf-gcc 8.3.1) |
| Device pack | dsPIC33AK-MC_DFP 1.4.172 |
| Device | dsPIC33AK256MC506 |
| Source files | 52 `.c` compiled, 0 failures |
| Link | OK → `.elf` / `.hex` |
| Program memory | 67,784 B (**25%**) |
| Data memory | 6,602 B (**10%**) |
| ISRs resolved | `__AD1CH0Interrupt` (ADC), `__T1Interrupt`, traps |

Build config: `FEATURE_ADC_CMP_ZC=0` (software ZC), `FEATURE_HW_OVERCURRENT=0`
(ATA6847 SCPCR/ILIM handle protection), FOC dormant.

## Device-port fixes applied (AK128MC106 → AK256MC506)
- **ADC**: 5-core model — channel config `ADnCHxCON1` (was single `ADnCHxCON`), `FRAC` (was `LEFT`); dedicated BEMF channels on AD1/AD2/AD3/AD5.
- **PWM**: split registers `PGxIOCON1/2`, `PGxEVT1/2`, `PGxCLPCI1/2`, `PGxSPCI1/2`; no `FPCI` on the 506 (dsPIC PWM fault-PCI disabled — the ATA6847 handles faults); fault field `FLT1ACT`.
- **Op-amps**: AMP register has no `OMONEN` on the 506 (removed).
- **SPI2** (not SPI1) to the ATA6847.
- Feature-gated struct members (`hwzc`, `ibusRaw`) guarded; `hal_comparator.c` (CMP3-OC) excluded.

## Remaining for bring-up (electrical correctness, not compile) — see `garuda_ese.X/INTEGRATION_TODO.md`
- **Commutation IOCON encoding**: `pgIoconWord()`/`PG_IOCON_*` macros currently write `PGxIOCON2` to compile; the bit pattern must be re-mapped to the 506's `IOCON1` (pin-enable/polarity) + `IOCON2` (override) split for correct 6-step commutation. **Do before driving a motor.**
- `hal_pwm.c`: set high-side **POLH=1** (active-LOW for ATA NBH) + zero MCU dead-time (ATA internal).
- Verify clock/PLL and the `_AD1CH0Interrupt` cadence on hardware.
- First-build only validates compilation/link — **not** verified on silicon.
