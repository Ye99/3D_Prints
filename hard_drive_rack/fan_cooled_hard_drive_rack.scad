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

number_of_drives = 6;

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

rounded_corner_radius=2;

// 5.5x2.1 plug socket.
OD_five_point_five_plug_socket_hole_diameter=8;
socket_hole_up_offset=1.2;

rack_total_x = ((wall_thickness * 2 + drive_x) * number_of_drives) + (spacer_x * (number_of_drives - 1));
echo("Rack total x is ", rack_total_x);

module one_section(drive_x, drive_y, drive_z, wall_thickness) {
    double_wall_thickness = (wall_thickness*2);
    union() {
        difference() {
            cube([drive_x+double_wall_thickness, drive_y+wall_thickness, drive_z+double_wall_thickness], center=true);
            cube([drive_x, drive_y+double_wall_thickness+0.1, drive_z], center=true);
            cube([drive_x+10, drive_y-lip_size*2, drive_z-lip_size*2], center=true);
			cube([drive_x-lip_size*3/2, drive_y-lip_size*2, drive_z+10], center=true);
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

module foot() {
	foot_z=(fan_size-drive_z-wall_thickness*2)/2;
	down(drive_z/2+wall_thickness+foot_z/2)
		roundedCube([(wall_thickness*2), drive_y+(wall_thickness), foot_z], 
				center=true, r=rounded_corner_radius,
				z=true,
				zcorners=[true, true, false, false],
				x=true,
				xcorners=[true, false, false, false],
				y=false,
				ycorners=[true,false,false,false]);
}

module socket_mount(hole_diameter, up_offset, thickness) {
	mount_z = hole_diameter*2;
	echo("mount height is ", mount_z);
	up(mount_z/2)
		difference() {
			cube([thickness, hole_diameter*3, mount_z], center=true);
			up(up_offset)
				yrot(90)
					cylinder(d=hole_diameter, h=wall_thickness*3, center=true, $fn=50);
		}
}

module rack(shift_unit, include_foot) {
    for (i=[1:number_of_drives]) {
    shift = shift_unit*i;
    right(shift)
        union() {
            one_section(drive_x, drive_y, drive_z, wall_thickness);
            if (i<number_of_drives) {
                right(drive_x/2+wall_thickness*2) {
                    connector(drive_y, drive_z, wall_thickness, spacer_x);
					if (include_foot) 
						foot();
				}
            }
			
			if (i == number_of_drives/2) { // Place socket mount at center
				back(drive_y/2)
					up(drive_z/2+wall_thickness)
						right((drive_x+spacer_x)/2+wall_thickness)
							zrot(90)
								socket_mount(OD_five_point_five_plug_socket_hole_diameter, socket_hole_up_offset, wall_thickness);
			}
        }
    }
}


shift_unit = (drive_x+wall_thickness*2+spacer_x);

module positioned_fan_guard() {
    fwd(drive_y/2-1.76) // This magic number 1.76 is to align the guard flush with the rack. It depends on fan guard thickness. Refactor later to remove this magic number. 
    right(shift_unit - (fan_size*2-rack_total_x)/2 + 45) // TODO: calculate this.
        xrot(90)
			union() { // Two guards side by side. 
				fan_guard();
				right(fan_size)
					fan_guard();
			}
}

union() {
    difference() {
        positioned_fan_guard();
        hull() 
            rack(shift_unit, false);
    }
    rack(shift_unit, true);
}
