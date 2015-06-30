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
    % https://www.openmicroscopy.org/site/support/bio-formats5.1/developers/matlab-dev.html
    if nargin == 0
        
        % use local test files for development
        fileName = 'CP-20150323-TR70-mouse2-1-son.oib';
        path = '/home/petteri/Desktop/testPM/';
        
        % fileName = 'CP-20150616-TR70-mouse1-scan8-son2_subset_noLeakage.ome.tif';
        % path = 'data';
        
        tiffPath = path; % use same now
        options.pathBigFiles = path; % don't save all the big files to Dropbox
        options.batchFlag = false;
        options.denoiseOnly = false; % just denoise, and save to disk, useful for overnight pre-batch processing
        
        % debug/development flag to speed up the development, for actual
        % processing of files, put all to false
        options.useOnlyFirstTimePoint = true;
        options.useOnlySubsetOfStack = true;
        options.resizeStacks2D = true;
        options.skipImportBioFormats = false;
        
    else
        % function called from outside, like with a dialog to open the
        % files, or batch processing multiple OIB or something
    end
    
    
    %% IMPORT THE FILE    
               
        if ~options.skipImportBioFormats
            % Import from the Olympus Fluoview file (OIB) using the Bio-Formats
            options.loadFromTIFF = false; % loading directly from the denoised OME-TIFF (if found)
            [data, imageStack, metadata, options] = importMicroscopyFile(fileName, path, tiffPath, options); 
            
            % note that now not necessarily the same as in the input image
            % imported as we have might tossed away a lot of data in order
            % to make the development faster
            options.noOfChannels = length(imageStack);
            options.noOfTimePoints = length(imageStack{1});
            save(fullfile('debugMATs', 'importTemp.mat'), 'imageStack', 'options') % devel/debug MAT
        else
            disp('Skipping OIB import, load directly from MAT (Faster)')
            load(fullfile('debugMATs', 'importTemp.mat')) % devel/debug MAT
        end
        
        
            
    %% IMAGE DENOISING
    
        % i.e. denoising / anisotropic diffusion for reducing noise            
        if options.loadFromTIFF
            disp('Denoising already done for the OME-TIFF, skipping denoising');
        else            
            options.denoisingCycleSpins = 4;
            options.denoisingMultiframe = 3;
            options.denoisingAlgorithm = 'PureDenoise';
            % options.denoisingAlgorithm = 'NLMeansPoisson';
            % options.denoisingAlgorithm = 'GuidedFilter';
            
            ch = 1; % not the same processing for all the channels anyway
            for t = 1 : options.noOfTimePoints
                denoisedImageStack{ch}{t} = denoiseMicroscopyImage(imageStack{ch}{t}(:,:,:), [], options); 
            end            
            
            % TODO: Maybe decide later whether it is better to pass 3D
            %       matrices to all the functions here or pass the whole
            %       "5D cell" and parse it inside.
            
            fileOut = fullfile('/home/petteri/Desktop', ['testOutput', options.denoisingAlgorithm, '_Denoised.tif']);
            export_stack_toDisk(fileOut, imageStack{ch}{t}) 
        end
        
        % Stop here if you only want the denoising to be done.
        % The basic idea of this flag was to batch denoise a lot of images
        % if the denoising is very time-consuming. Whether this is needed
        % really in the end depends on the denoising method chosen (if any,
        % for example with Vesselness Enhancing Diffusion, VED)
        if options.denoiseOnly
            return
        end
        
    %% IMAGE DECONVOLUTION?
    
        % Needed?
        
        
    %% IMAGE ENHANCEMENT    
    
        % i.e. vesselness filter such as Frangi vesselness filter or
        % Optimally Oriented Flux (OOF) filter, or OOF-OFA filter        
        options.vesselAlgorithm = 'OOF'; % e.g. 'OOF', 'OOF-OFA', 'MDOF', 'VED'
        options.scales = [1 6]; % same for OOF now
        options.scaleStep = 0.5;      
        
        ch = 1; % not the same processing for all the channels anyway
        for t = 1 : options.noOfTimePoints
            tubularity{ch}{t}.(options.vesselAlgorithm) = vesselnessFilter(denoisedImageStack{ch}{t}(:,:,:), options);
        end
            
        % DISPLAY
        if ~options.batchFlag
            disp(['Visualize Vesselness with and without denoising ({',num2str(ch),'}{',num2str(t),'} fixed)'])
            visualize_vesselnessWithDenoising(imageStack{ch}{t}, tubularity{ch}{t}, denoisedImageStack{ch}{t}, options.denoisingAlgorithm, options.vesselAlgorithm, options)
        end       
        
        
    
    %% VESSEL SEGMENTATION    
    
        % i.e. to separate the image stack to two compartments:
        % 1) intravascular compartment
        % 2) extravascular compartment ("fluorescent signal due to BBB
        %                                disruption)
            
        % use a subset of the stack as well for speeding up the testing
        ch = 1; % not the same processing for all the channels anyway
        for t = 1 : options.noOfTimePoints
            segmentation{ch}{t} = segmentVessels(denoisedImageStack{ch}{t}(:,:,:), tubularity{ch}{t}, options);
        end
        
            % Depending on the vessel segmentation to be done, one could
            % add here a possibility to add manually defined masks for
            % "ground truth" backgrounds and foregrounds, or simple aid
            % points for tricky segmentations so that the masks are added
            % only once and do not require user intervention every time the
            % script is run


    %% RECONSTRUCT
    
        ch = 1; % not the same processing for all the channels anyway
        for t = 1 : options.noOfTimePoints
            reconstruction{ch}{t} = reconstructSegmentation(segmentation{ch}{t}(:,:,:), options);
        end
    
    
    %% REGISTER the RECONSTRUCTION
    
        ch = 1; % not the same processing for all the channels anyway
        for t = 1 : options.noOfTimePoints
            regReconstruction{ch}{t} = registerTheStack(reconstruction{ch}{t}(:,:,:), options);
        end
        
        
    %% ANALYSIS    
    
        % i.e. quantify the BBB disruption, compute the permeability
        % coefficient P(t), e.g. from Dreher et al. (2006)
        % http://dx.doi.org/10.1093/jnci/djj070
        
        % Measure also vesser diameter, and quantify the leakage dynamics
        % which were previously done manually using ImageJ (see 2.4 of
        % Burgess et al. 2014, http://dx.doi.org/10.1148/radiol.14140245)
        
        ch = 1; % not the same processing for all the channels anyway
        for t = 1 : options.noOfTimePoints
            analysis{ch}{t} = analyzeSegmentedImage(regReconstruction{ch}{t}, segmentation{ch}{t}, denoisedImageStack{ch}{t}, options);
        end
        
        
    %% EXPORT
    
        % Save to various formats if you need to work on the data with some
        % 3rd party software. For example .stl if you want to do a nicer
        % rendering of the 3D structure for example using Rhinoceros 3D
        % with Brazil/Keyshot/etc. renderer
        exportTheResults(metadata, analysis, regReconstruction, options)
    
            