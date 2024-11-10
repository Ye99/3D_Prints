inner_radius = 12.5;
wall_thickness = 2.5;
open_angle = 80;//[25:170]
height = 30.0;

/* [Hidden] */
$fn = 200;

/* improved by Pascal */

module pie_slice(r, start_angle, end_angle) {
    R = r * sqrt(2) + 1;
    a0 = (4 * start_angle + 0 * end_angle) / 4;
    a1 = (3 * start_angle + 1 * end_angle) / 4;
    a2 = (2 * start_angle + 2 * end_angle) / 4;
    a3 = (1 * start_angle + 3 * end_angle) / 4;
    a4 = (0 * start_angle + 4 * end_angle) / 4;
    if(end_angle > start_angle)
        intersection() {
        circle(r);
        polygon([
            [0,0],
            [R * cos(a0), R * sin(a0)],
            [R * cos(a1), R * sin(a1)],
            [R * cos(a2), R * sin(a2)],
            [R * cos(a3), R * sin(a3)],
            [R * cos(a4), R * sin(a4)],
            [0,0]
       ]);
    }
}

module rotate_extrude_helper(angle){
    if(version_num() < 20190500){
        intersection(){
            linear_extrude(height)
                pie_slice(inner_radius + 1.505 * wall_thickness, 0, angle);
            rotate_extrude()
                children();
        }
    }else{
        rotate_extrude(angle = angle)
            children();
    }
}

function angle_from_law_of_cosines(a, b, c) = acos((pow(c, 2) - pow(a,
2) - pow(b, 2)) / (-2 * a * b));

outer_radius = inner_radius + wall_thickness;
rotate([0, 0, open_angle / 2])
{
    difference(){
        union(){
            rotate_extrude_helper(angle = 360 - open_angle)
                translate([inner_radius, 0])
                        square([1.5 * wall_thickness, height]);

            translate([outer_radius, 0])
                    cylinder(r = wall_thickness, height);
            rotate([0, 0, -open_angle])
                translate([outer_radius, 0])
                        cylinder(r = wall_thickness, height);
        }
        translate([outer_radius, 0])
                cylinder(r = wall_thickness * 0.6, height);
        rotate([0, 0, -open_angle])
            translate([outer_radius, 0])
                    cylinder(r = wall_thickness * 0.6, height);
       
        round_edge_angle_offset =
angle_from_law_of_cosines(outer_radius, outer_radius + wall_thickness, 2
* wall_thickness);
       
        rotate([0, 0, round_edge_angle_offset])
            translate([outer_radius + wall_thickness, 0])
                    cylinder(r = wall_thickness, height);
        rotate([0, 0, -open_angle - round_edge_angle_offset])
            translate([outer_radius + wall_thickness, 0])
                    cylinder(r = wall_thickness, height);

        rotate([0, 0, round_edge_angle_offset])
            rotate_extrude_helper(angle = 360 - open_angle - 2 *
round_edge_angle_offset)
                translate([inner_radius + wall_thickness, 0])
                        square([0.505 * wall_thickness, height]);
    }
}
