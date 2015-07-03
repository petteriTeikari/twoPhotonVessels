% Image Denoising using Optimally Weighted Bilateral Filters
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Authors: Kollipara Rithwik & Kunal N. Chaudhury
%   
%  Date:  May 14, 2015.
%
%  References:
%
%  [1] K.N. Chaudhury and K. Rithwik, "Image
%  denoising using optimally weighted bilateral
%  filters: A SURE and fast approach,'' Proc. IEEE
%  International Conference on Image Proc., 2015.
%  available: http://arxiv.org/abs/1505.00074.
%
%  [2] K.N. Chaudhury, D. Sage, and M. Unser, 
%  "Fast O(1) bilateral filtering using trigonometric
%  range kernels," IEEE Trans. Image Proc.,
%  vol. 20, no. 11, 2011.
%
%  [3] K.N. Chaudhury, "Acceleration of the
%  shiftable O(1) algorithm for bilateral filtering
%  and non-local means,"  IEEE Transactions on
%  Image Proc., vol. 22, no. 4, 2013.
%
%  Acronyms used:
% 
%  SBF: Standard Bilateral Filter; RBF: Robust
%  Bilater Filter; WBF: Weighted Bilateral Filter
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Modified by Petteri Teikari
function filtered = bilateralFilter_wrapper(f, sigmaNoise, sigmaS, sigmaR1, sigmaR2, tol, output)

    if strcmp(output, 'SBF') || strcmp(output, 'RBF') || strcmp(output, 'WBF')
        % valid argument for output        
    else % could be right away before the co
        error('what output did you want?')
    end

    % derived parameters
    w = 6*round(sigmaS)+1;

    % sigmaS = 4;        %  spatial gaussian kernel 
    % sigmaR1 = 20;    %  range gaussian kernel for SBF
    % sigmaR2 = 20;    %  range gaussian kernel  for RBF
    % tol = 0.01;

    % PT: QUICK FIX
    % double(uint8()) : otherwise the local dynamic range is too much for
    %                   the truncation part
    
    % compute SBF and divergence
    L = 0;
    [M, N] = computeTruncation(double(uint8(f)), sigmaR1, w, tol);
    [f1, div1] = computeDivergence(f, f, sigmaS,sigmaR1,L,w,N,M);
    if strcmp(output, 'SBF')
        filtered = f1;
        return
    end
    
    % compute RBF and divergence
    L = 1;
    h = ones(2*L+1, 2*L+1) /((2*L+1)^2) ;
    barf  =  imfilter(f,h);
    [M, N] = computeTruncation(double(uint8(barf)), sigmaR2, w, tol);
    [f2, div2] = computeDivergence(f, barf,sigmaS,sigmaR2,L,w,N,M);
    if strcmp(output, 'RBF')
        filtered = f2;
        return
    end

    % compute optimal weights
    A = [norm(f1,'fro')^2,  sum(sum(f1.*f2));
             sum(sum(f1.*f2)), norm(f2,'fro')^2];
    b = [sum(sum(f1.*f)) - sigmaNoise^2*div1; 
            sum(sum(f2.*f)) - sigmaNoise^2*div2];
    theta = A\b; 

    % form the WBF
    bfoptSURE = theta(1)*f1 + theta(2)*f2;
    
    if strcmp(output, 'WBF')
        filtered = bfoptSURE;
    else % should never really go here unless code is changed in some way
        error('how did the "output" change during the execution?')
    end

