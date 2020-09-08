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

*/////////////////////////// - Info - //////////////////////////////

// All coordinates are starting as integrated circuit pins.
// From the top view :

//   CoordD           <---       CoordC
//                                 ^
//                                 ^
//                                 ^
//   CoordA           --->       CoordB

////////////////////////////////////////////////////////////////////

use <BOSL/transforms.scad>

selected_board="XL4015Red"; //["XL4015Red", "LM2596Blue", "RD_Green"];

/* [PCB_Feet--the_board_will_not_be_exported) ] */
// All dimensions are from the center foot axis
// - Coin bas gauche - Low left screw hole X position
PCBPosX         = 0;
// - Coin bas gauche - Low left screw hole Y position
PCBPosY         = 0;

// 5.5x2.1 plug socket.
DC_socket_hole_diameter=8;
DC_socket_protrusion_length=16;

// XL4015 board
xl4015_pcb_hole_x_distance = 47; // hole to hole. edge to edge is 51.2;
xl4015_pcb_hole_y_distance = 22; // edge to edge is 26.3;
xl4015_PCBHeight = 20; // This equals to the tallest component height + PCB board thickness. 

// LM2596 board
lm2596_pcb_hole_x_distance = 30; // hole to hole. edge to edge is 43.5;
lm2596_pcb_hole_y_distance = 16; // edge to edge is 21;
lm2596_PCBHeight = 16; // This equals to the tallest component height + PCB board thickness. Not including the pin length underneath PCB board.

// RD green board, https://www.aliexpress.com/item/995963510.html?spm=a2g0s.9042311.0.0.27424c4dcc0soI 
rd_pcb_hole_x_distance = 36; // hole to hole. edge to edge is 43.7;
rd_pcb_hole_y_distance = 23; // edge to edge is 30.4;
rd_PCBHeight = 15; // This equals to the tallest component height + PCB board thickness. Not including the pin length underneath PCB board.

pcb_hole_x_distance = selected_board=="XL4015Red" ? xl4015_pcb_hole_x_distance : (selected_board=="LM2596Blue" ? lm2596_pcb_hole_x_distance  : (selected_board=="RD_Green" ? rd_pcb_hole_x_distance : 0));
pcb_hole_y_distance = selected_board=="XL4015Red" ? xl4015_pcb_hole_y_distance : (selected_board=="LM2596Blue" ? lm2596_pcb_hole_y_distance  : (selected_board=="RD_Green" ? rd_pcb_hole_y_distance : 0));
PCBHeight = selected_board=="XL4015Red" ? xl4015_PCBHeight : (selected_board=="LM2596Blue" ? lm2596_PCBHeight  : (selected_board=="RD_Green" ? rd_PCBHeight : 0));

/* [Box dimensions] */
Length = pcb_hole_x_distance + DC_socket_protrusion_length + 32; // 95;   // This is the outmost dimention, net usable space by PCB board is much smaller.
Width = rd_pcb_hole_y_distance + 24; // 47;   
Height = PCBHeight + 10;
  
// Wall thickness  
Thick = 3; //[2:5]  
  
/* [STL element to export] */
//Coque haut - Top shell
  TShell        = 0;// [0:No, 1:Yes]
//Coque bas- Bottom shell
  BShell        = 1;// [0:No, 1:Yes]
//Panneau arrière - Back panel  
  BPanel        = 0;// [0:No, 1:Yes]
//Panneau avant - Front panel
  FPanel        = 0;// [0:No, 1:Yes]
//Texte façade - Front text
  Text          = 0;// [0:No, 1:Yes]
  
/* [Box options] */
// Pieds PCB - PCB feet (x4) 
  PCBFeet       = 1;// [0:No, 1:Yes]
// - Decorations to ventilation holes
  Vent          = 1;// [0:No, 1:Yes]
// - Decoration-Holes width (in mm)
  Vent_width    = 2;   
// - Text you want
  txt           = "";           
// - Font size  
  TxtSize       = 3;                 
// - Font  
  Police        ="Arial Black"; 
// - Diamètre Coin arrondi - Filet diameter  
  Filet         = 0.1;//[0.1:12] 
