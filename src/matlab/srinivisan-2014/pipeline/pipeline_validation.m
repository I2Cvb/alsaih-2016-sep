clear all;
close all;
clc;

% Add the path for the function
addpath('../validation');

% Refer to the classification pipeline to know how the testing set
% was created
% Location of the ground-truth
gt_file = '../../../../data/data.csv';

% Load the csv data
[~, ~, raw_data] = xlsread(gt_file);
% Extract the information from the raw data
% Store the filename inside a cell
filename = { raw_data{ 2:end, 1} };
% Store the label information into a vector
data_label = [ raw_data{ 2:end, 2 } ];
% Get the index of positive and negative class
idx_class_pos = find( data_label ==  1 );
idx_class_neg = find( data_label == -1 );

gt_label = [];
% We gan create the GT labels
for idx_cv_lpo = 1:length(idx_class_pos)
    % Concatenate the value as in the classification pipeline
    gt_label = [ gt_label 1 -1 ];
end

% Load the results data
results_filename = ['/data/retinopathy/OCT/SERI/results/' ...
                    'srinivasan_2014/predicition_hog_lbp_8_ri.mat'];
load(results_filename);

% Linearize the vector loaded
pred_label = pred_label_cv';
pred_label = pred_label(:);

% Get the statistic 
[ sens, spec, prec, npv, acc, f1s, mcc, gmean, cm ] = metric_confusion_matrix( ...
    pred_label, gt_label );

% Display the information
disp( ['Sensitivity: ',                     num2str(sens)] );
disp( ['Specificity: ',                     num2str(spec)] );
disp( ['Precision: ',                       num2str(prec)] );
disp( ['Negative Predictive Value: ',       num2str(npv)] );
disp( ['Accuracy: ',                        num2str(acc)] );
disp( ['F1-score: ',                        num2str(f1s)] );
disp( ['Matthew Correlation Coefficiant: ', num2str(mcc)] );
disp( ['Geometric Mean: ',                  num2str(gmean)] );
