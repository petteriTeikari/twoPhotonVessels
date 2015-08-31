function L = vigraWatershed(inputArray)
% function L = vigraWatershed(inputArray)
% function L = vigraWatershed(inputArray, options);
% 
% L = vigraWatershed(inputArray);
%         Uses the union find algorithm to compute a label matrix identifying
%         the watershed regions of the inputArray (which may be 2 or 3 dimensional).
%         The elements of L are Int32 values greater than 0. Boundaries are
%         represented by crack edges, i.e. there are no explicit watershed pixels.
% 
% options = struct('seeds', seedImage, 'crack' = 'keepContours');
% L = vigraWatershed(inputImage, options);
%         Uses seeded region growing to compute a label matrix identifying
%         the watershed regions of the inputArray (which may be 2 or 3 dimensional).
%         The elements of L are Int32 values greater than 0. Boundaries are
%         represented by explicit watershed pixels, i.e. there is a one-pixel
%         thick boundary between every pair of regions.
% 
% inputArray - a 2D or 3D array of type 'single' or 'double'
% 
% options    - is a struct with the following possible fields
%     'seeds':    An Array of same size as inputArray. If supplied, seeded region growing
%                 shall be used. If not, the union find algorithm will be used. As of now,
%                 the seed array has to be of same type as the input array - this will be changed in the next update.
%     'conn':     2D: 4 (default),  8 (only supported by the union find algorithm)
%                 3D: 6 (default), 26 (only supported by the union find algorithm)
%                 While using seeded region growing, only the default values can be used.
%     'crack':    'completeGrow' (default), 'keepContours' (only supported by seeded region growing and 2D Images)
%                 Choose whether to keep watershed pixels or not. While using union find,
%                 only the default value can be used.
%     'CostThreshold':  -1.0 (default) - any double value.
%                 If, at any point in the algorithm, the cost of the current candidate exceeds the optional
%                 max_cost value (which defaults to -1), region growing is aborted, and all voxels not yet
%                 assigned to a region remain unlabeled.
% Usage:
%     opt = struct('fieldname' ,'value',....);
%     out = vigraWatershed(in, opt);
% 
  error('mex-file missing. Call buildVigraExtensions(INSTALL_PATH) to create it.')