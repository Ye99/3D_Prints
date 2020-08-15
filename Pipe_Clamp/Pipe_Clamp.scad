shaftDiameter = 27.5; // SCH40 PVC 3/4" OD + 1mm tolerance
clampWidth = 18;
clampThickness = 3.0;
clampLegLengthFromShaft = 10; // room for wing nut and thumb srew
clampLegThickness = clampThickness; // default is 'clampThickness' to keep it the same thickness as the clamp
clampLegGap = 8; 
clampToClampScrewCenter = (clampLegLengthFromShaft - clampThickness) / 2 - 0.5 ; //using '(clampLegLengthFromShaft - clampThickness) / 2' nearly centres this hole on the clamp leg
clampScrewDiameter = 4.5 ; // #8 clearance hole
shaftToMountPlate = 1;
mountPlateThickness = 4.2;
mountPlateLength = 55;
mountHoleSpacing = 40;
mountHoleDiameter = 4; 
screwHoleSmoothness = 50 ; // Aha! cylinder with $fn can generate hexagon for bolt! 6 = printable vertically. Applies to mount plate screw holes and clamp leg screw holes
clampSmoothness = 100 ;

clampWithMountPlate();

/*
translate([50,0,50]) clamp();
*/

module clampWithMountPlate(){
	union(){
		translate([0, shaftDiameter / 2 + shaftToMountPlate + mountPlateThickness / 2, clampWidth / 2])
			difference(){
				cube([mountPlateLength, mountPlateThickness, clampWidth], center = true);
				translate([-mountHoleSpacing / 2,0,0]) rotate([90,0,0]) 
                    cylinder(r = mountHoleDiameter / 2, h = mountPlateThickness + 2, center = true, $fn = screwHoleSmoothness);
				translate([mountHoleSpacing / 2,0,0]) rotate([90,0,0]) 
                    cylinder(r = mountHoleDiameter / 2, h = mountPlateThickness + 2, center = true, $fn = screwHoleSmoothness);
			}
		clamp();
	}
}


 module clamp(){
	difference(){
		union(){
			cylinder(r = shaftDiameter / 2 + clampThickness, h = clampWidth, $fn = clampSmoothness);
			translate([0,-(shaftDiameter / 2 + clampLegLengthFromShaft) / 2,clampWidth / 2]) 
                // Clamp leg.
                *cube([clampLegThickness * 2 + clampLegGap, shaftDiameter / 2 + clampLegLengthFromShaft,clampWidth], center = true);
		}
			translate([0,0,-1]) 
                cylinder(r = shaftDiameter / 2,h = clampWidth + 2, $fn = clampSmoothness);			
			translate([0, -(shaftDiameter / 4 + clampLegLengthFromShaft ) + 0.1, clampWidth / 2]) 
                cube([clampLegGap, shaftDiameter / 2 + clampLegLengthFromShaft * 2, clampWidth + 2], center = true);
			translate([0, -(shaftDiameter / 2 + clampThickness + clampToClampScrewCenter ), clampWidth / 2]) rotate([0, 90, 0]) 
                // Leg screw bot hole. 
                *cylinder(r = clampScrewDiameter / 2, h = clampLegThickness * 2 + clampLegGap + 2,center = true, $fn = screwHoleSmoothness);
	}
}