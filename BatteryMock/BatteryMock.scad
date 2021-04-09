// Mock battery that connects LiFePO4 battery to existing alkaline battery powered applications. 
// Author mr.yezhang@gmail.com
// License: MIT https://en.wikipedia.org/wiki/MIT_License
// TODO: check in a finished photo for illustration. 

include <../BOSL/constants.scad>
use <../BOSL/transforms.scad>
include <../OpenSCAD-common-libraries/roundedCube.scad>
include <../OpenSCAD-common-libraries/screw_matrics.scad>
use <../BOSL/metric_screws.scad>

// reserved length for contact plate
contact_thickness=0.5;

// Dimensions from https://batteryuniversity.com/learn/article/battery_packaging_a_look_at_old_and_new_systems
AAA_battery_length=44.5;
AAA_battery_diameter=10.5;

AA_battery_length=50;
AA_battery_diameter=14.5;

selected_battery_size="AAA"; //["AAA", "AA"]; 
echo("selected_battery_size=", selected_battery_size);
 
battery_length = selected_battery_size=="AAA" ? AAA_battery_length-contact_thickness: (selected_battery_size=="AA" ? AA_battery_length-contact_thickness : 0);
echo("battery_length=", battery_length);

battery_diameter = selected_battery_size=="AAA" ? AAA_battery_diameter: (selected_battery_size=="AA" ? AA_battery_diameter: 0);
echo("battery_length=", battery_length);

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