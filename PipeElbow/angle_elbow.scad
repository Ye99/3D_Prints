// Caravan / RV / motorhome drain water pipe connector
// nominally for 28mm pipe used in European caravans but adjust to suit what you need.
// customisable, so play with the settings!
// NOTE: Don't forget to turn the Cross-section option OFF for your final print :)
// All measurements in mm
// written by Steve Malikoff     March 2020   in Brisbane, Australia
// PLACED IN THE PUBLIC DOMAIN. Use at your own risk. Enjoy!
// Last updated 20200311

// Customisable settings

include <BOSL/constants.scad>
use <BOSL/metric_screws.scad>
use <BOSL/transforms.scad>
use <OpenSCAD-common-libraries/roundedCube.scad>
include <OpenSCAD-common-libraries/screw_matrics.scad>

CONNECTOR_TYPE = "straight";//["straight","Tee", "X", "Y", "straight Y", "Multi", "90 elbow", "45 elbow", "30 elbow", "20 elbow","120 elbow",  "U bend", "cap", "reducer"]
PIPE_ANGULAR_SEPARATION = 90;//[45,60,75,90,100,110,120,125,130,135,140,150]
MULTI_PIPES = 5;

TO_SUIT_PIPE_DIAMETER = 27.5;
STRAIGHT_CONNECTOR_LENGTH = 73;
PIPE_OUTERMOST_DEPTH = 10;
PIPE_NOMINAL_WALL_THICKNESS = 3;
PIPE_INTERMEDIATE_STEP_REDUCTION = 0.2; //[0.0,0.1,0.2,0.3]
PIPE_INTERMEDIATE_ID = TO_SUIT_PIPE_DIAMETER - PIPE_INTERMEDIATE_STEP_REDUCTION;
PIPE_INTERMEDIATE_DEPTH = 28;
PIPE_INNERMOST_ID = PIPE_INTERMEDIATE_ID - 2;
PIPE_OD = TO_SUIT_PIPE_DIAMETER + 2 * PIPE_NOMINAL_WALL_THICKNESS;

EMBOSS_SIZE_LABEL = false;
EMBOSS_ANGLE_LABEL = false;
EMBOSS_FLOW_DIRECTION_UP = false;
EMBOSS_FLOW_DIRECTION_DOWN = false;
TEXT_SIZE = 5;

CAP_TIE_LOOP = true;
CAP_HAS_HOLE = true;

TO_SUIT_REDUCER_PIPE_DIAMETER = 20.0;
PIPE_REDUCER_INTERMEDIATE_ID = TO_SUIT_REDUCER_PIPE_DIAMETER - PIPE_INTERMEDIATE_STEP_REDUCTION;
PIPE_REDUCER_INNERMOST_ID = PIPE_REDUCER_INTERMEDIATE_ID - 2;
REDUCER_PIPE_OD = TO_SUIT_REDUCER_PIPE_DIAMETER + 2 * PIPE_NOMINAL_WALL_THICKNESS;

CROSS_SECTIONAL_DEMO = false;

// ----------------------------------------------------------------------------------
module Customiser_Stopper() {} // Stop customiser looking at variables below here

// Prepare the embossed pipe size and angle texts (optional)
PIPE_SIZE_TEXT = str(round(TO_SUIT_PIPE_DIAMETER),"mm Ø");
PIPE_ANGLE_TEXT = str(round(PIPE_ANGULAR_SEPARATION)," ◦");
REDUCER_PIPE_SIZE_TEXT = str(round(TO_SUIT_REDUCER_PIPE_DIAMETER),"mm Ø");
PIPE_DIRECTION_ARROW_UP_TEXT = "↑";
PIPE_DIRECTION_ARROW_DOWN_TEXT = "↓";

FACETS = 138;
$fn = FACETS;

// Select 90 elbow to show the secure tab. 
secure_tab_thickness=3; // in mm
secure_tab_x_length=60; // in mm
secure_tab_y_length=36;
union()
{
    cut_cube_size=50;
    
