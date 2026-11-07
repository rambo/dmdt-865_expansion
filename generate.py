"""Generate a millimetre DXF and watertight STL from the measured tablet geometry."""
import csv
import json
import math
from pathlib import Path

import ezdxf
from ezdxf.addons import Importer
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import Circle, Polygon as PlotPolygon
from matplotlib.font_manager import FontProperties
from matplotlib.textpath import TextPath
from matplotlib.path import Path as PlotPath
from matplotlib.patches import PathPatch
import numpy as np
from shapely.geometry import Point, Polygon
from shapely.geometry.polygon import orient
import trimesh


ROOT = Path(__file__).resolve().parent


def polygons(shape):
    return [shape] if shape.geom_type == "Polygon" else list(shape.geoms)


def make_labels(name, x11, y11):
    shape = Polygon()
    font = FontProperties(family="DejaVu Sans", weight="bold")
    for text, x, y, size in [(name,15,27,5), (f"X {x11:.2f}",15,21,3.2),
                              (f"Y {y11:.2f}",15,16,3.2)]:
        for ring in TextPath((x,y), text, size=size, prop=font).to_polygons():
            contour = Polygon(ring)
            if contour.area > 1e-10:
                shape = shape.symmetric_difference(contour)
    assert shape.is_valid and shape.area > 0
    return [orient(poly,sign=1) for poly in polygons(shape)]


