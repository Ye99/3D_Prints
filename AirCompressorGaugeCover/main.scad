// OpenSCAD code to create a cover for a cylinder

// Parameters
inner_diameter = 52; // Inner diameter in mm
height = 24;         // Height in mm
wall_thickness = 4;  // Wall thickness in mm
$fn = 200;

// Create the outer cylinder
outer_diameter = inner_diameter + 2 * wall_thickness;

difference() {
    cylinder(h = height, d = outer_diameter, center = false);
    
    // Subtract the inner cylinder to create the hollow section
    translate([0, 0, wall_thickness]) { // To keep one end closed
        cylinder(h = height, d = inner_diameter, center = false);
    }
    
    translate([0, 0, (wall_thickness*1/3)]) {
        //difference() {
            #cylinder(h = height, d1 = 0, d2 = outer_diameter, center = false);
            *translate([0, 0, wall_thickness]) { // To keep one end closed
                cylinder(h = height, d = inner_diameter, center = false);
            }
        // }
    }
}

// Draw a cone with base diameter equal to the outer diameter of the cylinder
