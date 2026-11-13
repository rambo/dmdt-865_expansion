"""T865 P1 FPC retainer. Units mm. Source parameters regenerate STEP/STL/DXF."""
import json
import os
import tempfile
os.environ.setdefault('MPLCONFIGDIR', tempfile.mkdtemp(prefix='t865-mpl-'))
from pathlib import Path
import cadquery as cq
import trimesh
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle, Circle
from mpl_toolkits.mplot3d.art3d import Poly3DCollection

ROOT = Path(__file__).resolve().parent

def rounded_box(w, h, z, x, y, bottom, radius):
    return (cq.Workplane('XY').box(w,h,z,centered=(True,True,False))
            .edges('|Z').fillet(radius).translate((x,y,bottom)))

def build(p):
    assert p['units']=='mm'
    travel=p['free_tip_to_solder_top']-p['compressed_tip_to_solder_top']
    assert 0 < p['target_compression'] < travel
    sx,sy=p['mount_spacing']; x11,y11=p['pin11']; pitch=p['contact_pitch']
    cx,cy=x11+pitch/2,y11+5*pitch/2
    lip=(p['free_tip_to_solder_top']-p['target_compression']-
         p['contact_plane_recess']-p['solder_top_above_retaining_rim'])
    standoff=lip-p['pocket_depth']
    t=p['screw_length']-p['target_thread_engagement']-standoff
    assert standoff>0 and t-p['pocket_depth']>=p['min_roof_thickness']
    assert 0<p['target_thread_engagement']<p['max_thread_depth']
    pw=p['body_short']+2*p['pocket_side_clearance']
    ph=p['body_long']+2*p['pocket_side_clearance']
    ww=p['body_short']-2*p['rim_overlap']
    wh=p['body_long']-2*p['rim_overlap']
    margin=p['edge_margin']
    plate=rounded_box(sx+2*margin,sy+2*margin,t,sx/2,sy/2,0,p['corner_radius'])
    # Pocket opens on tablet-facing underside; central window passes through roof.
    plate=plate.cut(rounded_box(pw,ph,p['pocket_depth']+1,cx,cy,-1,0.6))
    plate=plate.cut(rounded_box(ww,wh,t+2,cx,cy,-1,0.5))
    # Left-only underpass: clearance above the flex at the retaining-rim datum.
    left=-margin-1
    relief=cq.Workplane('XY').box(cx-left,p['flex_relief_width'],
                p['pocket_depth']+p['flex_relief_above_rim']+1,
                centered=(False,True,False)).translate((left,cy,-1))
    plate=plate.cut(relief)
    mounts=[(0,0),(sx,0),(sx,sy),(0,sy)]
    for x,y in mounts:
        hole=cq.Workplane('XY').circle(p['mount_hole_diameter']/2).extrude(t+2).translate((x,y,-1))
        plate=plate.cut(hole)
    # A corner notch keys lower-left A; it does not shift the mounting holes.
    notch=(cq.Workplane('XY').polyline([(-margin,-margin),(-margin+2,-margin),
             (-margin,-margin+2)]).close().extrude(t+1))
    plate=plate.cut(notch)
    # Minimal inset markings on outward face, cut without breaking through roof.
    labels=(cq.Workplane('XY').text('FPC LEFT',2.3,0.3,combine=True)
            .translate((23,20,t-0.3)))
    plate=plate.cut(labels)
    for label,x,y in [('A',3,0),('P1',19,5)]:
        plate=plate.cut(cq.Workplane('XY').text(label,2.2,0.3,combine=True)
                        .translate((x,y,t-0.3)))
    return plate, mounts, (cx,cy), (ww,wh), t

def export_checked(shape,name,report):
    assert shape.val().isValid(), name
    assert len(shape.solids().vals())==1, name
    cq.exporters.export(shape,str(ROOT/f'{name}.step'))
    cq.exporters.export(shape,str(ROOT/f'{name}.stl'),tolerance=0.035,angularTolerance=0.12)
    m=trimesh.load_mesh(ROOT/f'{name}.stl')
    assert m.is_watertight and m.is_winding_consistent and m.volume>0, name
    assert len(m.split())==1, name
    step=cq.importers.importStep(str(ROOT/f'{name}.step'))
    assert step.val().isValid() and len(step.solids().vals())==1
    assert abs(step.val().Volume()-shape.val().Volume())<1e-5
    report[name]={'watertight':True,'connected_solids':1,'volume_mm3':round(m.volume,4),
                  'bounds_mm':m.bounds.round(5).tolist(),'step_reimport_valid':True}
    return m

