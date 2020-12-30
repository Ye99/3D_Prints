use <large_end.scad>;
use <small_end.scad>;
include <BOSL/constants.scad>
use <BOSL/transforms.scad>

small_end();
  
// down(60)
xrot(180) 
    large_end();
