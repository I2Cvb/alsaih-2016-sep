function [ Oimg ] = crop( Iimg,ma )
%CROP Summary of this function goes here
%   Detailed explanation goes here

    Oimg=Iimg(floor(ma)-89:floor(ma)+30,size(Iimg,2)/2-169:size(Iimg,2)/2+170);

end

