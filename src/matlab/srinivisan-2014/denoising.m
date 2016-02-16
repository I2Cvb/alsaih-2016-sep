function [ Oimg ] = denoising( Iimg )
%DENOISING Summary of this function goes here
%   Detailed explanation goes here

    % Add BM3D dependency
    addpath('../../../third-party/BM3D');

    % Check the input type
    if isfloat(Iimg)
        % Check that the value are between 0. and 1.
        if ( ( max(Iimg(:)) > 1. ) || ( min(Iimg(:)) < 0. ) )
            error(['Image of type with value out of range. Need to ' ...
                   'scale between 0. and 1.'])
        end
    elseif isinteger(Iimg)
        % Convert the data to floating number
        Iimg = im2double(Iimg);
    end

    % Estimate the noise variance from the image
    sigma = std2(Iimg(800:900,100:200));

    % Apply the BM3D filter
    [t, Oimg] = BM3D(1, Iimg, sigma);
end

