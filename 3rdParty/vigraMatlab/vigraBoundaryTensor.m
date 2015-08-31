function out = vigraBoundaryTensor(inputImage)
% function out = vigraBoundaryTensor(inputImage)
% function out = vigraBoundaryTensor(inputImage, scale);
% 
% inputImage - 2D scalar input array
% scale      - 1.0 (default), a positive floating point scale
%              parameter for boundary tensor computation
%              
% out        - output boundary tensor image
%              the first dimension holds the boundary tensor entries
%                  B11(y,x) = out(1,y,x)
%                  B21(y,x) = B12(y,x) = out(2,y,x)
%                  B22(y,x) = out(3,y,x)
% 
% Usage:
%     out = vigraBoundaryTensor(in, 2.0);
% 
  error('mex-file missing. Call buildVigraExtensions(INSTALL_PATH) to create it.')