    difference()
    {
        // Generate the model and optionally show cross-section
        PipeConnector();
        
        if (CONNECTOR_TYPE == "90 elbow") {
            // Cut upper part
            up(cut_cube_size/2)
                cube(cut_cube_size, center=true);
        }
    }
    
    if (CONNECTOR_TYPE == "90 elbow") {
        secure_tab();
    }
}

module arrange_screws() {
    up(secure_tab_thickness/2) {
        screw_hole_offset=(secure_tab_x_length-PIPE_OD)/2/2 + PIPE_OD/2;
        
        right(screw_hole_offset)
            children();
    
        left(screw_hole_offset)
            children();
    }
}

module secure_tab() {
    difference()
    {
        up(-secure_tab_thickness/2)
            roundedCube([secure_tab_x_length, secure_tab_y_length, secure_tab_thickness], center=true, r=10);
        
        arrange_screws()
                screw(number4_screw_hole_diameter, 
                    screwlen=number4_screw_stem_length,
                    headsize=number4_screw_head_diameter,
                    headlen=3, countersunk=false, align="base");
        
        hull()
            down(20)
                StraightPipeConnectorHalf();
    }
}
        
module PipeConnector()
{
    difference()
    {
        PipeConnectorChoices();
        if (CROSS_SECTIONAL_DEMO)
            translate([0,0,-200])
                cube([200,200,400]);
    }
}

// If you need an elbow at another angle, add that here
module PipeConnectorChoices()
{
    if (CONNECTOR_TYPE == "straight")
        StraightPipeConnector();
    else if (CONNECTOR_TYPE == "Tee")
        TeePipeConnector(3);
    else if (CONNECTOR_TYPE == "X")
        TeePipeConnector(4);
    else if (CONNECTOR_TYPE == "Y")
        MultiPipeConnector(3, PIPE_ANGULAR_SEPARATION);
    else if (CONNECTOR_TYPE == "straight Y")
        StraightYPipeConnector(PIPE_ANGULAR_SEPARATION);
    else if (CONNECTOR_TYPE == "Multi")
        MultiPipeConnector(MULTI_PIPES, 360/MULTI_PIPES);
    else if (CONNECTOR_TYPE == "90 elbow")
        ElbowPipeConnector(90);
    else if (CONNECTOR_TYPE == "45 elbow")
        ElbowPipeConnector(75);
    else if (CONNECTOR_TYPE == "30 elbow")
        ElbowPipeConnector(30);
    else if (CONNECTOR_TYPE == "20 elbow")
        ElbowPipeConnector(20);
    else if (CONNECTOR_TYPE == "120 elbow")
        ElbowPipeConnector(120);
    else if (CONNECTOR_TYPE == "U bend")
        ElbowPipeConnector(180);
    else if (CONNECTOR_TYPE == "cap")
        CapPipeConnector();
    else if (CONNECTOR_TYPE == "reducer")
        ReducerPipeConnector();
}

// Straight-through pipe to pipe connector
module StraightPipeConnector()
{
    // Generate one end only and rotate for other end
    StraightPipeConnectorHalf();
    rotate([180,0,0])
        StraightPipeConnectorHalf();
    FlowDirectionArrow();    
}

// One pipe connector. This is the basic unit of all the patterns here.
module StraightPipeConnectorHalf()
{
    difference()
    {
        PipeConnectorHalfSolidOuter(false);
        PipeConnectorHalfInnerPlug();
    }
}

// The complete outer part of the connector (with optional labelling)
module PipeConnectorHalfSolidOuter(EMBOSS_ANGLE_LABEL)
{
    cylinder(d=PIPE_OD, h=STRAIGHT_CONNECTOR_LENGTH/2);
    if (EMBOSS_SIZE_LABEL)
        translate([PIPE_OD/2 - 0.3, -TEXT_SIZE/2,STRAIGHT_CONNECTOR_LENGTH/2 - 3])
            PipeSizeLabel();
    if (EMBOSS_ANGLE_LABEL)
        rotate([0,0,-30])
            translate([PIPE_OD/2 - 0.3, -TEXT_SIZE/2,STRAIGHT_CONNECTOR_LENGTH/2 - 3])
                PipeAngleLabel();    
}

