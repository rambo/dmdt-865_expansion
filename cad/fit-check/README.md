# Four labelled T865 expansion connector fit gauges

**R2: contact inspection holes enlarged from 1.6 to 2.4 mm**, leaving 0.6 mm
webs between adjacent holes. Raised R2 labels identify this revision. The mounting
hole pattern, contact centres, plate thickness and four offset variants are unchanged.

**Print `T865-four-plates.stl` to test all four offsets in one batch.** It contains
four separate, watertight plates arranged 2 x 2 with a 6 mm gap. The combined
footprint is **86 x 102 mm**. Units are millimetres; print at **100% scale**.

Each plate is **40 x 48 x 1.2 mm**, with **0.6 mm raised labels**, for a maximum
height of **1.8 mm**. The labels are boolean-unioned into the plate, not floating
text shells. Individual `T865-P1` through `T865-P4` STL/DXF files are also supplied.

Print flat with Z = 0 on the bed, preferably PLA and 0.2 mm layers, without raft
or supports. The labelled face goes up. Small printed holes may need clearing
of plastic; there is no printer-specific hole-size compensation.

## What differs between the four plates

All four share provisional **32 x 40 mm mounting centres**, four **2.4 mm M2
clearance holes**, and twelve **2.4 mm inspection holes** on a **3 x 3 mm grid**.
Only the contact-grid offset changes between variants. The raised P1-P4, R2, X and Y labels identify
the plate and its pin-11 location relative to the lower-left screw centre.

| Plate | Pin-11 X (mm) | Pin-11 Y (mm) | Shortest diagonal edge gap (mm) |
| --- | ---: | ---: | ---: |
| P1 | 5.500 | 12.367 | 11.860 |
| P2 | 6.000 | 12.132 | 11.860 |
| P3 | 6.500 | 11.872 | 11.860 |
| P4 | 7.000 | 11.584 | 11.860 |

The diagonal fixes a radius, not a unique XY coordinate. These four positions
vary the angle along the **13.535 mm centre-distance arc**, covering the much
less certain axis offsets. The contact grid itself remains rectangular; it is
translated, never rotated. Three decimal places describe calculation precision,
not the accuracy of the physical measurements. Raised labels round to 0.01 mm.

## Orientation and checking fit

Look at the tablet back with camera toward the top and USB cable exiting right,
as in IMG20261107151256. X goes right and Y goes up. Mount A, the lower-left
screw centre, is (0,0). B is (32,0), C is (32,40), D is (0,40).
The **larger corner chamfer identifies A**. The opposite left mounting hole D
also retains the round connector cap; take its existing screw/head and cap strap
into account when placing the gauge, and restore that fastener after any removal.

The twelve inspection holes should line up over the tablet's contact openings.
From the bottom going upward, the left column is 11,9,7,5,3,1; the right is
12,10,8,6,4,2. Pin 12 is 3 mm right of pin 11; pin 1 is 15 mm above pin 11.
These are visual inspection holes, not solderable pogo-pin footprints. No model
has protruding pins that could touch the electrical contacts.

Raised tablet features or the cap strap may keep a flat gauge from seating flush.
Do not force screws to compensate for a positioning mismatch. Compare all four
gauges and report the best label and any remaining shift. The mounting spacing
itself remains provisional and is identical across the four tests.

`four-plates-preview.png` and individual `layout-P1.png` etc. show the rear-view
hole coordinates and actual raised lettering contours. These diagrams are not
print-to-scale paper templates. The STLs are printable at 100% in millimetres.

## Measurement provenance and uncertainty

* Earlier mounting spans **33.55 and 41.37** used the farthest edges of the
  **1.75 mm threaded openings**, as finally clarified by the user. Subtracting
  1.75 gives **31.80 and 39.62 mm centres**. Nominal 32 x 40 follows the user's
  whole-millimetre hypothesis, but remains unconfirmed; the long-axis difference
  is 0.38 mm. Do not substitute the brass insert OD into this calculation.
* New pin-11 photo spans **8.58 and 15.01** used outside edges of the **3.3 mm
  brass insert OD and 1.6 mm contact opening**. The plastic ring is about 4 mm
  and is not a measurement reference. Subtracting (3.3+1.6)/2 gives a rough
  X=6.130, Y=12.560. Photos: IMG20261107165024 and IMG20261107164853.
  The user reports much larger error in these two measurements because there
  was no hard stop. They indicate the likely angle; they are not exact constraints.
* Later shortest diagonal gap from the **threaded opening edge** to pin-11
  opening edge is **11.86 mm**; adding 1.75/2+1.6/2 gives **13.535 mm centres**.
  Additional diagonal readings are **11.75 and 12.00 mm**, with about **+/-0.1 mm**
  error. The first print keeps 11.86 as its working gap for all variants.
* For each chosen X, Y=sqrt(13.535^2-X^2). The photo-only offset would instead
  predict a diagonal edge gap of about 12.301 mm. The approximate axis spans
  and diagonal cannot all be satisfied simultaneously with the supplied diameters.

First-print feedback: P1 showed slight top mounting-hole misalignment; P2 looked
well aligned there. Original and R2 P1-P4 all have the same mounting centres, so
this observation alone does not establish a CAD mounting-pattern correction.
Placement, printing and seating differences are not isolated. The original 1.6 mm
inspection holes made the contact alignment hard to judge. R2 retains all four
offsets and enlarges the windows; no best contact offset has been established.
Photos IMG20261107175954 and IMG20261107180655 are retained under
`../../measurements/photos/`. These are observations of the earlier prints, not
validation of the R2 prints. Physical corner/pose differences were not calibrated.

There is no established OEM mounting drawing, thread depth or final electrical
connector fit here. This remains a positioning experiment.

## CAD, source and validation

DXFs use true circles and closed polylines in millimetres. OUTLINE, MOUNT_HOLES
and CONTACT_HOLES describe the 1.2 mm base. **RAISED_LABELS is a separate layer**:
exclude it from the base cutouts, then extrude the lettering regions upward
0.6 mm from the plate top, retaining the counters in P/0/etc. The combined DXF
uses the same 2 x 2 arrangement as the combined STL.

`dimensions.json` contains the dimensions and four X offsets. Individual
`hole-centres-P1.csv` etc. contain the unshifted local hole coordinates. Rear-view
coordinates are not a mirrored PCB mating-side view.

Regenerate with Python 3.12:

```sh
python3 -m venv .venv
.venv/bin/python -m pip install -r requirements.txt
.venv/bin/python generate.py
```

The generator reopens every STL and DXF, checking units, DXF audit, all hole
centres/radii, positive volume, consistent winding, watertightness, bounds,
expected volume including lettering and sixteen through-holes per plate.
Each labelled plate must be **one connected solid**, and the combined STL must
contain **four** connected solids. The combined DXF must contain **64 circles**.
`validation.json` records the checks; they do not establish physical fit.

Source and deliverables are versioned at
`git@github.com:rambo/dmdt-865_expansion.git`. Files over 1 MB use Git LFS;
the combined STL is LFS-managed. Install Git LFS and run `git lfs install`
before cloning. In an existing clone, `git lfs pull` downloads the full files.
