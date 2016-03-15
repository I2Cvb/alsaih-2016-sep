clear all;
close all;
clc;

% Give the information about the data location
% Location of the features
data_directory_hog = ['/data/retinopathy/OCT/SERI/feature_data/' ...
                    'srinivasan_2014/'];
data_directory_lbp = ['/data/retinopathy/OCT/SERI/feature_data/' ...
                    'srinivasan_2014_lbp/'];
% Location to store the results
store_directory = ['/data/retinopathy/OCT/SERI/results/' ...
                   'srinivasan_2014/'];
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

% poolobj = parpool('local', 48);

% Pre-allocate where the data will be locate
pred_label_cv = zeros( length(idx_class_pos), 2 );

% Cross-validation using Leave-Two-Patients-Out
for idx_cv_lpo = 1:length(idx_class_pos)
    disp([ 'Round #', num2str(idx_cv_lpo), ' of the L2PO']);

    % The two patients for testing will corresspond to the current
    % index of the cross-validation

    % FOR HOG FEATURES
    % CREATE THE TESTING SET
    testing_data_hog = [];
    testing_label = [];
    % Load the positive patient
    load( strcat( data_directory_hog, filename{ idx_class_pos(idx_cv_lpo) ...
                   } ) );
    % Concatenate the data
    testing_data_hog = [ testing_data_hog ; hog_feat ];
    % Create and concatenate the label
    testing_label = [ testing_label ones(1, size(hog_feat, 1)) ];
    % Load the negative patient
    load( strcat( data_directory_hog, filename{ idx_class_neg(idx_cv_lpo) ...
                   } ) );
    % Concatenate the data
    testing_data_hog = [ testing_data_hog ; hog_feat ];
    % Create and concatenate the label
    testing_label = [ testing_label ( -1 * ones(1, size(hog_feat, 1))) ];

    disp('Created the testing set for HOG');

    % CREATE THE TRAINING SET
    training_data_hog = [];
    training_label = [];
    for tr_idx = 1:length(idx_class_pos)
        % Consider only the data which where not used for the
        % testing set
        if ( tr_idx ~= idx_cv_lpo)
            % Load the positive patient
            load( strcat( data_directory_hog, filename{ idx_class_pos(tr_idx) ...
                   } ) );
            % Concatenate the data
            training_data_hog = [ training_data_hog ; hog_feat ];
            % Create and concatenate the label
            training_label = [ training_label ones(1, size(hog_feat, 1)) ];
            % Load the negative patient
            load( strcat( data_directory_hog, filename{ idx_class_neg(tr_idx) ...
                   } ) );
            % Concatenate the data
            training_data_hog = [ training_data_hog ; hog_feat ];
            % Create and concatenate the label
            training_label = [ training_label (-1 * ones(1, size(hog_feat, 1))) ];
        end
    end

    disp('Created the training set for HOG');

    % Make PCA decomposition keeping the 40 first components which
    % are the one > than 0.1 % of significance
    [coeff, score, latent, tsquared, explained, mu] = ...
        pca(training_data_hog, 'NumComponents', 40);
    % Apply the transformation to the training data
    training_data_hog = score;
    % Apply the transformation to the testing data
    % Remove the mean computed during the training of the PCA
    testing_data_hog = (bsxfun(@minus, testing_data_hog, mu)) * coeff;

    disp('Projected the data using PCA for HOG');

    % FOR LBP FEATURES
    % CREATE THE TESTING SET
    testing_data_lbp = [];
    % Load the positive patient
    load( strcat( data_directory_lbp, filename{ idx_class_pos(idx_cv_lpo) ...
                   } ) );
    % Concatenate the data
    testing_data_lbp = [ testing_data_lbp ; lbp_feat ];
    % Load the negative patient
    load( strcat( data_directory_lbp, filename{ idx_class_neg(idx_cv_lpo) ...
                   } ) );
    % Concatenate the data
    testing_data_lbp = [ testing_data_lbp ; lbp_feat ];

    disp('Created the testing set for LBP');

    % CREATE THE TRAINING SET
    training_data_lbp = [];
    for tr_idx = 1:length(idx_class_pos)
        % Consider only the data which where not used for the
        % testing set
        if ( tr_idx ~= idx_cv_lpo)
            % Load the positive patient
            load( strcat( data_directory_lbp, filename{ idx_class_pos(tr_idx) ...
                   } ) );
            % Concatenate the data
            training_data_lbp = [ training_data_lbp ; lbp_feat ];
            % Load the negative patient
            load( strcat( data_directory_lbp, filename{ idx_class_neg(tr_idx) ...
                   } ) );
            % Concatenate the data
            training_data_lbp = [ training_data_lbp ; lbp_feat ];
        end
    end

    disp('Created the training set for LBP');

    % Make PCA decomposition keeping the 20 first components which
    % are the one > than 0.5 % of significance
    [coeff, score, latent, tsquared, explained, mu] = ...
        pca(training_data_lbp, 'NumComponents', 20);
    % Apply the transformation to the training data
    training_data_lbp = score;
    % Apply the transformation to the testing data
    % Remove the mean computed during the training of the PCA
    testing_data_lbp = (bsxfun(@minus, testing_data_lbp, mu)) * coeff;
    
    disp('Projected the data using PCA for LBP');

    % Concatenate the data
    training_data = [ training_data_hog, training_data_lbp ];
    testing_data = [ testing_data_hog, testing_data_lbp ];

    % Perform the training of the SVM
    % svmStruct = svmtrain( training_data, training_label );
    SVMModel = fitcsvm(training_data, training_label);
    disp('Trained SVM classifier');
    % Test the performance of the SVM
    % pred_label = svmclassify(svmStruct, testing_data);
    pred_label = predict(SVMModel, testing_data);
    disp('Tested SVM classifier');

    % We need to split the data to get a prediction for each volume
    % tested
    % Compute the majority voting for each testing volume
    maj_vot = [ mode( pred_label(1:size(hog_feat,1)) ) ...
                mode( pred_label(size(hog_feat, 1) + 1:end) )];
    pred_label_cv( idx_cv_lpo, : ) = maj_vot;    
    disp('Applied majority voting');
end

save(strcat(store_directory, 'predicition_hog_lbp_pca.mat'), 'pred_label_cv');

%delete(poolobj);