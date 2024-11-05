/*//////////////////////////////////////////////////////////////////
              -    FB Aka Heartman/Hearty 2016     -                   
              -   http://heartygfx.blogspot.com    -                  
              -       OpenScad Parametric Box      -                     
              -         CC BY-NC 3.0 License       -                      
////////////////////////////////////////////////////////////////////                                                                                                             
12/02/2016 - Fixed minor bug 
28/02/2016 - Added holes ventilation option                    
09/03/2016 - Added PCB feet support, fixed the shell artefact on export mode. 

09/06/2020 - Ye Zhang change ventiliation holes for DC-DC buck convertor; reformat code to reduce nest level and improve readability. 
09/12/2020 - Ye Zhang Refactor code fixing magic numbers, making the module contrains computed rahter than hardcoded, making PCB board real size. 
*/

use <../BOSL/transforms.scad>
use <../BOSL/metric_screws.scad>
use <../MCAD/regular_shapes.scad>
include <../OpenSCAD-common-libraries/screw_matrics.scad>

selected_board="LM2596Blue"; //["XL4015Red", "LM2596Blue", "RD_Green", "XL4016DoubleHeatSinks"];
echo("selected_board=", selected_board);

/* [STL element to export] */
//Coque haut - Top shell
  top_shell    = 0;// [0:No, 1:Yes]
//Coque bas- Bottom shell
  bottom_shell = 0;// [0:No, 1:Yes]
//Panneau arrière - Back panel  
  back_panel   = 0;// [0:No, 1:Yes]
//Panneau avant - Front panel
  front_panel  = 1;// [0:No, 1:Yes]
//Texte façade - Front text
  Text          = 0;// [0:No, 1:Yes]
  
/* [Box options] */
// Pieds PCB - PCB feet (x4) 
  PCBFeet = 1;// [0:No, 1:Yes]
// - Decorations to ventilation holes
  Vent = 1;// [0:No, 1:Yes]
// - Text you want
  txt = "";           
// - Font size  
  TxtSize = 3;                 
// - Font  
  Police        ="Arial Black"; 
// - Diamètre Coin arrondi - Filet diameter  
  Filet         = 0.1;//[0.1:12] 
// - lissage de l'arrondi - Filet smoothness  
  Resolution    = 50;//[1:100] 
// - Tolérance - Tolerance (Panel/rails gap)
  m             = 0.9;

// - Heuteur pied - Feet height
FootHeight      = 3; // Notice this is the net height above bottom, it doesn't include box wall thickness.
// - Diamètre pied - Foot diameter
FootDia         = 3.6;
// - Diamètre trou - Hole diameter
FootHole        = 2;

// 5.5x2.1 plug socket.
DC_socket_hole_diameter=8;
DC_socket_protrusion_length=17;

output_wire_hole_diameter=5.5;

// XL4015 board
xl4015_pcb_hole_x_distance = 47; // hole to hole. edge to edge is 51.2;
xl4015_pcb_hole_y_distance = 22; // edge to edge is 26.3;
xl4015_PCBHeight = 20; // This equals to the tallest component height + PCB board thickness. 
xl4015_pcb_edge_to_hole_x_distance = 2;
xl4015_pcb_edge_to_hole_y_distance = 2;
xl4015_adjustment_hole_count = 2;
// reference point is the bottom-left pcb hole
xl4015_adjustment_hole_x1_offset = 16.5;
xl4015_adjustment_hole_x2_offset = xl4015_adjustment_hole_x1_offset+5;
xl4015_adjustment_hole_y1_offset = 7;
xl4015_adjustment_hole_y2_offset = xl4015_adjustment_hole_y1_offset;

