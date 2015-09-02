function createTrainingSetFromGroundTruth()

    %% BASIC SETTINGS
        
        clear all; close all;
        fileName = mfilename; fullPath = mfilename('fullpath');
        pathCode = strrep(fullPath, fileName, ''); 
        cd(pathCode)
        scrsz = get(0,'ScreenSize'); % get screen size for plotting
    
        % Import data
        path = fullfile('..', 'testData');
        file = 'BM4D_denoised.mat'; % tp 3
        load(fullfile(path,file));
        file = 'groundTruthMatrices.mat';
        load(fullfile(path,file));
        im = im_BM4D;

        % output location
        outPathBASE = fullfile('/home/petteri/', 'learningFilterData');
        outPathClassifier = fullfile(outPathBASE, 'classification', 'data_3D');
        outPathFilterTraining = fullfile(outPathBASE, 'filterLearnConv', 'datasets');
        
        DATA_SET = 'vesselTest';
        outPath = fullfile(outPathClassifier, DATA_SET);
        if exist(outPath, 'dir') == 0
            mkdir(outPath)
        end
        
    %% DEGRADE IMAGE
    
        % now we have only one 3-D Volume with one Ground Truth mask, so in
        % order to train the classifier we degrade the input image and we
        % can use the same ground truth mask, as done for example in
        
            % Schneider M, Hirsch S, Weber B, Székely G, Menze BH. 2015. 
            % Joint 3-D vessel segmentation and centerline extraction using oblique Hough forests with steerable filters. 
            % Medical Image Analysis 19:220–249. http://dx.doi.org/10.1016/j.media.2014.09.007.

        noOfFiles = 10;
        denoiseDegraded = true;
        normalizeSlices = true;
        resizeON = true;
        resizeFactor = 0.25;
        degraded_im = degradeVesselImage(im, noOfFiles, denoiseDegraded, normalizeSlices, resizeON, resizeFactor);
        
    
    %% THE LEARNING SEPARABLE FILTER
    
        % Required (see "README_data.txt" in outPathBase)
        
        % define the masks
        [test_gt, train_gt, test_masks, train_masks, dilatMask, negMask, posMask] ...
            = defineClassifierMasks(groundTruth, noOfFiles, resizeON, resizeFactor);
               
        % Define "hand-crafted" vessel filter outputs
            % - test_ef_3D.txt (optional): list of files containing EF output on test images;
            % - test_oof_3D.txt (optional): list of files containing OOF output on test images;
            % - train_ef_3D.txt (optional): list of files containing EF output on train images;
               
        % - test_imgs_3D.txt: list of images used for test;        
        
        
        % start with fixed portions for testing / training images, and move
        % on to cross-validation then, e.g. 
        % http://www.mathworks.com/help/stats/cvpartition.html  
        testingPercentage = 0.3;
        isTesting = getTestingIndices(degraded_im, testingPercentage);
        
        defineClassifierImages(groundTruth, degraded_im, outPath, isTesting, ...
                        test_gt, train_gt, test_masks, train_masks, dilatMask, negMask, posMask, outPathFilterTraining)
       
        
        
    % degrades the input images
    function degraded_im = degradeVesselImage(im,noOfFiles,denoiseDegraded,normalizeSlices,resizeON,resizeFactor)
        
        degraded_im = cell(noOfFiles,1);
        disp('Degrading images, image index:')
        for i = 1 : noOfFiles
            
            fprintf('%d\n ', i)
            
            if resizeON
                disp('    .. resizing')
                
                im2 = zeros(size(im,1)*resizeFactor, size(im,2)*resizeFactor, size(im,3));
                for z = 1 : size(im,3)
                    im2(:,:,z) = imresize(im(:,:,z), resizeFactor);                
                end
            end    

            % quick fix for depth attenuation
            if normalizeSlices
                for z = 1 : size(im2,3)
                    im2(:,:,z) = im2(:,:,z) / max(max(im2(:,:,z)));
                end
            end            
            
            degraded_im{i}.image = im2;
            
            if i < 10
                index = ['00', num2str(i)];
            elseif i < 100
                index = ['0', num2str(i)];
            else
                index = numstr(i);
            end
            
            % simple degradation model with some blur and poisson noise
        
                % 1) blur
                blurCenter = 6;
                sigma = 2;
                blurPSF = round(abs(normrnd(blurCenter, sigma)));                
                degraded_im{i}.blurPSF = blurPSF;
                degraded_im{i}.image =  blurImage(degraded_im{i}.image, blurPSF);

                % 2) apply poisson noise
                poissonCenter = 10;
                sigma = 2;
                poissonSNR = abs(normrnd(poissonCenter, sigma));
                sigmaGaussian = 0;
                degraded_im{i}.poissonSNR = poissonSNR;
                degraded_im{i}.image = applyPoissonNoise(degraded_im{i}.image, poissonSNR, sigmaGaussian);
                
            
            degraded_im{i}.fileName = ['degraded_', index, '_blur', num2str(blurPSF,2), '_poisson', num2str(poissonSNR,2), '.nrrd'];
            
            % in the end you wanna train the classifier using denoised
            % images and not noisy ones so it makes sense to denoise again
            % the degraded images
            
            if denoiseDegraded
                [degraded_im{i}.image, degraded_im{i}.sigmaEst, degraded_im{i}.PSNR, degraded_im{i}.SSIM] ...
                    = denoise_BM4D_withAnscombe_wrapper(degraded_im{i}.image);
            end
            
        end
        fprintf('\n')
        
        
        
        
    function imBlurred = blurImage(im, blurAmount)
        
        PSF = fspecial('gaussian', blurAmount, blurAmount);
        
        imBlurred = zeros(size(im));
        for i = 1 : size(im, 3)
            imBlurred(:,:,i) = imfilter(im(:,:,i), PSF, 'same');
            if i > 10
                % subplot(1,2,1); imshow(im(:,:,i), []); subplot(1,2,2); imshow(imBlurred(:,:,i), []); pause
            end
        end        
        
    function imNoisy = applyPoissonNoise(im, SNR, sigmaGaussian)
        
        % The Poisson option of imnoise wants the values to be scaled by 1e-12,
        % so let's have the values go from 0 to 10e-12:
        % see e.g. http://www.scribd.com/doc/112067134/Matlab-Image-Noises-algorithms-explained-and-manually-implementation#scribd
        maxValue = max(im(:));
        im = double(im) / double(max(im(:)));
        im = im * 10e-12;
        imNoisy = maxValue * imnoise(im, 'poisson');                
        % i = 10; subplot(1,2,1); imshow(im(:,:,i), []); subplot(1,2,2); imshow(imNoisy(:,:,i), []); pause
       
        % TODO: implement the SNR/magnitude of noise still
        
    % define the images, and the .txt lists needed
    function defineClassifierImages(groundTruth, degraded_im, outPath, isTesting, ...
                    test_gt, train_gt, train_masks, test_masks, dilatMask, negMask, posMask, outPathFilterTraining)
        
        jTest = 0; jTrain = 0;
                        
        for i = 1 : length(degraded_im)                       
            
            % TRAINING
            if ~isTesting(i)
                
                jTrain = jTrain + 1;
                
                % - train_imgs_3D.txt: list of images used for training;  
                textFile = 'train_imgs_3D.txt'; toFilterFolder = 1;
                classifierPerLoopCall(jTrain, i, outPath, degraded_im{i}.fileName, degraded_im{i}.image, textFile, toFilterFolder, outPathFilterTraining)
            
                % - train_gt_3D.txt: list of files containing ground truth of train images;
                textFile = 'train_gt_3D.txt'; toFilterFolder = 0;
                classifierPerLoopCall(jTrain, i, outPath, strrep(degraded_im{i}.fileName, '.nrrd', '_gt.nrrd'), train_gt, textFile, toFilterFolder, outPathFilterTraining)

                % - train_masks_3D.txt: list of masks of train images (used to train algorithm only in a part of the image);
                textFile = 'train_masks_3D.txt'; toFilterFolder = 0;
                classifierPerLoopCall(jTrain, i, outPath, strrep(degraded_im{i}.fileName, '.nrrd', '_roiMask.nrrd'), train_masks, textFile, toFilterFolder, outPathFilterTraining) 
                
                % - dilat_sampling_masks_3D.txt: list of files containing a generic mask for sampling train data (e.g. gt dilatated);
                textFile = 'dilat_sampling_masks_3D.txt'; toFilterFolder = 0;
                classifierPerLoopCall(jTrain, i, outPath, strrep(degraded_im{i}.fileName, '.nrrd', '_gtDilat.nrrd'), dilatMask, textFile, toFilterFolder, outPathFilterTraining)

                
            % TESTING
            else
                                
                jTest = jTest + 1;
                
                % test_imgs_3D.txt: list of images used for test;
                textFile = 'test_imgs_3D.txt'; toFilterFolder = 1;
                classifierPerLoopCall(jTest, i, outPath, degraded_im{i}.fileName, degraded_im{i}.image, textFile, toFilterFolder, outPathFilterTraining)                
                
                % - test_gt_3D.txt: list of files containing ground truth of test images;
                textFile = 'test_gt_3D.txt'; toFilterFolder = 0;
                classifierPerLoopCall(jTest, i, outPath, strrep(degraded_im{i}.fileName, '.nrrd', '_gt.nrrd'),  test_gt, textFile, toFilterFolder, outPathFilterTraining)                
               
                % - test_masks_3D.txt: list of masks of test images (used to test algorithm only in a part of the image);
                textFile = 'test_masks_3D.txt'; toFilterFolder = 0;
                classifierPerLoopCall(jTest, i, outPath, strrep(degraded_im{i}.fileName, '.nrrd', '_roiMask.nrrd'), test_masks, textFile, toFilterFolder, outPathFilterTraining)                
                
            end
            
            % IN OUR NOISE-DEGRADATION-faked situation, all the masks are
            % the same unless you want to modify them
            
            % - neg_sampling_masks_3D.txt: list of files containing the masks of the negative samples;          
            textFile = 'neg_sampling_masks_3D.txt'; toFilterFolder = 0;
            classifierPerLoopCall(i, i, outPath, strrep(degraded_im{i}.fileName, '.nrrd', '_neg.nrrd'),  negMask, textFile, toFilterFolder, outPathFilterTraining)          
        
            % - pos_sampling_masks_3D.txt: list of files containing the masks of the positive samples;
            textFile = 'pos_sampling_masks_3D.txt'; toFilterFolder = 0;
            classifierPerLoopCall(i, i, outPath, strrep(degraded_im{i}.fileName, '.nrrd', '_pos.nrrd'),  posMask, textFile, toFilterFolder, outPathFilterTraining)  
            
            
        end
        
    function classifierPerLoopCall(j, i, outPath, fileName, img, textFile, toFilterFolder, outPathFilterTraining)

        % save the image, you chould check if file exists at some point
        %fileName = [fileName, '.nrrd'];
        outPathFull = fullfile(outPath, fileName);        
      
        if islogical(img)
            img = uint8(img);
        end
        disp([num2str(i), ') writing to disk, file: ', outPathFull])        
            
        nrrdSave(outPathFull, img); 

        % add this to the text list
        if j == 1
            fid=fopen(fullfile(outPath, textFile),'w');
            fprintf(fid,'%s\n', fullfile(outPath,fileName));
            fclose(fid);
        else
            fid=fopen(fullfile(outPath, textFile),'a');
            fprintf(fid,'%s\n', fullfile(outPath,fileName));
            fclose(fid);
        end
        
        if toFilterFolder == 1
            
            % The Learning procedure needs a text list of the file
            % location, so we need to update that as well 

            splitted = strsplit(outPathFull, '/');
            fileNameOut = splitted{end};
            outPathFull = fullfile(outPathFilterTraining, fileNameOut);
            
            nrrdSave(outPathFull, img); 
            disp(['  -- needed also for filter training (', num2str(i), ') writing to disk, file: ', outPathFull])
            
            fileNameTXT = 'vesselImages_textlist.txt';
            disp(['   ... Writing filename to text file (', fullfile(outPathFilterTraining, fileNameTXT), ')'])

            if i == 1
                fid=fopen(fullfile(outPathFilterTraining, fileNameTXT),'w');
                fprintf(fid,'%s\n', fullfile(outPathFilterTraining, fileNameOut));
                fclose(fid);
            else
                fid=fopen(fullfile(outPathFilterTraining, fileNameTXT),'a'); % append
                fprintf(fid,'%s\n', fullfile(outPathFilterTraining, fileNameOut));
                fclose(fid);
            end
            
        end

                
    % define binary masks needed by the pixel classifier
    function [test_gt, train_gt, test_mask, train_mask, dilatMask, negMask, posMask] = defineClassifierMasks(groundTruth, noOfFiles, resizeON, resizeFactor)
        
        if resizeON
            disp('    .. resizing ground truth mask')                
            gt = zeros(size(groundTruth,1)*resizeFactor, size(groundTruth,2)*resizeFactor, size(groundTruth,3));
            for z = 1 : size(groundTruth,3)
                gt(:,:,z) = imresize(groundTruth(:,:,z), resizeFactor);                
            end
            groundTruth = gt;
        end
        
        % - test_gt_3D.txt: list of files containing ground truth of test images;
        test_gt = groundTruth;
        
        % - train_gt_3D.txt: list of files containing ground truth of train images;
        train_gt = groundTruth;
        
        % - test_masks_3D.txt: list of masks of test images (used to test algorithm only in a part of the image);

            % leakage ROI
            j = 1; roi_x{j} = round([348:475]*resizeFactor); roi_y{j} = round([163:290]*resizeFactor);
            
            % bifurcation ROI
            j = j+1; roi_x{j} = round([122:249]*resizeFactor); roi_y{j} = round([198:325]*resizeFactor);
            
            % faint vessels
            j = j+1; roi_x{j} = round([282:409]*resizeFactor); roi_y{j} = round([333:460]*resizeFactor);
            
            testMask2D = logical(zeros(size(groundTruth,1), size(groundTruth,2)));
            for ij = 1 : j
               testMask2D(roi_y{j}, roi_x{j}) = 1;
            end
            test_mask = logical(repmat(testMask2D,[1,1,size(groundTruth,3)])); % 3D
            train_mask = test_mask; % 3D
            
        
        % - dilat_sampling_mask_3D.txt: list of files containing a generic mask for sampling train data (e.g. gt dilatated);
        dilatMask = logical(zeros(size(groundTruth)));
        se = strel('disk', 3);
        for i = size(groundTruth,3)
            dilatMask(:,:,i) = imdilate(groundTruth(:,:,6), se);
        end
        
        % for a definition of negative and positive samples, see:
        % http://docs.opencv.org/doc/user_guide/ug_traincascade.html
        
        % - neg_sampling_mask_3D.txt: list of files containing the masks of the negative samples;
        negMask = ~groundTruth;
        
        % - pos_sampling_mask_3D.txt: list of files containing the masks of the positive samples;
        posMask = groundTruth;
        
    % divide training and testing
    function isTesting = getTestingIndices(degraded_im, testingPercentage);
        numberOfTestingImages = round(testingPercentage * length(degraded_im));
        indices = 1 : 1 : length(degraded_im);
        msize = numel(indices);
        idx = randperm(msize);
        idxTesting = idx(1:numberOfTestingImages);
        isTesting = logical(zeros(size(indices)));
        isTesting(idxTesting) = 1;