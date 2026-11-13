# Reference documents retained from the investigation

These are archived reference copies and sourcing leads, not verified tablet
schematics or promises of present supplier stock. Manufacturer documents retain
their original authorship. The files' source groups and hashes are recorded in
`../docs/evidence-manifest.json` and [teardown source notes](lora-teardown/sources.md).

* [E220-900T30S exact module manual](lora-teardown/E220-900T30S_UserManual_EN_v1.0.pdf):
  user-confirmed 18-pad package, pin 6 VCC; use this for the radio-board probing.
  The historical `lora-teardown/E220-900T30S.pdf` has a different 24-pad layout.
* `radio-manuals/E220-900T22D_UserManual_EN_v1.0.pdf`: user-supplied E220 manual.
  The advertised radio uses nominal 3.3 V UART levels; this does not establish the
  tablet connector's electrical ratings or the exact module output topology.
* `uart-bridge/WK2124.pdf`: candidate bridge datasheet. A wk2xxx SPI driver is
  observed, but the tablet's exact UART-bridge silicon is not confirmed.
* `fcc/`: FCC exhibits and their source URLs/hashes in `SOURCES.md`.
  `inspection/` retains reviewed/extracted board images and Topicon module photos.
  No reviewed exhibit was established as a teardown of the complete Topicon LoRa
  accessory. The EByte exhibit is a different 433 MHz E220 variant.
* `connector-datasheets/Mill-Max-discrete-pogo-pins.pdf`: individual through-hole
  pin drawings, including 0906-1 and 0914-0.
* `connector-datasheets/Harwin-P70-600.pdf` and `Harwin-P70-20X.pdf`: SMT contacts
  with locating pegs and small spherical tips.
* `connector-catalogues/euroconn-3mm.pdf`: 3 x 3 mm grid, but 2x5 contacts.
  A 2x6 version/availability was not verified.
* `connector-catalogues/neltron.pdf`: 3 mm single-row families; two six-way strips
  were considered as a possible alternative. Six-way availability needs confirmation.
* `connector-catalogues/degson.pdf`: DG1156-17 is a 2x6 pogo block, but its pitch
  was not established from the catalogue.
* `connector-catalogues/uwe6.pdf`: six-way 3 mm strip with a housing too wide to
  simply place two strips on 3 mm row centres.

Individual pin candidates found at Mouser, with stock/prices from indexed listings
rather than a live cart:

| Part | Tip diameter | Free / normal working height | Mounting |
| --- | ---: | ---: | --- |
| Mill-Max 0906-1-15-20-75-14-11-0 | 1.07 mm | 4.50 / 3.80 mm | Through-hole, at least 0.51 mm finished hole |
| Mill-Max 0914-0-15-20-77-14-11-0 | 1.07 mm | 6.96 / 5.82 mm | Through-hole, at least 0.74 mm finished hole |
| Harwin P70-6000045R | 0.60 mm | 2.80 / 2.10 mm | SMT with short locating peg |

The larger Mill-Max flange stays outside the tablet's 1.6 mm opening. Recess
depth, working compression and final PCB spacing still need physical measurement.

Original sourcing pages:

* https://www.mouser.fi/en/ProductDetail/Mill-Max/0906-1-15-20-75-14-11-0
* https://www.mouser.fi/en/ProductDetail/Mill-Max/0914-0-15-20-77-14-11-0
* https://www.mouser.fi/en/ProductDetail/Harwin/P70-6000045R
* https://www.mill-max.com/sites/default/files/external/catalog/2019-04/023M-028M.pdf
* https://www.harwin.com/products/P70-6000045R
* https://www.harwin.com/products/P70-2010045R
* https://euro-conn.com/images/catalogo-datasheet/A-06-POGO-PIN/07-EC3000599M10XX/EC-30005990101.pdf
* https://www.camelgeco.it/wp-content/uploads/2022/11/Neltron-Pogo-Pin-Series.pdf
* https://www.spezial.com/userdata/filegallery/original/510_degson_-_data_connectors.pdf
* https://www.uweelectronic.de/images/ue-products/kontakttechnologie/Batteriekontakte/UEBK-30269-30270/UEBK-30269-30270.pdf