// The complete stepped plug, which is subttracted from the outer
module PipeConnectorHalfInnerPlug()
{
        cylinder(d=PIPE_INNERMOST_ID, h=STRAIGHT_CONNECTOR_LENGTH/2);
        // The pipe ID steps
        // 1) Intermediate
        translate([0,0,STRAIGHT_CONNECTOR_LENGTH/2 - PIPE_INTERMEDIATE_DEPTH])
            cylinder(d=PIPE_INTERMEDIATE_ID, PIPE_INTERMEDIATE_DEPTH);
        // 2) Outermost
        translate([0,0,STRAIGHT_CONNECTOR_LENGTH/2 - PIPE_OUTERMOST_DEPTH])
            cylinder(d=TO_SUIT_PIPE_DIAMETER, PIPE_OUTERMOST_DEPTH);
        // Chamfers
        // 1) Outermost (to allow pipe). 
        translate([0,0,STRAIGHT_CONNECTOR_LENGTH/2 - 3.8])
            OuterChamfer();
        // 2) Innermost (so no scaffolding needed)
        translate([0,0,STRAIGHT_CONNECTOR_LENGTH/2 - PIPE_INTERMEDIATE_DEPTH -1.3])
            #InnerChamfer();
}

// Allow easy insertion of pipe to connector
module OuterChamfer()
{
    #cylinder(d1=PIPE_INNERMOST_ID, d2=PIPE_INNERMOST_ID+4, h=4);
}

// To allow printing without needing support (for straight tube anyway)
module InnerChamfer()
{
    cylinder(d1=PIPE_INNERMOST_ID, d2=PIPE_INTERMEDIATE_ID, h=1.5);
}

// A connector for two different pipe sizes
module ReducerStraightPipeConnectorHalf()
{
    difference()
    {
        ReducerPipeConnectorHalfSolidOuter(false);
        ReducerPipeConnectorHalfInnerPlug();
    }
}

module ReducerPipeConnectorHalfSolidOuter(EMBOSS_ANGLE_LABEL)
{
    cylinder(d=REDUCER_PIPE_OD, h=STRAIGHT_CONNECTOR_LENGTH/2);
    if (EMBOSS_SIZE_LABEL)
        translate([REDUCER_PIPE_OD/2 - 0.3, -TEXT_SIZE/2,STRAIGHT_CONNECTOR_LENGTH/2 - 3])
                rotate([90,90,90])
                    linear_extrude(1.2)
                        text(REDUCER_PIPE_SIZE_TEXT, size=TEXT_SIZE);
}

module ReducerPipeConnectorHalfInnerPlug()
{
        cylinder(d=PIPE_REDUCER_INNERMOST_ID, h=STRAIGHT_CONNECTOR_LENGTH/2);
        // The pipe ID steps
        // 1) Intermediate
        translate([0,0,STRAIGHT_CONNECTOR_LENGTH/2 - PIPE_INTERMEDIATE_DEPTH])
            cylinder(d=PIPE_REDUCER_INTERMEDIATE_ID, PIPE_INTERMEDIATE_DEPTH);
        // 2) Outermost
        translate([0,0,STRAIGHT_CONNECTOR_LENGTH/2 - PIPE_OUTERMOST_DEPTH])
            cylinder(d=TO_SUIT_REDUCER_PIPE_DIAMETER, PIPE_OUTERMOST_DEPTH);
}

// Label so you can see what size pipe it's for
module PipeSizeLabel()
{
    rotate([90,90,90])
        linear_extrude(1.2)
            text(PIPE_SIZE_TEXT, size=TEXT_SIZE);
}

