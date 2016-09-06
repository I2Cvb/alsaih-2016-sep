Machine Learning Techniques for DME Classification on SD-OCT images
===================================================================

How to use the pipeline?
-------

### Pre-processing pipeline

The follwoing pre-processing routines were applied:

- BM3D denoising,
- Flattening,
- Cropping.

#### Data variables

In the file `pipeline/feature-preprocessing/pipeline_preprocessing.m`, you need to set the following variables:

- `data_directory`: this directory contains the orignal SD-OCT volume. The format used was `.img`.
- `store_directory`: this directory corresponds to the place where the resulting data will be stored. The format used was `.mat`.

#### Algorithm variables

The variables which are not indicated in the inital publication and that can be changed are:

- `x_size`, `y_size`, `z_size`: the original size of the SD-OCT volume. It is needed to open `.img` file.
- `sigma`: the estimate of the standard deviation for the BM3D denoising.
- `h_over_rpe`, `h_under_rpe`, `width_crop`: the different variables driving the cropping.

#### Run the pipeline

From the root directory, launch MATLAB and run:

```
>> run pipeline/feature-preprocessing/pipeline_preprocessing.m
```

### Extraction pipeline

For this pipeline, the following features were extracted:

- HOG,
- LBP with radius set to 8, 16, and 24. Both rotation and non-rotation invariant features were extracted.

#### Data variables

In the file `pipeline/feature-extraction/pipeline_extraction_***.m`, you need to set the following variables:

- `data_directory`: this directory contains the pre-processed SD-OCT volume. The format used was `.mat`.
- `store_directory`: this directory corresponds to the place where the resulting data will be stored. The format used was `.mat`.

#### Run the pipeline

From the root directory, launch MATLAB and run:

```
>> run pipeline/feature-extraction/pipeline_extraction_hog.m
>> run pipeline/feature-extraction/pipeline_extraction_lbp_8_ri.m
>> run pipeline/feature-extraction/pipeline_extraction_lbp_16_ri.m
>> run pipeline/feature-extraction/pipeline_extraction_lbp_24_ri.m
>> run pipeline/feature-extraction/pipeline_extraction_lbp_8_nri.m
>> run pipeline/feature-extraction/pipeline_extraction_lbp_16_nri.m
>> run pipeline/feature-extraction/pipeline_extraction_lbp_24_nri.m
```

### Classification pipeline

The method for classification used was:

- Random Forest,
- Linear SVM,
- RBF-SVM.

#### Data variables

In the file `pipeline/feature-classifier/_***.m`, you need to set the following variables:

- `data_directory`: this directory contains the feature extracted from the SD-OCT volumes. The format used was `.mat`.
- `store_directory`: this directory corresponds to the place where the resulting data will be stored. The format used was `.mat`.
- `gt_file`: this is the file containing the label for each volume. You will have to make your own strategy.


#### Experiment 1

##### Classification of individual features

Move to the folder `pipeline/feature-classification/experiment-1/individual/`

The classifier name needs to be set with either `linear_svm`, `rbf_svm`, or `random_forest`.

From the root directory, launch MATLAB and run:

```
>> classifier_name = 'random_forest';
>> pipeline_classification_hog(classifier_name)
>> pipeline_classification_lbp_8_ri(classifier_name)
>> pipeline_classification_lbp_16_ri(classifier_name)
>> pipeline_classification_lbp_24_ri(classifier_name)
>> pipeline_classification_hog_pca(classifier_name)
>> pipeline_classification_lbp_8_ri_pca(classifier_name)
>> pipeline_classification_lbp_16_ri_pca(classifier_name)
>> pipeline_classification_lbp_24_ri_pca(classifier_name)
```

##### Classification of combined features

Move to the folder `pipeline/feature-classification/experiment-1/combination/`

The classifier name needs to be set with either `linear_svm`, `rbf_svm`, or `random_forest`.

From the root directory, launch MATLAB and run:

```
>> classifier_name = 'random_forest';
>> pipeline_classification_hog_lbp_8_ri_pca(classifier_name)
>> pipeline_classification_hog_lbp_16_ri_pca(classifier_name)
>> pipeline_classification_hog_lbp_24_ri_pca(classifier_name)
```

#### Experiment 2

Move to the folder `pipeline/feature-classification/experiment-2/`

The classifier name needs to be set with either `linear_svm`, `rbf_svm`, or `random_forest`.
The number of visual words need also to be set.

From the root directory, launch MATLAB and run:

```
>> nb_words = 30;
>> classifier_name = 'random_forest';
>> pipeline_classification_hog_pca(classifier_name, nb_words)
>> pipeline_classification_lbp_8_ri_pca(classifier_name, nb_words)
>> pipeline_classification_lbp_16_ri_pca(classifier_name, nb_words)
>> pipeline_classification_lbp_24_ri_pca(classifier_name, nb_words)
```

#### Run the pipeline

From the root directory, launch MATLAB and run:

```
>> run pipeline/feature-classification/pipeline_classifier_pca_hog.m
>> run pipeline/feature-classification/pipeline_classifier_pca_hog_lbp_8_16_24_ri.m
>> run pipeline/feature-classification/pipeline_classifier_pca_hog_lbp_8_16_24_nri.m
```

### Validation pipeline

#### Data variables

In the file `pipeline/feature-validation/pipeline_validation_***.m`, you need to set the following variables:

- `data_directory`: this directory contains the validation results. The format used was `.mat`.
- `gt_file`: this is the file containing the label for each volume. You will have to make your own strategy.

#### Experiment 1

##### Validation of individual features

Move to the folder `pipeline/feature-validation/experiment-1/individual/`

The classifier name needs to be set with either `linear_svm`, `rbf_svm`, or `random_forest`.

From the root directory, launch MATLAB and run:

```
>> classifier_name = 'random_forest'
>> pipeline_validation_hog(classifier_name)
>> pipeline_validation_lbp_8_ri(classifier_name)
>> pipeline_validation_lbp_16_ri(classifier_name)
>> pipeline_validation_lbp_24_ri(classifier_name)
>> pipeline_validation_hog_pca(classifier_name)
>> pipeline_validation_lbp_8_ri_pca(classifier_name)
>> pipeline_validation_lbp_16_ri_pca(classifier_name)
>> pipeline_validation_lbp_24_ri_pca(classifier_name)
```

##### Validation of combined features

Move to the folder `pipeline/feature-validation/experiment-1/combination/`

The classifier name needs to be set with either `linear_svm`, `rbf_svm`, or `random_forest`.

From the root directory, launch MATLAB and run:

```
>> classifier_name = 'random_forest'
>> pipeline_validation_hog_lbp_8_ri_pca(classifier_name)
>> pipeline_validation_hog_lbp_16_ri_pca(classifier_name)
>> pipeline_validation_hog_lbp_24_ri_pca(classifier_name)
```

#### Experiment 2

Move to the folder `pipeline/feature-validation/experiment-2/`

The classifier name needs to be set with either `linear_svm`, `rbf_svm`, or `random_forest`.

From the root directory, launch MATLAB and run:

```
>> classifier_name = 'random_forest'
>> pipeline_validation_hog_pca(classifier_name)
>> pipeline_validation_lbp_8_ri_pca(classifier_name)
>> pipeline_validation_lbp_16_ri_pca(classifier_name)
>> pipeline_validation_lbp_24_ri_pca(classifier_name)
```
