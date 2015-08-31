function D = vigraDistance(inputArray)
% function D = vigraDistance(inputArray)
% function D = vigraDistance(inputArray, options);
% 
% D = vigraDistance(inputArray) computes the distance transform using the default options.
% D = vigraDistance(inputImage, options)  does the same with user options.
% 
% inputArray  - a 2D or 3D array of numeric type
% options     - a struct with the following possible fields (default will be used
%               if field is not present)
%     'method':          'MULT'(default), 'MULT_SQUARED', 'IMAG_DIST_TRANS'
%                        MULT and MULT_SQUARED are the faster and newer distance transform
%                        methods defined with VIGRA-Multiarrays (vigra::seperableMultiDist....).
%                        MULT_SQUARED returns the squared values of MULT.
%                        IMAG_DIST_TRANS is defined with BasicImage (vigra::distanceTransform) and
%                        less accurate. Use it only if you explicitely need the 'backgroundValue'
%                        or 'norm' options.
%     'backgroundValue': 0 (default) , arbitrary value (only supported by IMAG_DIST_TRANS)
%                        This option defines the background value. In MULT and MULT_SQUARED, the
%                        'backgroundValue' is always 0, but see option 'backgroundMode'.
%     'backgroundMode':  0 , 1 (default) , 2:
%                        This option is only used with methods MULT and MULT_SQUARED.
%                        In method IMAG_DIST_TRANS, the distance of background points
%                          (according to 'backgroundValue' above) to the nearest
%                          non-background is computed.
%                        If 'backgroundMode' is 1, then the (squared) distance of all background
%                          points to the nearest object is calculated.
%                        If 'backgroundMode' is 0, the (squared) distance of all object
%                          points to the nearest background is calculated.
%                        If 'backgroundMode' is 2, the signed (squared) distance of all points
%                          to the contour will be calculated, such that negative values are
%                          inside the objects, positive ones in the background. IMAG_DIST_TRANS
%     'norm':            2 (default, Euclidean distance), 1 (L1 distance), 0 (L-infinity distance).
%                        Defines the norm used to calculate the distance.
%                        Only supported by method IMAG_DIST_TRANS
%     'pitch':           2D: [1.0, 1.0] (default), arbitrary int32-Array of length 2.
%                        3D: [1.0, 1.0, 1.0] (default), arbitrary int32-Array of length 3.
%                        Define the pixel distance if data has non-uniform resolution.
%                        Only supported by methods MULT and MULT_SQUARED.
% 
% Usage:
%     opt = struct('method' ,'IMAGE_DIST_TRANS' , 'backgroundValue', 10 , 'norm' , 0);
%     out = vigraDistance(in, opt);
% 
% 
  error('mex-file missing. Call buildVigraExtensions(INSTALL_PATH) to create it.')