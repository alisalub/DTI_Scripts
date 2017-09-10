function ret_section = slice_brain(brain_sect, brain_vol)
% Return a 3D section of a brain.
% Parameters:
% brain_sect: Instance of the brain_section object.
% brain_vol: A nii-like 3D array of brain data.

ret_section = brain_vol(brain_sect.x_low:brain_sect.x_high, ...
                        brain_sect.y_low:brain_sect.y_high, ...
                        brain_sect.z_low:brain_sect.z_high);

end