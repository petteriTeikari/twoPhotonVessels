function labels = vigraPredictLabelsRF(RF, features)
% function labels = vigraPredictLabelsRF(RF, features)
% 
% Use a previously trained random forest classifier to predict labels for the given data
%     RF        - MATLAB cell array representing the random forest classifier
%     features  - M x N matrix, where M is the number of samples, N the number of features
% 
%     labels    - M x 1 matrix holding the predicted labels
% 
% 
  error('mex-file missing. Call buildVigraExtensions(INSTALL_PATH) to create it.')