// LM2596/RD board's screw holes size is 3.5mm, larger than XL4105, 3mm. But both can use M2x4 screw in this set https://smile.amazon.com/gp/product/B081DVZMHH/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1
// LM2596 board
lm2596_pcb_hole_x_distance = 30; // hole to hole. edge to edge is 43.5;
lm2596_pcb_hole_y_distance = 16; // edge to edge is 21;
lm2596_PCBHeight = 16; // This equals to the tallest component height + PCB board thickness. Not including the pin length underneath PCB board.
lm2596_pcb_edge_to_hole_x_distance = 6.5;
lm2596_pcb_edge_to_hole_y_distance = 3;
lm2596_adjustment_hole_count = 1;
// reference point is the bottom-left pcb hole
lm2596_adjustment_hole_x1_offset = 16;
lm2596_adjustment_hole_y1_offset = 1;

// RD green board, https://www.aliexpress.com/item/995963510.html?spm=a2g0s.9042311.0.0.27424c4dcc0soI 
rd_pcb_hole_x_distance = 36.2; // hole to hole. edge to edge is 43.7;
rd_pcb_hole_y_distance = 23.2; // edge to edge is 30.4;
rd_PCBHeight = 15; // This equals to the tallest component height + PCB board thickness. Not including the pin length underneath PCB board.
rd_pcb_edge_to_hole_x_distance = 4;
rd_pcb_edge_to_hole_y_distance = 4;
rd_adjustment_hole_count = 1;
// reference point is the bottom-left pcb hole
rd_adjustment_hole_x1_offset = 22;
rd_adjustment_hole_y1_offset = -0.5;

// https://www.aliexpress.com/item/32804886645.html?spm=a2g0s.9042311.0.0.27424c4dATkzPV
// https://www.aliexpress.com/item/32804886645.html?spm=a2g0s.9042311.0.0.27424c4dhF0qUw
// XL4016 9A double heat sink board
xl4016_double_heatsinks_pcb_hole_x_distance = 58.43; // hole to hole. edge to edge is 65
xl4016_double_heatsinks_pcb_hole_y_distance = 26.3; // edge to edge is 48; heat sinks extrude from x top and bottom pcb holes both 11.5
xl4016_double_heatsinks_PCBHeight = 22; // This equals to the tallest component height + PCB board thickness. 
xl4016_double_heatsinks_pcb_edge_to_hole_x_distance = 3.5;
xl4016_double_heatsinks_pcb_edge_to_hole_y_distance = 11.5;
xl4016_double_heatsinks_adjustment_hole_count = 2;
// reference point is the bottom-left pcb hole
xl4016_double_heatsinks_adjustment_hole_x1_offset = -1.5;
xl4016_double_heatsinks_adjustment_hole_x2_offset = -1.5;
xl4016_double_heatsinks_adjustment_hole_y1_offset = 3;
xl4016_double_heatsinks_adjustment_hole_y2_offset = xl4016_double_heatsinks_adjustment_hole_y1_offset + 10;

pcb_hole_x_distance = selected_board=="XL4015Red" ? xl4015_pcb_hole_x_distance : (selected_board=="LM2596Blue" ? lm2596_pcb_hole_x_distance  : (selected_board=="RD_Green" ? rd_pcb_hole_x_distance : (selected_board=="XL4016DoubleHeatSinks" ? xl4016_double_heatsinks_pcb_hole_x_distance : 0)));
echo("pcb_hole_x_distance=", pcb_hole_x_distance);

pcb_hole_y_distance = selected_board=="XL4015Red" ? xl4015_pcb_hole_y_distance : (selected_board=="LM2596Blue" ? lm2596_pcb_hole_y_distance  : (selected_board=="RD_Green" ? rd_pcb_hole_y_distance : (selected_board=="XL4016DoubleHeatSinks" ? xl4016_double_heatsinks_pcb_hole_y_distance : 0)));
echo("pcb_hole_y_distance=", pcb_hole_y_distance);

PCBHeight = selected_board=="XL4015Red" ? xl4015_PCBHeight : (selected_board=="LM2596Blue" ? lm2596_PCBHeight : (selected_board=="RD_Green" ? rd_PCBHeight : (selected_board=="XL4016DoubleHeatSinks" ? xl4016_double_heatsinks_PCBHeight : 0)));
echo("PCBHeight=", PCBHeight);

