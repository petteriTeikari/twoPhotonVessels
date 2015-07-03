function denoise_demoGuidedFilter() 
    
    %% Import test data
    load(fullfile('..', 'debugMATs', 'testSlices.mat'))
    
        % z-slices of 9-11 from first time point of:
        % "CP-20150323-TR70-mouse2-1-son.oib" from Charissa
        
        % we use just one slice for testing
        sliceIndex = 2;
        im = testSlices(:,:,sliceIndex);
        
        % parameters
        computeSlowOnes = true;
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
        sigma.Noise_test = noiseest(imTest, valrange, p);
        sigma.Noise_test_refined = refinednoiseest(imTest, valrange);
        
        
    %% ALGORITHMS
    
        ind = 1;
        d_cell{ind} = im;
        timing(ind) = 0;
        title1st{ind} = 'Input';
    
        
        %% GUIDED FILTER
        
            disp('Guided Filter')
            
            % parameters
            % see e.g. Fig 2 of http://dx.doi.org/10.1109/TPAMI.2012.213
            epsilonVector = [0.1 0.2 0.4].^2;
            winVector = [2 4 8];
            s = 1; % 1, no subsampling
            
            for j = 1 : length(epsilonVector)
                for k = 1 : length(winVector)
                    
                    epsilon = epsilonVector(j);
                    win_size = winVector(k);
                    
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

                    tic;
                    guide = im;
                    d_cell{ind} = fastguidedfilter(im, guide, epsilon, win_size, s);
                    % d_cell{ind} = guidedfilter(im, guide, epsilon, win_size);
                    timing(ind) = toc;
                    title1st{ind} = ['GIF, \epsilon=', num2str(epsilon), ', w=', num2str(win_size)];
                    
                end
            end
            
        
    %% DISPLAY DENOISING
    
        visualize_denoisingDemo(d_cell, timing, title1st, sigma)
        export_fig(fullfile('..', 'figuresOut', 'guidedDenoisingComparison.png'), '-r300', '-a1')
    