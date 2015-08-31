function resized = vigraResize2(original)
% function resized = vigraResize2(original)
% function resized = vigraResize2(original, newShape)
% function resized = vigraResize2(original, newShape, options)
% 
% D = vigraResize2(inputImage)   # resizes original image data with default options.
% D = vigraResize2(inputImage, [200 300], options)  # does the same with user options.
% 
%     original    - Array with original 2D image data
%                     (gray scale or multi-band/RGB, numeric type)
%     newShape    - standard Array of length 2 that gives the new shape
%                     (default: 2*size(original)-1 )
%     options
%         splineOrder - order of interpolation
%             (0 <= splineOrder <= 5, default: 3, i.e. cubic splines)
%             this option is only used for method 'BSpline'
%         method - 'BSpline' (default), 'Coscot' or 'Catmull'
% 
  error('mex-file missing. Call buildVigraExtensions(INSTALL_PATH) to create it.')