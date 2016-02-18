clear all;
close all;
clc;

% Add the path for the function
addpath('../detection');

% Data after the pre-processing
data_directory = ['/data/retinopathy/OCT/SERI/pre_processed_data/' ...
                  'srinivasan_2014/'];
store_directory = ['/data/retinopathy/OCT/SERI/feature_data/' ...
                   'srinivasan_2014/'];
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
        CellSize = [4 4];
        BlockSize = [2 2];
        BlockOverlap = [1 1];
        NumBins = 9;

        hog_feat = extract_hog_volume( vol_cropped, pyr_num_lev, ...
                                       CellSize, ...
                                       BlockSize, BlockOverlap, ...
                                       NumBins );
        disp( [ 'Feature for file  ', directory_info(idx_file).name, ...
                ' extracted' ] );

        % Store the data
        store_filename = strcat( store_directory, ...
                                 directory_info(idx_file).name ); 
        save( store_filename, 'hog_feat' );
        disp( [ 'Feature for file  ', directory_info(idx_file).name, ...
                ' stored' ] );
    end
end

delete(poolobj);
