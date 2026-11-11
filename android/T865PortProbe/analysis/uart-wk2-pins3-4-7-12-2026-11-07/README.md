# uart-wk2-pins3-4-7-12-2026-11-07 capture notes

See [UART-PIN12-RESULT-2026-11-07.md](../UART-PIN12-RESULT-2026-11-07.md) for setup, interpretation and limitations.
Ground pin 1, CH1->3 CH2->7 CH3->4 CH4->12. Scripts record real hardware actions; not dry-run tests.
BYTE volts = (value - preamble[8] - preamble[9]) * preamble[7].
Time = (index - preamble[6]) * preamble[4] + preamble[5].
