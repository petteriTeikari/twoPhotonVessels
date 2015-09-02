function demo_segmentationASETS_3D()

    clear all; close all;
    fileName = mfilename; fullPath = mfilename('fullpath');
    pathCode = strrep(fullPath, fileName, ''); cd(pathCode)

    %% INPUT DATA
    
        %fileName = 'slices10_16_timepoint3_denoised_NLMeansPoisson.mat';        
        fileName = 'slices10_16_timepoint3_denoised_NLMeansPoisson_oofOfa.mat';
        % fileName = 'slices10_16_denoised_NLMeansPoisson_oofOfa.mat';         
        fileMat = fullfile('testData', fileName);
        
        resizeOn = true;
        resizeFactor = 1/1;
        plotOn = false;
        [imageStack, vesselnessStack] = input_segmentationTestDataASETS(fileMat, resizeOn, resizeFactor, plotOn);
        sliceIndex = 1;

    %% Pre-process images
    
        % close all
        
        % Pre-process images  
        [imageStack, fusionImageStack, fusionImageStackBright, vesselnessStack, edges, edgesSigmoid, im_bias_corrected] ...
            = segment_asetsPreProcessImages(imageStack, vesselnessStack);
          
        
        visualizeON = 1;
        if visualizeON
            rows = 2; cols = 6;
            fig = figure('Color','w');
                scrsz = get(0,'ScreenSize'); % get screen size for plotting   
                set(fig,  'Position', [0.3*scrsz(3) 0.445*scrsz(4) 0.65*scrsz(3) 0.50*scrsz(4)])
            
            subplot(rows,cols,1); imshow(max(imageStack, [], 3), []); title('Image MIP')
            subplot(rows,cols,2); imshow(max(fusionImageStack, [], 3), []); title('Fusion Image MIP')
            subplot(rows,cols,3); imshow(max(fusionImageStackBright, [], 3), []); title('Fusion Image Bright MIP')            
            subplot(rows,cols,4); imshow(max(vesselnessStack, [], 3)); title('Vesselness MIP')            
            subplot(rows,cols,5); imshow(max(edges,[],3)); title('Edges MIP')
            subplot(rows,cols,6); imshow(max(edgesSigmoid,[],3)); title('Edges Sigmoid MIP')
            
            diff1 = abs(imageStack - fusionImageStack);
            subplot(rows,cols,7); imshow(max(diff1,[],3)); title('diff(Image-FusionImage) MIP')
            
            diff2 = abs(imageStack - fusionImageStackBright);
            subplot(rows,cols,8); imshow(max(diff2,[],3)); title('diff(Image-FusionImageBright) MIP')
            
            vesselPositive = vesselnessStack;
            vesselPositive(vesselPositive < 0.2) = 0;
            fusion3 = fusionImageStack + vesselPositive;
            % fusion3(fusion3 > 1) = 1;
            subplot(rows,cols,9); imshow(max(fusion3,[],3)); title('Fusion Image 3 MIP')
            
            diff3 = abs(imageStack - fusion3);
            subplot(rows,cols,10); imshow(max(diff3,[],3)); title('diff(Image-FusionImage3) MIP')
            
            subplot(rows,cols,11); imshow(max(im_bias_corrected,[],3)); title('bias corrected')
            
        end
        
        
        
    %% Create the init region (from vessel)
    
        regionInit = segment_createRegionFromVessel(vesselnessStack);

    %% SEGMENTATION
        
        % actual call of the segmentation
        fileOutBase = 'iter3D_';
        visualize3D = true; visualizeON = true;
        
        % Parameters
        maxLevelSetIterations = 15; % number of maximum time steps
        tau = 5000; % speed parameter
        w1 = 0.4; % weight parameter for intensity data term
        w2 = 0.2; % weight parameter for the speed data term
        w3 = 0.4; % weight parameter for the vesselness
        
        % 6. Set up the parameters for the max flow optimizer:
        % [1] graph dimension 1
        % [2] graph dimension 2
        % [3] number of maximum iterations for the optimizer (default 200)
        % [4] an error bound at which we consider the solver converged (default
        %     1e-5)
        % [5] c parameter of the multiplier (default 0.2)
        % [6] step 7size for the gradient descent step when calulating the spatial
        %     flows p(x) (default 0.16)        
        [sx, sy, sz] = size(imageStack);
        maxIter = 200;
        errorBound = 1e-6;
        cMultiplier = 0.2;
        stepSize = 0.16;
        pars = [sx; sy; sz; maxIter; errorBound; cMultiplier; stepSize];
             
        % for creating alpha from the edges
        regWeight1 = 0.005; regWeight2 = 0.01; regWeight3 = 50;
        
        % Actual call 
        secondPass = false;
        imgForSegmentation = fusionImageStackBright;

        region = asets_demoWrapper_3D_v3(imgForSegmentation, vesselnessStack, edges, regionInit, ...
                                         maxLevelSetIterations, tau, w1, w2, w3, pars, ...
                                         regWeight1, regWeight2, regWeight3, ...
                                         secondPass, sliceIndex, visualize3D, visualizeON, fileOutBase);

        %% Iterate?
        %{
        removeBorders = true;
        edges = segment_getPerimeterOfRegion(region, removeBorders);        
        edges = double(edges);
        
        fileOutBase = 'iter_secondPass_3D_';
        img4 = img2; % (0.5*(region .* img2)) + (0.5*img2);
        secondPass = true;
        tau = 5;        
        w1 = 0.1; % weight parameter for intensity data term
        w2 = 0.6; % weight parameter for the speed data term
        w3 = 0.3; % weight parameter for the vesselness
        
        regWeight1 = 0.005; regWeight2 = 0.01; regWeight3 = 0.05;
        region2 = asets_demoWrapper_3D_v3(img4, vessel, edges, region, ...
                                         maxLevelSetIterations, tau, w1, w2, w3, pars, ...
                                         regWeight1, regWeight2, regWeight3, ...
                                         secondPass, sliceIndex, visualize3D, visualizeON, fileOutBase);
        %}
                                     
    