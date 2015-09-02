function train_fromOIB_macro()

    pathInputFolder = '/home/petteri/Desktop/marc2PMtrain/2';        
    ch = 2; % ch index for vessel data
    tp = 1; % time point(s) used
    pathResults = '/home/petteri/learningFilterData';
    
    fileName = mfilename; fullPath = mfilename('fullpath');
    pathCode = strrep(fullPath, fileName, '');
    if ~isempty(pathCode); cd(pathCode); end
    
    convertOIB_to_NRRD = false;

    
    %% Convert OIB -> NRRD with Denoising (BM4D) and ICA channel separation
    
        if convertOIB_to_NRRD
            justTheVessels = true;
            applyICAseparation = true;
            convert_OIBfolderToNRRD(pathInputFolder, ch, tp, justTheVessels, applyICAseparation)
        end
    
    %% Plot the input
    
        if(exist('learnPath','var')==0); learnPath = fullfile(pathResults, 'filterLearnConv'); end
        if(exist('folderPath','var')==0); folderPath = fullfile(learnPath, 'datasets'); end

        asMIP = true; sliceToPlot = []; nameString = 'deg*.nrrd';
        %visualize_folderOfStacks(folderPath, nameString, asMIP, sliceToPlot)    
    
    %% Learn Filters (The non-separable filter bank, "Dictionary"
    
        maxIterConv = 18000;        
        resume_fb_conv = 0;
        paramConv.iterations_no = 1000; % Number of iterations before dumping the results
        
        % give whatever number of these, if not specified (or commented
        % away), the default value in "get_config_convLearn3D.m" is used
        paramConv.size_patch = [16,16,16]; %size of random patch
        paramConv.filters_no = 144; % Number of filters in the filter bank
        paramConv.filters_size = [13,13,13]; % Filter's size
        paramConv.ISTA_steps_no = 3; % Number of ISTA steps on the coefficients
        paramConv.gd_step_size_fm = 1e-1; % Gradient step size for the feature maps        
        paramConv.lambda_l1 = 2e-2; % Regularization's parameter
        
        % PT added
        paramConv.denoiseInputs = false; % if the disk images are noisy
        
        lastFilterBankSaved = learnFilterDictionary(pathResults, maxIterConv, resume_fb_conv, paramConv);
        
 
    %% Approximate these non-separable filters as separable
    
        maxIterApprox = 18000;
        resume_fb_approx = 0;
        paramApprox.steps_no = 1000; % number of steps after which partial results are saved
        
        % give whatever number of these, if not specified (or commented
        % away), the default value in "get_config_Approx.m" is used
        paramApprox.rank = 5; % rank used in CD decomposition  
        paramApprox.gradient_steps_no = 10; % number of gradient steps on coefficients
        paramApprox.gradient_step_size = 1e-1; % gradient step size on coefficients
        paramApprox.filters_grad_step_size = 7e-2; % gradient step size on sep filters
        paramApprox.lambda_l1 = 0; % regularization parameter on the coefficients
        paramApprox.lambda_nuclear = 1e-2; % regularizarion paramether on ktensor coefficients of the sep filters

        paramApprox.filters_size = [13,13,13];
        paramApprox.filters_no = 36; %number of separable filters used to approximate original filter bank

        % [fb_name, learnPath, approxResultsPath, weightPath, filterPath, pathBigFiles] = learnFiltersAndApproximate(pathResults);
        [filterName, filterPath] = approximateAsSeparableFilters(pathResults, paramApprox, maxIterApprox, resume_fb_approx, lastFilterBankSaved);
        fb_name = strrep(filterName, '.txt', '');
        
        
    %% Plot the Filters
    
        %{
        % if you already have run the learning part, and want to plot the
        % results afterwards
        separableYes = true;
        if(exist('fb_name','var')==0);
            [learnPath, approxPath, pathBigFiles] = init_setAllTrainingPaths(pathResults);
            [fb_name, weightPath, filterPath] = init_getLearnResultsFromDisk(separableYes, learnPath, approxPath, pathBigFiles);
        end        
    
        % imageName = 'RGBdepthstack22.nrrd';
        imageName = 'degraded_001_blur7_poisson11.nrrd';
        testImage = fullfile(folderPath, imageName);
        
        % first compute the filter responses
        asMIP = true; sliceToPlot = 10;
        [fResponseToPlot, imTest] = compute_learnedFilterBankResponsesForPlot(fb_name, learnPath, approxPath, weightPath, filterPath, pathBigFiles, testImage, asMIP, sliceToPlot);
        
        % then plot        
            % visualize_filterBankResponses(imTest, fResponseToPlot, imageName)

        % plot reconstruction
            % implement later
        %}
        
    %% Classify then using the learned filters and Random Forest classifier
    
        if(exist('pathResults','var')==0); pathResults = '/home/petteri/learningFilterData'; end
        if(exist('learnPath','var')==0); learnPath = fullfile(pathResults, 'filterLearnConv'); end
        if(exist('folderPath','var')==0); folderPath = fullfile(learnPath, 'datasets'); end
    
        separableYes = true;        
        if(exist('fb_name','var')==0);
            [learnPath, approxPath, pathBigFiles] = init_setAllTrainingPaths(pathResults);
            [fb_name, weightPath, filterPath] = init_getLearnResultsFromDisk(separableYes, learnPath, approxPath, pathBigFiles);
            
        end        
        pathBigFiles = fullfile(pathBigFiles, 'classification');
        
        % copy the separable filter bank to the classification folder
        filterFolder = fullfile(pathBigFiles, 'data_3D', 'vesselTest', 'filter_banks_3D'); % TODO: vesselTest now static!!!
        fb_file = fullfile(filterPath, [fb_name, '.txt']);
        copyfile(fullfile(fb_file), fullfile(filterFolder, [fb_name, '.txt']))
        
        % Hand-crafted vessel filters
        use_oof = false; % put OOF-OFA here
        use_ef = false; % put Spherical Flux here
    
        % Use Random Forest
        classifier = 'RF'; % or 'l1reg'
        
        % Classifier parameters
        paramClassif.rf.trees_no = 600; % Number of trees for a Random Forest classifier         
        paramClassif.l1reg.lambda = 0.01; % Regularization parameter for l1-regularized regression
        
        paramClassif.train_samples_no = 10000; % Number of training samples.        
        paramClassif.results_thresholds_no = 500; % Number of thresholds used in the computations of the statistics
        
        paramClassif.BoostedTrees.loss = 'exploss'; % can be logloss or exploss
        paramClassif.BoostedTrees.shrinkageFactor = 0.1;% this has to be not too high (max 1.0)
        paramClassif.BoostedTrees.subsamplingFactor = 0.01;
        paramClassif.BoostedTrees.maxTreeDepth = uint32(2);  % this was the default before customization
        paramClassif.BoostedTrees_numIters = 10;        
        paramClassif.BoostedTrees_numItersToEvaluate = 5; % predict, you can skip the last parameter and it will evaluate all the stumps
    
        % call the actual classification function
        model = pixel_classification_3D_PT(fb_name, use_oof, use_ef, classifier, weightPath, pathBigFiles, paramClassif);
        save(fullfile('/home/petteri/Desktop', 'resultsSoFar.mat'))
        
        % and now you are actually ready to use the learned model
        
    
    
        
    

        
        
   