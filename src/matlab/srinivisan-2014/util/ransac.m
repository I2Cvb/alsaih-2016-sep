function [ poly_f ] = ransac(x, fx, deg_poly, num, iter, thres_dist)

    % Check the input parameters
    if ( length(x) ~= length(fx) )
        error(['The lengthgth of x and fx should be the same.']);
    end
    if ( ( num < 0 ) || ( num > length(x) ) )
        error(['The number to point to radomly select is inconsistant.']);
    end

    best_inlier_num = 0;

    for it = 1:iter
        % Randomly select the points
        idx = randperm(length(x), num);
        % Fit the polynomial using the data available
        p = polyfit( x(idx), fx(idx), deg_poly);
        % Compute the estimate
        fx_est = polyval(p, x);
        % Compute the Root Mean Squared Error
        dist_poly = sqrt( ( fx - fx_est ) .* ( fx - fx_est ) );
        % Find the indexes of inliers
        inlier_idx = find(dist_poly <= thres_dist);
        % Find the number of inliers
        inlier_num = length(inlier_idx);
        if ( inlier_num > best_inlier_num )
            best_inlier_num = inlier_num;
            poly_f = polyfit( x(inlier_idx), fx(inlier_idx), ...
                              deg_poly); 
        end
    end
    
end