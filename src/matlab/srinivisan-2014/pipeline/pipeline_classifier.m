clear all;
close all;
clc;

% Give the information about the data location
% Location of the features
data_directory = ['/data/retinopathy/OCT/SERI/feature_data/' ...
                  'srinivasan_2014/'];
% Location to store the results
store_directory = ['/data/retinopathy/OCT/SERI/results/' ...
                   'srinivasan_2014'];
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

% Pre-allocate where the data will be locate
pred_label_cv = zeros( length(idx_class_pos), 2 );

% poolobj = parpool('local', 40);

% Cross-validation using Leave-Two-Patients-Out using a parallel
% for (not right now thought)
for idx_cv_lpo = 1:length(idx_class_pos)
    % The two patients for testing will corresspond to the current
    % index of the cross-validation

    % CREATE THE TESTING SET
    testing_data = [];
    testing_label = [];
    % Load the positive patient
    load( strcat( data_directory, filename{ idx_class_pos(idx_cv_lpo) ...
                   } } ) );
    % Concatenate the data
    testing_data = [ testing_data ; hog_feat ];
    % Create and concatenate the label
    testing_label = [ testing_label ones(size(hog_feat, 1)) ];
    % Load the negative patient
    load( strcat( data_directory, filename{ idx_class_neg(idx_cv_lpo) ...
                   } } ) );
    % Concatenate the data
    testing_data = [ testing_data ; hog_feat ];
    % Create and concatenate the label
    testing_label = [ testing_label (-1 * ones(size(hog_feat, 1))) ];

    % CREATE THE TRAINING SET
    training_data = [];
    training_label = [];
    for tr_idx = 1:length(idx_class_pos)
        % Consider only the data which where not used for the
        % testing set
        if ( tr_idx ~= idx_cv_lpo)
            % Load the positive patient
            load( strcat( data_directory, filename{ idx_class_pos(tr_idx) ...
                   } } ) );
            % Concatenate the data
            training_data = [ training_data ; hog_feat ];
            % Create and concatenate the label
            training_label = [ training_label ones(size(hog_feat, 1)) ];
            % Load the negative patient
            load( strcat( data_directory, filename{ idx_class_neg(tr_idx) ...
                   } } ) );
            % Concatenate the data
            training_data = [ training_data ; hog_feat ];
            % Create and concatenate the label
            training_label = [ training_label (-1 * ones(size(hog_feat, 1))) ];
        end
    end

    % Perform the training of the SVM
    svmStruct = svmtrain( training_data, training_label );
    % Test the performance of the SVM
    pred_label = svmclassify(svmStruct, testing_data);

    % We need to split the data to get a prediction for each volume
    % tested
    pred_label_cv( idx_cv_lpo, 1 ) = mode( pred_label(1:length(hog_feat)) ...
                                           );
    pred_label_cv( idx_cv_lpo, 2 ) = mode( pred_label(length(hog_feat) ...
                                                      + 1 : end ) ...
                                           ); 
end

% delete(poolobj);
