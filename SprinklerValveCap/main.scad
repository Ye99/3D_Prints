$fn = 120;

sides = 6;
sprinkler_inner_flat = 20;
sprinkler_wall_thickness = 3;
sprinkler_base_thickness = 3;
sprinkler_inner_height = 15;
sprinkler_inner_chamfer_height = 3;
sprinkler_inner_chamfer_offset = 2;
render_epsilon = 0.5;

function radius_from_flat(flat_distance) = (flat_distance / 2) / cos(180 / sides);

module hex_prism(radius_value, height_value) {
    cylinder(r = radius_value, h = height_value, $fn = sides);
}

module sprinkler_cap() {
    assert(sprinkler_inner_chamfer_height <= sprinkler_inner_height, "Chamfer taller than inner height");
    assert(sprinkler_inner_chamfer_offset <= sprinkler_wall_thickness, "Chamfer offset exceeds wall thickness");

    outer_flat = sprinkler_inner_flat + (2 * sprinkler_wall_thickness);
    outer_radius = radius_from_flat(outer_flat);
    inner_radius = radius_from_flat(sprinkler_inner_flat);
    outer_height = sprinkler_inner_height + sprinkler_base_thickness;
    chamfer_start_height = sprinkler_base_thickness + sprinkler_inner_height - sprinkler_inner_chamfer_height;

    difference() {
        hex_prism(outer_radius, outer_height);
        union() {
            translate([0, 0, sprinkler_base_thickness])
                hex_prism(inner_radius, sprinkler_inner_height + render_epsilon);
            translate([0, 0, chamfer_start_height])
                cylinder(h = sprinkler_inner_chamfer_height + render_epsilon,
                         r1 = inner_radius,
                         r2 = inner_radius + sprinkler_inner_chamfer_offset,
                         $fn = sides);
        }
    }
}

sprinkler_cap();

