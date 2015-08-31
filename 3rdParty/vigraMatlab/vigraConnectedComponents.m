function D = vigraConnectedComponents(inputArray)
% function D = vigraConnectedComponents(inputArray)
% function D = vigraConnectedComponents(inputArray, options);
% 
% D = vigraConnectedComponents(inputArray) performs connected components labeling
%         using the default options.
% D = vigraConnectedComponents(inputImage, options)  does the same with user options.
% 
% inputArray - a 2D or 3D array of numeric type
% 
% options    - is a struct with the following possible fields:
%     'conn':            The neighborhood to be used
%                        2D: 4 (default) or  8
%                        3D: 6 (default) or 26
%     'backgroundValue': Specify the value of a background region not to be labeled (will be labeled 0
%                        in the result array, even when it doesn't form a single connected component).
%                        If this option in not present, the entire image/volume will be labeled.
% 
% Usage:
%     opt = struct('conn', 8);
%     out = vigraConnectedComponents(in, opt);
% 
% 
  error('mex-file missing. Call buildVigraExtensions(INSTALL_PATH) to create it.')