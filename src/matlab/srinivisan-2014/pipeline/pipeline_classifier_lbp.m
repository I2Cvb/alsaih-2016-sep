clear all;
close all;
clc;
nTrees=80;
% Give the information about the data location
% Location of the features
data_directory_lbp = ['/data/retinopathy/OCT/SERI/feature_data/' ...
							     'srinivasan_2014/lbp_16_2_ri/'];
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

 % FOR LBP FEATURES
    % CREATE THE TESTING SET
    testing_data_lbp = [];
    testing_label_lbp= [];
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
    testing_label_lbp = [ testing_label_lbp ( -1 * ones(1, size(lbp_feat, 1))) ];
disp('Created the testing set for LBP');

    % CREATE THE TRAINING SET
    training_data_lbp = [];
training_label_lbp = [];
for tr_idx = 1:length(idx_class_pos)
        % Consider only the data which where not used for the
        % testing set
	       if ( tr_idx ~= idx_cv_lpo)
            % Load the positive patient
		load( strcat( data_directory_lbp, filename{ idx_class_pos(tr_idx) ...
		    } ) );
            % Concatenate the data
            training_data_lbp = [ training_data_lbp ; lbp_feat ];
training_label_lbp = [ training_label_lbp ones(1, size(lbp_feat, 1)) ];
            % Load the negative patient
            load( strcat( data_directory_lbp, filename{ idx_class_neg(tr_idx) ...
		    } ) );
            % Concatenate the data
            training_data_lbp = [ training_data_lbp ; lbp_feat ];
training_label_lbp = [ training_label_lbp (-1 * ones(1, size(lbp_feat, 1))) ];       
        end
    end

	disp('Created the training set for LBP');

    % Make PCA decomposition keeping the 20 first components which
    % are the one > than 0.5 % of significance
    %[coeff, score, latent, tsquared, explained, mu] = ...
	 %    pca(training_data_lbp, 'NumComponents', 20);
    % Apply the transformation to the training data
    % training_data_lbp = score;
    % Apply the transformation to the testing data
    % Remove the mean computed during the training of the PCA
    %testing_data_lbp = (bsxfun(@minus, testing_data_lbp, mu)) * coeff;
    
%disp('Projected the data using PCA for LBP');

 
k = 60;
[idxs C] = kmeans(training_data_lbp,k);
temp_res=[];
for mm = 1 : 128 :size(training_data_lbp,1)
	   [knn_idxs D] = knnsearch( C, training_data_lbp(mm:mm+127,:));
temp = hist(knn_idxs,k);
temp = temp ./ sum(temp);
temp_res = [temp_res; temp];
end
training_data_lbp = temp_res;
temps = [];
%size(training_label)
for mm = 1 : 128 : size(training_label_lbp,2)
	   temps = [temps mode(training_label_lbp(mm:mm+127))];
end
% size(temps)
training_label_lbp = temps;
temp_res=[];
for mm = 1 : 128 : size(testing_data_lbp,1)
	   [knn_idxs D] = knnsearch( C, testing_data_lbp(mm:mm+127,:));
temp = hist(knn_idxs,k);
temp = temp ./ sum(temp);
temp_res=[temp_res; temp];
end
testing_data_lbp = temp_res;
temps = [];
for mm = 1 : 128 : size(testing_label_lbp,2)
	   temps = [temps mode(testing_label_lbp(mm:mm+127))];
end
testing_label_lbp = temps;
   

    % Perform the training of the SVM
    % svmStruct = svmtrain( training_data, training_label );
%SVMModel = fitcsvm(training_data_lbp, training_label_lbp);
%SVMModel = fitcsvm(training_data_lbp, training_label_lbp,'KernelFunction','rbf');
B = TreeBagger(nTrees,training_data_lbp,training_label_lbp, 'Method', 'classification');
disp('Trained SVM classifier');
    % Test the performance of the SVM
    % pred_label = svmclassify(svmStruct, testing_data);
%pred_label = predict(SVMModel, testing_data_lbp);
pred_label = B.predict(testing_data_lbp);
pred_label = str2double(pred_label);
disp('Tested SVM classifier');

    % We need to split the data to get a prediction for each volume
    % tested
    % Compute the majority voting for each testing volume
   % maj_vot = [ mode( pred_label(1:size(lbp_feat,1)) ) ...
        %		  mode( pred_label(size(lbp_feat, 1) + 1:end) )];
maj_vot = [pred_label(1) pred_label(2) ];
pred_label_cv( idx_cv_lpo, : ) = maj_vot;    
disp('Applied majority voting');
end

save(strcat(store_directory, 'predicition_lbp_Randfor_BoW50_16ri.mat'), 'pred_label_cv');

%delete(poolobj);
