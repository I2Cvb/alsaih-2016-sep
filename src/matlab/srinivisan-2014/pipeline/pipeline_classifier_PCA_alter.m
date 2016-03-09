clear all;
close all;
clc;

% Give the information about the data location
% Location of the features
data_directory = ['/data/retinopathy/OCT/SERI/feature_data/' ...
							     'srinivasan_2014/'];
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

    % CREATE THE TESTING SET
    testing_data = [];
testing_label = [];
    % Load the positive patient
    load( strcat( data_directory, filename{ idx_class_pos(idx_cv_lpo) ...
	    } ) );
    % Concatenate the data
    testing_data = [ testing_data ; hog_feat ];
    % Create and concatenate the label
    testing_label = [ testing_label ones(1, size(hog_feat, 1)) ];
    % Load the negative patient
    load( strcat( data_directory, filename{ idx_class_neg(idx_cv_lpo) ...
	    } ) );
    % Concatenate the data
    testing_data = [ testing_data ; hog_feat ];
    % Create and concatenate the label
    testing_label = [ testing_label ( -1 * ones(1, size(hog_feat, 1))) ];

disp('Created the testing set');

    % CREATE THE TRAINING SET
    training_data = [];
training_label = [];
for tr_idx = 1:length(idx_class_pos)
        % Consider only the data which where not used for the
        % testing set
	       if ( tr_idx ~= idx_cv_lpo)
            % Load the positive patient
		load( strcat( data_directory, filename{ idx_class_pos(tr_idx) ...
		    } ) );
            % Concatenate the data
            training_data = [ training_data ; hog_feat ];
            % Create and concatenate the label
            training_label = [ training_label ones(1, size(hog_feat, 1)) ];
            % Load the negative patient
            load( strcat( data_directory, filename{ idx_class_neg(tr_idx) ...
		    } ) );
            % Concatenate the data
            training_data = [ training_data ; hog_feat ];
            % Create and concatenate the label
            training_label = [ training_label (-1 * ones(1, size(hog_feat, 1))) ];
        end
    end

	disp('Created the training set');
mn = mean(training_data);
training_data = bsxfun(@minus,training_data,mn); % substract mean
[coefs,scores,variances] = princomp(training_data,'econ'); % PCA
dims = 6000;
training_data = training_data*coefs(:,1:dims); % dims - keep this many dimensions
    % Perform the training of the SVM
svmStruct = svmtrain( training_data, training_label);
disp('Trained SVM classifier');
    % Test the performance of the SVM
    testing_data = bsxfun(@minus,testing_data,mn);
testing_data = testing_data*coefs(:,1:dims); 
pred_label = svmclassify(svmStruct, testing_data);
disp('Tested SVM classifier');

    % We need to split the data to get a prediction for each volume
    % tested
    % Compute the majority voting for each testing volume
    maj_vot = [ mode( pred_label(1:size(hog_feat,1)) ) ...
		  mode( pred_label(size(hog_feat, 1) + 1:end) )];
pred_label_cv( idx_cv_lpo, : ) = maj_vot;    
disp('Applied majority voting');
end

save(strcat(store_directory, 'predicition.mat'), 'pred_label_cv');

%delete(poolobj);
