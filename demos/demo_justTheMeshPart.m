function demo_justTheMeshPart()

    % Some settings needed, that would have been otherwise set before
    % running these parts
    fileName = mfilename; fullPath = mfilename('fullpath');
    pathCode = strrep(fullPath, fileName, ''); cd(pathCode)
    options.pathCode = pathCode;
    
    options.tP = [1]; t = 1; ch = 1;
    options.pathBigFiles = options.pathCode; % outside Dropbox
    options.segmentationAlgorithm = 'asets_levelSets';
    
    % load actual data
    filePath = fullfile('segmentationDemo', 'testData');
    fileName = 'segmentation_asets_levelSets_ch1_t1_regionMaskOnly.mat';
    fullFile = fullfile(filePath, fileName);
    load(fullFile)
    

    %% RECONSTRUCT MESH
    
        options.reconstructionAlgorithm = 'marchingCubes';
        options.reconstructionIsovalue = 0.01;
        
        reconstruction = reconstructMeshFromSegmentation(mask, options.pathBigFiles, ...
                options.segmentationAlgorithm, options.reconstructionAlgorithm, options.reconstructionIsovalue, options, options.tP(t), ch);
        
    
    %% FILTER THE MESH RECONSTRUCTION
    
        % probably needed? - simplification - downsampling - smoothing        
        operations = {'repair'; 'simplification'; 'smoothing'}; 
        
        for o = 1 : length(operations)
            % sequential, on top of the previous pass 
            reconstruction = filterReconstructedMesh(reconstruction, operations{o}, options, options.tP(t), ch);
        end
     
                
    %% MORPHOLOGICAL ANALYSIS    
    
        analysis = analyzeMeshMorphology(reconstruction, options);