// Holder for 26650/32700 batteries.
// Author mr.yezhang@gmail.com
// License: MIT https://en.wikipedia.org/wiki/MIT_License
// Battery contacts use https://www.aliexpress.com/item/32953210416.html?spm=a2g0s.9042311.0.0.7c7e4c4dB4evB1
// Put battery over-discharge protection board like this (dimension 2mm X 16mm) under side cover
// https://www.aliexpress.com/item/4000966259698.html?spm=a2g0s.9042311.0.0.7c7e4c4dB4evB1
// The protection board B+ to battery positive; B- to battery negative. Output P+ is same as with B+; 
// output P- is the back metal plate or P- on the PCB.
// Wiring ducts and holes are designed into the 3D model.
// Use 2mm * 20mm screw to mount side cover to the holder:
// https://smile.amazon.com/gp/product/B07HPYS77H/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1

include <../BOSL/constants.scad>
use <../BOSL/transforms.scad>
include <../OpenSCAD-common-libraries/roundedCube.scad>
include <../OpenSCAD-common-libraries/screw_matrics.scad>
use <../BOSL/metric_screws.scad>

emit_holder = true;
emit_cover = true;
emit_mocked_battery = false;
cover_has_vent = true;

// Number of batteries along Y (side-by-side)
battery_number = 7;
echo("battery_number=", battery_number);

selected_battery_size="32700"; //["32700", "26650"]; These are norminalized battery size options. 
echo("selected_battery_size=", selected_battery_size);

wall_thickness=4.2;

// To print compartment and cover from one exported STL, the space between them.
space_between_comopartment_and_cover = 1;

// Battery is cylinder shape. 
battery_length = selected_battery_size=="26650" ? 66 : (selected_battery_size=="32700" ? 70 : 0);
echo("battery_length=", battery_length);

battery_diameter = selected_battery_size=="26650" ? 26 : (selected_battery_size=="32700" ? 32 : 0);
echo("battery_diameter=", battery_diameter);

// Output wires
wire_thickness = 3.3;
wire_hole_diameter = wire_thickness+0.12;

contact_width = 10; //
anode_height = 1.5;

// Cathod has spring. This is uncompressed value. 
cathode_height = 8;

// This is the net sizes inside the walls.
compartment_x_length=battery_length+anode_height+(cathode_height/2); // make cathod spring compressed
compartment_y_length=battery_diameter+1.5;
compartment_z_length=compartment_y_length; 

// Overall holder Y length including outer and shared inner walls
holder_y_length = compartment_y_length*battery_number + wall_thickness*(battery_number+1);
// Net inner span across all compartments (excludes the two outer walls)
inner_span_y_length = holder_y_length - 2*wall_thickness;
// Center-to-center spacing between adjacent compartments
compartment_center_spacing = compartment_y_length + wall_thickness;

screw_tab_x_length=12; // at each end. 
rounded_corner_radius=1;

// Motor shaft cut metrics.
cut_height=5.82;
cut_diameter=3; 
cut_depth=1;
cube_offset=(cut_diameter+cut_depth)/2;

// Over discharge protection board.
protecton_board_diameter=16;
protecton_board_thickness=2;

// Enable charging conduit features
has_no_charging_conduit=false;
// This is net inside size.
cover_depth=8;

// To easily insert/remove battery.
module side_cut() {
    diameter=compartment_x_length*0.7;
    
    up(wall_thickness/2+compartment_y_length/2)
        xrot(90)
            // * 2 to make sure OpenSCAD displays the surface display correctly. Though without it the final print result is corret. 
            cylinder(h = wall_thickness*2, d=diameter, center = true, $fn=90); 
}

module draw_horizontal_cut(raise, horizontal_cut_diameter) {
    up(raise)
        back(compartment_y_length/2)
            cube([horizontal_cut_diameter, compartment_y_length, horizontal_cut_diameter], center = true);
}

function compute_hole_or_mark_diameter(has_no_charging_conduit) = has_no_charging_conduit ?  0.4 : wire_hole_diameter; 

module wire_hole_or_mark(raise, has_no_charging_conduit) {
    draw_horizontal_cut(raise, compute_hole_or_mark_diameter(has_no_charging_conduit)); 
}

