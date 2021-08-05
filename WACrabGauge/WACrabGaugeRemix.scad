// WA crab gauge, remix from https://www.thingiverse.com/thing:2839932
// Remix author mr.yezhang@gmail.com
// License: MIT https://en.wikipedia.org/wiki/MIT_License
// TODO: check in a finished photo for illustration. 

include <../BOSL/constants.scad>
use <../BOSL/transforms.scad>
include <../OpenSCAD-common-libraries/roundedCube.scad>
include <../OpenSCAD-common-libraries/screw_matrics.scad>
use <../BOSL/metric_screws.scad>

module gauge() {
    difference() {
        import("Crab_Calipers_Washington.STL");
        back(6.3)
            cube([200, 10, 200]);
    }
}

difference() {
    gauge();

    right(88)
    up(56)
        xrot(-90)
            linear_extrude(7) {
                text("DUNGENESS 6 1/4 inches-LIMIT 5 MALES", size=5, halign="center");
                fwd(20)
                text("RED ROCK 5 inches-LIMIT 6", size=5, halign="center");
            }
}