function [denoised,timeExecDenoising] = denoiseMicroscopyImage(imageIn, labelIn, t, ch, options) 
    
    %% INIT

        % Now using the ImageJ plugin () via MIJ bridge for ImageJ plugins to 
        % denoise our Poison/shot noise -corrupted 2-photon images
        
        % checking number of input for faster local debugging
        %{
        if nargin == 0
            disp('Running LOCALLY the DENOISING from DEBUGGING .MAT')
            load('debugMATs/testDenoising.mat ')
            maxOfInput = max(imageIn(:));
            im = imageIn / maxOfInput;
        else
            maxOfInput = max(imageIn(:));
            im = imageIn / maxOfInput;        
            if ~options.batchFlag
                save('debugMATs/testDenoising.mat ')               
            end
            
        end
        %}
        currDir = pwd;

        % imageIn = imageIn(:, :, 9:11);
        
        fileOutName = [options.denoisingAlgorithm, '_DenoisingWholeStack_t', num2str(t), '_ch', num2str(ch), '.png'];
    
    %% DENOISING
    
        %% NL-MEANS (for POISSON NOISE)
        if strcmp(options.denoisingAlgorithm, 'NLMeansPoisson')
            
            % This is very slow, but the quality of the output is good
            % (edges preserved, smooth surfaces)
            hW = 10; hB = 3; hK = 6;
            [denoised, timeExecDenoising] = denoise_NLMeansPoissonWrapper(imageIn, hW, hB, hK);
        
            
    
        %% PURE DENOISE
        elseif strcmp(options.denoisingAlgorithm, 'PureDenoise')
            
            disp('Denoising the stack using PureDenoise (via ImageJ)')
            disp('     from: http://bigwww.epfl.ch/algorithms/denoise/')
            % http://bigwww.epfl.ch/algorithms/denoise/
            % a lot of crap required for the ImageJ-interfacing, so cleaner
            % just to use the wrapper
            
            % TIME: roughly takes 120 seconds for 67 slices at Petteri's computer

            options.saveImageJ_outputAsImage = true;
            stackIndices = 1:67; % manual QUICK FIX to reduce computation time

            cycles = options.denoisingCycleSpins;
            frames = options.denoisingMultiframe;        
            command = 'PureDenoise ...';
            arguments = ['source=[', num2str(frames), ' ', num2str(cycles), 'estimation=[Auto Global]'];

            % ImageJ filtering via MIJ
            [denoised, timeExecDenoising] = MIJ_wrapper(imageIn(:,:,:), command, arguments, options);        
            
                % PURE-LET
                % --------
                
                % If you have a Wavelet Toolbox (type 'ver' on command
                % console), you could use alternative implementation (or try to go
                % around with free Wavelab toolbox e.g.)
                % http://www.mathworks.com/matlabcentral/fileexchange/31557-pure-let-for-poisson-image-denoising

                % F. Luisier, C. Vonesch, T. Blu, M. Unser, "Fast Interscale Wavelet Denoising of Poisson-corrupted Images", 
                % Signal Processing, vol. 90, no. 2, pp. 415-427, February 2010.
                % http://dx.doi.org/10.1016/j.sigpro.2009.07.009
            
            
        %% GUIDED FILTER
        elseif strcmp(options.denoisingAlgorithm, 'GuidedFilter')
        
            % http://research.microsoft.com/en-us/um/people/kahe/eccv10/
            % does not really work for denoising for our images, maybe need
            % to tuneup the parameters. But does not denoise enough
            tic;
            imageIn = double(imageIn);
            options.guidedType = 'fast'; % 'original'; % 'fast'
            guide = imageIn; % use the same image as guide
            epsilon = 1^2;
            win_size = 4;
            NoOfIter = 10;
            options.guideFast_subsampleFactor = 1; % only for 'fast', otherwise does not matter what value is here
            [denoised, fileOutName] = denoise_guidedFilterWrapper(imageIn, guide, ...
                            epsilon, win_size, NoOfIter, options.guidedType, options.guideFast_subsampleFactor, options);
            timeExecDenoising = toc;
                        
        else
            error('What is your denoising method?')
        end
            
        timeExecDenoising
        
    %% OTHER
    
        % Poisson NLSPCA (2012)
        % Matlab open-source software to perform non-local filtering in an extended PCA domain for Poisson noise.
        % http://www.math.u-bordeaux1.fr/~cdeledal/
        
        
    %% DISPLAY
    
        % fileOutName
        % timeExecDenoising    
        if ~options.batchFlag
            stackIndex = 9;
            visualize_denoising(imageIn, denoised, stackIndex, timeExecDenoising, fileOutName, t, ch, path, options)            
        end