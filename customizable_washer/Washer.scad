outerDiameter = 11.2;
innerDiameter = 4.1;
thickness = 1.2;
$fn=198;

linear_extrude(height=thickness)
  difference() { circle(d=outerDiameter); circle(d=innerDiameter); }
