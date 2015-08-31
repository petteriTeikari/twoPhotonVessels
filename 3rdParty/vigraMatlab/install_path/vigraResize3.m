function resized = vigraResize3(original)
% function resized = vigraResize3(original)
% function resized = vigraResize3(original, newShape)
% function resized = vigraResize3(original, newShape, options)
% 
% D = vigraResize3(inputVolume)   # resizes original volume data with default options.
% D = vigraResize3(inputVolume, [200 300 100], options)  # does the same with user options.
% 
%     original    - Array with original 3D volume data
%                     (gray scale or multi-band/RGB, numeric type)
%     newShape    - Array of length 3 that gives the new shape
%                     (default: 2*size(original)-1 )
%     options
%         splineOrder - order of interpolation
%             (0 <= splineOrder <= 5, default: 3, i.e. cubic splines)
%             this option is only used for method 'BSpline'
%         method - 'BSpline' (default) or 'Catmull'
% 
  error('mex-file missing. Call buildVigraExtensions(INSTALL_PATH) to create it.')