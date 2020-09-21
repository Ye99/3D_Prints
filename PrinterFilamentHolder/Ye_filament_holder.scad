include <BOSL/constants.scad>
use <BOSL/metric_screws.scad>
use <BOSL/transforms.scad>
include <OpenSCAD-common-libraries/screw_matrics.scad>
include <OpenSCAD-common-libraries/roundedCube.scad>

base_x_length=308; // Sovol. 
base_y_length=3.2; // Thickness. 
base_z_length=20; // 20 rail size.

screw_tab_x_length=12; // at each end. 
holder_x_length=base_x_length-(screw_tab_x_length*2);
holder_hole_y_size=3; // 1.75 filament.
holer_y_edge_size=4; // Make it strong enough to sustain spool tangle filament drag force. 
holder_y_length=holder_hole_y_size+holer_y_edge_size;
holder_z_length=holer_y_edge_size; 
rounded_corner_radius=holer_y_edge_size/2;

module mount_screw() {
    fwd(1.5)
        xrot(90)
            screw(m3_screw_hole_diameter,
               screwlen=m3_screw_stem_length,
               headsize=m3_screw_head_diameter,
               headlen=3, countersunk=false, align="base");
}

module holder_side(holder_side_y_length) {
        fwd(holder_side_y_length/2)
            roundedCube([holer_y_edge_size, holder_side_y_length, holder_z_length], center=true, r=rounded_corner_radius,
                z=false,
                y=true,
                ycorners=[false, true, true, false]);
}

module filament_holder() {
    difference() {
        union() {
            roundedCube([base_x_length, base_y_length, base_z_length], center=true, r=rounded_corner_radius,
                z=false,
                y=false,
                x=true,
                xcorners=[false, false, true, true]);
            
            up(base_z_length/2-holder_z_length/2) {
                fwd(base_y_length+holder_hole_y_size)
                    roundedCube([holder_x_length, holer_y_edge_size, holder_z_length], center=true, r=rounded_corner_radius,
                        z=false,
                        x=true,
                        xcorners=[true, true, false, false]);
                
                holder_side_y_length=holer_y_edge_size+holder_hole_y_size;
                side_x_offset=base_x_length/2-screw_tab_x_length-holer_y_edge_size/2;
                left(side_x_offset)
                    holder_side(holder_side_y_length);
                
                right(side_x_offset)
                    yrot(180) // Make the rounded corner toward inner hole.
                        holder_side(holder_side_y_length);
            }
        }
        
        screw_mount_x_offset=base_x_length/2-screw_tab_x_length/2;
        left(screw_mount_x_offset)
            mount_screw();
        right(screw_mount_x_offset)
            mount_screw();
    }
}
filament_holder();

/*
screw_to_end_distance=5;
between_adjacent_screws_distance=15;
screw_group_distance=55;

// cell hole area z lengh 17mm
hole_researved_area_z_length=z_length-(screw_to_end_distance*2+between_adjacent_screws_distance)*2;
hole_researved_area_y_protrude_thickness=8;
hole_researved_area_x_protrude_thickness=8;

module position_screw(surrounding_wall_thickness, is_on_down_side) {
    if (is_on_down_side) {
        up(screw_to_end_distance)
            back(surrounding_wall_thickness+y_length)
            right(x_length/2)
                zrot(180)
                    xrot(90)
                        children();
    }
    else {
        up(screw_to_end_distance)
            fwd(surrounding_wall_thickness)
            right(x_length/2)
                xrot(90)
                    children();
    }
}

module duplicate_two_screws() {
    children();
    up(between_adjacent_screws_distance)
        children();
} */