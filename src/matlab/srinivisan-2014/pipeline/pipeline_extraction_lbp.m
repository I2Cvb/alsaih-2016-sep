clear all;
close all;
clc;

% Add the path for the function
addpath('../detection');

% Data after the pre-processing
data_directory = ['/data/retinopathy/OCT/SERI/pre_processed_data/' ...
                  'srinivasan_2014/'];
store_directory = ['/data/retinopathy/OCT/SERI/feature_data/' ...
                   'srinivasan_2014/lbp_8_1_ri/'];
directory_info = dir(data_directory);

poolobj = parpool('local', 40);

for idx_file = 1:size(directory_info)

    % Get only of the extension is .img
    if ( ~isempty( strfind( directory_info(idx_file).name, '.mat' ) ...
                   ) )
        % Find the full path for the current file
        filename = strcat( data_directory, directory_info(idx_file).name ...
                           );

        % Read the file
        load( filename );

        % Extract the HOG features
        pyr_num_lev = 4;
        NumNeighbors = 8;
        Radius = 1;
        CellSize = [32 32];
        Upright = false;

        lbp_feat = extract_lbp_volume( vol_cropped, pyr_num_lev, ...
                                       NumNeighbors, Radius, ...
                                       CellSize, Upright);
        disp( [ 'Feature for file  ', directory_info(idx_file).name, ...
                ' extracted' ] );

        % Store the data
        store_filename = strcat( store_directory, ...
                                 directory_info(idx_file).name ); 
        save( store_filename, 'lbp_feat' );
        disp( [ 'Feature for file  ', directory_info(idx_file).name, ...
                ' stored' ] );
    end
end

delete(poolobj);
