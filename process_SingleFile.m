function process_SingleFile(path, tiffPath, fileName, options)

    % Dr. Petteri Teikari, 2015, pteikari@sri.utoronto.ca
    % Sunnybrook Research Institute

    % This function describes basically the "workflow" what should be done
    % to each microscopy stack with calls for functions responsible for
    % each processing block

    % This function could be called outside eventually, and could be inside
    % a parfor loop for example
    
    % We have assumed that the channels are independent from each other in
    % terms of analysi (which is a reasonable assumption as the labels most
    % likely label different things, and if this is not the case, we can
    % think of ways to reduce the redundancy then)
    
    % Similarly we assume that the time points are independent from each
    % other (which they are not in stric sense as the vasculature is most
    % likely in the same place more or less). But in terms of analysis we
    % think that they are independent and try to register them after the
    % reconstruction

    % See the introduction to Bio-Formats with Matlab
    % https://www.openmi3croscopy.org/site/support/bio-formats5.1/developers/matlab-dev.html
    if nargin == 0

        % Debug variables when running locally (without input arguments)        
        fileName = mfilename; fullPath = mfilename('fullpath');
        pathCode = strrep(fullPath, fileName, ''); cd(pathCode)
        
        options.noOfCores = 2;
        init_parallelComputing(options.noOfCores)
        
        % use local test files for development
        fileName = 'CP-20150323-TR70-mouse2-1-son.oib';
        path = '/home/petteri/Desktop/testPM';
        
        % fileName = 'CP-20150616-TR70-mouse1-scan8-son2_subset_noLeakage.ome.tif';
        % path = 'data';        
        tiffPath = path; % use same now        
        options.pathBigFiles = fullfile(path,'out'); % don't save all the big files to Dropbox
        options.batchFlag = false;
        options.denoiseOnly = false; % just denoise, and save to disk, useful for overnight pre-batch processing
        
        % debug/development flag to speed up the development, for actual
        % processing of files, put all to false
        options.useOnlyFirstTimePoint = false;
        options.useOnlySubsetOfStack = false;
        options.resizeStacks2D = true;
        options.resize2D_factor = 1 / 16;
        options.skipImportBioFormats = false;
        options.loadFromTIFF = false; % loading directly from the denoised OME-TIFF (if found)
                
        options.manualTimePoints = true;
        options.tP = [4 5]; % manual time point definition
        
        ch = 1; % fixed now, if you had multiple vasculature labels, modify
                % channel behavior
                
        % TODO: Add this later to a .m script and make sure that all the
        %       variables are defined if calling this .m-file from outside for
        %       example

    else
        % function called from outside, like with a dialog to open the
        % files, or batch processing multiple OIB or something
    end
    
    
    %% IMPORT THE FILE    
       
        % Import from the Olympus Fluoview file (OIB) using the Bio-Formats
        [data, imageStack, metadata, options] = importMicroscopyFile(fileName, path, tiffPath, options);        
            
    %% IMAGE DENOISING
            
        options.denoisingAlgorithm = 'GuidedFilter'; % 'NLMeansPoisson'; % 'PureDenoise', 'GuidedFilter'
        
        for t = 1 : length(options.tP)
            [denoisedStack{ch}{options.tP(t)}, timing.denoising(ch,t)] = denoiseMicroscopyImage(imageStack{ch}{options.tP(t)}(:,:,:), options.denoisingAlgorithm, options, t, ch);            
        end
        
        % if you only want denoising, and not the remaining algorithms
        if options.denoiseOnly; return; end        
        
    %% INTRA-IMAGE MOTION COMPENSATION
    
        % Needed?
        % Vinegoni C, Lee S, Feruglio PF, Weissleder R. 2014. Advanced Motion Compensation Methods for Intravital Optical Microscopy. IEEE Journal of Selected Topics in Quantum Electronics 20:83–91. http://dx.doi.org/10.1109/JSTQE.2013.2279314.
        % Soulet D, Paré A, Coste J, Lacroix S. 2013. Automated Filtering of Intrinsic Movement Artifacts during Two-Photon Intravital Microscopy. PLoS ONE 8:e53942. http://dx.doi.org/10.1371/journal.pone.0053942.
        % Greenberg DS, Kerr JND. 2009. Automated correction of fast motion artifacts for two-photon imaging of awake animals. Journal of Neuroscience Methods 176:1–15. http://dx.doi.org/10.1016/j.jneumeth.2008.08.020.
        
    %% IMAGE DECONVOLUTION?
    
        % Needed?        
        
    %% VESSELNESS FILTER
            
        options.vesselAlgorithm = 'OOF_OFA'; % e.g. 'OOF', 'OOF-OFA', 'MDOF', 'VED'
        options.scales = 1:3; % same for all the different filters
        
        for t = 1 : length(options.tP)
            vesselness{ch}{options.tP(t)}.(options.vesselAlgorithm) = vesselnessFilter(denoisedStack{ch}{options.tP(t)}(:,:,:), options.vesselAlgorithm, options.scales, options, t, ch);
        end        
    
    %% VESSEL SEGMENTATION    
    
        % Binary segmentation (intravascular and extravascular space)        
        options.segmentationAlgorithm = 'asets_levelSets'; % or 'maxFlow_JingYuan'
            % now there are bunch of parameters for the segmentation!
        
        for t = 1 : length(options.tP)
            [segmentationStack{ch}{options.tP(t)}, segmentationMask{ch}{options.tP(t)}] = segmentVessels(denoisedStack{ch}{options.tP(t)}(:,:,:), ...
                                    vesselness{ch}{options.tP(t)}.(options.vesselAlgorithm).data(:,:,:), options.segmentationAlgorithm, options, t, ch);
        end
        close all
        

    %% RECONSTRUCT MESH
    
        options.reconstructionAlgorithm = 'marchingCubes';
        options.reconstructionIsovalue = 0.01;
    
        for t = 1 : length(options.tP)           
            reconstruction{ch}{options.tP(t)} = reconstructMeshFromSegmentation(segmentationMask{ch}{options.tP(t)}, options.pathBigFiles, ...
                options.segmentationAlgorithm, options.reconstructionAlgorithm, options.reconstructionIsovalue, options, t, ch);
        end
    
    %% FILTER THE MESH RECONSTRUCTION
    
        % probably needed? - simplification - downsampling - smoothing        
        operations = {'simplification'; 'smoothing'}; % sequential, on top of previous
        
        for o = 1 : length(operations)
            for t = 1 : length(options.tP)           
                reconstruction{ch}{options.tP(t)} = filterReconstructedMesh(reconstruction{ch}{options.tP(t)}, operations{o}, options, t, ch);
            end
        end        
        
    %% EXTRACT THE CENTERLINE ("SKELETONIZE")
    
        options.centerlineAlgorithm = 'parallelMedialAxisThinning'; % or 'fastMarchingKroon'
        
        for t = 1 : length(options.tP)           
            centerline{ch}{options.tP(t)} = extractCenterline(reconstruction{ch}{options.tP(t)}, segmentationMask{ch}{options.tP(t)}(:,:,:), options.centerlineAlgorithm, options, t, ch);
        end
        close all
        
    %% REGISTER the RECONSTRUCTION
    
        % use the first time point as the model now     
        options.registerModelIndex = 1; % the remaining ones are registered to this   
        options.registrationAlgorithm = 'ICP';
        modelMesh = reconstruction{ch}{options.tP(options.registerModelIndex)};
        
        for t = 1 : length(options.tP)
            [regReconstruction{ch}{options.tP(t)}, transformMatrix{ch}{options.tP(t)}] = registerTheMeshes(modelMesh, reconstruction{ch}{options.tP(t)}, ...
                        options.registrationAlgorithm, options.registerModelIndex, options.tP, options, t, ch);
        end
        
    %% FLUORESCENCE ANALAYSIS
    
        % e.g. fluorescence difference (intra vs. extravascular space)
        
        
    %% MORPHOLOGICAL ANALYSIS    
    
        % Vesser diameter, volume, stenonis, etc.
        for t = 1 : length(options.tP)
            analysis{ch}{options.tP(t)} = analyzeSegmentedImage(regReconstruction{ch}{options.tP(t)}, segmentation{ch}{options.tP(t)}, denoisedImageStack{ch}{options.tP(t)}, options);
        end        
        
        
    %% EXPORT
    
        % Save to various formats if you need to work on the data with some
        % 3rd party software. For example .stl if you want to do a nicer
        % rendering of the 3D structure for example using Rhinoceros 3D
        % with Brazil/Keyshot/etc. renderer
        exportTheResults(metadata, analysis, regReconstruction, options)
    
            