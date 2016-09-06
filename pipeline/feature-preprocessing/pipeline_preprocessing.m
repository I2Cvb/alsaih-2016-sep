clear all;
close all;
clc;

% Execute the setup for protoclass matlab
run('../../../../third-party/protoclass_matlab/setup.m');

% Define the size of the OCT volume
x_size = 512;
y_size = 128;
z_size = 1024;

% Define a fix sigma value 
method_denoising = 'bm3d';
sigma = 190. / 255.;

% Define the method for flattening
method_flattening = 'srinivasan-2014';

% Define the parameters for the cropping
method_cropping = 'srinivasan-2014';
h_over_rpe = 325;
h_under_rpe = 30;
width_crop = 340;

% Define the data directory
data_directory = '/data/retinopathy/OCT/SERI/original_data/';
store_directory = ['/data/retinopathy/OCT/SERI/pre_processed_data/alsaih_2016/'];
directory_info = dir(data_directory);

poolobj = parpool('local', 40);

for idx_file = 1:size(directory_info)

    % Get only of the extension is .img
    if ( ~isempty( strfind( directory_info(idx_file).name, '.img' ) ...
                   ) )
        filename = strcat( data_directory, directory_info(idx_file).name ...
                           );

        % Read the volume
        [ vol ] = read_oct_volume( filename, x_size, y_size, z_size ...
                                   );

        % Convert to double
        vol = vol / max( vol(:) );

        % Apply the preprocessing
        vol_denoised = denoising_volume( vol, method_denoising, sigma );
        disp( [ 'Image ', directory_info(idx_file).name, ' denoised' ] ...
             );
        [ baseline_vol, vol_flattened ] = flattening_volume( ...
            vol_denoised, method_flattening );
        disp( [ 'Image ', directory_info(idx_file).name, ' flattened' ] ...
             );
        vol_cropped = crop_volume( vol_flattened, method_cropping, ...
                                   baseline_vol, h_over_rpe, ...
                                   h_under_rpe, width_crop );
        disp( [ 'Image ', directory_info(idx_file).name, ' cropped' ] ...
             );

        % Store the volume inside a mat file
        store_filename = strcat( store_directory, strrep( ...
            directory_info(idx_file).name, '.img', '.mat' ) );
        save( store_filename, 'vol_cropped' );
        disp( [ 'Image ', directory_info(idx_file).name, ' cropped ' ...
                            'was stored' ] );

    end

end


delete(poolobj);
