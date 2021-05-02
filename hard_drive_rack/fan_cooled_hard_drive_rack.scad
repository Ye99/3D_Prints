// According to this paper http://static.googleusercontent.com/media/research.google.com/en/us/archive/disk_failures.pdf
// High temperature results in disk failure. This 3D model is fan cooled rack for external HDD enclosures.   
// Author mr.yezhang@gmail.com
// License: MIT https://en.wikipedia.org/wiki/MIT_License
// TODO: check in a finished photo for illustration. 

include <../BOSL/constants.scad>
use <../BOSL/transforms.scad>
include <../OpenSCAD-common-libraries/roundedCube.scad>
include <../OpenSCAD-common-libraries/screw_matrics.scad>
use <../BOSL/metric_screws.scad>
use <fan_guard.scad>

number_of_drives = 4;

// TODO: update after measurement. 
// This is the net inside dimesions. 
drive_x = 25;
drive_y = 120;
drive_z = 90;

// Space between drives.
spacer_x = 5;

wall_thickness = 2.5;
lip_size = 8;

fan_size=120;

// 8*2.5+3*5+25*4=135
/*
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

wire_channel_width=3; */

$fn=100;

module one_section(drive_x, drive_y, drive_z, wall_thickness) {
    double_wall_thickness = (wall_thickness*2);
    union() {
        difference() {
            cube([drive_x+double_wall_thickness, drive_y+wall_thickness, drive_z+double_wall_thickness], center=true);
            cube([drive_x, drive_y+double_wall_thickness+0.1, drive_z], center=true);
            cube([drive_x+10, drive_y-lip_size*2, drive_z-lip_size*2], center=true);
        }
        up(drive_z/4)
            back((drive_y)/2)
                cube([drive_x+double_wall_thickness, wall_thickness, double_wall_thickness*2], center=true);
    }
}

module connector(drive_y, drive_z, wall_thickness, spacer_x) {
    z_offset = (drive_z+wall_thickness)/2;
        
    up(z_offset)
        cube([spacer_x, drive_y+wall_thickness, wall_thickness], center=true);
    down(z_offset)
        cube([spacer_x, drive_y+wall_thickness, wall_thickness], center=true);
}

module rack(shift_unit) {
    for (i=[1:number_of_drives]) {
    shift = shift_unit*i;
    right(shift)
        union() {
            one_section(drive_x, drive_y, drive_z, wall_thickness);
            if (i<number_of_drives) {
                right(drive_x/2+wall_thickness*2)
                    connector(drive_y, drive_z, wall_thickness, spacer_x);
            }
        }
    }
}


shift_unit = (drive_x+wall_thickness*2+spacer_x);

module positioned_fan_guard() {
    fwd(drive_y/2-1.76)
    right(shift_unit+(fan_size/2-drive_x))
        xrot(90)
            fan_guard();
}

union() {
    difference() {
        positioned_fan_guard();
        hull() 
            rack(shift_unit);
    }
}
rack(shift_unit);