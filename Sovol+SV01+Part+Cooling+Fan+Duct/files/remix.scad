use <../../BOSL/transforms.scad>

module SovolSV1_fan_duct() {
    difference() {
        down(1.9)
            left(40)
                back(120)
                    xrot(90)
                        import("SV01_PartCooling_V5+.stl");
       
        #cube([100, 100, 10], center=true);
    }
}

SovolSV1_fan_duct();