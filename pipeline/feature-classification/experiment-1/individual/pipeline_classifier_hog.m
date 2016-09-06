function pipeline_classifier_hog(classifier_name)

% Check that the classifier is known
if ~(strcmp(classifier_name, 'linear_svm') | ...
     strcmp(classifier_name, 'rbf_svm') | ...
     strcmp(classifier_name, 'random_forest'))
    error('The classifier name provided was not tested.')
end

% Give the information about the data location
% Location of the features
data_directory = ['/data/retinopathy/OCT/SERI/feature_data/' ...
                  'alsaih_2016/hog/'];
% Location to store the results
store_directory = ['/data/retinopathy/OCT/SERI/results/' ...
                   'alsaih_2016/experiment-1/'];
% Location of the ground-truth
gt_file = '/data/retinopathy/OCT/SERI/data.xls';

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

    if strcmp(classifier_name, 'linear_svm')

        % Perform the training of the SVM
        SVMModel = fitcsvm(training_data, training_label, ...
                           'KernelFunction', 'linear');
        disp('Trained SVM classifier');
        % Test the performance of the SVM
        pred_label = predict(SVMModel, testing_data);
        disp('Tested SVM classifier');

    elseif strcmp(classifier_name, 'rbf_svm')

        % Perform the training of the SVM
        SVMModel = fitcsvm(training_data, training_label, ...
                           'KernelFunction', 'rbflinear');
        disp('Trained SVM classifier');
        % Test the performance of the SVM
        pred_label = predict(SVMModel, testing_data);
        disp('Tested SVM classifier');

        if strcmp(classifier_name, 'random_forest')

            nTrees = 80;
            % Perform the training of the Random Forest
            RFModel = TreeBagger(nTrees, training_data, training_label, 'Method', ...
                                 'classification'); 
            disp('Trained RF classifier');
            % Test the performance of the SVM
            pred_label = RFModel.predict(testing_data);
            pred_label = str2double(pred_label);
            disp('Tested RF classifier');
            
        end

        % We need to split the data to get a prediction for each volume
        % tested
        % Compute the majority voting for each testing volume
        maj_vot = [ mode( pred_label(1:size(hog_feat,1)) ) ...
                    mode( pred_label(size(hog_feat, 1) + 1:end) )];
        pred_label_cv( idx_cv_lpo, : ) = maj_vot;    
        disp('Applied majority voting');
    end

    save(strcat(store_directory, ['predicition_hog_', classifier_name, '.mat']), 'pred_label_cv');

end

%delete(poolobj);