pcb_edge_to_hole_x_distance = selected_board=="XL4015Red" ? xl4015_pcb_edge_to_hole_x_distance : (selected_board=="LM2596Blue" ? lm2596_pcb_edge_to_hole_x_distance : (selected_board=="RD_Green" ? rd_pcb_edge_to_hole_x_distance : (selected_board=="XL4016DoubleHeatSinks" ? xl4016_double_heatsinks_pcb_edge_to_hole_x_distance : 0)));
pcb_edge_to_hole_y_distance = selected_board=="XL4015Red" ? xl4015_pcb_edge_to_hole_y_distance : (selected_board=="LM2596Blue" ? lm2596_pcb_edge_to_hole_y_distance : (selected_board=="RD_Green" ? rd_pcb_edge_to_hole_y_distance : (selected_board=="XL4016DoubleHeatSinks" ? xl4016_double_heatsinks_pcb_edge_to_hole_y_distance : 0)));

adjustment_hole_count = selected_board=="XL4015Red" ? xl4015_adjustment_hole_count : (selected_board=="LM2596Blue" ? lm2596_adjustment_hole_count : (selected_board=="RD_Green" ? rd_adjustment_hole_count : (selected_board=="XL4016DoubleHeatSinks" ? xl4016_double_heatsinks_adjustment_hole_count : 0)));

// reference point is the top-left pcb hole
adjustment_hole_x1_offset = selected_board=="XL4015Red" ? xl4015_adjustment_hole_x1_offset : (selected_board=="LM2596Blue" ? lm2596_adjustment_hole_x1_offset : (selected_board=="RD_Green" ? rd_adjustment_hole_x1_offset : (selected_board=="XL4016DoubleHeatSinks" ? xl4016_double_heatsinks_adjustment_hole_x1_offset : 0)));
adjustment_hole_x2_offset = selected_board=="XL4015Red" ? xl4015_adjustment_hole_x2_offset : (selected_board=="LM2596Blue" ? 0 : (selected_board=="RD_Green" ? 0 : (selected_board=="XL4016DoubleHeatSinks" ? xl4016_double_heatsinks_adjustment_hole_x2_offset : 0)));
adjustment_hole_y1_offset = selected_board=="XL4015Red" ? xl4015_adjustment_hole_y1_offset : (selected_board=="LM2596Blue" ? lm2596_adjustment_hole_y1_offset  : (selected_board=="RD_Green" ? rd_adjustment_hole_y1_offset : (selected_board=="XL4016DoubleHeatSinks" ? xl4016_double_heatsinks_adjustment_hole_y1_offset : 0)));
adjustment_hole_y2_offset = selected_board=="XL4015Red" ? xl4015_adjustment_hole_y2_offset : (selected_board=="LM2596Blue" ? 0 : (selected_board=="RD_Green" ? 0 : (selected_board=="XL4016DoubleHeatSinks" ? xl4016_double_heatsinks_adjustment_hole_y2_offset : 0)));

adjustment_hole_diameter = selected_board=="XL4016DoubleHeatSinks" ? 5.5 : 0; // 3.5;

board_to_wall_clearance_x = 2;
board_to_wall_clearance_y = 2;
board_x = pcb_hole_x_distance+pcb_edge_to_hole_x_distance*2;
board_y = pcb_hole_y_distance+pcb_edge_to_hole_y_distance*2;

// Wall thickness  
Thick = 2; //[2:5]

// The empty part.
vent_hole_x = 3.5;
// The solid part.
vent_grill_x = 1.3;
// empty/total_area ratio = vent_hole_x / (vent_hole_x + vent_grill_x)

