function denoise_demoNLPoisson() 
    
    %% Import test data
    load(fullfile('..', 'debugMATs', 'testSlices.mat'))
        % z-slices of 9-11 from first time point of:
        % "CP-20150323-TR70-mouse2-1-son.oib" from Charissa
        
        % we use just one slice for testing
        sliceIndex = 2;
        im = testSlices(:,:,sliceIndex);        
        
        
            % take just a subset of the image to reduce the computation
            % time
            im = im(162:402, 41:281);
            % im = imresize(im, 0.5); % even faster

        
    %% EVALUATE INPUT NOISE
    
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
        
            disp('NL-Means (Poisson) Filter')
            
            % parameters
            % see e.g. Fig 2 of http://dx.doi.org/10.1109/TPAMI.2012.213
            hWVector = [10 21]; % def. 10 in code, 21 in the paper
            hBVector = [3 7]; % def. 3 in code, 7 in the paper
            hKVector = [6 13]; % def. 6 in code, 13 in the paper
            
            % See: "poisson_nlmeans_example.m"
            % without this the filter never really converges (PT)
            Q = max(max(im)) / 20;   % reducing factor of underlying luminosity
            ima_lambda = im / Q;
            ima_lambda(ima_lambda == 0) = min(min(ima_lambda(ima_lambda > 0)));
            
            for j = 1 : length(hWVector)
                for k = 1 : length(hBVector)
                    for l = 1 : length(hKVector)

                        ind = ind +1;
                        % http://www.math.u-bordeaux1.fr/~cdeledal/poisson_nlmeans.php

                        % Parameters
                        hW = hWVector(j); % search window of size (2hW+1)^2
                        hB = hBVector(k); % patches of size (2hW+1)^2
                        hK = hKVector(l); % pre-filtering with convolution by a disk
                                                % of radius 2hK+1
                        tol = 0.01/mean2(Q); % stopping criteria |CSURE(i) - CSURE(i-1)| < tol
                        maxIter = 40;

                        tic;

                        % Pre-filtering with convolution by a disk of radius 2hK+1
                        ima_lambda_ma = diskconvolution(ima_lambda, hK);

                        % Sure-NL Poisson
                        whos
                        d_cell{ind} = poisson_nlmeans_PT(ima_lambda, ...
                                                     ima_lambda_ma, ...
                                                     hW, hB, ...
                                                     tol, maxIter);
                                                 % maxIter added by PT

                        % scale back to input
                        d_cell{ind} = d_cell{ind} * Q;

                        timing(ind) = toc;
                        title1st{ind} = ['NL, w=', num2str(hW), ', B=', num2str(hB), ', K=', num2str(hK)];
                    end
                end
            end
            
        
    %% DISPLAY DENOISING
    
        save poissonResults.mat
        visualize_denoisingDemo(d_cell, timing, title1st, sigma)
        export_fig(fullfile('figuresOut', 'NLMPoisson_DenoisingComparison.png'), '-r300', '-a1')
    