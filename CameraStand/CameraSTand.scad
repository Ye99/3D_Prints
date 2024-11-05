// LLM Prompt: Write code for OpenSCAD, create 3D model that is right angle L shape, wall thickness 4mm, L1 edge 80mm, L2 edge 50mm; width 200 mm
// Parameters
wall_thickness = 4; // Thickness of the walls in mm
L1 = 80;             // Length of one edge of the "L" shape in mm
L2 = 50;             // Length of the other edge of the "L" shape in mm
width = 200;         // Width of the shape in mm

module L_shape() {
    union() {
        cube([L1, width, wall_thickness]);
        cube([wall_thickness, width, L2]);
    }
}

L_shape();
