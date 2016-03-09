clear all;
close all;
clc;


addpath('../util');
addpath('../preprocessing');


x_size = 512;
y_size = 128;
z_size = 1024;

 
sigma = 190. / 255.;


h_over_rpe = 325;
h_under_rpe = 30;
width_crop = 340;


data_directory = '/data/retinopathy/OCT/SERI/original_data/';
filename = strcat( data_directory,'PMS15336OD.img');
[ vol ] = read_oct_volume( filename, x_size, y_size, z_size);


vol = vol / max( vol(:) );


vol_denoised = denoising_volume( vol, sigma );
[ baseline_vol, in_vol ] = flattening_volume(vol_denoised );
width = 340
  for i = 1:128
    i
	    h_over_rpe = 325;
h_under_rpe = 30;
width_crop = 340;
if ( ( baseline_vol(i) - h_over_rpe ) < 0 ) || ( ( baseline_vol(i) +  h_under_rpe ) > 512 )
						 baseline_vol(i)  
						 h_over_rpe = baseline_vol(i) -1
        h_under_rpe = 356 - h_over_rpe - 1
     end
						 in_img = in_vol(:,:,i);
center_width = floor( size(in_img, 2) / 2. );
out_img(:,:,i) = in_img( baseline_vol(i) - h_over_rpe : baseline_vol(i) + h_under_rpe,center_width - floor(width / 2.) : center_width + ceil(width / 2.));
end
