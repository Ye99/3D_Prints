include <BOSL/constants.scad>
use <BOSL/transforms.scad>
include <../OpenSCAD-common-libraries/roundedCube.scad>

// https://smile.amazon.com/gp/product/B07PWBNQ5V/ref=ppx_yo_dt_b_asin_title_o01_s00?ie=UTF8&psc=1 
// propeller center holes
diameter_large = 9.5; // actual 9.52
diameter_small = 6.1; // actual 6.1
// large hole concave depth 3.1.

prop_hub_diameter=13;

balancer_thickness=2;
insert_height=7;
needle_cone_bottom_diameter=diameter_small; // This is wides part diameter of the cone
needle_cone_height=insert_height+balancer_thickness/2;

// Small hole insert, to secure the balancer to prop
module insert() {    
    cylinder(d=diameter_small, h=insert_height, center=false, $fn=200);
}

// Insert into large hole
module large_hole_balancer() {    
    difference() {
        union() {
            cylinder(d=diameter_large, h=balancer_thickness, center=true, $fn=200);
            up(balancer_thickness/2)
                insert();
        }
        down(balancer_thickness/2)
            #cylinder(d1=needle_cone_bottom_diameter, d2=0, h=needle_cone_height, center=false, $fn=200);
    }
    
}


right(15)
    large_hole_balancer();

// Insert into small hole
module small_hole_balancer() {    
    difference() {
        union() {
            up(balancer_thickness/2)
                insert();
            cylinder(d=prop_hub_diameter, h=balancer_thickness, center=true, $fn=200);
        }
        down(balancer_thickness/2)
            cylinder(d1=needle_cone_bottom_diameter, d2=0, h=needle_cone_height, center=false, $fn=200);
    }
    
}
small_hole_balancer();