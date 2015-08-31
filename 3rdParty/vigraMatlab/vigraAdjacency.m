function D = vigraAdjacency(inputArray)
% function D = vigraAdjacency(inputArray)
% function D = vigraAdjacency(inputArray, options);
% 
% D = vigraAdjacency(inputArray) computes the Adjacencymatrix of Label images.
% D = vigraAdjacency(inputImage, options)  does the same with user options.
% options is a struct with possible fields: "hasWatershedPixel"
% 
% D               is a sparse matrix of size max_region_label x max_region_label.
%                 The entries in D correlate to the length of region borders.
%                 (Images with and without watershedPixels return different values)
% inputArray          must be a Image or a Volume with regions labeled with positive whole numbers
%                 0 denotes watershed Pixels.
% hasWatershedPixel:  it is advised to set this attribute. Otherwise the Function searches for 0 in the
%                 image.
% 
% Usage:
%     opt = struct('method' ,value);
%     out = vigraAdjacency(in, opt);
% 
% 
  error('mex-file missing. Call buildVigraExtensions(INSTALL_PATH) to create it.')