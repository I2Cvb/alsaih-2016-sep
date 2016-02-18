function [ baseline_vol, warped_vol ] = flattening_volume( in_vol )

    % We will make a parallel processing
    % Pre-allocate the volume
    warped_vol = zeros( size(in_vol) );
    baseline_vol = zeros( size(in_vol, 3) );
    for sl = 1 : size(in_vol, 3)
        if sl <= size(in_vol, 3)
            [ baseline_vol(sl), warped_vol(:, :, sl) ] = flattening_image( in_vol(:, :, sl) );
        end
    end

end


function [ baseline_y, warped_img ] = flattening_image( in_img )

    addpath('../util');

    % Find the indexes of the first maximum
    [~, idx_max_1] = max( in_img );
    % Temporary put to zeros the first maximum
    sec_im = in_img;
    sec_img(idx_max_1, :) = 0;
    % Find the indexes of the second maximum
    [~, idx_max_2] = max( sec_im );
    % Take the maximum index by column which mean the lowest
    % boundary of the convex hull
    idx = max([idx_max_1; idx_max_2]);
    
    % Compute the best polynom of second degree using RANSAC
    deg_poly = 2;
    min_num = 5;
    iter_num = 1000;
    dist_max = 20;
    poly_f = ransac( 1:size(in_img,2), idx, deg_poly, min_num, iter_num, dist_max );
    point_poly = round( polyval( poly_f, 1:size(in_img,2) ) );

    % Find the minum of the baselin to realign everything
    baseline_y = max(point_poly);

    warped_img = zeros(size(in_img));

    for col_idx = 1:size(in_img, 2)
        % Compute the distance to apply the rolling
        dist_roll = round( baseline_y - point_poly(col_idx) );
        
        % Assign the new column to the warped image
        warped_img(:, col_idx) = circshift( in_img(:, col_idx), ...
                                            dist_roll );
    end    

end