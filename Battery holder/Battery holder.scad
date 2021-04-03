// Holder for 26650/32700 batteries
// Author mr.yezhang@gmail.com

include <BOSL/constants.scad>
use <BOSL/transforms.scad>
include <../OpenSCAD-common-libraries/roundedCube.scad>

selected_battery_size="26650"; //["32700", "26650"]; These are norminalized battery size options. 
echo("selected_battery_size=", selected_battery_size);

wall_thickness=5.2;

// Battery is cylinder shape. 
battery_length = selected_battery_size=="26650" ? 66 : (selected_battery_size=="32700" ? 70 : 0);
echo("battery_length=", battery_length);

battery_diameter = selected_battery_size=="26650" ? 26 : (selected_battery_size=="32700" ? 32 : 0);
echo("battery_diameter=", battery_diameter);

module battery_mock(battery_length, battery_diameter) {
    cylinder(h = battery_length, d=battery_diameter, center = true, $fn=90);
}

// Output wires
wire_thickness = 4.1;
wire_hole_diameter = wire_thickness+0.12;

contact_width = 10; //
anode_height = 1.5;

// Cathod has spring. This is uncompressed value. 
cathode_height = 8;

// This is the net sizes inside the walls.
compartment_x_length=battery_length+anode_height+(cathode_height/2); // make cathod spring compressed
compartment_y_length=battery_diameter+1.5;
compartment_z_length=compartment_y_length; 

screw_tab_x_length=12; // at each end. 
rounded_corner_radius=2;

// Motor shaft cut metrics.
cut_height=5.82;
cut_diameter=3; 
cut_depth=1;
cube_offset=(cut_diameter+cut_depth)/2;

// Over discharge protection board.
protecton_board_diameter=16;
protecton_board_thickness=2;

// If false, for charging configuration.
has_side_compartment = true;

// To easily insert/remove battery.
module side_cut() {
    diameter=compartment_x_length*0.7;
    
    up(wall_thickness/2+compartment_y_length/2)
        xrot(90)
            cylinder(h = wall_thickness, d=diameter, center = true, $fn=90);
}

module draw_horizontal_cut(raise, horizontal_cut_diameter) {
    up(raise)
        back(compartment_y_length/2)
            cube([horizontal_cut_diameter, compartment_y_length, horizontal_cut_diameter], center = true);
}

function compute_hole_or_mark_diameter(has_side_compartment) = has_side_compartment ?  0.4 : wire_hole_diameter; 

module wire_hole_or_mark(raise, has_side_compartment) {
    draw_horizontal_cut(raise, compute_hole_or_mark_diameter(has_side_compartment)); 
}

module place_wire_holes_or_marks(raise, has_side_compartment) {
    x_offset=(compartment_x_length+compute_hole_or_mark_diameter(has_side_compartment))/2;
    right(x_offset)
        wire_hole_or_mark(raise, has_side_compartment);
        
    left(x_offset)
        wire_hole_or_mark(raise, has_side_compartment);
}

module long_wire_channel(x_length, width, z_length) {
    // The vertical cut in side wall.
    down(z_length/2)
        left((compartment_x_length+width)/2)
            cube([width, width, z_length], center=true);
    
    // The horizontal cut in bottom wall.
    down((compartment_z_length+width)/2-0.2)
        left((width)/2)
            cube([x_length, width, width], center=true);
    
    // The 45 degree cut on the other side wall.
    down((compartment_z_length+width)/2-0.2)
        right(compartment_x_length/2)
          yrot(-45)
            right(compartment_x_length/2)
                cube([x_length, width, width], center=true);
}

module short_wire_channel(y_length, width) {
    right((compartment_x_length+width)/2-0.01) // Minus 0.01 to expose the cut.
        union() {
            // The horizontal cut in side wall.
            back(y_length/2)
                cube([width, y_length, width], center=true);
            
            // The cut to penetrate the wall.
            back(y_length-width/2)
                cube([wall_thickness*2, width, width], center=true);
        }
}

module battery_holder(has_side_compartment) {
    difference() { 
        zcorner_for_side_compartment = has_side_compartment ? false : true;
        roundedCube([compartment_x_length+(wall_thickness*2), compartment_y_length+(wall_thickness*2), compartment_z_length+wall_thickness], 
            center=true, r=rounded_corner_radius,
            zcorners=[true, zcorner_for_side_compartment, zcorner_for_side_compartment, true],
            y=false,
            x=false);
       
       compartment_center_raise=wall_thickness/2;
        up(compartment_center_raise+0.1)
            cube([compartment_x_length, compartment_y_length, compartment_z_length], 
                center=true);
      
      y_offset=(compartment_y_length+wall_thickness)/2;
      back(y_offset)  
        side_cut();
        
      fwd(y_offset)  
        side_cut();
      
      place_wire_holes_or_marks(compartment_center_raise, has_side_compartment);
      
      up(compartment_center_raise) 
        union() {
            long_wire_channel(compartment_x_length+wire_hole_diameter, wire_hole_diameter, compartment_z_length/2);
            short_wire_channel(compartment_y_length/2, wire_hole_diameter);
        }
    }
}

// battery_holder(has_side_compartment);

battery_mock(battery_length, battery_diameter);