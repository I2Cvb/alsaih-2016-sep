function pipeline_classifier_hog_pca_bow(classifier_name, nb_words)

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
                   'alsaih_2016/experiment-2/'];
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

    % Make PCA decomposition keeping the 40 first components which
    % are the one > than 0.1 % of significance
    [coeff, score, latent, tsquared, explained, mu] = ...
        pca(training_data, 'NumComponents', 40);
    % Apply the transformation to the training data
    training_data = score;
    % Apply the transformation to the testing data
    % Remove the mean computed during the training of the PCA
    testing_data = (bsxfun(@minus, testing_data, mu)) * coeff;

    disp('Create BoW representation');

    % Feed all the data to a kmeans classifiers to find the words
    [idxs, words] = kmeans(training_data, nb_words);

    % Build the histogram for the training data
    training_histogram = [];
    % For each volume build an histogram -- size(hog_feat, 1)
    % represent the 128 B-scans
    for vol_idx_start = 1 : size(hog_feat, 1) : size(training_data, ...
                                                     1)
        % Compute the distance from each sample to each words
        [knn_idxs, dist] = knnsearch(words, training_data(vol_idx_start : ...
                                                          vol_idx_start + ...
                                                          size(hog_feat, 1) ...
                                                          - 1, :));
        % Compute the number of occurence of the words
        vol_histogram = histogram(knn_idxs, nb_words);
        norm_histogram = vol_histogram.Data ./ sum(vol_histogram.Data);
        % Concatenate with the other training histograms
        training_histogram = [training_histogram; norm_histogram];
    end
    training_data = training_histogram;
    testing_histogram = [];
    for vol_idx_start = 1 : size(hog_feat, 1) : size(testing_data, ...
                                                     1)
        [knn_idxs dist] = knnsearch(words, testing_data(vol_idx_start : ...
                                                        vol_idx_start + ...
                                                        size(hog_feat, 1) ...
                                                        - 1,:));
        % Compute the number of occurence of the words
        vol_histogram = histogram(knn_idxs, nb_words);
        norm_histogram = vol_histogram.Data ./ sum(vol_histogram.Data);
        % Concatenate with the other training histograms
        testing_histogram = [testing_histogram; norm_histogram];
    end
    testing_data = testing_histogram;

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

save(strcat(store_directory, ['predicition_hog_pca_', classifier_name, '.mat']), 'pred_label_cv');

end

%delete(poolobj);