module place_wire_holes_or_marks(raise, has_no_charging_conduit) {
    x_offset=(compartment_x_length+compute_hole_or_mark_diameter(has_no_charging_conduit))/2;
    right(x_offset)
        wire_hole_or_mark(raise, has_no_charging_conduit);
        
    left(x_offset)
        wire_hole_or_mark(raise, has_no_charging_conduit);
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

module short_wire_channel(y_length, width, penetrate_x_wall=true) {
    right((compartment_x_length+width)/2-0.01) // Minus 0.01 to expose the cut.
        union() {
            back(y_length/2)
                cube([width, y_length, width], center=true);
            if (penetrate_x_wall) {
                back(y_length-width/2)
                    cube([wall_thickness*2, width, width], center=true);
            }
        }
}

module short_wire_channel_left(y_length, width, penetrate_x_wall=true) {
    left((compartment_x_length+width)/2-0.01)
        union() {
            back(y_length/2)
                cube([width, y_length, width], center=true);
            if (penetrate_x_wall) {
                back(y_length-width/2)
                    cube([wall_thickness*2, width, width], center=true);
            }
        }
}

/* Cut for wires between protection board and appliance to be powered */
module compartment_wire_out_cut(x_length, y_length, z_length) {
    cube([x_length, y_length, z_length], center=true);
}

module battery_holder(has_no_charging_conduit) {
    difference() { 
        zcorner_for_side_compartment = has_no_charging_conduit ? false : true;
        roundedCube([compartment_x_length+(wall_thickness*2), holder_y_length, compartment_z_length+wall_thickness], 
            center=true, r=rounded_corner_radius,
            z=true,
            zcorners=[true, zcorner_for_side_compartment, zcorner_for_side_compartment, true],
            x=true,
            xcorners=[false, true, true, false],
            y=true,
            ycorners=[true,false,false,false]);
       
       compartment_center_raise=wall_thickness/2;
        up(compartment_center_raise+0.1)
            for (i=[0:battery_number-1])
                translate([0, (i - (battery_number - 1)/2) * compartment_center_spacing, 0])
                    cube([compartment_x_length, compartment_y_length, compartment_z_length], 
                        center=true);
      
      y_offset_outer=(holder_y_length - wall_thickness)/2;
      back(y_offset_outer)  
        side_cut();
        
      fwd(y_offset_outer)  
        side_cut();

      // Apply the same side cut to each internal dividing wall between compartments
      if (battery_number > 1)
        for (i=[0:battery_number-2])
            translate([0, (i+1 - battery_number/2) * compartment_center_spacing, 0])
                side_cut();
       
      for (i=[0:battery_number-1])
        translate([0, (i - (battery_number - 1)/2) * compartment_center_spacing, 0])
            place_wire_holes_or_marks(compartment_center_raise, has_no_charging_conduit);
      
      up(compartment_center_raise) 
        union() {
            for (i=[0:battery_number-1])
                translate([0, (i - (battery_number - 1)/2) * compartment_center_spacing, 0])
                    long_wire_channel(compartment_x_length+wire_hole_diameter, wire_hole_diameter, compartment_z_length/2);
      if (!has_no_charging_conduit) {
                // Create continuous conduits along Y on both +/-X walls (no penetration here)
                short_wire_channel(inner_span_y_length/2, wire_hole_diameter, penetrate_x_wall=false);
                short_wire_channel_left(inner_span_y_length/2, wire_hole_diameter, penetrate_x_wall=false);
                if (battery_number > 1) {
                    // Y-direction bus to connect compartments in parallel across inner span
                    right((compartment_x_length+wire_hole_diameter)/2-0.01)
                        cube([wire_hole_diameter, inner_span_y_length, wire_hole_diameter], center=true);
                    left((compartment_x_length+wire_hole_diameter)/2-0.01)
                        cube([wire_hole_diameter, inner_span_y_length, wire_hole_diameter], center=true);
                }
                // Add a single side-wall exit hole near the middle, just inside the selected compartment's dividing wall
                y_center_index = floor(battery_number/2);
                y_comp_center = (y_center_index - (battery_number - 1)/2) * compartment_center_spacing;
                wall_clearance = 0.2;
                y_dividing_wall_center = y_comp_center + compartment_y_length/2 + wall_thickness/2;
                y_exit = y_dividing_wall_center - (wall_thickness/2 + wire_hole_diameter/2 + wall_clearance);
                right((compartment_x_length+wire_hole_diameter)/2-0.01)
                    translate([0, y_exit, 0])
                        cube([wall_thickness*2, wire_hole_diameter, wire_hole_diameter], center=true);
                left((compartment_x_length+wire_hole_diameter)/2-0.01)
                    translate([0, y_exit, 0])
                        cube([wall_thickness*2, wire_hole_diameter, wire_hole_diameter], center=true);
            } else {
                for (i=[0:battery_number-1])
                    translate([0, (i - (battery_number - 1)/2) * compartment_center_spacing, 0])
                        short_wire_channel(compartment_y_length/2, wire_hole_diameter);
            }
        }
        
      arrange_to_four_corners(compartment_x_length/2+wall_thickness, (holder_y_length - wall_thickness)/2, (compartment_z_length)/2)
        screw_hole(true);


      // Base wire out hole removed; use side-wall conduit exit positioned at middle compartment.
      // Corner channel at (+X, -Y) where two vertical sides meet: run along Y (long side), penetrate X (short side)
      #if (!has_no_charging_conduit) {
        channel_length = compartment_y_length/3;
        // Position along +Y edge just inside the outer wall, and at +X wall to penetrate outside
        fwd(y_offset_outer - wall_thickness + 1)
            right(wall_thickness+compartment_x_length/2 - wire_hole_diameter/2)
                down(wire_hole_diameter*2)
                    cube([wire_hole_diameter, channel_length, wire_hole_diameter * 1.5], center=true);
      }
    }
}

