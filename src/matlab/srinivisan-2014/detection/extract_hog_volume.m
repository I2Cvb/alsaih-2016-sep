function [ feature_mat_vol ] = extract_hog_volume( in_vol, CellSize, BlockSize, BlockOverlap, NumBins)
    
    BlocksPerImage = floor( ( size(in_vol(:, :) ) ./ CellSize – ...
                              BlockSize ) ./ ( BlockSize – BlockOverlap ...
                                               ) + 1 );
    feat_dim = prod([BlocksPerImage, BlockSize, NumBins]);

    % Pre-allocate feature_mat_vol
    feature_mat_vol = zeros( size(in_vol, 3), feat_dim );

    parfor sl = 1 : size(in_vol, 3)
        if ( sl <= size(in_vol, 3) )
            feature_mat_vol(sl, :) = extract_hog_image( in_vol(:, :, sl) ...
                                                   );
        end
    end    

end

function [ feature_vec_img ] = extract_hog_image( in_img, CellSize, BlockSize, BlockOverlap, NumBins )

    I0 = in_img;
    
    % Compute the pyramid
    I1 = impyramid(I0, 'reduce');
    I2 = impyramid(I1, 'reduce');
    I3 = impyramid(I2, 'reduce');

    % Extract HOG for each image of the pyramid
    feature_vec_img = extractHOGFeatures(I0,'CellSize', CellSize, ...
                                         'BlockSize', BlockSize ...
                                         ,'BlockOverlap', BlockOverlap); 
    feature_vec_img = [feature_vec_img extractHOGFeatures(I0,'CellSize', CellSize, ...
                                         'BlockSize', BlockSize ...
                                         ,'BlockOverlap', BlockOverlap)]; 
    feature_vec_img = [feature_vec_img extractHOGFeatures(I0,'CellSize', CellSize, ...
                                         'BlockSize', BlockSize ...
                                         ,'BlockOverlap', BlockOverlap)]; 
    feature_vec_img = [feature_vec_img extractHOGFeatures(I0,'CellSize', CellSize, ...
                                         'BlockSize', BlockSize ...
                                         ,'BlockOverlap', BlockOverlap);]; 
    
end


