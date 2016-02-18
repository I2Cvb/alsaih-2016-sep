clear all;
close all;
clc;

% Add the path for the function
addpath('../util');
addpath('../preprocessing');

% Define the size of the OCT volume
x_size = 512;
y_size = 128;
z_size = 1024;

% Read the volume
[ vol ] = read_oct_volume( '../../../../data/P741009OS.img', x_size, ...
          y_size, z_size );

% Convert to double
vol = vol / max( vol(:) );

% Define a fix sigma value 
sigma = 190. / 255.;

% Define the parameters for the cropping
h_over_rpe = 90;
h_under_rpe = 30;
width_crop = 340;

poolobj = parpool('local', 40);

vol_denoised = denoising_volume( vol, sigma );

[ basline_vol, vol_flattened ] = flattening_volume( vol_denoised );

vol_cropped = crop_volume( vol_flattened, baseline_vol, h_over_rpe, ...
                           h_under_rpe, width_crop );

delete(poolobj);