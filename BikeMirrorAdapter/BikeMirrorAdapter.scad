// To minimize support, print the model standing on the half circle surface. 
// Notice one of the contact surfaces is larger than the other,
// to improve bed adhesion. Pay attention to use the larger one. 

include <../BOSL/constants.scad>
use <../BOSL/metric_screws.scad>
use <../BOSL/transforms.scad>
include <../OpenSCAD-common-libraries/screw_matrics.scad>
use <../MCAD/regular_shapes.scad>

// First layer height + layer height. 
bed_adhesion_lip_height=0.32 + 0.28;

diameter_thick=18.2;
diameter=13.7;
height_tall=39.5;
height_short=11;
// Calculator https://www.calculator.net/right-triangle-calculator.html?av=18.2&alphav=&alphaunit=d&bv=28.5&betav=&betaunit=d&cv=&hv=&areav=&perimeterv=&x=76&y=22
// Triangle b=39.5-11=28.5
// Triangle a=18.2
// ∠α = 32.562° = 32°33'44" = 0.56832 rad
// ∠β = 57.438° = 57°26'16" = 1.00248 rad

bolt_hole_diameter=10.5;
bolt_width=12;
screw_hole_diameter=5.2;

// Determin circle smothness. 
face_number=100;

module screw_hole() {
    linear_extrude(height = height_tall, center = false)
        hull() {
            left(screw_hole_diameter/2)
                circle(d=screw_hole_diameter);
            right(screw_hole_diameter/2)
                circle(d=screw_hole_diameter);
        }
}

module bolt_hole() {
    xrot(90)
        cylinder(r=bolt_hole_diameter/2, h=diameter, $fn=face_number, center=true);
}

module cut() {
    a=[[0,28.5],[18.2,28.5],[0,0]];
    left(18.2/2)
        back(diameter/2)
            xrot(90)
                linear_extrude(height = diameter, center = false)
                    polygon(a);            
}

module adapter() {
    difference() {
        cylinder(r=diameter/2, h=height_tall, $fn=face_number);
        screw_hole();
        bolt_hole();
        up(height_short)
            cut();
    }
}

adapter();
