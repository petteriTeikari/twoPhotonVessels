% These depend on the 3rd party toolboxes
% TODO: Add toolboxes to github
function denoise_demoMethods() 
    
    %% Import test data
    load(fullfile('..', 'debugMATs', 'testSlices.mat'))
    
        % z-slices of 9-11 from first time point of:
        % "CP-20150323-TR70-mouse2-1-son.oib" from Charissa
        
        % we use just one slice for testing
        sliceIndex = 2;
        im = testSlices(:,:,sliceIndex);
        
        % parameters
        computeSlowOnes = false
            % trilateral filter
            % NL-means for Poisson
        
    %% EVALUATE INPUT NOISE
    
        % S. M. Yang and S. C. Tai: "Fast and reliable image-noise estimation using a hybrid approach". Journal of Electronic Imaging 19(3), pp. 033007-1–15, 2010. 
        % http://dx.doi.org/10.1117/1.3476329
        % MATLAB CODE: http://www5.informatik.uni-erlangen.de/fileadmin/Persons/SchwemmerChris/noiseest_matlab.zip
                
        % the input image needs to be divisible by 5 to work with the noise
        % test
        options = [];       
        imTest = reshapeImageForNoiseTest(im, options);
        
        valrange = 4096; % 12-bit input
        p = 0.1; % 0.1 default value
        sigmaNoise_test = noiseest(imTest, valrange, p);
        sigmaNoise_test_refined = refinednoiseest(imTest, valrange);
        
        
    %% ALGORITHMS
    
        ind = 1;
        d_cell{ind} = im;
        timing(ind) = 0;
        title1st{ind} = 'Input';
        
    
        %% PURE DENOISE

            ind = ind + 1;
            options.saveImageJ_outputAsImage = true;
            cycles = 3;
            frames = 4;        
            command = 'PureDenoise ...';
            arguments = ['source=[', num2str(frames), ' ', num2str(cycles), 'estimation=[Auto Global]'];

            % ImageJ filtering via MIJ
            [d_cell{ind}, timing(ind)] = MIJ_wrapper(im, command, arguments, options);  
            title1st{ind} = 'Pure Denoise';

        %% ANISOTROPIC DIFFUSION | Standard
        
            ind = ind +1;
            
            % parameters
            Options.Scheme = 'S'; % 'S' Standard Discretization
        
            % download and add to path: http://www.mathworks.com/matlabcentral/fileexchange/25449-image-edge-enhancing-coherence-filter-toolbox
            tic;
            try
                d_cell{ind} = CoherenceFilter(im,Options);
            catch err
                if strcmp(err.identifier, 'MATLAB:UndefinedFunction') && ~isempty(strfind(err.message, 'CoherenceFilter'))
                    error('You do not have the Coherence Toolbox in your path (3rdParty or http://www.mathworks.com/matlabcentral/fileexchange/25449-image-edge-enhancing-coherence-filter-toolbox)')
                end
            end
            
            timing(ind) = toc;
            title1st{ind} = 'Anis. Diff. (Std)';

        
        %% ANISOTROPIC DIFFUSION | Novel Optimized by Dirk-Jan Kroon

            ind = ind +1;
            
            % Kroon et al. 2010: Optimized Anisotropic Rotational Invariant
            %                    Diffusion Scheme on Cone-beam CT
        
            % parameters
            Options.Scheme = 'O'; % 'O', Optimized Derivative Kernels
            
            % download and add to path: http://www.mathworks.com/matlabcentral/fileexchange/25449-image-edge-enhancing-coherence-filter-toolbox
            tic;
            try
                d_cell{ind} = CoherenceFilter(im,Options);
            catch err
                if strcmp(err.identifier, 'MATLAB:UndefinedFunction') && ~isempty(strfind(err.message, 'CoherenceFilter'))
                    error('You do not have the Coherence Toolbox in your path (3rdParty or http://www.mathworks.com/matlabcentral/fileexchange/25449-image-edge-enhancing-coherence-filter-toolbox)')
                end
            end
            timing(ind) = toc;
            title1st{ind} = 'Anis. Diff. (Optim.)';
        
            
       %% BILATERAL FILTER, Standard
        
            % http://www.mathworks.com/matlabcentral/fileexchange/50855-robust-bilateral-filter
            ind = ind +1;
            
            %  Acronyms used:
            %  SBF: Standard Bilateral Filter; RBF: Robust
            %  Bilater Filter; WBF: Weighted Bilateral Filter
            
            sigmaNoise = 30;
            sigmaS = 4;     %  spatial gaussian kernel 
            sigmaR1 = 20;   %  range gaussian kernel for SBF
            sigmaR2 = 20;   %  range gaussian kernel  for RBF
            tol = 0.01;                      
            
            disp('Bilateral Filter')
            tic;
            output = 'SBF';
            d_cell{ind} = bilateralFilter_wrapper(im, sigmaNoise, sigmaS, sigmaR1, sigmaR2, tol, output);
            timing(ind) = toc;
            title1st{ind} = 'Bilateral Filter';
            
            
        %% BILATERAL FILTER, Robust/Weighed
        
            % http://www.mathworks.com/matlabcentral/fileexchange/50855-robust-bilateral-filter
            ind = ind +1;
            
            %  Acronyms used:
            %  SBF: Standard Bilateral Filter; RBF: Robust
            %  Bilater Filter; WBF: Weighted Bilateral Filter
            
            sigmaNoise = 30;
            sigmaS = 4;     %  spatial gaussian kernel 
            sigmaR1 = 20;   %  range gaussian kernel for SBF
            sigmaR2 = 20;   %  range gaussian kernel  for RBF
            tol = 0.01;                      
            
            disp('Bilateral Filter (WBF)')
            tic;
            output = 'WBF';
            d_cell{ind} = bilateralFilter_wrapper(im, sigmaNoise, sigmaS, sigmaR1, sigmaR2, tol, output);
            timing(ind) = toc;
            title1st{ind} = 'Bilateral Filter (WBF)';
            
        
        %% TRILATERAL FILTER
        
            %{
            if computeSlowOnes
                
                ind = ind +1;
                % http://www.mathworks.com/matlabcentral/fileexchange/44613-two-dimensional-trilateral-filter
                
                resizeForSpeed = false;
                
                % TAKES FOREVER!!
                disp('TRILATERAL FILTER (2D, slow)')
                if ~resizeForSpeed
                    im2 = im;
                else
                    resizeFactor = 4;
                    disp('   .. downsampling image for trilateral filter')
                    im2 = imresize(im, 1/resizeFactor); % to speedup, downsample
                end

                tic;
                sigmaC = 8;
                epsilon = 0.1;
                if ~resizeForSpeed
                    d_cell{ind} = trilateralFilter(im2,sigmaC,epsilon); 
                    title1st{ind} = 'Trilateral Filter (2D)';
                else
                    imSmall = trilateralFilter(im2,sigmaC,epsilon); 
                    disp('     .. upsampling output image from trilateral filter back to input size')
                    d_cell{ind} = imresize(imSmall, resizeFactor); % upsample again
                    title1st{ind} = 'Trilateral Filter (2D, downs.)';
                end
                timing(ind) = toc;                
                
            end
        %}
            
            
            
        %% NL-MEANS for Gaussian NOISE    
        
            disp('NL-MEANS (Gaussian)')
            ind = ind +1;
            PatchSizeHalf = 5;
            WindowSizeHalf = 3;
            Sigma = 0.05; % the estimated "noise level", now we have a static parameter when 
                          % we could use some adaptive estimate based on the
                          % image itself (or an estimate of the whole stack)
            tic
            maxIn = max(im(:)); % input must be sclaed to [0 1] so we multiply it back after
            d_cell{ind} = maxIn * FAST_NLM_II(im/maxIn, PatchSizeHalf, WindowSizeHalf, Sigma);
            timing(ind) = toc;
            title1st{ind} = 'NL-Means (Gaussian)';
            
            % imshow(d_cell{ind}, [])
            
        %% NL-MEANS for POISSON NOISE
        
            % TAKES FOREVER!!
            if computeSlowOnes
                
                disp('NL-MEANS (Poisson, slow)')
                % im2 = imresize(im, 0.25); % to speedup
                im2 = im;
                
                % See: "poisson_nlmeans_example.m"
                % without this the filter never really converges (PT)
                Q = max(max(im2)) / 20;   % reducing factor of underlying luminosity
                ima_lambda = im2 / Q;
                ima_lambda(ima_lambda == 0) = min(min(ima_lambda(ima_lambda > 0)));
                
                ind = ind +1;
                % http://www.math.u-bordeaux1.fr/~cdeledal/poisson_nlmeans.php

                % Parameters
                hW = 10;                % search window of size (2hW+1)^2
                hB = 3;                 % patches of size (2hW+1)^2
                hK = 6;                 % pre-filtering with convolution by a disk
                                        % of radius 2hK+1
                tol = 0.01/mean2(Q);   % stopping criteria |CSURE(i) - CSURE(i-1)| < tol
                maxIter = 40;

                tic;

                % Pre-filtering with convolution by a disk of radius 2hK+1
                ima_lambda_ma = diskconvolution(ima_lambda, hK);

                % Sure-NL Poisson
                d_cell{ind} = poisson_nlmeans_PT(ima_lambda, ...
                                             ima_lambda_ma, ...
                                             hW, hB, ...
                                             tol, maxIter);
                                         % maxIter added by PT

                % scale back to input
                d_cell{ind} = d_cell{ind} * Q;
                                         
                timing(ind) = toc;
                title1st{ind} = 'NL-MEANS (Poisson)';
                
            end
            
        
        %% GUIDED FILTER
        
            disp('Guided Filter')
            ind = ind +1;
            % http://www.mathworks.com/matlabcentral/fileexchange/33143-guided-filter
            % a bit like bilateral filter, but behaves better on edges
            
            % implemented also on recent version of Matlab by default:
            % http://www.mathworks.com/help/images/ref/imguidedfilter.html
            
            % Kaiming He, Jian Sun, Xiaou Tang, Guided Image Filtering. 
            % IEEE Transactions on Pattern Analysis and Machine Intelligence, Volume 35, Issue 6, pp. 1397-1409, June 2013
            % http://dx.doi.org/10.1109/TPAMI.2012.213
            
                % See also:
                % "MRT Letter: Guided filtering of image focus volume for
                % 3D shape recovery of microscopic objects"
                % http://dx.doi.org/10.1002/jemt.22438
            
            % parameters
            epsilon = .01;
            win_size = 5;
            s = 1; % 1, no subsampling
            
            tic;
            guide = im;
            d_cell{ind} = fastguidedfilter(im, guide, epsilon, win_size, s);
            timing(ind) = toc;
            title1st{ind} = 'Guided Filter';
            
        %% Weighed Guided Filter (WGIF)
        
            %{
            % http://dx.doi.org/10.1109/TIP.2014.237123
            % Weighted Guided Image Filtering 
            
            % parameters
            epsilon = .01;
            win_size = 5;
            
            tic;
            
            % first compute the tubularity
            opts.responsetype=0; %  l1+l2;
            opts.displayOn=false;
            tubularValue_OOF = vesselness_OOF_wrapper(testSlices, [1 6], opts);
            edges = tubularValue_OOF(:,:,sliceIndex);
            guide = edges;
            
                % needs further implementation to work actually, see the
                % paper
            
            % and use the edges as the guide image, otherwise as above
            d_cell{ind} = guided_filter(im, guide, .01, win_size);
            timing(ind) = toc;
            title1st{ind} = 'Weighed Guided Filter';
            %}
            
            
        %% Wavelet Multiframe Denoising (3D, Volume)
        
            % Markus A. Mayer, Anja Borsdorf, Martin Wagner, Joachim
            % Hornegger, Christian Y. Mardin, and Ralf P. Tornow: "Wavelet denoising of multiframe optical coherence tomography data", 
            % Biomedical Optics Express, 2012 (accepted, to appear)
            % From: https://www5.cs.fau.de/research/software/idaa/
            %    -> http://www5.informatik.uni-erlangen.de/fileadmin/Forschung/Software/IDAA/waveletMultiFrame.zip
            
            
        %% Rolling Guidance Filter
        
            %{
            ind = ind +1;
            % http://www.cse.cuhk.edu.hk/leojia/projects/rollguidance/
            % CODE: http://www.cse.cuhk.edu.hk/leojia/projects/rollguidance/download/RollingGuidanceFilter_Matlab.zip
            
            %   @sigma_s   : spatial sigma (default 3.0). Controlling the spatial 
            %                weight of bilateral filter and also the filtering scale of
            %                rolling guidance filter.
            %   @sigma_r   : range sigma (default 0.1). Controlling the range weight of
            %                bilateral filter. 
            %   @iteration : the iteration number of rolling guidance (default 4).
            sigma_s = 3;
            sigma_r = 0.1;
            iteration = 4;
            
            tic
            d_cell{ind} = RollingGuidanceFilter(im,sigma_s,sigma_r,iteration);
                % RGF iteration 2...
                % Error using convnc
                % Out of memory. Type HELP MEMORY for your options.
            timing(ind) = toc;
            title1st{ind} = 'Rolling Guidance Filter';
            %}
            
        %% Non-Local Patch Regression
        
            % https://sites.google.com/site/kunalnchaudhury/Research/code
           
            % Non-Local Patch Regression [Matlab code].
                % http://www.mathworks.com/matlabcentral/fileexchange/40624-non-local-patch-regression
        
        %% Non-Local Patch Regression
        
            % https://sites.google.com/site/kunalnchaudhury/Research/code
                        
            % Non-Local Euclidean Medians [Matlab code].
                % http://www.mathworks.com/matlabcentral/fileexchange/40204-non-local-euclidean-medians
               
        %% TV-Denoising (Total Variational)
        
            % e.g.  http://www.getreuer.info/home/tvreg
            %       http://visl.technion.ac.il/~gilboa/PDE-filt/tv_denoising.html
            
            %       Image Denoising Algorithms Archive
            %       https://www5.cs.fau.de/research/software/idaa/
            
        
        %% SPEEDUP SCHEMES
        
            % Fast High-Dimensional Filtering Using th Permutohedral Lattice        
            % http://graphics.stanford.edu/papers/permutohedral/permutohedral.pdf
            
            % Gaussian KD-Trees for Fast High-Dimensional Filtering
            % https://graphics.stanford.edu/papers/gkdtrees/gkdtrees.pdf
            
        
    %% DISPLAY DENOISING
    
        % save(fullfile('debugMATs', 'resultsSoFar.mat'))
        warning on
    
        % Define quality metrics (short inline fucntions)
        mse = @(a,b) (a(:)-b(:))'*(a(:)-b(:))/numel(a);
        snr = @(clean,noisy) 20*log10(mean(noisy(:))/mean(abs(clean(:)-noisy(:))));
    
        % define the data to be plotted
        noOfDenoisedImages = length(d_cell) - 1;
            
        % define subplot
        rows = 3; cols = noOfDenoisedImages + 1;
            zoomWindow_x = 140:340; zoomWindow_y = 70:270;
                
        % define figure
        close all
        fig = figure;
            scrsz = get(0,'ScreenSize');
            set(fig,  'Position', [0.05*scrsz(3) 0.245*scrsz(4) 0.94*scrsz(3) 0.70*scrsz(4)])
            
            % Go through the denoised images
            for ind = 1 : noOfDenoisedImages + 1
               
                % easier variable name
                d = d_cell{ind};                
                
                % denoised
                sp(ind) = subplot(rows,cols,ind);
                
                    try
                        imshow(d, [])
                    catch err
                        err
                        axis off
                    end
                    
                    try 
                        titStr = sprintf('%s\n %s\n %s', title1st{ind}, ...
                                                       [num2str(timing(ind),3), ' sec'], ...
                                                       ['mse = ' num2str(mse(im,d), 2)]);
                        tit(ind) = title(titStr);
                    catch err
                        err
                        titStr = sprintf('%s\n %s', title1st{ind}, 'some problem')
                        tit(ind) = title(titStr);
                    end
                    
                % difference (normalized)
                j = ind + cols;
                sp(j) = subplot(rows,cols,j);
                    try
                        imshow(abs(im-d), [])
                    catch err
                        err
                        axis off
                    end
                    
                    peakVal = 2^12 - 1; % we have 12-bit microscopy images
                    
                    try 
                        resPSNR(ind) = psnr(d, im, 4095);                    
                        
                        if ind == 1
                            titStr = sprintf('%s\n %s\n', ['\sigma_t_e_s_t = ', num2str(sigmaNoise_test,4)], ...
                                                          ['\sigma_t_e_s_t_R_e_f_i_n_e_d = ', num2str(sigmaNoise_test_refined,4)]);
                        else
                            titStr = sprintf('%s\n %s\n', ['psnr = ', num2str(resPSNR(ind),4), ' dB'], ...
                                                         ['snr = ', num2str(snr(im,d),4), ' dB']);
                        end
                        tit(j) = title(titStr);
                    catch err
                        err
                        tit(j) = title('');
                    end
                                              
                % Zoom
                k = j + cols;
                sp(j) = subplot(rows,cols,k);
                    try
                        imshow(d(zoomWindow_x, zoomWindow_y), [])
                    catch err
                        err 
                        axis off
                    end
                    tit(j) = title('Zoomed View');
                    
            end
            
            export_fig(fullfile('..', 'figuresOut', 'denoiseComparison.png'), '-r300', '-a1')
            
        %% DISPLAY only two methods
        
            % Guided filter vs. NL-Means (Poisson)
            
                % find indices
                indices = strfind(title1st, 'Guided Filter');
                for i = 1 : length(indices)
                   if ~isempty(indices{i})
                      guided_ind = i;
                   end                   
                end

                indices = strfind(title1st, 'NL-MEANS (Poisson)');
                for i = 1 : length(indices)
                   if ~isempty(indices{i}) 
                      nl_ind = i;
                   end                   
                end
                d_cell{ nl_ind} = d_cell{ nl_ind} * Q;
            
            fig2 = figure('Color','w');
                rows = 2; cols = 3;
                scrsz = get(0,'ScreenSize');
                set(fig2,  'Position', [0.025*scrsz(3) 0.025*scrsz(4) 0.96*scrsz(3) 0.95*scrsz(4)])
                
                % gamma correction to bring up the shadows and noise
                gamma = 0.35;
                
                jj = 1;
                sp2(jj) = subplot(rows,cols,jj);
                   
                    im2 = d_cell{1} .^ gamma;
                    im2 = 4095 * im2 / max(im2(:));
                    imshow(im2,[])
                    title([title1st{1}, ' \gamma = ', num2str(gamma)])
                    colorbar
                    
                    sp2(jj+cols) = subplot(rows,cols,jj+cols);
                        axis off
              
                jj = 2;
                sp2(jj) = subplot(rows,cols,jj);
                    im3 = d_cell{guided_ind} .^ gamma;
                    im3 = 4095 * im3 / max(im3(:));
                    imshow(im3,[])
                    title([title1st{guided_ind}, ' \gamma = ', num2str(gamma)])
                    colorbar
                    
                    sp2(jj+cols) = subplot(rows,cols,jj+cols);
                        imshow(abs(d_cell{1}-d_cell{guided_ind}),[])
                        title('Norm. Abs. difference to input')
                        colorbar
                    
                    
                jj = 3;
                sp2(jj) = subplot(rows,cols,jj);
                    im4 = d_cell{nl_ind} .^ gamma;
                    im4 = 4095 * im4 / max(im4(:));
                    imshow(im4,[])
                    title([title1st{nl_ind}, ' \gamma = ', num2str(gamma)])
                    colorbar
                    
                    sp2(jj+cols) = subplot(rows,cols,jj+cols);
                        imshow(abs(d_cell{1} - d_cell{nl_ind}),[])
                        title('Norm. Abs. difference to input')
                        colorbar
            
            % export_fig(fullfile('figuresOut', 'denoiseSelectedComparison.png'), '-r300', '-a1')
    
    % Peak SNR
    function res = psnr(hat, star, std)

        if nargin < 3
            std = std2(star);
        end

        res = 10 * ...
              log(std^2 / mean2((hat - star).^2)) ...
              / log(10);
          
  % Image Enhancement Factor?
      % IEF = Image Enhancement Factor
      % http://www.mathworks.com/matlabcentral/fileexchange/46561-bilateral-filter
