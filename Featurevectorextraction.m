function [ feature ] = Featurevectorextraction( Iimg )
%FEATUREVECTOREXTRACTION Summary of this function goes here
%   Detailed explanation goes here
    I0 = Iimg;
    I1 = impyramid(I0, 'reduce');
    I2 = impyramid(I1, 'reduce');
    I3 = impyramid(I2, 'reduce');
    feature = extractHOGFeatures(I0,'CellSize',[4 4],'BlockSize',[2 2] ,'BlockOverlap',[1 1]);
    feature = [feature extractHOGFeatures(I1,'CellSize',[4 4],'BlockSize',[2 2] ,'BlockOverlap',[1 1])];
    feature = [feature extractHOGFeatures(I2,'CellSize',[4 4],'BlockSize',[2 2] ,'BlockOverlap',[1 1])];
    feature = [feature extractHOGFeatures(I3,'CellSize',[4 4],'BlockSize',[2 2] ,'BlockOverlap',[1 1])];

end

