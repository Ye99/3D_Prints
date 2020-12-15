include <BOSL/constants.scad>
use <BOSL/transforms.scad>
include <../OpenSCAD-common-libraries/roundedCube.scad>

base_x_length=60; // Length.
base_y_length=6.2; // Thickness. 
base_z_length=10; // Width.

screw_tab_x_length=12; // at each end. 
rounded_corner_radius=2;

// Motor shaft cut metrics.
cut_height=5.82;
cut_diameter=3; 
cut_depth=1;
cube_offset=(cut_diameter+cut_depth)/2;

module motor_shaft_cut() {
    back((base_y_length-cut_height)/2)
        xrot(90) {
            difference() {
                cylinder(d=5, h=cut_height, center=true, $fn=50);
                back(cube_offset)
                    cube([20, cut_depth, cut_height], center=true);
                fwd(cube_offset)
                    cube([20, cut_depth, cut_height], center=true);
            }
        }
}

module filament_holder() {
    difference() {    
        roundedCube([base_x_length, base_y_length, base_z_length], center=true, r=rounded_corner_radius,
            z=false,
            y=false,
            x=true,
            xcorners=[false, false, true, true]);
        
        screw_mount_x_offset=0; //base_x_length/2-screw_tab_x_length/2; // uncomment to put shaft hole at one end.
        left(screw_mount_x_offset)
            motor_shaft_cut();
    }
}

filament_holder();