/* [Box dimensions] */
box_side_thickness = 3*Thick;
Length = board_x + board_to_wall_clearance_x*2 + box_side_thickness*2 + DC_socket_protrusion_length; // This is the outmost dimention, net usable space by PCB board is much smaller.
echo("Box x length=", Length);
// 4 thickness because of the top-bottom tabs
Width = board_y + Thick*4 + board_to_wall_clearance_y*2; // 47;
echo("Box y length=", Width);
Height = PCBHeight + Thick*2 + FootHeight + 2; // Add 2 as clearance.
echo("Box z length=", Height);

number4_screw_hole_tap_diameter=2.78;
number4_screw_thread_diamater=2.84;
// No-drag through-hole diameter
number4_screw_hole_diameter=number4_screw_thread_diamater+0.7;

top_bottom_connecting_screw_tap_diameter=number4_screw_hole_tap_diameter; // tap hole size
top_bottom_connecting_screw_hole_diameter=number4_screw_hole_diameter; // no drag hole size

/* [Hidden] */
// - Couleur coque - Shell color  
Couleur1        = "Orange";       
// - Couleur panneaux - Panels color    
Couleur2        = "OrangeRed"; 

assert(Height >= Thick*2 + FootHeight + PCBHeight, "Make box taller please");

/////////// - Boitier générique bord arrondis - Generic Fileted box - //////////
module RoundBox($a=Length, $b=Width, $c=Height) {// Cube bords arrondis
    $fn=Resolution;
    translate([0,Filet,Filet]) {  
        minkowski () {       
            cube ([$a-(Length/2),$b-(2*Filet),$c-(2*Filet)], center = false);
            rotate([0,90,0])
                cylinder(r=Filet,h=Length/2, center = false);
        }
    }
}

module adjustment_hole() {
    screw(adjustment_hole_diameter,
       screwlen=M4_screw_stem_length,
       headsize=adjustment_hole_diameter,
       headlen=3, countersunk=false, align="base");
}

// This transfers reference from PCB edge to system coordinates, which is same as box x/y/z zero. 
board_edge_x=box_side_thickness+board_to_wall_clearance_x;
// Thick*2 because there are wall+tab.
board_edge_y=Thick*2+board_to_wall_clearance_y;
module offset_pcb() {
    back(board_edge_y)
        right(board_edge_x)
            children();
}

//// PCB parts (hole) references PCB screw hole. This make them reference PCB edge.
module offset_pcb_hole() {
    back(pcb_edge_to_hole_y_distance)
        right(pcb_edge_to_hole_x_distance) 
            children();
}

module CutAdjustmentHole() {
    // At least one hole. 
    right(adjustment_hole_x1_offset)
        back(adjustment_hole_y1_offset)
            adjustment_hole();
    
    if (adjustment_hole_count == 2) {
        right(adjustment_hole_x2_offset)
            back(adjustment_hole_y2_offset)
                adjustment_hole();
    }
}

////////////////////////////////// - Module Coque/Shell - //////////////////////////////////         
module Coque(is_bottom){//Coque - Shell  
    Thick = Thick*2; // Why overload Thick? Hard to understand its current value. 
    tab_lower_screw_hole_z_offset = Height/2-4;
    tab_upper_screw_hole_z_offset = Height/2+4;
    tab_x_offset = 3*Thick+5;
    