// Pipe size diameter label in mm
module PipeAngleLabel()
{
    rotate([90,90,90])
        linear_extrude(1.2)
            text(PIPE_ANGLE_TEXT, size=TEXT_SIZE);
}

// Emboss a large arrow in the middle of the length of the connector
// Normally Up and Down would be mutually exclusive however you can select 
// both Up and Down checkboxes to get a double-ended arrow.
module FlowDirectionArrow()
{
    // Add an up or down flow direction arrow
    if (EMBOSS_FLOW_DIRECTION_UP)
        rotate([0,0,90])
            translate([PIPE_OD/2 - 0.7, -TEXT_SIZE*2, -4.5])
                PipeDirectionArrowUpLabel();
    
    if (EMBOSS_FLOW_DIRECTION_DOWN)
        rotate([0,0,90])
            translate([PIPE_OD/2 - 0.7, -TEXT_SIZE*2, -5.5])
                PipeDirectionArrowDownLabel();          
}

module PipeDirectionArrowUpLabel()
{
    rotate([90,0,90])
        linear_extrude(2)
            text(PIPE_DIRECTION_ARROW_UP_TEXT, size=TEXT_SIZE * 6);
}

module PipeDirectionArrowDownLabel()
{
    rotate([90,0,90])
        linear_extrude(2)
            text(PIPE_DIRECTION_ARROW_DOWN_TEXT, size=TEXT_SIZE * 6);
}

// Standard 3-way T fitting
module TeePipeConnector(pipesRequired)
{
    MultiPipeConnector(pipesRequired, 90);
    FlowDirectionArrow();
}

// Connector to bring a number of pipes together
module MultiPipeConnector(pipesRequired, angularSeparation)
{
    PIPES = pipesRequired;
    PIPE_ANGULAR_SEPERATION = angularSeparation;
    difference()
    {
        union()
        {
            for (pipe=[1 : PIPES - 1])
            {
            PipeConnectorHalfSolidOuter();
            rotate([pipe * PIPE_ANGULAR_SEPERATION, 0, 0])
                PipeConnectorHalfSolidOuter(EMBOSS_ANGLE_LABEL);
            }
        }
        // Substract the inners
        for (pipe=[1 : PIPES - 1])
        {
            PipeConnectorHalfInnerPlug();
            rotate([pipe * PIPE_ANGULAR_SEPERATION, 0, 0])
                PipeConnectorHalfInnerPlug();
        }
    }    
    FlowDirectionArrow();
}

// Straight-through with angled side Y pipe connector
module StraightYPipeConnector(someSideAngle, EMBOSS_FLOW_DIRECTION_LABEL)
{
    difference()
    {
        union()
        {
            // Do the straight through pipe then the side pipe
            for (pipe=[0 : 1])
            {
                PipeConnectorHalfSolidOuter();
                rotate([pipe*180, 0, 0])
                    PipeConnectorHalfSolidOuter(EMBOSS_ANGLE_LABEL);
            }
            rotate([someSideAngle, 0, 0])
                PipeConnectorHalfSolidOuter(EMBOSS_ANGLE_LABEL);
        }
        // Substract the inners
        // Do the straight through pipe then the side pipe
        for (pipe=[0 : 1])
        {
            PipeConnectorHalfInnerPlug();
            rotate([pipe * 180, 0, 0])
                PipeConnectorHalfInnerPlug();
        }
        rotate([someSideAngle, 0, 0])
            PipeConnectorHalfInnerPlug();
    }
    FlowDirectionArrow();
}

// Fitting for angled outlet to inlet
module ElbowPipeConnector(angularSeparation)
{
    Xoffset = PIPE_OD/2 - (cos(angularSeparation) * PIPE_OD/2);
    Zoffset = sin(angularSeparation) * PIPE_OD/2;

