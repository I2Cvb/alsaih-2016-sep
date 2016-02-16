function [ Oimg ] = denoising( Iimg )
%DENOISING Summary of this function goes here
%   Detailed explanation goes here

    % First we need to add the path to BM3D
    addpath ../../../third-party/BM3D

    Iimg=uint8(Iimg);
    sigma = std2(Iimg(800:900,100:200));
    [t,Oimg] = BM3D(1, Iimg,sigma);
end

