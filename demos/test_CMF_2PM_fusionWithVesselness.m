function [uu, erriter, num, tt] = test_CMF_2PM_fusionWithVesselness
%
%   Function test_CMF
%
%   The matlab function to show how to use the functions CMF_Mex and CMF_GPU
%
%   Before using the functions CMF_mex, you should compile it as follows:
%       >> mex CMF_mex.c
%
%   Before using the functions CMF_GPU, you should compile the GPU program:
%       >> nvmex -f nvmexopts.bat CMF_GPU.cu -IC:\cuda\v4.0\include -LC:\cuda\v4.0\lib\x64 -lcufft -lcudart
%
%   After compilation, you can define all the parameters (penalty, C_s, C_t, para) as follows: 
%   
%        - penalty: point to the edge-weight penalty parameters to
%                   total-variation function.
% 
%          For the case without incorporating image-edge weights, 
%          penalty is given by the constant everywhere. For the case 
%          with image-edge weights, penalty is given by the pixelwise 
%          weight function:
% 
%          for example, penalty(x) = b/(1 + a*| grad f(x)|) where b,a > 0 .
% 
%        - C_s: point to the capacities of source flows ps
% 
%        - C_t: point to the capacities of sink flows pt
% 
%        - para: a sequence of parameters for the algorithm
%             para[0,1]: rows, cols of the given image
%             para[2]: the maximum iteration number
%             para[3]: the error bound for convergence
%             para[4]: cc for the step-size of augmented Lagrangian method
%             para[5]: the step-size for the graident-projection step to the
%                    total-variation function. Its optimal range is [0.1, 0.17].
% 
%
%        Example:
%            >> [u, erriter, i, timet] = CMF_GPU(single(penalty), single(Cs), single(Ct), single(para));
%
%            >> us = max(u, beta);  % where beta in (0,1)
%
%            >> imagesc(us), colormap gray, axis image, axis off;figure(gcf)
%
%            >> figure, loglog(erriter,'DisplayName','erriterN');figure(gcf)
%
%
%
%   Please email Jing Yuan (cn.yuanjing@gmail.com) for any questions, 
%   suggestions and bug reports
%
%   The Software is provided "as is", without warranty of any kind.
%
%               Version 1.0
%   https://sites.google.com/site/wwwjingyuan/       
%
%   Copyright 2011 Jing Yuan (cn.yuanjing@gmail.com)   
%

% ur = double(imread('cameraman.jpg'))/255;
load(fullfile('..', 'debugMATs', 'testVessels2D.mat'))

ur = im / max(im(:)); % normalize the input to 0 - 1
imOrig = ur;
[rows, cols] = size(ur);

varParas = [rows; cols; 300; 1e-4; 0.3; 0.16];
%                para 0,1 - rows, cols of the given image
%                para 2 - the maximum number of iterations
%                para 3 - the error bound for convergence
%                para 4 - cc for the step-size of augmented Lagrangian method
%                para 5 - the step-size for the graident-projection of p

penalty = 0.5*ones(rows,cols);
% 1) OOF, 
edges = abs(oof / max(oof(:)));
gain = 5; cutoff = 0.025;  % trial-and-error set
edges =  1./(1 + exp(gain*(cutoff-edges)));  % Apply Sigmoid function
edges = edges / max(edges(:));
edges = imadjust(edges);
ur2 = edges;

% Now these are static, try to make more adaptive in the future based on
% the actual image coming in
ulab(1) = 0.001;
ulab(2) = 0.4;

gain = 5; cutoff = 0.5; % trial-and-error set
ur =  1./(1 + exp(gain*(cutoff-ur)));  % Apply Sigmoid function
ur = ur  / max(ur(:));

% build up the priori data terms
fCs = abs(ur - ulab(1)); % C_s: point to the capacities of source flows ps
fCt = abs(ur - ulab(2)); % C_t: point to the capacities of sink flows pt

% for vesselness as the image
fCs_oof = abs(ur2 - ulab(1)); % C_s: point to the capacities of source flows ps
fCt_oof = abs(ur2 - ulab(2)); % C_t: point to the capacities of sink flows pt

%  Use the function CMF_Mex to run the algorithm on CPU

% 1) original bitmap with no penalty
[uu, erriter,num,tt] = CMF_mex(single(penalty), single(fCs), single(fCt), single(varParas));

% 2) vesselness as the image (OOF), with no penalties
[uu2, erriter2, num2, tt2] = CMF_mex(single(penalty), single(fCs_oof), single(fCt_oof), single(varParas));

% 3) vesselness as the image (OOF), with penalties
[uu3, erriter3, num3, tt3] = CMF_mex(single(edges), single(fCs_oof), single(fCt_oof), single(varParas));


% DISPLAY

     fig = figure('Color','w');

        scrsz = get(0,'ScreenSize'); % get screen size for plotting 
        set(fig,  'Position', [0.03*scrsz(3) 0.145*scrsz(4) 0.85*scrsz(3) 0.70*scrsz(4)])
        row = 2; col = 6;
    
    i = 1;
    subplot(row, col, i)
        imshow(imOrig,'DisplayRange',[0 1]); hold on; 
        c = contours(uu,[0,0]);
        zy_plot_contours(c,'linewidth',1);
        title('Input')

    subplot(row, col, i+col)
        imshow(penalty,'DisplayRange',[0 1])
        title('Penalty (None)')
        drawnow
        
    i = i+1;
    subplot(row, col, i)
        imshow(ur2,'DisplayRange',[0 1]); hold on; 
        c = contours(uu2,[0,0]);
        zy_plot_contours(c,'linewidth',1);
        title('OOF as Image')
                    
    subplot(row, col, i+col)
        imshow(penalty,'DisplayRange',[0 1])
        title('Penalty (none)')
        drawnow
        
    i = i+1;
    subplot(row, col, i)
        imshow(ur2,'DisplayRange',[0 1]); hold on; 
        c = contours(uu3,[0,0]);
        zy_plot_contours(c,'linewidth',1);
        title('OOF as Image')
    
    subplot(row, col, i+col)
        imshow(edges,'DisplayRange',[0 1])
        title('Penalty (OOF)')
        drawnow
        
    i = i+1;
    subplot(row, col, i)
        imshow(uu3,'DisplayRange',[0 1]); hold on; 
        title('Segmentation Image')

    subplot(row, col, i+col)
    
        level = graythresh(edges)
        edgesBw = im2bw(edges, level);
        
        imshow(edgesBw,'DisplayRange',[0 1])
        title('Segmentation Binary')
        drawnow
        
    i = i+1;
    subplot(row, col, i)
        weighedSegmentation = uu3 .* imOrig;
        imshow(weighedSegmentation, 'DisplayRange',[0 1]); hold on; 
        title('w = Segmentation Image \cdot Input')

    subplot(row, col, i+col)
    
        imshow(weighedSegmentation,'DisplayRange',[0 1]); hold on; 
        c = contours(uu3,[0,0]);
        zy_plot_contours(c,'linewidth',1);
        title('"Final Segmentation"')
        drawnow

    i = i+1;
    subplot(row, col, i)
        diff = abs(weighedSegmentation - imOrig);
        imshow(diff, []); hold on; 
        title('norm(abs(w - input))')

    subplot(row, col, i+col)
        imshow(diff,'DisplayRange',[0 1]); hold on; 
        title('abs(w - input)')
        drawnow