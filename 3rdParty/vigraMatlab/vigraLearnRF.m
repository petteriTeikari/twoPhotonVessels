function RF = vigraLearnRF(features, labels) Trains a randomForest with Default TreeCount and options
% function RF = vigraLearnRF(features, labels) Trains a randomForest with Default TreeCount and options
% function RF = vigraLearnRF(features, labels, treeCount)  does the same treeCount number of trees and default options.
% function RF = vigraLearnRF(features, labels, treeCount, options)  does the same with user options.
% function [RF oob] = vigraLearnRF(...)                Outputs the oob error estimate
% function [RF oob var_imp] = vigraLearnRF(...)       Outputs variable importance.
% 
% features    - A Nxp Matrix with N samples containing p features
% labels      - A Nx1 Matrix with the corresponding Training labels
% treeCount   - default: 255. An Integral Scalar Value > 0 - Number of Trees to be used in the Random Forest.
% options     - a struct with the following possible fields (default will be used
%               if field is not present)
%     'sample_with_replacement'       logical, default : true
%     'sample_classes_individually'   logical, default : false
%     'min_split_node_size'           Scalar, default: 1.0 - controls size pruning of the tree while training.
%     'mtry'                          Scalar or String, 
%                                     default: floor(sqrt(number of features)) ('RF_SQRT')
%                                     if a Scalar value is specified it is taken as the 
%                                     absolute value. Otherwise use one of the Tokens
%                                     'RF_SQRT', 'RF_LOG' or 'RF_ALL'
% 
%     'training_set_size'             Scalar, default: Not used
%     'training_set_proportion'       Scalar, default: 1.0
%                                     The last two options exclude each other. if training_set_size always overrides
%                                     training_set_proportional, if set.
%                                     Controls the number of samples drawn to train an individual tree.
%     'weights'
%                                     Array containing training weights for each class. The size of the array is
%                                     not checked so you may get wierd errors if you do not enforce the size constraints.
% var_imp     - A FeatureCount x ClassCount +2 Matrix. 
%                                     The last column is the variable importance based on mean decrease in impurity
%                                     over all trees the end -1 column is the permutation based variable importance
%                                     Columns 1 - ClassCount are the class wise permutation based variable importance
%                                     scores.
% 
% //not yet supported
% oob_data    - A NxNumberOfTrees Matrix. oob_data(i, j) = 0 if ith sample was not in the test set for the jth tree
%                                                        = 1 if ith sample was correctly classified in jth tree
%                                                        = 2 if ith sample was misclassified int jth tree
% 
  error('mex-file missing. Call buildVigraExtensions(INSTALL_PATH) to create it.')