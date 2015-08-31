function D = vigraCorner(inputImage)
% function D = vigraCorner(inputImage)
% function D = vigraCorner(inputImage, options);
% 
% D = vigraCorner(inputArray) does Corner detection.
% D = vigraCorner(inputImage, options)  does the same with user options.
% 
% inputImage - 2D input array
% options    - struct with following possible fields:
%    'method':  'Corner' (default, corenr response function according to Harris), 'Beaudet', 'Foerstner', 'Rohr'
%               Use corresponding method to detect corners (see vigra reference for more details).
%    'scale':   1.0 (default), any positive floating point value
%               scale parameter for corner feature computation
% 
% Usage:
%     opt = struct('method' ,value);
%     out = vigraCorner(in, opt);
% 
% 
  error('mex-file missing. Call buildVigraExtensions(INSTALL_PATH) to create it.')