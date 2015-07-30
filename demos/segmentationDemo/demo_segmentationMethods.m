function demo_segmentationMethods()

    clear all; close all;

    %% INPUT DATA
    
        fileName = 'slices10_16_wVesselnessEdgesGVF.mat';
        fileMat = fullfile('testData', fileName);
        resizeOn = true;
        resizeFactor = 1/1;
        plotOn = false;
        [img, vessel, edges, GVF] = input_segmentationTestData(fileMat, resizeOn, resizeFactor, plotOn);

        
    %% SEGMENTATION

    
        %% DENOISE (extreme) 
        
            im_denoised_2D = denoise_NLMeansPoissonWrapper(img(:,:,sliceIndex), 10, 3, 6);
    
            
            
        %% PRE-PROCESS
    
            sliceIndex = 1;
            rows = 3; cols = 2;

            im = img(:,:,sliceIndex);
                imOut = im / max(im(:));
                imOut = uint8(imOut * 255);
                subplot(rows,cols,1); imshow(imOut,[]); title('Input')
                %imwrite(imOut, 'imAsImage.png')

            vesselAsImage = vessel(:,:,sliceIndex);
                % vesselAsImage(vesselAsImage < mean(vesselAsImage(:))) = 0;
                vesselAsImage = abs(vesselAsImage);
                vesselAsImage = vesselAsImage / max(vesselAsImage(:));
                vesselOut = uint8(vesselAsImage * 255);
                subplot(rows,cols,2); imshow(vesselOut,[]); title('abs(OOF)')
                %imwrite(vesselOut, 'vesselAsImage.png')

            GVFasImage = GVF(:,:,sliceIndex);
                GVFasImage(GVFasImage < mean(GVFasImage(:))) = 0;
                GVFout = GVFasImage / max(GVFasImage(:));
                GVFout = uint8(GVFout * 255);
                subplot(rows,cols,3); imshow(GVFout,[]); title('abs(GVF)')
                %imwrite(GVFout, 'gvfAsImage.png')

                threshold = 10/255;
                zeroIndices = vesselAsImage < threshold;            
                subplot(rows,cols,4); imshow(zeroIndices, []); title('Zeroes from OOF')
                    % you could possibly refine your mask via "Guided Filter
                    % feathering" if needed / wanted

            % thresholdedVessels = im2bw(vesselAsImage, 1/256);
            imFusion = vesselAsImage .* im; % removes the noise
                imFusion = imFusion / max(imFusion(:));
                imFusion = imFusion * 50; % quick'n'dirty brightness 
                imFusion(imFusion > 1) = 1; % clip
                imFusion = imFusion / max(imFusion(:));
                subplot(rows,cols,5); imshow(imFusion,[]); title('Fusion (im*OOF)')

                % use the GVF to index the background out
                imFusion(zeroIndices) = 0;
                subplot(rows,cols,6); imshow(imFusion,[]); title('Fusion (-OOF zeros)')
            
        %% 2D Level set
        
            im2 = im_denoised_2D - min(im_denoised_2D(:));
            im2 = im2 / max(im2(:));
            level = graythresh(im2); % quick'n'dirty 
            im2 = im2 * (1/level);
            im2(im2 > 1) = 1; % clip
            
            region = asets_demoWrapper_2D(im2, vessel(:,:,sliceIndex), edges(:,:,sliceIndex));
        
        %% 3D Level set        
        
            asets_demoWrapper_3D(img, vessel, edges, sliceIndex)

        %% 3D Snake
        
            % create a mesh from vesselness image
            debugPlot = false;
            isoValue = 0.1; % relative to max
            downSampleFactor = [1 1]; % [xy z] downsample to get less vertices/faces
            physicalScaling = [1 1 1]; % physical units of FOV
            [FV.faces,FV.vertices] = reconstruct_marchingCubes_wrapper(vessel, isoValue, downSampleFactor, physicalScaling, debugPlot);
            FV
            
            Options.Mu = 0.2; % Trade of between real edge vectors, and noise vectors,
                              % default 0.2. (Warning setting this to high >0.5 gives an instable Vector Flow)            
            Options.GIterations = 0; % Number of GVF iterations, default 0
            Options.Sigma3 = 1.0; % Sigma used to calculate the laplacian in GVF, default 1.0
            % OV = Snake3D(img, FV, Options);
        
        
    
    

    
    
    
