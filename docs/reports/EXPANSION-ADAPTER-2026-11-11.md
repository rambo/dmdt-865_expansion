# Expansion adapter / contact relocation plate - 2026-11-11

Evidence: four user-supplied photos in
[photos and previews](../../measurements/photos/expansion-adapter-2026-11-11/) (original HEIC + JPEG previews).
No hardware operations or continuity measurements performed.

## Visible construction

- A long flexible printed circuit links two 2 x 6 contact arrays.
- One end has a spring-contact block: exposed pogo tips in IMG20261111201131;
  its soldered rear is shown in IMG20261111202302.
- The other end has twelve flat circular contact lands and two mounting holes
  in the flex/stiffened end, shown in IMG20261111202258.
- The assembled support plate relocates the contact interface longitudinally.
- No ICs, regulators or other populated electronic components are visible on
  the exposed flex. This is consistent with a passive interconnect.
- User reports four mounting screws at one end and two at the presumed phone
  end. Preserve this observation without assigning the host device model.

## Flex printing, as read from IMG20261111201131

```text
MDT65-barometer-FPC-V10-20250916
JFHD-MDT865
```

The MDT865 text is a direct association with the tablet platform. The
barometer name may reflect a shared or reused flex design; it does not show
that a barometer sensor is present on this adapter. MDT65 alone is insufficient
to identify a DMD-T665 phone accessory.

## Compatibility check (manufacturer pages retrieved 2026-11-11)

https://www.thorkracing.com/produto/dmd-t865-t880-lora-module/

```text
Product is described as the DMD-T865/T880 LoRa module.
```

https://docs.dmdnavigation.com/otherapps/manage-app/

```text
Lists LoRa for T865X/T880X/Norte and explicitly says T665 does not support LoRa.
```

Neither source identifies this particular extension plate. Phone compatibility
therefore remains unconfirmed; do not label it as a verified T665 adapter.

## Electrical implications

This could be useful for accessing module connections away from the tablet,
provided its mechanical fit and continuity mapping are verified first. Twelve
contacts do not establish twelve independent nets, and a passive flex does not
prove a position-for-position mapping. Some routing uses vias and wider copper
areas; no net assignments are made from these photos. Preserve a defined view
of each mating face when numbering: changing faces can mirror the layout.

The photos do not establish pitch, screw spacing, contact assignments, current
rating, or end-to-end electrical continuity. No CAD dimensions are updated.

## Additional mechanical measurements, 2026-11-11

- IMG20261111204318: black pogo connector body long dimension = 18.67 mm.
- IMG20261111204245: body short dimension = 6.67 mm.

These are observed caliper readings, not guaranteed manufacturing tolerances.
Use 18.67 x 6.67 mm as the measured body envelope for later adapter design;
printed pocket clearance is separate. Previously inferred contact pitch is
3 mm, giving a 15 x 3 mm contact-centre rectangle. If centred in this body,
that implies 1.835 mm centre-to-body-edge margins, a derived assumption.
Still needed before final CAD: body height, free pin protrusion, intended
compression/working travel, flex exit clearance and corner shape/radius.
No CAD geometry or nominal screw pattern was changed.

## Height follow-up and retainer, 2026-11-13

The user measured 2.27 mm housing thickness, 5.60 mm free tip-to-solder-top total
height (correcting 5.25 mm) and 4.60 mm fully compressed tip-to-solder-top total
height. This gives 1.00 mm measured travel. The user subsequently reports the
tablet contact plane is recessed approximately **1 mm** below the mounting
surface. Working preload and the solder-top-to-housing-rim offset remain
unverified.

The FPC exits **left** in the mounted tablet-back orientation, despite pointing
right in IMG20261111202302. A [parameterized retaining plate](../../cad/fpc-retainer/README.md)
uses the selected P1 alignment, a top solder window, left flex underpass and
removable spacers for height adjustment. Physical fit has not been tested.

Retainer R2 accounts for that recess with a 3.00 mm nominal spacer stack
(2.60 + 0.40 mm), replacing R1's 4.00 mm stack. The printable plate is unchanged.

R3 accommodates the reported 8.5 mm screws with a 4.00 mm plate and 3.00 mm spacer
stack: 1.50 mm target engagement, nominal 0.50 mm margin to the approximately
2 mm thread depth. Length is interpreted under-head to tip. The housing retaining
plane remains at 4.30 mm; see the current CAD README for screw-stack assumptions.
