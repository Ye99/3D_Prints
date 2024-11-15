// Updated to add a slab with thickness matching the thickness variable, connecting mount_tab to the edge of the half_pipe

include <../BOSL/constants.scad>
use <../BOSL/metric_screws.scad>
use <../BOSL/transforms.scad>
include <../OpenSCAD-common-libraries/screw_matrics.scad>
use <../MCAD/regular_shapes.scad>

// Constants for dimensions and smoothness
bed_adhesion_lip_height=0.32 + 0.28;
start=2;
stop=50;
step=3;
thickness=2.8;
mount_tab_height=60;
connecting_slab_thickness=8;
face_number=100;
gap_length = 41.8;
    
// Adjusted Factor_B for 3-inch diameter (76.2mm)
Factor_B=96; // When this value is updated, must change the left parameter thickness*ratio in piple_holder module. Don't have time to optimize this hacky code.

// Updated coefficient and module definitions remain as in the original code
Coefficient_a=0.05;

module half_pipe(start, stop) {
    down(stop)
        MakePipe(start,stop);
}

module MakePipe(start,stop){
    difference() {
        union() {
            for (i=[start:step:stop-step]) {
                hull() {
                    up(i) 
                        MakeRing(Factor_B/pow(i, Coefficient_a)+thickness*2);
                    
                    up(i+step) 
                        MakeRing(Factor_B/pow(i+step, Coefficient_a)+thickness*2);
                }
            }
        }

        union() {
            for (i=[start-step:step:stop]){
                hull() {
                    up(i)
                        MakeRing(Factor_B/pow(i, Coefficient_a));
                     up(i+step) 
                        MakeRing(Factor_B/pow(i+step, Coefficient_a));
                }
            }
        }
    }
}

module MakeRing(Diameter) {
    cylinder(r=Diameter/2, h=0.01, $fn=face_number);
}

module bed_adhesion_lip() {
    down(48)
        #cylinder_tube(height=bed_adhesion_lip_height, radius=Factor_B/2+0.5, wall=thickness, center=false, $fn=face_number);
}

module full_piple() {
    half_pipe(start, stop);
    xrot(180)
        half_pipe(start, stop);
    bed_adhesion_lip();
}

module mount_screw() {
    screw(M5_screw_hole_diameter,
       screwlen=30,
       headsize=m3_screw_head_diameter,
       headlen=3, countersunk=false, align="base");
}

// Rotate mount_tab by 90 degrees and move backward along y-axis by 3 inches (76.2mm)
module mount_tab(gap_length_parameter) {
    tab_z_length=stop*1.5;
    tab_y_length=mount_tab_height;
    tab_x_length=thickness*2.5;
    
    fwd(gap_length_parameter)
        union() {
            left(tab_y_length/2-connecting_slab_thickness/2)
                zrot(90)
                    difference() {
                                cube([tab_x_length, tab_y_length, tab_z_length], center=true);
                                
                                //back(connecting_slab_thickness) // Move screw hole "up/down" along tab.
                                    right(5) // Make the cut penentrate the tab. 
                                        yrot(90)
                                            mount_screw();
                        
                    }
        
            // Add the connecting slab to attach mount_tab to half_pipe
            connecting_slab();
        }
}

// Slab to connect mount_tab to half_pipe, with thickness equal to `thickness`
module connecting_slab() {
    slab_length = 80;
    back(slab_length/2)
        cube([connecting_slab_thickness, slab_length, stop * 1.5], center=true);
}

module piple_holder() {
    difference() {
        full_piple();
        
        fwd(Factor_B/2)
            cube([Factor_B*2, Factor_B, Factor_B*2], center=true);
    }
    
    left(gap_length/2+10-thickness*.8)
        // translate([0, -gap_length, 0]) // Move backward along y-axis by 3 inches (76.2mm)
            mount_tab(gap_length);
}

piple_holder();
