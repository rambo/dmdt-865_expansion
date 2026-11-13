# LoRa teardown reference sources

LP3987H.pdf: manufacturer datasheet, revision 10 Sep 2022, retrieved 2026-11-11.
Source: https://admin.lowpowersemi.com/storage/files/2026-04/e58e13cbb5f9c58580aceb91f943f14e.pdf
SHA256: 87a2620a7574361cb0926b3471f6931f44faeb5e0cefd4e87a4441cd1c48e174
PDF parser warned about truncated EOF marker, but extracted all 11 pages; marking and pin table are on pages 1-2.

E220-900T30S.pdf — historical reference for a different 24-pad layout.
Superseded for this module by the user-confirmed 18-pad manual below; do not use its pin numbers for probing.
Source: https://www.cdebyte.com/Uploadfiles/Files/2022-1-10/2022110163667880.pdf
Retrieved: 2026-11-11
SHA256: 8653485f515337c0315cd767cc657e58990afb17b238ea21613a49730d86fdea

MP2155.pdf
Source: https://www.monolithicpower.cn/cn/documentview/productdocument/index/version/2/document_type/Datasheet/lang/en/sku/MP2155GQ/
Retrieved: 2026-11-11
SHA256: 83281da9f72c585e2f1062602fc6962886048aafe2e44ce306757772d237d342

## User-confirmed radio manual: 18-pad package

[E220-900T30S_UserManual_EN_v1.0.pdf](E220-900T30S_UserManual_EN_v1.0.pdf)

- Source: [EBYTE manual hosted by F1 Depo](https://www.f1depo.com/class/INNOVAEditor/assets/E220-900T30S_UserManual_EN_v1.0.pdf)
- Retrieved: 2026-11-13; user confirms this is the exact module manual.
- Size: 1,995,491 bytes; 23 PDF pages.
- SHA-256: `70feb45bad1afcb2470829c01a547fbe08653b265514481315d2a3cc49378375`.
- Section 3, printed pages 6–7 (PDF pages 7–8): 18-pad package; pins 1 M0,
  2 M1, 3 RXD, 4 TXD, 5 AUX, 6 VCC, 7 GND. Other grounds: 9, 15, 16, 17.
  Pin 18 ANT; pins 8, 10–14 NC.
- Pinout and both package views visually checked. The older E220-900T30S.pdf
  has a 24-pad layout and different numbering; it remains historical evidence only.

## E22 replacement candidate: separate manufacturer revision

[E22-900T30S-manufacturer-2022.pdf](E22-900T30S-manufacturer-2022.pdf)

- Source: [EBYTE-hosted manual](https://www.cdebyte.com/Uploadfiles/Files/2022-1-19/2022119174379296.pdf).
- Retrieved: 2026-11-13; 1,388,857 bytes; 27 PDF pages.
- SHA-256: `c057b2b2f92edf8d86d2f95a1eadff71201d565e78d6cb1b07acb60411577b98`.
- Dimension drawing visually inspected on PDF page 9 (printed page 8).
  It shows 18 physical pads with numbering through 24 and gaps.
- This is not asserted byte-identical to the user's
  [Hubtronics-hosted manual](https://hubtronics.in/docs/E22-900T30S-UserManual.pdf).
  That copy's text was readable through web retrieval, but direct download returned
  HTTP 403 and its drawing was unavailable for visual inspection.
- Material revision difference: the Hubtronics pin table lists pads 21 and 24 as
  NC; this OEM copy identifies +3.3 V and NRST respectively. Match the purchased
  module revision before any replacement.
- [Driver/replacement plan](../../docs/plans/EBYTE-RADIO-DRIVER.md) records the
  signal-position comparison and remaining compatibility checks.
