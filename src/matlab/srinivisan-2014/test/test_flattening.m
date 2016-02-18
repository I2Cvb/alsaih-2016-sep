% Add the path for the function
addpath('../util');
addpath('../preprocessing');

% Define the size of the OCT volume
x_size = 512;
y_size = 128;
z_size = 1024;

% Read the volume
[ vol ] = read_oct_volume( '/data/retinopathy/OCT/SERI/original_data/PCS57635OS.img', x_size, ...
                            y_size, z_size );

% Convert to double
vol = vol / max( vol(:) );

[ baseline_vol, vol_flattened ] = flattening_volume( ...
                                    vol );