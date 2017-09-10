function sec = brain_section_constructor(name, x_low, x_high, y_low, y_high, z_low, z_high)
    sec = struct();
    sec(1).name = name;
    sec(1).x_low = x_low;
    sec(1).x_high = x_high;
    sec(1).y_low = y_low;
    sec(1).y_high = y_high;
    sec(1).z_low = z_low;
    sec(1).z_high = z_high;
end