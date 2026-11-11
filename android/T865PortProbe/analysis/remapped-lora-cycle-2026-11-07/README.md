# remapped-lora-cycle-2026-11-07 capture notes

Captured during one user-requested LoRa enable cycle at 09:47 UTC on 2026-11-07.
See [REMAPPED-LORA-CYCLE-2026-11-07.md](../REMAPPED-LORA-CYCLE-2026-11-07.md) for mapping, validity and limitations.
User subsequently said CH3 probe might have become misaligned: pin-3 behavior
cannot be inferred from this cycle's flat CH3 record. No further cycle performed.
capture_scope.py is the scope-only helper; invoking arm changes scope setup.
It does not operate Android. UART/power activity was initiated using DMD's UI.
Voltage = (unsigned BYTE - preamble[8] - preamble[9]) * preamble[7].
Time = (index - preamble[6]) * preamble[4] + preamble[5].
relevant-logcat.txt contains the initialization/shutdown sequence, filtered from
captured logcat. Device timestamps are epoch seconds; host events use UTC ISO.
