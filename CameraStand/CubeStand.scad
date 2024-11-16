// Define dimensions of the cube and radius of the rounded edges
edge_radius = 0.5; // in cm (radius of rounded edges)
cube_width = 6 - edge_radius * 2;  // in cm
cube_height = 8 - edge_radius * 2; // in cm
cube_depth = 14 - edge_radius * 2; // in cm


// Convert dimensions from cm to mm (OpenSCAD uses mm as the unit)
cube_dims = [cube_width * 10, cube_height * 10, cube_depth * 10];
edge_radius_mm = edge_radius * 10;

// Set high number of facets for smoother edges
$fn = 100;

// Create cube with rounded edges using minkowski
minkowski() {
    cube(cube_dims, center = true); // Cube centered at origin
    sphere(r = edge_radius_mm);     // Sphere for rounding
}
