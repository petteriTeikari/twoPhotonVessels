function D = vigraRadialSymmetry(inputImage)
% function D = vigraRadialSymmetry(inputImage)
% function D = vigraradialSymmetry(inputImage, options);
% 
% D = vigraRadialSymmetry(inputImage) computes the Fast Radial Symmetry Transform
%             using default options, see vigra::RadialSymmetryTransform for more information.
% D = vigraRadialSymmetry(inputImage, options)  does the same with user options.
% 
% inputImage - 2D input array
% options    - a struct with following possible fields:
%     'scale':    1.0 (default), any positive floating point value
%                 scale parameter for the vigraRadialSymmetry
% 
% 
% Usage:
%     opt = struct('method' ,value);
%     out = vigraRadialSymmetry(in, opt);
% 
% 
  error('mex-file missing. Call buildVigraExtensions(INSTALL_PATH) to create it.')