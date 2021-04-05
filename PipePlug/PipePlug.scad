include <../BOSL/constants.scad>
use <../BOSL/transforms.scad>

cylinder(h=40, d1=14.2, d2=13.8, center=false, $fn=1000);
down(3)
    cylinder(h=3, d=30, center=false, $fn=100);