clear all;

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

% Denoise the first image 
sigma = 190. / 255.;
img_out = denoising( vol( :, :, 1 ), sigma );

% Show the original image
figure( 1 );
imshow( vol( :, :, 1) );
figure( 2 );
imshow( img_out );