    difference() {
        difference() { //sides decoration
            union() {    
                difference() { //soustraction de la forme centrale - Substraction Fileted box
                    difference() { //soustraction cube median - Median cube slicer
                        union() { //union  
                            difference() { //Coque  
                                RoundBox();
                                translate([Thick/2,Thick/2,Thick/2]) 
                                    RoundBox($a=Length-Thick, $b=Width-Thick, $c=Height-Thick);
                            }
                            
                            difference() {//largeur Rails        
                                 translate([Thick+m,Thick/2,Thick/2])
                                    RoundBox($a=Length-((2*Thick)+(2*m)), $b=Width-Thick, $c=Height-(Thick*2));
                                 translate([((Thick+m/2)*1.55),Thick/2,Thick/2+0.1]) // +0.1 added to avoid the artefact
                                    RoundBox($a=Length-((Thick*3)+2*m), $b=Width-Thick, $c=Height-Thick);
                            } 
                        }
                        
                       translate([-Thick,-Thick,Height/2])// Cube à soustraire
                            cube ([Length+100, Width+100, Height], center=false);
                    } //fin soustraction cube median - End Median cube slicer
                    
                    translate([-Thick/2,Thick,Thick])// Forme de soustraction centrale 
                        RoundBox($a=Length+Thick, $b=Width-Thick*2, $c=Height-Thick);                                
                }                                      

                // Box tabs
                difference() { 
                    union() {
                        translate([tab_x_offset, Thick, Height/2])
                            rotate([90,0,0]) {
                                    $fn=6; // Smart, use cylinder to generate hexagon!
                                    cylinder(d=16,Thick/2);
                            }
                            
                       translate([Length-(tab_x_offset), Thick, Height/2]) 
                            rotate([90,0,0]){
                                    $fn=6;
                                    cylinder(d=16,Thick/2);
                            }
                    }
                    
                    // Cut tab bottom gentle slop, so no support is needed during print. 
                    translate([4, Thick+Filet, Height/2-57])
                        rotate([45,0,0]){
                           cube([Length,40,40]);    
                        }
                   
                    translate([0, -(Thick*1.46), Height/2])
                        cube([Length,Thick*2,10]);
                        
                } //Fin fixation box legs
            }

            ventilation_hole_z_length = tab_lower_screw_hole_z_offset - top_bottom_connecting_screw_hole_diameter/2 - 1;
            iteration_step = vent_hole_x + vent_grill_x;
            union() {
                // Cut ventilation holes on sides
                right(board_edge_x)
                    for(i=[0:iteration_step:board_x]) {
                            right(i)
                                cube([vent_hole_x, board_edge_y, ventilation_hole_z_length]);
                            
                            translate([i, Width-board_edge_y, 0])
                                cube([vent_hole_x, board_edge_y, ventilation_hole_z_length]);
                    }
                
                // Cut ventilation holes on center
                offset_pcb() 
                    offset_pcb_hole()
                            for (i=[4:iteration_step:pcb_hole_x_distance-4]) {
                                right(i)
                                    cube([vent_hole_x, pcb_hole_y_distance, ventilation_hole_z_length]);
                            }
            }
        }
        
        // top and bottom connecting screw holes
        union(){ 
            $fn=50;
            
            translate([tab_x_offset, 20, tab_upper_screw_hole_z_offset])
                rotate([90,0,0])
                    cylinder(d=top_bottom_connecting_screw_tap_diameter, 20);
                
            translate([Length-tab_x_offset, 20, tab_upper_screw_hole_z_offset])
                rotate([90,0,0])
                    cylinder(d=top_bottom_connecting_screw_tap_diameter, 20);
                
            translate([tab_x_offset, Width+5, tab_lower_screw_hole_z_offset])
                rotate([90,0,0])
                   cylinder(d=top_bottom_connecting_screw_hole_diameter, Thick*2);
                
            translate([Length-tab_x_offset, Width+5, tab_lower_screw_hole_z_offset])
                rotate([90,0,0])
                    cylinder(d=top_bottom_connecting_screw_hole_diameter, Thick*2);
        }
        
    } //fin de difference holes
    
    if (is_bottom) {
        mount_tab();
        
        back(Width)
            right(Length)
                zrot(180)
                    mount_tab();
        
        Feet();
    }
}

///////////////////////////////// - Module Front/Back Panels - //////////////////////////
module Panels(){
    color(Couleur2) {
        translate([Thick+m, m/2, m/2])
            difference() {
                translate([0, Thick, Thick])
                    RoundBox(Length, Width-((Thick*2)+m), Height-((Thick*2)+m));
                translate([Thick,-5,0])
                     cube([Length,Width+10,Height]);
                }
    }
}