module screw_hole(is_tap) {
    diameter = is_tap ? m2_screw_hole_tap_diameter : m2_screw_hole_diameter;
    yrot(90)
        screw(diameter, 
           screwlen=m2_screw_stem_length,
           headsize=m2_screw_head_diameter,
           headlen=3, countersunk=false, align="base");
}

/* move children to four corners. The offset origin is the center. */
module arrange_to_four_corners(x_offset, y_offset, z_offset) {
    right(x_offset)
        union() {
            translate([0, 
                       y_offset, 
                       z_offset])
                children();
            
            translate([0, 
                       -y_offset, 
                       z_offset])
                    children();
            
            translate([0, 
                       y_offset, 
                       -z_offset])
                    children();

            translate([0, 
                       -y_offset, 
                       -z_offset])
                    children();
        }
}

// length & height & wall_thickness are vent area dimensions.
// grill_size determins the grill interval.
module vent(length, height, wall_thickness, grill_size) {
     back(length/2)
         for(i=[0:1:length/grill_size]) {
             if (i%2 == 0) {
                fwd(i*grill_size)
                    up(height/2)
                        #cube([wall_thickness * 5, grill_size, height], center=true); // * 5 to make sure cut through the wall.
             }
        }
}

module compartment_cover() {
    difference() { 
        roundedCube([(wall_thickness+cover_depth), holder_y_length, compartment_z_length+wall_thickness], 
            center=true, r=rounded_corner_radius,
            z=true,
            zcorners=[false, true, true, false],
            x=true,
            xcorners=[false, true, true, false],
            y=true,
            ycorners=[false,true,false,false]);
        
        left(wall_thickness/2+0.01)
            cube([cover_depth, inner_span_y_length, compartment_z_length-wall_thickness], center=true);
        
        arrange_to_four_corners((cover_depth+wall_thickness)/2, (holder_y_length - wall_thickness)/2, (compartment_z_length)/2)
            screw_hole(false);
        
        if (cover_has_vent) {
            vent_height = (compartment_z_length - wall_thickness) - 3;
            down(vent_height/2)
                vent(inner_span_y_length, vent_height, wall_thickness, 2);
        }
    }
}

module battery_mock(battery_length, battery_diameter) {
    // Shorter by 1mm to reserve room for adding contacts.
    cylinder(h = battery_length - 1, d=battery_diameter, center = true, $fn=90);
}

if (emit_holder)
    battery_holder(has_no_charging_conduit);

if (emit_cover)
    down((compartment_z_length+wall_thickness)/2-(wall_thickness+cover_depth)/2)
        left((compartment_x_length)/2 + wall_thickness + (compartment_z_length+wall_thickness)/2 + space_between_comopartment_and_cover)
            yrot(90)
                compartment_cover(); 

if (emit_mocked_battery)
    battery_mock(battery_length, battery_diameter);