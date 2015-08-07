function [denoised,timeExecDenoising] = denoiseMicroscopyImage(imageStack, denoisingAlgorithm, options, t, ch) 
    
    %% INPUT CHECKS
    
        % If denoising already done for this file
        if options.loadFromTIFF
            disp('Denoising already done for the OME-TIFF, skipping denoising');
            warning('Not really implemented yet, but this might be time-consuming so you do not want to re-run if not needed')
            return
        end
        
        % construct filename for the output files
        filename = fullfile(options.pathBigFiles, ...
                            ['denoised_', denoisingAlgorithm '_ch', num2str(ch), '_t', num2str(t), '.mat']);
                        
        % TODO: Now all the filters run with default parameters, make it possible
        %       to provide input arguments to this
        
    
    %% DENOISING    
    
        % NL-MEANS (for POISSON NOISE)
        if strcmp(denoisingAlgorithm, 'NLMeansPoisson')
            
            % This is very slow, but the quality of the output is good
            % (edges preserved, smooth surfaces)
            hW = 10; hB = 3; hK = 6;
            [denoised, timeExecDenoising] = denoise_NLMeansPoissonWrapper(imageStack, hW, hB, hK);
            
    
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
        save(filename, 'denoised')
        fileOutTIFF = strrep(filename, '.mat', '.tif');
        export_stack_toDisk(fileOutTIFF, denoised) 
                
        % display timing
        denoisingTook = timeExecDenoising;
        denoisingTime.hours = floor(denoisingTook/60/60);
        denoisingTime.minutes = floor(rem(denoisingTook/60/60,1) * 60);
        denoisingTime.seconds = denoisingTook - (denoisingTime.minutes * 60) - (denoisingTime.hours * 60 * 60);        
          
            disp(['DONE! Denoising took (timePoint = ', num2str(t), ') ', num2str(denoisingTime.hours), ' h ', num2str(denoisingTime.minutes), ' min ', num2str(denoisingTime.seconds), ' s'])
            disp(' ')