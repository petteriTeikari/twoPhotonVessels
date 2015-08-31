function dense_lsq = vigraLeastAngleRegression(A, b)
% function dense_lsq = vigraLeastAngleRegression(A, b)
% function dense_lsq = vigraLeastAngleRegression(A, b, options);
% function [dense_lsq dense_lasso] = vigraLeastAngleRegression(...);
% 
% Solves Equations of Type A*x = b using L1 regularisation
% The columns of dense_lsq are the least squares Solutions in the
%     (iterations?) of the Lasso
% Columns of dense_lasso are...
% 
% options    - a struct with following possible fields:
%     'mode':    default 'lasso', nnlasso (non negative lasso), lars (least angle regression)
%     'max_solution_count':   default: Unused, Integral value > 0
% 
% 
% 
  error('mex-file missing. Call buildVigraExtensions(INSTALL_PATH) to create it.')