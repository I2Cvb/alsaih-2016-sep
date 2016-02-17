% function [ out_vol ] = denoising( in_vol, sigma )

%     % Check the input type
%     if isfloat( in_vol )
%         % Check that the value are between 0. and 1.
%         if ( ( max(in_vol(:)) > 1. ) || ( min(in_vol(:)) < 0. ) )
%             error(['Volume of type float with value out of range. Need to ' ...
%                    'scale between 0. and 1.'])
%         end
%         % Check the value of sigma
%         if ( ( sigma > 1. ) || ( sigma < 0. ) )
%             error(['The image data are in the range between 0.0 and ' ...
%                    '1.0. sigma need to be in the same range.']);
%         else
%             % From the BM3D toolbox, sigma need to be scale between
%             % 0 and 255
%             sigma = 255. * sigma;
%         end
%     elseif isinteger( in_vol )
        
%         % Divide sigma by the maximum value of the image
%         sigma = float( sigma );

%         % Convert the data to floating number
%         in_vol = im2double( in_vol );
%     end


% end

function [ Oimg ] = denoising( Iimg, sigma )
%DENOISING Summary of this function goes here
%   Detailed explanation goes here

    % Add BM3D dependency
    addpath('../../../../third-party/BM3D');

    % Check the input type
    if isfloat( Iimg )
        % Check that the value are between 0. and 1.
        if ( ( max(Iimg(:)) > 1. ) || ( min(Iimg(:)) < 0. ) )
            error(['Image of type float with value out of range. Need to ' ...
                   'scale between 0. and 1.'])
        end
        % Check the value of sigma
        if ( ( sigma > 1. ) || ( sigma < 0. ) )
            error(['The image data are in the range between 0.0 and ' ...
                   '1.0. sigma need to be in the same range.']);
        else
            % From the BM3D toolbox, sigma need to be scale between
            % 0 and 255
            sigma = 255. * sigma;
        end
    elseif isinteger( Iimg )
        
        % Divide sigma by the maximum value of the image
        sigma = float( sigma );

        % Convert the data to floating number
        Iimg = im2double( Iimg );
    end

    % Apply the BM3D filter
    [t, Oimg] = BM3D(1, Iimg, sigma);
end