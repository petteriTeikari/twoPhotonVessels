function [denoised, timeExecDenoising] = denoise_NLMeansPoissonWrapper(imageIn, hW, hB, hK)
            
    if nargin == 1
        disp('only one input argument, use default values')
        hW = 10;
        hB = 3;
        hK = 6;
    end

    % http://www.math.u-bordeaux1.fr/~cdeledal/poisson_nlmeans.php
    disp(' ')
    disp('Denoising the stack using NL-Means for Poisson-noise corrupted images (slow)')
    disp('     from: http://www.math.u-bordeaux1.fr/~cdeledal/poisson_nlmeans.php')

    % TIME: roughly takes 5-6 hours (!) for 67 slices at Petteri's computer
    % (single thread, with no parfor)

    tic;      
        
    % test of reshape
    % imageIn = reshape(imageIn, size(imageIn,1), size(imageIn,2)*size(imageIn,3));
        % not really any faster?

    % slice-by-slice denoising    
    parfor slice = 1 : size(imageIn,3)

        disp(['  Slice = ', num2str(slice), '/', num2str(size(imageIn,3))])
        im = double(imageIn(:,:,slice));


        % See: "poisson_nlmeans_example.m"
        % without this step the filter never really converges (PT)
        Q = max(max(im)) / 20;   % reducing factor of underlying luminosity
        ima_lambda = im / Q;
        ima_lambda(ima_lambda == 0) = min(min(ima_lambda(ima_lambda > 0)));

        % Parameters
        hW; % search window of size (2hW+1)^2
                          % def. 10 in code, 21 in the paper
        hB; % patches of size (2hW+1)^2
                          % def. 3 in code, 7 in the paper
        hK; % pre-filtering with convolution by a disk
                          % of radius 2hK+1
                          % % def. 6 in code, 13 in the paper

        tol = 0.01/mean2(Q); % stopping criteria |CSURE(i) - CSURE(i-1)| < tol
        maxIter = 40;

        % Pre-filtering with convolution by a disk of radius 2hK+1
        ima_lambda_ma = diskconvolution(ima_lambda, hK);

        % Sure-NL Poisson
        im = poisson_nlmeans_PT(ima_lambda, ...
                                     ima_lambda_ma, ...
                                     hW, hB, ...
                                     tol, maxIter);
                                     % maxIter added by PT

        % scale back to input
        denoisedCell{slice}(:,:) = im * Q;
        
        % dlmwrite(fullfile('temp', ['slice', num2str(slice), '_isDone.txt']), [1])

    end   
    
    % Put back to a matrix    
    denoised = zeros(size(imageIn));    
    for i = 1 : length(denoisedCell)
        denoised(:,:,i) = denoisedCell{i};
    end
    
    timeExecDenoising = toc;