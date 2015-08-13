function analysis = analyzeMeshMorphology(reconstruction, options, visualizeOn)

    %% INPUT CHECKING

        if nargin == 0
            % load('./debugMATs/testMorphology.mat')        
        else
            % save('./debugMATs/testMorphology.mat')    
        end
        
        analysis = [];
        %  reconstruction = 
        % 
        %          faces: [57400x3 double]
        %       vertices: [29408x3 double]
        %     meshOnDisk: [1x89 char]
        
        disp(' - Analyze the 3D Morphology, e.g. vessel diameters (dummy)')
    
    %% ANALYSIS
    
        % see e.g. Fig. 3. of Lindvere et al. (2013), http://dx.doi.org/10.1016/j.neuroimage.2013.01.011
        % or Figs 4.2-4 from http://adm.irbbarcelona.org/image-j-fiji

        % GET SDF Values
        diameterVals = analyze_getSDFvalues(reconstruction.meshOnDisk, options);
    
        % Visualize the mesh with the SDF values
        plotType = 'SDF';
        visualize_meshWithColormap(reconstruction.faces, reconstruction.vertices, diameterVals, plotType, options);        
            % something like this
   