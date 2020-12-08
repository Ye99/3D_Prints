// To minimize support, print the model standing on the half circle surface. 
// Notice one of the contact surfaces is larger than the other,
// to improve bed adhesion. Pay attention to use the larger one. 

include <BOSL/constants.scad>
use <BOSL/metric_screws.scad>
use <BOSL/transforms.scad>
include <../OpenSCAD-common-libraries/screw_matrics.scad>
use <../MCAD/regular_shapes.scad>

// First layer height + layer height. 
bed_adhesion_lip_height=0.32 + 0.28;

// Pipe section start (in mm from theoretic bell-side end; in practice you start at 5mm from the theoretic end).
// Determins the lip end steepness. 
start=2;
//Pipe section end
stop=50;
// Determins curve resolution of z direction. 
step=3;

// Wall thickness. Mount tab thickness is this value * 2. 
thickness=2;

mount_tab_height=30;

// Determin circle smothness. 
face_number=100;

// The shape of the pipe is according to the folling formula: Radius=B/(x+offset)^a. Factor B mostly influences the size of the bell at the middle.
Factor_B=129; // narrowest piple section diameter is around 106.

//Coefficient a mostly influences the diameter at the small end of the pipe.
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

// No structure funcion. To increase bed adhesion, add
// contact surface at one end. 
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

module mount_tab() {
    tab_z_length=stop*1.5;
    tab_y_length=mount_tab_height;
    tab_x_length=thickness*4;
    
    tab_triangle_z_length=stop*2;
    difference() {
        right(1)
            union() {
                cube([tab_x_length, tab_y_length, tab_z_length], center=true);
                
                back(tab_y_length/4)
                    right(tab_x_length/2)
                        xrot(90)
                            linear_extrude(height = tab_y_length/2, center = true)
                                polygon(points=[[0,tab_z_length/2], 
                                                [tab_x_length/2,0],
                                                [0, -tab_z_length/2]], 
                                        paths=[[0,1,2]]);
            }
        
        fwd(8) // Move screw hole "up/down" alone tab.
            right(5)
                yrot(90)
                    mount_screw();
    }
}


module piple_holder() {
    difference() {
        full_piple();
        
        fwd(Factor_B/2)
            cube([Factor_B*2, Factor_B, Factor_B], center=true);
    }
    
    left(62)
       mount_tab();
}

piple_holder();