def main():
    p=json.loads((ROOT/'parameters.json').read_text())
    plate,mounts,(cx,cy),(ww,wh),t=build(p)
    report={}
    export_checked(plate,'T865-FPC-retainer-assembly-coordinates',report)
    # Outward face down on bed, pocket upwards; proper rotation, not mesh reflection.
    printable=plate.rotate((0,0,0),(0,1,0),180).translate((0,0,t))
    m=export_checked(printable,'T865-FPC-retainer-print',report)
    # Spacer set: four per thickness. Each is separate, so inspect individually.
    height_set=[p['base_spacer_height']]+p['shim_heights']
    kit=[]
    for row,h in enumerate(height_set):
        ring=(cq.Workplane('XY').circle(p['spacer_od']/2)
              .circle(p['mount_hole_diameter']/2).extrude(h))
        export_checked(ring,f'spacer-{h:.2f}mm',report)
        for col in range(4):
            kit.append(ring.translate((col*8,row*8,0)).val())
    kitshape=cq.Compound.makeCompound(kit)
    cq.exporters.export(kitshape,str(ROOT/'T865-FPC-spacer-kit.stl'),tolerance=.035)
    km=trimesh.load_mesh(ROOT/'T865-FPC-spacer-kit.stl')
    assert len(km.split())==12 and km.is_watertight
    report['spacer_kit']={'connected_solids':12,'watertight':True}
    # Effective retaining datum in tablet coordinates, prior to physical fit calibration.
    lip=(p['free_tip_to_solder_top']-p['target_compression']-
         p['contact_plane_recess']-p['solder_top_above_retaining_rim'])
    standoff=lip-p['pocket_depth']
    report['derived']={'connector_center_mm':[cx,cy],'window_mm':[ww,wh],
        'measured_travel_mm':p['free_tip_to_solder_top']-p['compressed_tip_to_solder_top'],
        'nominal_retaining_height_mm':lip,'required_standoff_mm':standoff,
        'plate_thickness_mm':t,'pocket_mm':[p['body_short']+2*p['pocket_side_clearance'],p['body_long']+2*p['pocket_side_clearance']]}
    assert abs(standoff-(p['base_spacer_height']+.4))<1e-6, 'Update spacer stack after changing Z parameters'
    engagement=p['screw_length']-(t+standoff)
    assert abs(engagement-p['target_thread_engagement'])<1e-6
    assert engagement<p['max_thread_depth']
    report['screw_fit']={'screw_length_mm':p['screw_length'],
        'plate_and_spacer_mm':t+standoff,'thread_engagement_mm':engagement,
        'nominal_bottom_clearance_mm':p['max_thread_depth']-engagement,
        'roof_thickness_mm':t-p['pocket_depth']}
    for x,y in mounts:
        bore=cq.Workplane('XY').circle(p['mount_hole_diameter']/2-.01).extrude(t+.2).translate((x,y,-.1))
        assert plate.intersect(bore).val().Volume()<1e-6
    # Check assembly volumes: body mock-up fits pocket and roof avoids central pads.
    body=rounded_box(p['body_short'],p['body_long'],p['body_thickness'],cx,cy,
                     lip-p['body_thickness'],0.7)
    mounted=plate.translate((0,0,standoff))
    overlap=mounted.intersect(body).val().Volume()
    assert overlap<1e-6, overlap
    # A changed envelope must regenerate successfully, then restore baseline.
    altered=dict(p); altered['body_short']+=.2
    changed,*_=build(altered)
    assert changed.val().isValid() and abs(changed.val().Volume()-plate.val().Volume())>.01
    report['parameter_change_check']='body_short +0.20 mm recomputes; original retained'
    report['mock_body_intersection_mm3']=overlap
    assy=cq.Assembly(name='T865_FPC_retainer_reference')
    assy.add(mounted,name='PRINTED_retainer',color=cq.Color(.25,.55,.80))
    assy.add(body,name='REFERENCE_connector_not_for_print',color=cq.Color(.16,.16,.18))
    flex=(cq.Workplane('XY').box(16,7,.15,centered=(False,True,False))
          .translate((cx-19,cy,lip)))
    assert mounted.intersect(flex).val().Volume()<1e-6
    for row in range(6):
        for col in range(2):
            probe=(cq.Workplane('XY').circle(1.0).extrude(t+2).translate(
                (p['pin11'][0]+col*3,p['pin11'][1]+row*3,standoff-1)))
            assert mounted.intersect(probe).val().Volume()<1e-6
    report['window_access_checks']=12
    report['left_flex_intersection_mm3']=0
    assy.add(flex,name='REFERENCE_left_FPC_not_for_print',color=cq.Color(.9,.5,.08))
    for i,(x,y) in enumerate(mounts):
        s=cq.Workplane('XY').circle(p['spacer_od']/2).circle(p['mount_hole_diameter']/2).extrude(standoff).translate((x,y,0))
        assy.add(s,name=f'REFERENCE_spacer_stack_{i}',color=cq.Color(.5,.5,.5))
    assy.save(str(ROOT/'T865-FPC-reference-assembly.step'))
    # 2D outlines are documentation/sketch aids; pocket and relief have different depths.
    import ezdxf
    d=ezdxf.new('R2010');d.units=4; ms=d.modelspace()
    for layer in ['OUTLINE','MOUNT_HOLES','POCKET_UNDERSIDE','WIRE_WINDOW','LEFT_RELIEF']:
        d.layers.new(layer)
    def rect(x,y,w,h,layer):
        ms.add_lwpolyline([(x-w/2,y-h/2),(x+w/2,y-h/2),(x+w/2,y+h/2),(x-w/2,y+h/2)],close=True,dxfattribs={'layer':layer})
    # Export exact curved boundary from planar projection separately via STEP; DXF outlines nominal envelopes.
    sx,sy=p['mount_spacing'];margin=p['edge_margin']
    rect(sx/2,sy/2,sx+2*margin,sy+2*margin,'OUTLINE');rect(cx,cy,p['body_short']+2*p['pocket_side_clearance'],p['body_long']+2*p['pocket_side_clearance'],'POCKET_UNDERSIDE')
    rect(cx,cy,ww,wh,'WIRE_WINDOW')
    rect((cx-4)/2,cy,cx+4,p['flex_relief_width'],'LEFT_RELIEF')
    for x,y in mounts: ms.add_circle((x,y),p['mount_hole_diameter']/2,dxfattribs={'layer':'MOUNT_HOLES'})
    assert not d.audit().has_errors
    d.saveas(ROOT/'T865-FPC-dimension-envelope.dxf')
    # Engineering preview: outward view and underside plus section and print orientation.
    fig=plt.figure(figsize=(13,10),layout='constrained')
    for pos,title,under in [(221,'Mounted view — FPC exits LEFT',False),(222,'Underside pocket and flex relief',True)]:
        ax=fig.add_subplot(pos); ax.set_aspect('equal')
        ax.add_patch(Rectangle((-4,-4),40,48,facecolor='#bdd9ed',edgecolor='#183f61'))
        if under:
            ax.add_patch(Rectangle((cx-(p['body_short']+.4)/2,cy-(p['body_long']+.4)/2),p['body_short']+.4,p['body_long']+.4,facecolor='#779db6'))
            ax.add_patch(Rectangle((-4,cy-4.5),cx+4,9,facecolor='#f4c679'))
        ax.add_patch(Rectangle((cx-ww/2,cy-wh/2),ww,wh,facecolor='white',edgecolor='#183f61'))
        for x,y in mounts: ax.add_patch(Circle((x,y),1.2,facecolor='white',edgecolor='black'))
        for row in range(6):
            for col in range(2):ax.plot(p['pin11'][0]+3*col,p['pin11'][1]+3*row,'o',color='#d7952c',markersize=4)
        ax.annotate('FPC',xy=(-9,cy),xytext=(-1,cy),arrowprops={'arrowstyle':'->','lw':2},va='center')
        ax.text(15,30,'32 x 40 mm\nmount centres',fontsize=10)
        ax.text(-1,0,'A',fontsize=9);ax.set_xlim(-12,40);ax.set_ylim(-7,48)
        ax.set_title(title);ax.set_xlabel('X mm, right');ax.set_ylabel('Y mm, up')
    ax=fig.add_subplot(223)
    ax.add_patch(Rectangle((0,0),12,.1,color='#666'))
    ax.add_patch(Rectangle((1,0),2,standoff,color='#999'))
    ax.add_patch(Rectangle((0,standoff),12,t,color='#bdd9ed'))
    ax.add_patch(Rectangle((5,standoff),7,p['pocket_depth'],color='white'))
    ax.add_patch(Rectangle((7,standoff),5,t,color='white'))
    ax.add_patch(Rectangle((5,lip-p['body_thickness']),6,p['body_thickness'],color='#444'))
    ax.plot([6,6],[-p['contact_plane_recess'],lip-p['body_thickness']],color='#d7952c',lw=3)
    ax.text(.3,standoff/2,f'spacers\n{standoff:.1f}',fontsize=9)
    ax.text(7,lip+.25,'open to wires',fontsize=9)
    ax.add_patch(Rectangle((4.5,-p['contact_plane_recess']-.1),7,.1,color='#666'))
    ax.text(7,-.75,f'contact plane: {p["contact_plane_recess"]:.1f} mm recess',fontsize=8)
    ax.set_xlim(-.5,13);ax.set_ylim(-p['contact_plane_recess']-.5,8);ax.set_aspect('equal')
    ax.set_title('Schematic section (not manufacturing section)');ax.set_ylabel('Height above mounting surface, mm')
    ax=fig.add_subplot(224)
    segments=trimesh.intersections.mesh_plane(m,plane_origin=[0,0,t-.1],plane_normal=[0,0,1])
    assert len(segments)>0
    from matplotlib.collections import LineCollection
    ax.add_collection(LineCollection(segments[:,:,:2],colors='#183f61',linewidths=1.3))
    ax.autoscale_view()
    ax.set_aspect('equal');ax.set_title('Actual print-mesh section — pocket side')
    ax.set_xlabel('Print X mm (flipped for outward face on bed)');ax.set_ylabel('Print Y mm')
    ax.grid(alpha=.15)
    fig.savefig(ROOT/'preview.png',dpi=150);plt.close(fig)
    (ROOT/'validation.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report['derived'],indent=2))
    print('PASS: CAD solids, reimported STEP, STL meshes, spacer count, body clearance and parameter change')

if __name__=='__main__':main()