def build_variant(p, plate_name, x11):
    assert p["units"] == "mm"
    for key, value in p.items():
        if isinstance(value, (int, float)):
            assert value > 0, key
        elif isinstance(value, list):
            assert all(math.isfinite(v) and v > 0 for v in value), key
    width, height = p["mount_spacing"]
    margin, thickness = p["edge_margin"], p["plate_thickness"]
    # The new spans use the brass OD; the older mounting spans use the thread opening.
    correction = (p["insert_outside_diameter"] + p["contact_opening_diameter"]) / 2
    photo_x11, photo_y11 = [v - correction for v in p["pin11_outside_edge_spans"]]
    diagonal = p["pin11_shortest_thread_to_contact_edge_gap"] + (
        p["thread_opening_diameter"] + p["contact_opening_diameter"]) / 2
    assert diagonal > x11 > 0 and photo_y11 > 0
    # The later diagonal supersedes the approximate vertical photo span.
    y11 = math.sqrt(diagonal**2 - x11**2)
    assert math.isclose(math.hypot(x11, y11), diagonal, abs_tol=1e-10)
    mounts = [("A", 0., 0.), ("B", width, 0.),
              ("C", width, height), ("D_CAP", 0., height)]
    contacts = [(f"PIN_{11 - 2*r + c}", x11 + c*p["contact_pitch"],
                 y11 + r*p["contact_pitch"])
                for r in range(6) for c in range(2)]
    holes = [(name, x, y, p["mount_clearance_diameter"], "MOUNT_HOLES")
             for name, x, y in mounts]
    holes += [(name, x, y, p["inspection_hole_diameter"], "CONTACT_HOLES")
              for name, x, y in contacts]
    # A larger chamfer identifies the corner nearest A (the origin), without extra holes.
    x0, y0, x1, y1 = -margin, -margin, width+margin, height+margin
    outer = [(x0+3, y0), (x1-1, y0), (x1, y0+1), (x1, y1-1),
             (x1-1, y1), (x0+1, y1), (x0, y1-1), (x0, y0+3)]
    outline = Polygon(outer)
    cutouts = [Point(x, y).buffer(d/2, quad_segs=32) for _, x, y, d, _ in holes]
    assert all(outline.contains(c) for c in cutouts), "Hole outside plate"
    assert all(not a.intersects(b) for i, a in enumerate(cutouts) for b in cutouts[i+1:])
    profile = orient(Polygon(outer, [list(c.exterior.coords) for c in cutouts]), sign=1)
    assert profile.is_valid and len(profile.interiors) == 16
    labels = make_labels(plate_name,x11,y11)
    assert all(profile.contains(poly) for poly in labels)

    doc = ezdxf.new("R2010", units=ezdxf.units.MM)
    doc.header["$MEASUREMENT"] = 1
    for layer, colour in [("OUTLINE", 7), ("MOUNT_HOLES", 1), ("CONTACT_HOLES", 3), ("RAISED_LABELS",5)]:
        doc.layers.new(layer, dxfattribs={"color": colour})
    msp = doc.modelspace()
    msp.add_lwpolyline(outer, close=True, dxfattribs={"layer": "OUTLINE"})
    for _, x, y, diameter, layer in holes:
        msp.add_circle((x, y), diameter/2, dxfattribs={"layer": layer})
    for poly in labels:
        for ring in [poly.exterior,*poly.interiors]:
            msp.add_lwpolyline(list(ring.coords)[:-1],close=True,dxfattribs={"layer":"RAISED_LABELS"})
    dxf_path, stl_path = ROOT / f"T865-{plate_name}.dxf", ROOT / f"T865-{plate_name}.stl"
    doc.saveas(dxf_path)

    mesh = trimesh.creation.extrude_polygon(profile, thickness, engine="earcut")
    reliefs = []
    for poly in labels:
        relief = trimesh.creation.extrude_polygon(poly,p["label_height"]+.05,engine="earcut")
        relief.apply_translation([0,0,thickness-.05])
        reliefs.append(relief)
    mesh = trimesh.boolean.union([mesh,*reliefs],engine="manifold")
    mesh.export(stl_path)
    # Reopen the deliverables: check units, every circle, topology, bounds and volume.
    checked_dxf = ezdxf.readfile(dxf_path)
    assert not checked_dxf.audit().has_errors and checked_dxf.units == ezdxf.units.MM
    circles = list(checked_dxf.modelspace().query("CIRCLE"))
    assert len(circles) == len(holes)
    for circle, (_, x, y, diameter, layer) in zip(circles, holes):
        assert np.allclose(circle.dxf.center, [x, y, 0])
        assert np.isclose(circle.dxf.radius, diameter/2) and circle.dxf.layer == layer
    checked = trimesh.load_mesh(stl_path)
    assert checked.is_watertight and checked.is_winding_consistent and checked.is_volume
    assert checked.body_count == 1 and checked.euler_number == 2-2*len(holes)
    assert np.allclose(checked.bounds, [[x0, y0, 0], [x1, y1, thickness+p["label_height"]]], atol=1e-5)
    assert np.isclose(checked.volume, profile.area*thickness+sum(poly.area for poly in labels)*p["label_height"], rtol=2e-6)
    with (ROOT / f"hole-centres-{plate_name}.csv").open("w", newline="") as f:
        writer = csv.writer(f, lineterminator="\n")
        writer.writerow(["feature", "x_mm", "y_mm", "model_hole_diameter_mm"])
        writer.writerows((n, f"{x:.3f}", f"{y:.3f}", f"{d:.3f}") for n,x,y,d,_ in holes)

    fig, ax = plt.subplots(figsize=(8, 9))
    ax.add_patch(PlotPolygon(outer, fc="#e8edf2", ec="#243447", lw=1.5))
    for name, x, y, d, layer in holes:
        colour = "#bf4f26" if layer == "MOUNT_HOLES" else "#007a76"
        ax.add_patch(Circle((x, y), d/2, fc="white", ec=colour, lw=1.2))
        if layer == "MOUNT_HOLES":
            ax.text(x, y+1.8, name.replace("_", " "), ha="center", fontsize=9, color=colour)
        else:
            left = int(name[4:]) % 2
            ax.text(x+(-1.2 if left else 1.2), y, name[4:], va="center",
                    ha="right" if left else "left", fontsize=8, color=colour)
    for poly in labels:
        paths = []
        for ring in [poly.exterior,*poly.interiors]:
            coords = np.array(ring.coords)
            codes = [PlotPath.MOVETO]+[PlotPath.LINETO]*(len(coords)-2)+[PlotPath.CLOSEPOLY]
            paths.append(PlotPath(coords,codes))
        ax.add_patch(PathPatch(PlotPath.make_compound_path(*paths),fc="#30485d",ec="none"))
    for a, b, text in [((0,-7),(width,-7), f"{width:g} mm nominal"),
                       ((width+7,0),(width+7,height), f"{height:g} mm nominal")]:
        ax.annotate("", xy=a, xytext=b, arrowprops={"arrowstyle":"<->"})
        ax.text((a[0]+b[0])/2, (a[1]+b[1])/2, text, ha="center", va="bottom",
                rotation=90 if a[0] == b[0] else 0, fontsize=9)
    ax.plot([0, x11, x11], [0, 0, y11], "--", color="#007a76", lw=.8)
    ax.set(xlim=(x0-4,x1+9), ylim=(y0-6,y1+5), aspect="equal",
           xlabel="X (mm)", ylabel="Y (mm)",
           title="T865 fit check - rear view, USB exits right\n"
                 f"Pin 11 = ({x11:.3f}, {y11:.3f}) mm; contact pitch 3 mm")
    ax.grid(alpha=.2)
    fig.text(.5,.015, "1.2 mm plate + 0.6 mm raised labels | mount holes Ø2.4 | inspection holes Ø1.6\n"
             "Large corner chamfer identifies A. Diagram is not a print-to-scale template.",
             ha="center", fontsize=9)
    fig.savefig(ROOT / f"layout-{plate_name}.png", dpi=150, bbox_inches="tight")
    plt.close(fig)
    report = {"result":"PASS", "plate":plate_name, "units":"mm", "mount_spacing":p["mount_spacing"],
              "calculated_mount_spacing":[v-p["thread_opening_diameter"]
                                          for v in p["mount_outside_thread_opening_spans"]],
              "pin11":[round(x11,3),round(y11,3)], "holes":len(holes),
              "photo_only_pin11":[round(photo_x11,3),round(photo_y11,3)],
              "pin11_centre_diagonal":diagonal,
              "reconstructed_shortest_edge_gap":math.hypot(x11,y11)-(
                  p["thread_opening_diameter"]+p["contact_opening_diameter"])/2,
              "vertical_photo_span_residual_mm":y11-photo_y11,
              "contact_angle_status":"approximate; horizontal photo offset has no hard stop",
              "mesh_watertight":bool(checked.is_watertight),
              "mesh_bodies":checked.body_count, "mesh_euler_number":checked.euler_number,
              "mesh_extents":checked.extents.tolist(), "mesh_volume_mm3":float(checked.volume),
              "dxf_audit_errors":0, "dxf_circles":len(circles),
              "raised_labels_unioned_to_plate":True}
    return doc,checked,report,holes


