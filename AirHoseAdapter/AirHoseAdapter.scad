include <../BOSL/constants.scad>
use <../BOSL/transforms.scad>
include <../OpenSCAD-common-libraries/roundedCube.scad>
include <../OpenSCAD-common-libraries/screw_matrics.scad>
use <../BOSL/metric_screws.scad>

print_small_port_adaptor=true;

wall_thickness=print_small_port_adaptor? 2 : 2.4;

pump_outer=31.8;
adapter_large_inner_diameter=pump_outer;
assert(adapter_large_inner_diameter>0);
echo(adapter_large_inner_diameter=adapter_large_inner_diameter);

pump_neck_length=50;
adapter_large_section_length=pump_neck_length;

air_bed_port_inner=17.3;
air_boat_port_inner=8;

air_port_inner=print_small_port_adaptor? air_boat_port_inner : air_bed_port_inner;

small_end_shrink_size=print_small_port_adaptor ? 1.0 : 2.0;
adapter_small_outer_diameter=air_port_inner - small_end_shrink_size;
echo(adapter_small_outer_diameter=adapter_small_outer_diameter);

adapter_small_inner_diameter=adapter_small_outer_diameter - wall_thickness*2;
assert(adapter_small_inner_diameter>0);
echo(adapter_small_inner_diameter=adapter_small_inner_diameter);

adapter_small_section_length=print_small_port_adaptor ? 100 : 70;

$fn=100;

module adapter_pump_end(length, inner_diameter, wall_thickness) {
    difference() {
        cylinder(h=length, d=inner_diameter+wall_thickness*2, center=true);
        cylinder(h=length, d=inner_diameter, center=true);
    }
}

module adapter_port_end(length, large_inner_diameter, small_inner_diameter, wall_thickness) {
    difference() {
        cylinder(h=length, d1=large_inner_diameter+wall_thickness*2, d2=small_inner_diameter+wall_thickness*2, center=true);
        cylinder(h=length, d1=large_inner_diameter, d2=small_inner_diameter, center=true);
    }
}

module adapter() {
    union() {
        adapter_pump_end(length=adapter_large_section_length, inner_diameter=adapter_large_inner_diameter, wall_thickness=wall_thickness);
        up(adapter_large_section_length/2+adapter_small_section_length/2)
            adapter_port_end(length=adapter_small_section_length, 
                large_inner_diameter=adapter_large_inner_diameter, 
                small_inner_diameter=adapter_small_inner_diameter,
                wall_thickness=wall_thickness);
    }
}
adapter();