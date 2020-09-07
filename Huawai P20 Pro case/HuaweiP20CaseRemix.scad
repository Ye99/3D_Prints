use <BOSL/transforms.scad>

module cut_top() {
    back(case_2_length/2 - 4)
        left(45)
            cube([178, 30, 12]);
}

module cut_corner() {
    back(case_2_length/2)
        up(6)
            left(41)
                zrot(45)   
                    cube([25, 20, 12], center=true);
}

module cut_corner2() {
    back(case_2_length/2)
        up(6)
            right(41)
                zrot(-45)   
                    cube([25, 20, 12], center=true);
}

module cut_corner3() {
    back(case_2_length/2)
        up(6)
            left(41)
                zrot(45)   
                    #cube([25, 20, 12], center=true);
}

module cut_corner4() {
    back(case_2_length/2)
        up(6)
            right(41)
                zrot(-45)   
                    #cube([25, 20, 12], center=true);
}

usb_hole_z_length=6.9;
module cut_usb_hole() {
    cube([4, 10, usb_hole_z_length], center=true);
}

mic_hole_z_length=2.9;
module cut_mic_hole() {
    cube([4, 10, mic_hole_z_length], center=true);
}

volume_hole_z_length=4.2;
volume_hole_y_length=42;
module cut_volume_power_hole() {
    cube([5, volume_hole_y_length, volume_hole_z_length], center=true);
}

case_1_width=78.22;
case_1_length=158.8;
case_1_height=9.99;

case_2_width=77.26;
case_2_length=158.4;
case_2_height=11.38;

// Case #1
difference() {
    import("Huawei_P20_Pro_case/files/P20_Pro_case_closed.stl");
    
    cut_top();
    
    cut_corner();
    cut_corner2();
    
    back(32.6)
        right(case_1_width/2-1)
            up(5)
                #cut_volume_power_hole();
}

// Case #2
2nd_case_right_shift_distance=case_2_width/2 + 10;
difference() {
    right(2nd_case_right_shift_distance)
        fwd(case_2_length/2)
            up(case_2_height)
                yrot(180)
                    zrot(90)
                        import("Case+Huawei+P20+Pro/files/Case_1-3-3.STL");
    
    cut_top();
    
    right(2nd_case_right_shift_distance + case_2_width/2) {
        cut_corner3();
        cut_corner4();
        
        back(31.6)
            right(case_1_width/2-2)
                up(6.8)
                    #cut_volume_power_hole();
        
        fwd(case_2_length/2-2)
            up(6.7)
            #cut_usb_hole();
        
        fwd(case_2_length/2-2)
            left(16)
                up(6.7)
                    #cut_mic_hole();
        
        fwd(case_2_length/2-2)
            right(16)
                up(6.7)
                    #cut_mic_hole();
    }
}
                    