def main():
    p = json.loads((ROOT/"dimensions.json").read_text())
    assert len(p["variant_pin11_x"]) == 4 and len(set(p["variant_pin11_x"])) == 4
    width,height = p["mount_spacing"]
    margin = p["edge_margin"]
    combined_doc = ezdxf.new("R2010",units=ezdxf.units.MM)
    combined_doc.header["$MEASUREMENT"] = 1
    meshes,reports,all_holes = [],[],[]
    fig,axes = plt.subplots(2,2,figsize=(12,14))
    for i,x11 in enumerate(p["variant_pin11_x"]):
        name = f"P{i+1}"
        doc,mesh,report,holes = build_variant(p,name,x11)
        reports.append(report)
        dx = (i%2)*(width+2*margin+p["print_gap"])
        dy = (1-i//2)*(height+2*margin+p["print_gap"])
        placed = mesh.copy()
        placed.apply_translation([dx,dy,0])
        meshes.append(placed)
        for entity in doc.modelspace():
            entity.translate(dx,dy,0)
        importer = Importer(doc,combined_doc)
        importer.import_modelspace()
        importer.finalize()
        all_holes.extend((n,x+dx,y+dy,d,layer) for n,x,y,d,layer in holes)
        axes.flat[i].imshow(plt.imread(ROOT/f"layout-{name}.png"))
        axes.flat[i].axis("off")
        print(f"{name}: X={report['pin11'][0]:.3f}, Y={report['pin11'][1]:.3f}, solid mesh PASS")
    combined_doc.saveas(ROOT/"T865-four-plates.dxf")
    reopened = ezdxf.readfile(ROOT/"T865-four-plates.dxf")
    assert reopened.units == ezdxf.units.MM and not reopened.audit().has_errors
    circles = list(reopened.modelspace().query("CIRCLE"))
    assert len(circles) == 64
    for circle,(_,x,y,d,layer) in zip(circles,all_holes):
        assert np.allclose(circle.dxf.center,[x,y,0])
        assert np.isclose(circle.dxf.radius,d/2) and circle.dxf.layer == layer
    combined = trimesh.util.concatenate(meshes)
    combined.export(ROOT/"T865-four-plates.stl")
    checked = trimesh.load_mesh(ROOT/"T865-four-plates.stl")
    assert checked.is_watertight and checked.is_winding_consistent and checked.is_volume
    assert checked.body_count == 4 and checked.euler_number == -120
    assert len(checked.split(only_watertight=True)) == 4
    assert np.isclose(checked.volume,sum(m.volume for m in meshes),rtol=2e-6)
    assert np.allclose(checked.bounds,[[-margin,-margin,0],
        [2*width+3*margin+p["print_gap"],2*height+3*margin+p["print_gap"],
         p["plate_thickness"]+p["label_height"]]],atol=1e-5)
    fig.suptitle("Four labelled T865 fit gauges - raised labels shown in blue\n"
                 "All preserve the 11.86 mm diagonal edge gap; contact angle varies",fontsize=15)
    fig.tight_layout(rect=(0,0,1,.96))
    fig.savefig(ROOT/"four-plates-preview.png",dpi=150)
    plt.close(fig)
    report = {"result":"PASS","plates":reports,"combined_watertight":True,
              "combined_bodies":checked.body_count,"combined_dxf_circles":len(circles),
              "combined_extents":checked.extents.tolist()}
    (ROOT/"validation.json").write_text(json.dumps(report,indent=2)+"\n")
    print("Combined DXF/STL validation PASS",checked.extents)


if __name__ == "__main__":
    main()
