function [denoised, dictionary, timeExecDenoising] = denoiseMicroscopyImage(imageStack, denoisingAlgorithm, options, t, ch) 
    

    %% INPUT CHECKS
    
        % If denoising already done for this file
        if options.loadFromTIFF % TIFF
            disp('Denoising already done for the OME-TIFF, skipping denoising');
            warning('Not really implemented yet, but this might be time-consuming so you do not want to re-run if not needed')
            return
        end
        
        % construct filename for the output files
        filename = fullfile(options.pathBigFiles, ...
                            ['denoised_', denoisingAlgorithm '_ch', num2str(ch), '_t', num2str(t), '.mat']);
                   
        % read from .mat file if already noised, saves a lot of hours
        % especially with NLMeansPoisson
        if options.denoiseLoadFromDisk
                       
            tic;
            disp(' option to load denoising from disk is TRUE')
            if exist(filename, 'file') == 2
                fileInfo = dir(filename); % file info
                fileSize = fileInfo.bytes / (1024 * 1024); % in MBs
                thresholdWarningMB = 5;
                if fileSize < thresholdWarningMB
                    warning(['Denoised .mat file only ', num2str(fileSize), ' MB, is it just a debugging .mat that replaced the actual denoising?'])
                end
                disp(['  .. file found (', num2str(fileSize,4), ' MB), ', filename])
                
                load(filename) 
                if ~exist('denoised','var')
                    try
                        denoised = stackOutAsMat;
                    catch err
                        err
                    end
                end  
                timeExecDenoising = toc;
                return
            else
                disp(['  .. ', filename, ' | File not found'])     
            end
        end
                        
        % TODO: Now all the filters run with default parameters, make it possible
        %       to provide input arguments to this
        
    
    %% DENOISING    
    
        % This allows us to consider the Poisson-corrupted 2-PM as
        % Gaussian-noise corrupted image
        scaleRange = 0.7;  %% ... then set data range in [0.15,0.85], to avoid clipping of extreme values
        disp('Anscombe Transform to "convert" Poisson noise to Gaussian noise'); disp(' ');
        [im_VST, y_sigma, transformLimits] = denoise_anscombeTransform(im, 'forward', scaleRange, []);
        options = [];
    
    
        if strcmp(denoisingAlgorithm, 'BM4D')

            tic
            [denoised_VST, sigmaEst, PSNR, SSIM] = denoise_BM4Dwrapper(im_VST);
            timeExecDenoising = toc;
            sigmaPercentage = 100*(sigmaEst / max(denoised_VST(:)));
            [denoised, ~, ~] = denoise_anscombeTransform(denoised_VST, 'inverse', scaleRange, transformLimits);
    
        % NL-MEANS (for POISSON NOISE)
        elseif strcmp(denoisingAlgorithm, 'NLMeansPoisson')
            
            % This is very slow, but the quality of the output is good
            % (edges preserved, smooth surfaces)
            hW = 10; hB = 3; hK = 6;
            [denoised, timeExecDenoising] = denoise_NLMeansPoissonWrapper(imageStack, hW, hB, hK);
            dictionary = []; % not a dictionary-based method
            
    
        % PURE DENOISE
        elseif strcmp(denoisingAlgorithm, 'PureDenoise')
            
            disp('Denoising the stack using PureDenoise (via ImageJ)')
            disp(' from: http://bigwww.epfl.ch/algorithms/denoise/')
            % http://bigwww.epfl.ch/algorithms/denoise/
            % a lot of crap required for the ImageJ-interfacing, so cleaner
            % just to use the wrapper
            
            % TIME: roughly takes 120 seconds for 67 slices at Petteri's computer
            options.saveImageJ_outputAsImage = true;
            
            % TODO: add later checks whether these variables have been
            %       defined at all, and if not, use these defaults
            options.denoisingCycleSpins = 4;
            options.denoisingMultiframe = 3;
            
            cycles = options.denoisingCycleSpins;
            frames = options.denoisingMultiframe;        
            command = 'PureDenoise ...';
            arguments = ['source=[', num2str(frames), ' ', num2str(cycles), 'estimation=[Auto Global]'];

            % ImageJ filtering via MIJ
            [denoised, timeExecDenoising] = MIJ_wrapper(imageStack(:,:,:), command, arguments, options);
            dictionary = []; % not a dictionary-based method
            
            
        % GUIDED FILTER
        elseif strcmp(denoisingAlgorithm, 'GuidedFilter')
        
            % http://research.microsoft.com/en-us/um/people/kahe/eccv10/
            % does not really work for denoising for our images, maybe need
            % to tuneup the parameters. But does not denoise enough
            tic;
            imageStack = double(imageStack);
            options.guidedType = 'fast'; % 'original'; % 'fast'
            guide = imageStack; % use the same image as guide
            epsilon = 1^2;
            win_size = 4;
            NoOfIter = 1;
            options.guideFast_subsampleFactor = 1; % only for 'fast', otherwise does not matter what value is here
            [denoised, fileOutName] = denoise_guidedFilterWrapper(imageStack, guide, ...
                            epsilon, win_size, NoOfIter, options.guidedType, options.guideFast_subsampleFactor, options);
            timeExecDenoising = toc;
            dictionary = []; % not a dictionary-based method
         
        % K-SVD
        elseif strcmp(denoisingAlgorithm, 'K-SVD')
            
            % add check later so that you can pass out these variables
            % outside this function and if not, use these defaults
            params.blocksize = 8;
            params.dictsize = 256;
            params.maxval = max(imageStack(:));
            params.trainnum = 400;
            params.iternum = 1;
            params.memusage = 'high';
            plotON = true;
            
            tic;            
            [denoised, dictionary] = denoise_kSVD_Wrapper(imageStack, params, plotON, options);
            timeExecDenoising = toc;

        % DLENE
        elseif strcmp(denoisingAlgorithm, 'DLENE')
            
        % CSR Denoise
        elseif strcmp(denoisingAlgorithm, 'CSR')
            
            
        elseif strcmp(denoisingAlgorithm, 'CSF')
            
            % dx.doi.org/10.1109/TSP.2014.2324994
            
        % OTHER
        elseif strcmp(denoisingAlgorithm, 'someVeryCoolMethod')
            
            % PURE-LET
            % --------

            % If you have a Wavelet Toolbox (type 'ver' on command
            % console), you could use alternative implementation (or try to go
            % around with free Wavelab toolbox)
            % http://www.mathworks.com/matlabcentral/fileexchange/31557-pure-let-for-poisson-image-denoising

            % F. Luisier, C. Vonesch, T. Blu, M. Unser, "Fast Interscale Wavelet Denoising of Poisson-corrupted Images", 
            % Signal Processing, vol. 90, no. 2, pp. 415-427, February 2010.
            % http://dx.doi.org/10.1016/j.sigpro.2009.07.009
            
            % SKellamMRSO
            % -----------
            % Cheng W, Hirakawa K. 2015. "Minimum Risk Wavelet Shrinkage Operator for Poisson Image Denoising." 
            % IEEE Transactions on Image Processing 24:1660–1671. 
            % http://dx.doi.org/10.1109/TIP.2015.2409566.
            
            % See
            % https://www.researchgate.net/post/Is_the_block-matching_and_3-D_filtering_BM3D_algorithm_the_most_powerful_and_effective_image_denoising_procedure_nowadays
            
            % LSSC, Non-local sparse models for image restoration, ICCV 2009

            % GMM-EPLL, From learning models of natural image
            % patches to whole image restoration, ICCV 2011

            % opt-MRF, Insights into analysis operator learning:
            % From patch-based sparse models to higher order MRFs, IEEE TIP 2014

            % WNNM, Weighted nuclear norm
            % minimization with application to image denoising, CVPR 2014

            % CSF, Shrinkage fields for effective image restoration, CVPR 2014 
            
        else
            warning('What is your denoising method? No denoising done now (input returned as denoised)')
            denoised = imageStack;
        end
                
        
    %% OUTPUT
    
        % DISPLAY the DENOISING    
        if ~options.batchFlag
            stackIndex = 9;
            fileOutName = [denoisingAlgorithm, '_DenoisingWholeStack_t', num2str(t), '_ch', num2str(ch), '.png'];
            visualize_denoising(imageStack, denoised, stackIndex, timeExecDenoising, fileOutName, t, ch, path, options)            
        end        
        
        % Save to disk
        if ~options.resizeStacks2D
            % save only when the stack has not been resized
            save(filename, 'denoised')
            fileOutTIFF = strrep(filename, '.mat', '.tif');
            export_stack_toDisk(fileOutTIFF, denoised) 
        end
        
                
        % display timing
        denoisingTook = timeExecDenoising;
        denoisingTime.hours = floor(denoisingTook/60/60);
        denoisingTime.minutes = floor(rem(denoisingTook/60/60,1) * 60);
        denoisingTime.seconds = denoisingTook - (denoisingTime.minutes * 60) - (denoisingTime.hours * 60 * 60);        
          
            disp(['DONE! Denoising took (timePoint = ', num2str(t), ') ', num2str(denoisingTime.hours), ' h ', num2str(denoisingTime.minutes), ' min ', num2str(denoisingTime.seconds), ' s'])
            disp(' ')