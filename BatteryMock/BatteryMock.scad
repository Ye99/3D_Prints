// Mock battery that connects LiFePO4 battery to existing alkaline battery powered applications. 
// Author mr.yezhang@gmail.com
// License: MIT https://en.wikipedia.org/wiki/MIT_License
// TODO: check in a finished photo for illustration. 

include <../BOSL/constants.scad>
use <../BOSL/transforms.scad>
include <../OpenSCAD-common-libraries/roundedCube.scad>
include <../OpenSCAD-common-libraries/screw_matrics.scad>
use <../BOSL/metric_screws.scad>

// Reserved length for contact plate. 
contact_thickness=0.5;
reserved_length=contact_thickness;

// Dimensions from https://batteryuniversity.com/learn/article/battery_packaging_a_look_at_old_and_new_systems
// Are tip to tip length. Below is cylinder length excluding the protruding anode.
AAA_battery_length=43;
AAA_battery_diameter=10.2;

AA_battery_length=48.5;
AA_battery_diameter=13.9;

selected_battery_size="AAA"; // [AAA, AA]
echo("selected_battery_size=", selected_battery_size);

battery_length = selected_battery_size=="AAA" ? AAA_battery_length-reserved_length: (selected_battery_size=="AA" ? AA_battery_length-reserved_length : 0);
echo("battery_length=", battery_length);

battery_diameter = selected_battery_size=="AAA" ? AAA_battery_diameter: (selected_battery_size=="AA" ? AA_battery_diameter: 0);
echo("battery_diameter=", battery_diameter);

wire_channel_width=3;

$fn=100;

module battery_mock(battery_length, battery_diameter) {
    difference() {
        cylinder(h=battery_length, d=battery_diameter, center=true);
        cut_y=battery_diameter/2;
        cut_z=battery_length/2;
        fwd(cut_y/2+2)
            up(cut_z/2)
                #cube([wire_channel_width, cut_y, cut_z], center=true);
    }
}

battery_mock(battery_length, battery_diameter);