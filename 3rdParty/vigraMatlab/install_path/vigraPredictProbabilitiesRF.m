function probs = vigraPredictProbabilitiesRF(RF, features)
% function probs = vigraPredictProbabilitiesRF(RF, features)
% 
% Use a previously trained random forest classifier to predict labels for the given data
%     RF        - MATLAB cell array representing the random forest classifier
%     features  - M x N matrix, where M is the number of samples, N the number of features
% 
%     probs     - M x L matrix holding the predicted probabilities for each of
%                 the L possible labels
% 
  error('mex-file missing. Call buildVigraExtensions(INSTALL_PATH) to create it.')