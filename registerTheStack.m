function regReconstruction = registerTheStack(reconstruction, options)

    disp('3D Registration of the reconstructed 3D image (dummy)')
    regReconstruction = reconstruction;
    
    % See the PDF for details
    
    % Easier to register probably the reconstructed vessels rather than
    % trying to register directly the stacks to other timepoint-stacks
    
    % There are more algorithms now available (and more code) for 3D
    % registering of mesh-data for example (or point clouds) rather than
    % the voxelized data (which we could register as well though)