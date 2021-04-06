// Container to lubricate noisy 3D printer fans.
// Author mr.yezhang@gmail.com
// License: MIT https://en.wikipedia.org/wiki/MIT_License
// It's hard to lubricate 3D printer fans. Even the fan is removed from a printer, you can't get to the fan's bearing, 
// especially blow fan type:
// https://smile.amazon.com/SoundOriginal-50x50x15mm-Humidifier-Aromatherapy-Replacement/dp/B076896HH1/ref=sr_1_3?dchild=1&keywords=40x40+blow+fan&qid=1617688206&sr=8-3
// This print is designed to lubricate the fan without dissembling it. 
// 1. Pour enough oil into this printed container, like this https://smile.amazon.com/gp/product/B0025PR4K2/ref=ox_sc_saved_title_6?smid=ATVPDKIKX0DER&psc=1
// 2. Immerse the fan into the oil. 
// 3. Lift the fan and let excessive oil drip. 
// 4. Close container cap for next use. 

include <../BOSL/constants.scad>
use <../BOSL/transforms.scad>
include <../OpenSCAD-common-libraries/roundedCube.scad>
include <../OpenSCAD-common-libraries/screw_matrics.scad>
use <../BOSL/metric_screws.scad>

// The free play added to cover dimesion, so the cover can be installed and removed without too much friction. 
cover_size_adjustment=0.5;

// Set this to false so the container and cover will lay flat on printer bed. 
preview=false; 

// x,y,z are the net sizes inside the walls.
module box(box_x_length, box_y_length, box_z_length, wall_thickness, rounded_corner_radius, is_cover) {
    difference() { 
        if (is_cover) {
        roundedCube([box_x_length+(wall_thickness*2), box_y_length+(wall_thickness*2), box_z_length+wall_thickness], 
            center=true, r=rounded_corner_radius,
            z=true,
            x=true,
            y=true);
        }
        else {
            roundedCube([box_x_length+(wall_thickness*2), box_y_length+(wall_thickness*2), box_z_length+wall_thickness], 
            center=true, r=rounded_corner_radius,
            z=true,
            zcorners=[true, true, true, true],
            x=true,
            xcorners=[false, true, true, false],
            y=true,
            ycorners=[true,true,false,false]);
        }
       
       compartment_center_raise=wall_thickness/2;
        up(compartment_center_raise+0.1)
            cube([box_x_length, box_y_length, box_z_length], 
                center=true);
    }
}

module cover(box_x_length, box_y_length, cover_z_length, wall_thickness, rounded_corner_radius) {
    double_wall_size_plus_cover_size_adjustment = wall_thickness*2+cover_size_adjustment;
    box(box_x_length+double_wall_size_plus_cover_size_adjustment, 
        box_y_length+double_wall_size_plus_cover_size_adjustment, 
        cover_z_length+wall_thickness, 
        wall_thickness, 
        rounded_corner_radius,
        true);
}

// x,y,z are the net sizes inside the walls.
// cover x, y are inferred automatically from box dimensions. 
module conatiner_and_cover(box_x_length, box_y_length, box_z_length, cover_z_length, wall_thickness, rounded_corner_radius) {
    box(box_x_length, box_y_length, box_z_length, wall_thickness, rounded_corner_radius, false);
    
    if (preview) {
        up((box_z_length+wall_thickness-cover_z_length)/2)
            xrot(180)
                cover(box_x_length, box_y_length, cover_z_length, wall_thickness, rounded_corner_radius); 
    }
    else {
        down((box_z_length-cover_z_length-wall_thickness)/2)
            right(box_x_length+wall_thickness*3.2)
                cover(box_x_length, box_y_length, cover_z_length, wall_thickness, rounded_corner_radius); 
    }
}


conatiner_and_cover(box_x_length=50, box_y_length=50, box_z_length=50, cover_z_length=18, wall_thickness=3.2, rounded_corner_radius=1);