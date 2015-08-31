function rf = vigraImporthdf5RF( filename, groupname);
% function rf = vigraImporthdf5RF( filename, groupname);
% 
% Import a previously trained Random Forest from  a hdf5 file
% 
%     rf        - MATLAB cell array representing the random forest classifier
%    filename  - name of hdf5 file
% 
%    groupname    - optional: name of group which shoud be used as the base
%                     path
% 
% to compile on Linux:
% --------------------
%   mex vigraImporthdf5RF.cpp -I../../include -lhdf5 -lhdf5_hl
% 
% to compile on Windows:
% ----------------------
%   mex vigraImporthdf5RF.cpp -I../../include -I[HDF5PATH]/include -L[HDF5PATH]/lib -lhdf5dll -lhdf5_hldll -D_HDF5USEDLL_ -DHDF5CPP_USEDLL
% 
% hdf5 1.6.x or hdf5 1.8.x must be installed. 
% 
  error('mex-file missing. Call buildVigraExtensions(INSTALL_PATH) to create it.')