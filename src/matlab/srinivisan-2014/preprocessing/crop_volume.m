function [ out_vol ] = crop_volume( in_vol, basline_vol, h_over_rpe, h_under_rpe, width)

    % We will make a parallel processing
    % Pre-allocate the volume
    % Check what is the width to avoid any inconsistance
    if ( width > ( size(in_vol, 2) - 2 ) )
        out_vol = zeros( h_over_rpe + h_under_rpe, ...
                         size(in_vol, 2), ... 
                         size(in_vol, 3) );
    else
        out_vol = zeros( h_over_rpe + h_under_rpe, ...
                         width, ... 
                         size(in_vol, 3) );
    end
    
    parfor sl = 1 : size(in_vol, 3)
        if (sl <= size(in_vol, 3) ) || ( sl <= lentgh( baseline_vol ) )
            out_vol(:, :, sl) = crop_image( in_vol(:, :, sl), ...
                                            basline_vol(sl), ...
                                            h_over_rpe, ...
                                            h_under_rpe, ...
                                            width );
        end
    end    

end

function [ out_img ] = crop_image( in_img, baseline_img, h_over_rpe, h_under_rpe, width)

    % Check that the dimension parameters are meaningful
    if ( h_over_rpe < 0 ) || ( h_under_rpe < 0 ) || ( width < 0 ) | ...
            | ( width > size(in_img, 2) )
        error(['The dimension given to crop the image are inconsistent.']);
    end
    % Check that the dimension allow a cropping
    if ( ( baseline_img - h_over_rpe ) < 0 ) || ( ( baseline_img + ...
                                                    h_under_rpe ) > ...
                                                  size(in_img, 1) )
        error(['The dimension heights dimension are inconsistent to ' ...
               'make a cropping.']);
    end

    % Crop the image
    % To avoid problem of rounding with the center
    if ( width > ( size(in_img, 2) - 2 ) )
        out_img = in_img( baseline_img - h_over_rpe : ...
                          baseline_img + h_under_rpe, ...
                          : );
    else
        % Compute the center in respect to the width
        center_width = floor( size(in_img, 2) / 2. );
        out_img = in_img( baseline_img - h_over_rpe : ...
                          baseline_img + h_under_rpe, ...
                          center_width - floor(width / 2.) : ...
                          center_width + ceil(width / 2.));
    end

end