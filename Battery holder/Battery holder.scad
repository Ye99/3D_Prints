// Holder for 26650/32700 batteries
// Author mr.yezhang@gmail.com

include <BOSL/constants.scad>
use <BOSL/transforms.scad>
include <../OpenSCAD-common-libraries/roundedCube.scad>

wall_thickness=4.3;

// Battery is cylinder shape. 
battery_length = 66;
battery_diameter = 26;

// Output wires
wire_thickness = 3.5;
wire_hole_diameter = wire_thickness+0.12;

contact_width = 10; //
anode_height = 1.5;

// Cathod has spring. This is uncompressed value. 
cathode_height = 8;

// This is the sizes inside the walls.
compartment_x_length=battery_length+anode_height+(cathode_height/2); // make cathod spring compressed
compartment_y_length=battery_diameter+0.6;
compartment_z_length=compartment_y_length; 

screw_tab_x_length=12; // at each end. 
rounded_corner_radius=2;

// Motor shaft cut metrics.
cut_height=5.82;
cut_diameter=3; 
cut_depth=1;
cube_offset=(cut_diameter+cut_depth)/2;

// To easily insert/remove battery.
module side_cut() {
    diameter=compartment_x_length*0.7;
    up(wall_thickness/2+compartment_y_length/2)
    xrot(90)
        cylinder(h = wall_thickness, d=diameter, center = true, $fn=90);
}

module wire_hole() {
    diameter=compartment_x_length*2/3;
    back(compartment_y_length/2)
        cube([wire_hole_diameter, compartment_y_length, wire_hole_diameter], center = true);
}

module battery_holder() {
    difference() {    
        roundedCube([compartment_x_length+(wall_thickness*2), compartment_y_length+(wall_thickness*2), compartment_z_length+wall_thickness], 
            center=true, r=rounded_corner_radius,
            z=false,
            y=false,
            x=false);
        
       up(wall_thickness/2)
            roundedCube([compartment_x_length, compartment_y_length, compartment_z_length], 
                center=true, r=rounded_corner_radius,
                z=false,
                y=false,
                x=false);
      
      y_offset=(compartment_y_length+wall_thickness)/2;
      back(y_offset)  
        side_cut();
        
      fwd(y_offset)  
        side_cut();
      
      x_offset=(compartment_x_length+wire_hole_diameter)/2;
      right(x_offset)
        #wire_hole();
        
      left(x_offset)
        #wire_hole();
    }
}

battery_holder();
