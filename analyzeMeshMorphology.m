function analysis = analyzeMeshMorphology(reconstruction, options, visualizeOn)

    %% INPUT CHECKING

        if nargin == 0
            % load('./debugMATs/testMorphology.mat')        
        else
            % save('./debugMATs/testMorphology.mat')    
        end
        
        
        %  reconstruction = 
        % 
        %          faces: [57400x3 double]
        %       vertices: [29408x3 double]
        %     meshOnDisk: [1x89 char]
    
    %% ANALYSIS
    
        % see e.g. Fig. 3. of Lindvere et al. (2013), http://dx.doi.org/10.1016/j.neuroimage.2013.01.011
        % or Figs 4.2-4 from http://adm.irbbarcelona.org/image-j-fiji

        % GET SDF Values
        [analysis.SDF_diameterVals, analysis.SDF_segmentIDs] = analyze_getSDFvalues(reconstruction.meshOnDisk, plotOn, options);
    
        % Visualize the mesh with the SDF values
        plotType = 'SDF';
        visualize_meshWithColormap(reconstruction.faces, reconstruction.vertices, analysis.SDF_diameterVals, plotType, options)
   
