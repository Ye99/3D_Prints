// OpenSCAD code to create a cover for a cylinder

// Parameters
inner_diameter = 52.8; // Inner diameter in mm
height = 24;         // Inner height in mm
wall_thickness = 4;  // Wall thickness in mm
outer_diameter = inner_diameter + 2 * wall_thickness;
$fn = 500;

difference() {
    cylinder(h = height + wall_thickness, d = outer_diameter, center = false);
    
    // Subtract the inner cylinder to create the hollow section
    translate([0, 0, wall_thickness]) { // Shift wall_thickness to keep one end closed
        // height + 1 to render the open end clearly
        cylinder(h = height + 1, d = inner_diameter, center = false);
    }
    
    // Subtract a modified cone to create a chamfer on the open end inner endge
    translate([0, 0, (wall_thickness*1/3) + wall_thickness]) {
        difference() {
            cylinder(h = height, d1 = 0, d2 = outer_diameter, center = false);
            // Cut the chamfer cone top, so it won't penetrate the close end surface
            cylinder(h = height, d = inner_diameter, center = false);
            
        }
    }
}
