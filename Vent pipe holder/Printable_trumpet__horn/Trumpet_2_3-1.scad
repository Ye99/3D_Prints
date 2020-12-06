//Pipe section start (in mm from theoretic bell-side end; in practice you start at 5mm from the theoretic end).
Start=5;
//Pipe section end
Stop=100;
// Number of polygons in between
Step=5;
//Wall Thickness
Thickness=2;
//Angle of pipe section. probably crashes at value 0.
Angle=45;
//Paramterers for notches to connect sections
SleeveLength=5;
SleeveMargin=0.5;



// The shape of the music pipe is according to the folling formula: Radius=B/(x+offset)^a. Factor B mostly influences the size of the bell at the middle.
Factor_B=240;

//Coefficient a mostly influences the diameter at the small end of the pipe.
Coefficient_a=0.42;

function BuigRadius(Stop,Start)=(Stop-Start)/Angle*360/2/3.14;


//#cylinder(r=30/2,h=110);
//#cylinder(r=120/2);
//#cylinder(r=11/2,h=15);
//for(i=[1000:100:1100]){
//translate([i/4,0,0]) MakePipe(i,i+100);
//}
MakePipe(Start,Stop);

module MakePipe(Start,Stop){

difference(){

union(){
for (i=[Start:Step:Stop-Step]){
hull(){
translate(MoveAround(i,Start,Stop)) rotate(TurnAround(i,Start,Stop)) MakeRing(Factor_B/pow(i,Coefficient_a)+Thickness*2);
translate(MoveAround(i+Step,Start,Stop)) rotate(TurnAround(i+Step,Start,Stop)) MakeRing(Factor_B/pow(i+Step,Coefficient_a)+Thickness*2);}}

hull($fn=8){
translate(MoveAround(Stop,Start,Stop)) rotate(TurnAround(Stop,Start,Stop)) MakeRing(Factor_B/pow(Stop,Coefficient_a)+Thickness*1.5-SleeveMargin);
translate(MoveAround(Stop+SleeveLength,Start,Stop)) rotate(TurnAround(Stop+SleeveLength,Start,Stop)) MakeRing(Factor_B/pow(Stop+SleeveLength,Coefficient_a)+Thickness-SleeveMargin);}

}

union(){
for (i=[Start-Step:Step:Stop+SleeveLength]){
hull(){
translate(MoveAround(i,Start,Stop)) rotate(TurnAround(i,Start,Stop)) MakeRing(Factor_B/pow(i,Coefficient_a));
translate(MoveAround(i+Step,Start,Stop)) rotate(TurnAround(i+Step,Start,Stop)) MakeRing(Factor_B/pow(i+Step,Coefficient_a));}}}

hull($fn=8){
translate(MoveAround(Start,Start,Stop)) rotate(TurnAround(Start,Start,Stop)) MakeRing(Factor_B/pow(Start,Coefficient_a)+Thickness*1.5);
translate(MoveAround(Start+SleeveLength,Start,Stop)) rotate(TurnAround(Start+SleeveLength,Start,Stop)) MakeRing(Factor_B/pow(Start+SleeveLength,Coefficient_a)+Thickness);}

}

}

module MakeRing(Diameter){
cylinder(r=Diameter/2,h=0.1);
//rotate_extrude()
//translate([Diameter/2, 0, 0])
//circle(r = Thickness/2);
}


// function MoveAround(i,Start,Stop)= [0,0,i];
function MoveAround(i,Start,Stop)= [0,BuigRadius(Stop,Start)*cos((i-Start)/(Stop-Start)*Angle)-BuigRadius(Stop,Start),BuigRadius(Stop,Start)*sin((i-Start)/(Stop-Start)*Angle)];
function TurnAround(i,Start,Stop)= [(i-Start)/(Stop-Start)*Angle,0,0];