// - lissage de l'arrondi - Filet smoothness  
  Resolution    = 50;//[1:100] 
// - Tolérance - Tolerance (Panel/rails gap)
  m             = 0.9;

// - Heuteur pied - Feet height
FootHeight      = 6; // Notice this isn't the net height, it inclues wall thickness! Refactor later!
// - Diamètre pied - Foot diameter
FootDia         = 3.6;
// - Diamètre trou - Hole diameter
FootHole        = 2;

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
// Thick X 2 - making decorations thicker if it is a vent to make sure they go through shell
Dec_Thick       = Vent ? Thick*2.8 : Thick; 
// - Depth decoration
Dec_size        = Vent ? Thick*2.8 : 0.8;

//////////////////// Oversize PCB limitation -Actually disabled - ////////////////////
//PCBL= pcb_hole_x_distance+PCBPosX>Length-(Thick*2+7) ? Length-(Thick*3+20+PCBPosX) : pcb_hole_x_distance;
//PCBW= PCBWidth+PCBPosY>Width-(Thick*2+10) ? Width-(Thick*2+12+PCBPosY) : PCBWidth;
// PCBL=pcb_hole_x_distance;
// PCBW=PCBWidth;
//echo (" PCBWidth = ",PCBW);

assert(Height > FootHeight + PCBHeight, "Make box taller please");

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

      
////////////////////////////////// - Module Coque/Shell - //////////////////////////////////         
module Coque(){//Coque - Shell  
    Thick = Thick*2;  
    difference(){
        difference() {//sides decoration
            union() {    
                difference() {//soustraction de la forme centrale - Substraction Fileted box
                    difference() {//soustraction cube median - Median cube slicer
                        union() {//union               
                            difference() {//Coque    
                                RoundBox();
                                translate([Thick/2,Thick/2,Thick/2]) { 
                                            RoundBox($a=Length-Thick, $b=Width-Thick, $c=Height-Thick);
                                    }
                            }//Fin diff Coque                            
                            
                            difference() {//largeur Rails        
                                 translate([Thick+m,Thick/2,Thick/2])
                                      RoundBox($a=Length-((2*Thick)+(2*m)), $b=Width-Thick, $c=Height-(Thick*2));
                                 translate([((Thick+m/2)*1.55),Thick/2,Thick/2+0.1]) // +0.1 added to avoid the artefact
                                      RoundBox($a=Length-((Thick*3)+2*m), $b=Width-Thick, $c=Height-Thick);
                            }//Fin largeur Rails
                        }//Fin union
                        
                       translate([-Thick,-Thick,Height/2])// Cube à soustraire
                            cube ([Length+100, Width+100, Height], center=false);
                    }//fin soustraction cube median - End Median cube slicer
                    
                    translate([-Thick/2,Thick,Thick])// Forme de soustraction centrale 
                        RoundBox($a=Length+Thick, $b=Width-Thick*2, $c=Height-Thick);                                
                }                                          

                difference() {// Fixation box legs
                    union() {
                        translate([3*Thick +5,Thick,Height/2])
                            rotate([90,0,0]) {
                                    $fn=6;
                                    cylinder(d=16,Thick/2);
                                    }
                            
                       translate([Length-((3*Thick)+5),Thick,Height/2]) 
                            rotate([90,0,0]){
                                    $fn=6;
                                    cylinder(d=16,Thick/2);
                                    }
                    }
                    
                    translate([4,Thick+Filet,Height/2-57])
                     rotate([45,0,0]){
                           cube([Length,40,40]);    
                          }
                   
                    translate([0,-(Thick*1.46),Height/2])
                        cube([Length,Thick*2,10]);
                } //Fin fixation box legs
            }

        union() {
            // Cut ventilation holdes on sides
            for(i=[0:Thick/1.5:Length/3]) {
                // Ventilation holes part code submitted by Ettie - Thanks ;) 
                    translate([10+i, -Dec_Thick+Dec_size, 0])
                        cube([Vent_width, Dec_Thick, Height/3.8]);
                    
                    translate([(Length-20)-i, -Dec_Thick+Dec_size, 0])
                        cube([Vent_width, Dec_Thick, Height/3.8]);
                    
                    translate([(Length-20)-i, Width-Dec_size, 0])
                        cube([Vent_width, Dec_Thick, Height/3.8]);
                    
                    translate([10+i, Width-Dec_size, 0])
                        cube([Vent_width, Dec_Thick, Height/3.8]);
            }
            
            // Cut ventilation holds on center
            for(i=[0:Thick/1.5:Length/2.5])
                translate([21+i, Width/3, 0])
                    cube([Vent_width, 15, Height/3.8]);
        }
    }//fin difference decoration

        // top and bottom connecting screw holes
        union(){ 
            $fn=50;
            translate([3*Thick+5, 20, Height/2+4])
                rotate([90,0,0])
                    cylinder(d=top_bottom_connecting_screw_tap_diameter, 20);
                
            translate([Length-((3*Thick)+5), 20, Height/2+4])
                rotate([90,0,0])
                    cylinder(d=top_bottom_connecting_screw_tap_diameter, 20);
                
            translate([3*Thick+5, Width+5, Height/2-4])
                rotate([90,0,0])
                    cylinder(d=top_bottom_connecting_screw_hole_diameter, Thick*2);
                
            translate([Length-((3*Thick)+5), Width+5, Height/2-4])
                rotate([90,0,0])
                    cylinder(d=top_bottom_connecting_screw_hole_diameter, Thick*2);
        }//fin de sides holes

    }//fin de difference holes
}// fin coque 