/////////////////////// - Foot with base filet - /////////////////////////////
module foot(FootDia, FootHole, FootHeight){
    Filet=4; // when you change this, it will impact raise of foot. Bad design that they are coupled. Refactor later!
    color("Blue")   
        translate([0, 0, Thick])
            difference() {
                cylinder(d=FootDia+Filet, FootHeight, $fn=100);
                    
                rotate_extrude($fn=100)
                    translate([(FootDia+Filet*2)/2, Filet, 0])
                        minkowski(){
                            square(10);
                            circle(Filet, $fn=100);
                        }
                
                cylinder(d=FootHole, FootHeight+1, $fn=100);
            }          
}

module Feet(){
    echo("From Feet, Thick is ", Thick);
    
    offset_pcb()
    {
        // PCB contour to check fitness. 
        up(Thick + FootHeight) {
            %cube([board_x, board_y, PCBHeight]);
            
            up(PCBHeight+M4_screw_stem_length)
                offset_pcb_hole() 
                    %CutAdjustmentHole();
        }
        
        ////////////////////////////// - 4 Feet - ///////////////////////////////     
        offset_pcb_hole() {
                foot(FootDia, FootHole, FootHeight);
                
                right(pcb_hole_x_distance)
                    foot(FootDia, FootHole, FootHeight);
                
                right(pcb_hole_x_distance)
                    back(pcb_hole_y_distance)
                        foot(FootDia,FootHole,FootHeight);
                
                back(pcb_hole_y_distance)
                    foot(FootDia,FootHole,FootHeight);
        }
    }
}
 
// To mount the box on to a surface by screws.
// TODO: export this as library. 
module mount_tab() {
    tab_x_length=23;
    tab_y_length=11;
    tab_z_length=Thick; // use wall thickness.
    
    // Tried and true size. :-)
    screw_hole_diameter=5;
    
    difference () {
        linear_extrude(height = tab_z_length, center = false, convexity = 10, twist = 0)
            difference() {
                back(tab_y_length/2)
                    ellipse(tab_x_length, tab_y_length, $fn=80);
                square([tab_x_length, tab_y_length]);
            }
            
        back(tab_y_length/2)
            left(tab_x_length/4)
                up(tab_z_length)
                    screw(screw_hole_diameter,
                           screwlen=M5_screw_stem_length,
                           headsize=M5_screw_head_diameter,
                           headlen=3, countersunk=false, align="base");
    }
}

///////////////////////////////////// - Main - ///////////////////////////////////////

if (back_panel==1)
    //Back Panel
    translate ([-m/2, 0, 0]){
        difference() {
            Panels();
            
            back(Width/2)
                up(Height/2)
                    right(Thick*3)  
                        yrot(-90)
                            #cylinder(d=output_wire_hole_diameter, h=Thick*3, center=false, $fn=50);
        }
    }

if (front_panel==1)
    // Front Panel
    rotate([0, 0, 180])
        translate([-Length-m/2, -Width, 0])
            difference() {
                Panels();
                
                back(Width/2)
                    up(Height/2)
                        right(Thick*3)  
                            yrot(-90)
                                cylinder(d=DC_socket_hole_diameter, h=Thick*3, center=false, $fn=50);
            }
    

if (Text==1)
    color(Couleur1){     
        translate([Length-(Thick),Thick*4,(Height-(Thick*4+(TxtSize/2)))]) {// x,y,z
            rotate([90,0,90]){
                linear_extrude(height = 0.25){
                    text(txt, font = Police, size = TxtSize,  valign ="center", halign ="left");
                }
            }
         }
    }

if (bottom_shell==1)    
    Coque(true);

if (top_shell==1)
    difference() {
        translate([0, Width, Height+0.2]) {
            rotate([0,180,180]){
                Coque(false);
            }
        }

        // Cut adjustment hole
        offset_pcb()
        {
            up(FootHeight+PCBHeight+M4_screw_stem_length) {
                offset_pcb_hole()
                    CutAdjustmentHole();
            }
        }
    }
