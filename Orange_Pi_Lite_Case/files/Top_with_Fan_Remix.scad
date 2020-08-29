use <BOSL/transforms.scad>
include <BOSL/constants.scad>
use <BOSL/metric_screws.scad>
// Make screw hole smoother---this includes metric_screws library. 
$fn=80;

// 40mm fan size – 32mm between screw holes.
screw_distance=32;
// Fan hole diameter 38mm. 
fan_hole_diameter=38-2;
mesh_blocker_x_length=40;
mesh_blocker_y_length=56;
mesh_blocker_z_length=2.64;
box_y_length=70;
// This is standard size.
screw_hole_diameter=3.5;

/* move children to four corners, also lift it up by control_compartment_wall_thickness */
module arrange_to_four_corners(control_compartment_x_length, control_compartment_y_length, control_compartment_wall_thickness) {
    double_wall_thickness=control_compartment_wall_thickness*2;
    cover_hole_to_edge_offset_x=control_compartment_wall_thickness*2;
    cover_hole_to_edge_offset_y=cover_hole_to_edge_offset_x;
    
    translate([cover_hole_to_edge_offset_x, 
                cover_hole_to_edge_offset_y, 
                control_compartment_wall_thickness])
        children();
    
    translate([cover_hole_to_edge_offset_x, 
                control_compartment_y_length+double_wall_thickness-cover_hole_to_edge_offset_y, 
                control_compartment_wall_thickness])
        zrot(-90)
            children();
    
    translate([control_compartment_x_length+double_wall_thickness-cover_hole_to_edge_offset_x, 
                control_compartment_y_length+double_wall_thickness-cover_hole_to_edge_offset_y, 
                control_compartment_wall_thickness])
        zrot(-180)
            children();

    translate([control_compartment_x_length+double_wall_thickness-cover_hole_to_edge_offset_x, 
                cover_hole_to_edge_offset_y, 
                control_compartment_wall_thickness])
        zrot(-270)
            children();
}

module fan_screw() {
        screw(screw_hole_diameter + 0.5, // leave some play
               screwlen=20,
               headsize=5.5,
               headlen=3, countersunk=false, align="base");
}

difference() {
    union() {
        import("Orange_Pi_Lite_Box_V2.0_Top_GPIO.stl");
        
        // Center mesh_blocker against box y direction.
        // box_y_length/2 = mesh_blocker_y_length/2 + delta
        // delta = (box_y_length-mesh_blocker_y_length)/2
        back((box_y_length-mesh_blocker_y_length)/2)
            left(mesh_blocker_x_length+8)
                mesh_cover();
    }
    fan_hole();
    
    align_fan()
        arrange_fan_screws()
            #fan_screw();
}

// Align to center of box.
module align_fan() {
    back(39)
       left(28.5)
         children();
}

// Duplicate four screws and assign them to four corners. 
module arrange_fan_screws() {
    up(mesh_blocker_z_length) {
        left(screw_distance/2)
            back(screw_distance/2)
                children();
        
        right(screw_distance/2)
            back(screw_distance/2)
                children();
        
        right(screw_distance/2)
            fwd(screw_distance/2)
                children();
        
        left(screw_distance/2)
            fwd(screw_distance/2)
                children();
    }
}

module fan_hole() {
    align_fan()
       down(0.1)
            cylinder(h=4, d=fan_hole_diameter, $fn=80);
}

// Make original mesh solid so I can cut fan hole.
module mesh_cover() {
    cube([mesh_blocker_x_length, mesh_blocker_y_length, mesh_blocker_z_length]);
}