////////////////////////////// - Experiment - ///////////////////////////////////////////


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
        translate([0, 0, Filet-1.5])
            difference() {
                cylinder(d=FootDia+Filet, FootHeight-Thick, $fn=100);
                    
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
    board_edge_x=3*Thick+2;
    board_edge_y=Thick+5;
    
    //////////////////// - PCB only visible in the preview mode - /////////////////////    
    translate([board_edge_x, board_edge_y, FootHeight-(Thick)+3]) { // TODO: fix these magic numbers!
        // This code assumes screw hole is 5mm away from PCB board edge. Need to fix this later!
        %cube([pcb_hole_x_distance+10, pcb_hole_y_distance+10, PCBHeight]);
        
        translate([pcb_hole_x_distance/2,pcb_hole_y_distance/2,0.5]) { 
            color("Olive")
            %text("PCB", halign="center", valign="center", font="Arial black");
        }
    }
    
    ////////////////////////////// - 4 Feet - //////////////////////////////////////////     
    first_screw_hole_x=board_edge_x+5;
    first_screw_hole_y=board_edge_y+5;
    translate([first_screw_hole_x, first_screw_hole_y, 0.5])
        foot(FootDia, FootHole, FootHeight);
    
    translate([first_screw_hole_x+pcb_hole_x_distance, first_screw_hole_y, 0.5])
        foot(FootDia, FootHole, FootHeight);
    
    translate([first_screw_hole_x+pcb_hole_x_distance, first_screw_hole_y+pcb_hole_y_distance, 0.5])
        foot(FootDia,FootHole,FootHeight);
    
    translate([first_screw_hole_x, first_screw_hole_y+pcb_hole_y_distance, 0.5])
        foot(FootDia,FootHole,FootHeight);
}
 

///////////////////////////////////// - Main - ///////////////////////////////////////

if (BPanel==1)
//Back Panel
    translate ([-m/2, 0, 0]){
        Panels();
    }

if (FPanel==1)
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
// Front text
    color(Couleur1){     
        translate([Length-(Thick),Thick*4,(Height-(Thick*4+(TxtSize/2)))]) {// x,y,z
            rotate([90,0,90]){
                linear_extrude(height = 0.25){
                    text(txt, font = Police, size = TxtSize,  valign ="center", halign ="left");
                }
            }
         }
    }


if (BShell==1)
    // Coque bas - Bottom shell
    color(Couleur1){ 
        Coque();
    }


if (TShell==1)
// Coque haut - Top Shell
    color( Couleur1,1){
        translate([0,Width,Height+0.2]){
            rotate([0,180,180]){
                Coque();
            }
        }
    }

if (BShell==1 && PCBFeet==1)
    // Feet
    translate([PCBPosX, PCBPosY, 0]) { 
        Feet();
    }