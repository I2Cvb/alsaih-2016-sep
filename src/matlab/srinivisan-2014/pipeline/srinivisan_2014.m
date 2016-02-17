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
[ vol ] = read_oct_volume( '../../../../data/PCS57635OS.img', x_size, ...
          y_size, z_size );

% Convert to double
vol = vol / max( vol(:) );

% Define a fix sigma value 
sigma = 190. / 255.;

% We will make a parallel processing
vol_out = zeros( size(vol) );

parfor sl = 1 : size(vol, 3)
    if sl <= size(vol, 3)
        denoising( vol(:, :, sl), sigma );
    end
end
