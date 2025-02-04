// All dimensions in millimeters

// Constants
BASE_SIZE = 90;
BASE_HEIGHT = 3; 
TOP_HEIGHT = 48;
TOP_DIAMETER = 42;
HOLE_DIAMETER = 36;
CHAMFER_SIZE = 3;  // Chamfer diameter

module base() {
    // Base square with chamfered corners and rounded top edges
    hull() {
        // Bottom plate
        translate([CHAMFER_SIZE/2, CHAMFER_SIZE/2, 0])
            cube([
                BASE_SIZE - CHAMFER_SIZE,
                BASE_SIZE - CHAMFER_SIZE,
                0.1
            ]);
        
        // Four cylinders at corners for top edge
        for(x = [CHAMFER_SIZE, BASE_SIZE - CHAMFER_SIZE])
            for(y = [CHAMFER_SIZE, BASE_SIZE - CHAMFER_SIZE])
                translate([x, y, BASE_HEIGHT - CHAMFER_SIZE/2])
                    sphere(d=CHAMFER_SIZE, $fn=32);
        
        // Four cylinders for edge rounding
        for(pos = [[CHAMFER_SIZE, BASE_SIZE/2], 
                   [BASE_SIZE - CHAMFER_SIZE, BASE_SIZE/2],
                   [BASE_SIZE/2, CHAMFER_SIZE],
                   [BASE_SIZE/2, BASE_SIZE - CHAMFER_SIZE]])
            translate([pos[0], pos[1], BASE_HEIGHT - CHAMFER_SIZE/2])
                sphere(d=CHAMFER_SIZE, $fn=32);
    }
}

module top_section() {
    // Position cylinder at center of base
    translate([BASE_SIZE/2, BASE_SIZE/2, BASE_HEIGHT]) {
        difference() {
            // Outer cylinder with rounded edges
            minkowski() {
                cylinder(h=TOP_HEIGHT - CHAMFER_SIZE, 
                        d=TOP_DIAMETER - CHAMFER_SIZE, 
                        $fn=64);
                sphere(d=CHAMFER_SIZE, $fn=32);
            }
            
            union() {
                // Main hole
                translate([0, 0, -1])
                    cylinder(h=TOP_HEIGHT + 2, d=HOLE_DIAMETER, $fn=64);
                
                // Chamfer for inner top edge
                translate([0, 0, TOP_HEIGHT - CHAMFER_SIZE])
                    cylinder(h=CHAMFER_SIZE + 0.1, 
                            d1=HOLE_DIAMETER, 
                            d2=HOLE_DIAMETER + 2*CHAMFER_SIZE, 
                            $fn=64);
            }
        }
    }
}

// Main assembly
module holder() {
    base();
    top_section();
}

// Render the shape
holder();