    // Generate half end only and rotate
    StraightPipeConnectorHalf();
    translate([0, -Xoffset,-Zoffset])
        rotate([180-angularSeparation,0,0])
            StraightPipeConnectorHalf();    
    // Elbow torus arc
    // color("green")
    translate([0, -PIPE_OD/2, 0])
    rotate([90, angularSeparation, 90])
        PartialHollowTorus(PIPE_OD*2, PIPE_OD, PIPE_INNERMOST_ID,angularSeparation);    
        FlowDirectionArrow();    
}

// An end cap to seal a pipe. It has a string tie eye added by default.
module CapPipeConnector()
{
    StraightPipeConnectorHalf();
    translate([0, 0, -PIPE_NOMINAL_WALL_THICKNESS]) {
        difference() {
            cylinder(d=PIPE_OD + PIPE_NOMINAL_WALL_THICKNESS * 2, h=PIPE_NOMINAL_WALL_THICKNESS);
            if (CAP_HAS_HOLE) {
                // Width of hole to run the mains input wires (mm)
                // Below 14/2 wire width is 10, height is 5
                // https://smile.amazon.com/gp/product/B000BPEQCC/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1
                wires_hole_width=11; // [8:12]
                // The height of hole to run the mains input wires (mm)
                wires_hole_height=6; // [4:12]
                cube([wires_hole_width, wires_hole_height, PIPE_NOMINAL_WALL_THICKNESS * 2], center=true);
            }
        }
    }
    if (CAP_TIE_LOOP)
    {
        translate([PIPE_OD / 2 + PIPE_NOMINAL_WALL_THICKNESS, 0, -PIPE_NOMINAL_WALL_THICKNESS])
            CapTieLoop();
    }
}

// The string tie loop. This is added to the side so you can use the flat underside of 
// the cap to write or place a label on.
module CapTieLoop()
{
    difference()
    {
        cylinder(d=PIPE_NOMINAL_WALL_THICKNESS*5, h=PIPE_NOMINAL_WALL_THICKNESS);
        cylinder(d=PIPE_NOMINAL_WALL_THICKNESS*3, h=PIPE_NOMINAL_WALL_THICKNESS * 2);
    }    
}

// Connector from one size to a different size
module ReducerPipeConnector()
{
    StraightPipeConnectorHalf();
    translate([0, 0, -PIPE_NOMINAL_WALL_THICKNESS*2])
    rotate([180,0,0])
        ReducerStraightPipeConnectorHalf();
    // The frustum between the different sizes
    translate([0,0,-PIPE_NOMINAL_WALL_THICKNESS*2])
        difference()
        {
            cylinder(d1=REDUCER_PIPE_OD, d2=PIPE_OD, h=PIPE_NOMINAL_WALL_THICKNESS*2);
            cylinder(d1=TO_SUIT_REDUCER_PIPE_DIAMETER, d2=PIPE_INNERMOST_ID, h=PIPE_NOMINAL_WALL_THICKNESS*2);       
        }    
}


/////////////////// Utility methods to create the torus elbow ////////////////////////////
module PartialHollowTorus(pipeMajorOD, pipeOD, pipeID, someAngle)
{
    difference()
    {
        PartialTorus(pipeMajorOD, pipeOD, someAngle);
        PartialTorus(pipeMajorOD - (pipeOD - pipeID), pipeID, someAngle+2);
    }
}

module Torus(majorRadius, minorRadius)
{    
    PartialTorus(majorRadius, minorRadius, 360);
}

module PartialTorus(majorRadius, minorRadius, sweepAngle)
{    
  halfMinorRadius = minorRadius / 2;
  minorRadiusCentreOffset = majorRadius / 2 - halfMinorRadius;    
    rotate_extrude(angle=sweepAngle, convexity=10)
        translate([minorRadiusCentreOffset, 0, 0])
            circle(r = halfMinorRadius);
}

module Pipe(someOD, someID, someLength)
{
    difference()
    {
        cylinder(d=someOD, someLength);
        cylinder(d=someID, someLength);
    }
}


