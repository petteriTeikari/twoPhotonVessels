function convert_OIBfolderToNRRD(path, chVessel, tpFixed, justTheVessels, applyICAseparation)

    % input data
    if nargin == 0
        path = '/home/petteri/Desktop/marc2PMtrain/2';        
        chVessel = 2; % ch index for vessel data
        tpFixed = 1; % time point(s) used
    end
    
    % some settings
    tiffPath = path;
    
    % this should be the one that is used by the learning filter
    options.pathBigFiles = fullfile('/home/petteri/learningFilterData/filterLearnConv', 'datasets'); % don't save all the big files to Dropbox
    options.batchFlag = false;
    options.denoiseOnly = false; % just denoise, and save to disk, useful for overnight pre-batch processing
    options.denoiseLoadFromDisk = false; % if this file/timepoint/channel already denoised
        % this collides with the resizeStacks2D, as we can now resize
        % the stack while the loaded stack could be full-size
    % options.vesselnessLoadFromDisk = true;  
    options.segmentationLoadFromDisk = false;  

    % debug/development flag to speed up the development, for actual
    % processing of files, put all to false
    options.useOnlyFirstTimePoint = false;
    options.useOnlySubsetOfStack = false;
    options.resizeStacks2D = false;
    options.resize2D_factor = 1 / 16;
    options.skipImportBioFormats = false;
    options.loadFromTIFF = false; % loading directly from the denoised OME-TIFF (if found)

    options.manualTimePoints = false;
    options.tP = tpFixed;
    
    %% go through the files
    
        % list files
        files = dir(fullfile(path, '*.oib'));

        for i = 1 : length(files)           
            
            tCpu = cputime;

            fileName = files(i).name;
            disp(['Processing file : ', fileName, ', #', num2str(i), '/', num2str(length(files))])
            dlmwrite(['procFile_', num2str(i), '.txt'], 1)
            
            % import .oib
            
                % Import from the Olympus Fluoview file (OIB) using the Bio-Formats
                [data, imageStack, metadata, options] = importMicroscopyFile(fileName, path, tiffPath, options);
            
            % DENOISE

                % This allows us to consider the Poisson-corrupted 2-PM as
                % Gaussian-noise corrupted image
                scaleRange = 0.7;  %% ... then set data range in [0.15,0.85], to avoid clipping of extreme values
                disp(' ')
                disp('Anscombe Transform - BM4D Denoising - Inverse Anscombe Transform'); disp(' ');
                                
                for ch = 1 : length(imageStack)
                    for tp = 1 : length(imageStack{1}) % TODO: fix to "options.tP = tpFixed"
                    
                        % Anscombe transform
                        [im_VST, y_sigma, transformLimits] = denoise_anscombeTransform(double(imageStack{1}{1}), 'forward', scaleRange, []);

                        % denoise with BM4D
                        [denoised_VST, sigmaEst, PSNR, SSIM] = denoise_BM4Dwrapper(im_VST);

                        % inverse Anscombe transform
                        [imageStack_denoised{1}{1}, ~, ~] = denoise_anscombeTransform(denoised_VST, 'inverse', scaleRange, transformLimits);
                        
                    end                    
                end

            if applyICAseparation
                
                % NOTE! Not implemented at the moment, proper handling of
                % all the channels in separation.
                
                % fastICA to separate the possible spectral crosstalk
                plotInput = true;
                rgbOrder = [3 2 1];
                noOfICs = 3;  

                for tp = 1 : length(imageStack{1})           
                    
                    disp('FastICA, slice:')
                    for slice = 1 : size(imageStack{1}{1},3)
                        imForICA = import_reshapeForICAseparation(imageStack_denoised, tp, slice);
                        imageSliceRGB = main_separateMixedImages_fastICA(imForICA, noOfICs, plotInput, rgbOrder);

                        fprintf('%d ', slice)
                        if plotInput 
                            if slice < 10
                                figFileOut = ['icaSeparation_tp', num2str(tp), '_slice_0', num2str(slice), strrep(fileName, '.oib', ''), '.png'];
                            else
                                figFileOut = ['icaSeparation_tp', num2str(tp), '_slice_', num2str(slice), strrep(fileName, '.oib', ''), '.png'];
                            end

                            export_fig(fullfile(path, 'figICA', figFileOut), '-r100', '-a1')
                        end

                        % get rid of the other channels
                        if justTheVessels
                            imageStackICA{1}{tp}(:,:,slice) = imageSliceRGB(:,:,ch);
                        else
                            for ch = 1 : size(imageSliceRGB,3)
                                imageStackICA{rgbOrder(ch)}{tp}(:,:,slice) = imageSliceRGB(:,:,ch);
                            end
                        end

                    end
                    fprintf('\n')
                end
                
                imageStackOut = imageStackICA;
                
            else
                
                imageStackOut = imageStack_denoised;
                
            end
            
            % WRITE OUT         
            
                % write as NRRD to disk
                stackOutMatrix = zeros(length(imageStackOut), length(imageStackOut{1}), ...
                    size(imageStackOut{1}{1}, 1),  size(imageStackOut{1}{1}, 2),  size(imageStackOut{1}{1}, 3));
                
                for ch = 1 : length(imageStackOut)
                    for tp = 1 : length(imageStackOut{1})
                        stackOutMatrix(ch,tp,:,:,:) = imageStackOut{1}{1};
                    end
                end
                
                if justTheVessels
                    % first two dimensions should be 1
                    whos
                    whos('stackOutMatrix')
                    stackOutMatrix = squeeze(stackOutMatrix);
                    whos('stackOutMatrix')
                end
                
                fileNameOut = [strrep(fileName, '.oib', '.nrrd')];
                fileNameOut(fileNameOut ==' ') = ''; % remove spaces 

                % .mat
                % disp(' '); disp(['Writing .mat to disk (', options.pathBigFiles, ')'])
                % save(fullfile(options.pathBigFiles, strrep(fileNameOut, '.nrrd', '.mat')), 'stackOut')

                % .nrrd
                disp(' '); disp(['Writing .nrrd to disk (', options.pathBigFiles, ')'])

                nrrdSave(fullfile(options.pathBigFiles, fileNameOut), stackOutMatrix);
                % stackBackIn = nrrdLoad(fullfile(options.pathBigFiles, fileNameOut));
                
                %{
                subplot(1,3,1); imshow(max(stackOut, [], 3));
                subplot(1,3,2); imshow(max(stackBackIn, [], 3));
                subplot(1,3,3); imshow(max(stackOut-stackBackIn, [], 3));
                drawnow
                %}
                
            % The Learning procedure needs a text list of the file
            % location, so we need to update that as well 

            fileNameTXT = 'vesselImages_textlist.txt';
            disp(' '); disp(['Writing filename to text file (', fullfile(options.pathBigFiles, fileNameTXT), ')'])

            if i == 1
                fid=fopen(fullfile(options.pathBigFiles, fileNameTXT),'w');
                fprintf(fid,'%s\n', fullfile(options.pathBigFiles, fileNameOut));
                fclose(fid);
            else
                fid=fopen(fullfile(options.pathBigFiles, fileNameTXT),'a'); % append
                fprintf(fid,'%s\n', fullfile(options.pathBigFiles, fileNameOut));
                fclose(fid);
            end
                
            timing.processPerFile(i) = cputime-tCpu;

            disp(' ')
            
        end
        
        timing.processPerFile
        mean(timing.processPerFile)
        
        disp(' ')
        disp('.OIB -> .NRRD complete')
        disp(['  in ', num2str(sum(timing.processPerFile)/60), ' minutes (', ...
            num2str(sum(timing.processPerFile) / length(files) / 60), 'min/file)'])
        disp(' ')
        
    function imForICA = import_reshapeForICAseparation(imageStack,tp,slice)
        
        for ch = 1 : length(imageStack)
            imForICA{ch} = double(imageStack{1}{1}(:,:,slice));
            maxValue(ch) = max(imForICA{ch}(:));
        end
        
        % normalize for image maximum
        maxOfMaxes = max(maxValue);
        for ch = 1 : length(imageStack)
            imForICA{ch} = imForICA{ch} / maxOfMaxes;
        end
   