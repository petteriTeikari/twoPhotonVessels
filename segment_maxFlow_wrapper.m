function [uu, weighed, uu_binary] = maxFlow_wrapper(imageStack, tubularity, parameters, ulab, ...
                                                        visualizeOn, saveOn, useTubularityAsImage, options)

        % parameters = [rows; cols; heights; 200; 5e-4; 0.35; 0.11];
        %                para 0,1,2 - rows, cols, heights of the given image
        %                para 3 - the maximum number of iterations
        %                para 4 - the error bound for convergence
        %                para 5 - cc for the step-size of augmented Lagrangian method
        %                para 6 - the step-size for the gradient-projection of p

    
        
    % normalize first
    if useTubularityAsImage
        ur = double(tubularity) / max(tubularity(:));
        [ur, tubularity] = segment_enhanceTubularityForImage(ur);
    else
        ur = double(imageStack) / max(imageStack(:));
    end
    [rows, cols, slices] = size(ur);   
    disp(['Fast Continuous Max-Flow Algorithm to Min-Cut | no of slices = ', num2str(slices)])
    % http://www.mathworks.com/matlabcentral/fileexchange/34126-fast-continuous-max-flow-algorithm-to-2d-3d-image-segmentation

    % penalty = 0.2 * ones(rows, cols, heights); % uniform penalty
    % construct the penalty from the tubularity
    penalty = tubularity;

    % build up the priori L_2 data terms
    fCs = abs(ur - ulab(1)); % C_s: point to the capacities of source flows ps
    fCt = abs(ur - ulab(2)); % C_t: point to the capacities of sink flows pt

    %  Use the function CMF3D_mex to run the algorithm on CPU
    try
        [uu, erriter, num, tt] = CMF3D_mex(single(penalty), single(fCs), single(fCt), single(parameters));
        % [uu, erriter,num,tt] = CMF3D_GPU(single(penalty), single(fCs), single(fCt), single(parameters));
    catch err        
        if strcmp(err.identifier, 'MATLAB:UndefinedFunction') && ...
                ~isempty(strfind(err.message, 'CMF3D'))
            error('CMF_3D not found from path, you need to add it')            
        else            
            err
            err.identifier            
        end
    end
    disp(['  - No of iterations = ', num2str(num), ', computation time = ', num2str(tt / 1000, 4), ' seconds, ', num2str(tt / 1000 / slices, 4), ' sec/slice'])
    
    % Output
    
        % Now the uu is not a binary image, so we can return either uu
        % directly, or threshold it (see us below), or weigh it with the
        % input
        weighed = uu .* imageStack;
        level = 0; % zeroes are background
        
        uu_binary = zeros(rows, cols, slices);
        for i = 1 : size(tubularity, 3)
            uu_binary(:,:,i) = im2bw(uu(:,:,i), level);
        end
    
    % DISPLAY
    if visualizeOn
        
        titleStr = 'MaxFlow';
        
        % DISPLAY
        beta = 0.8; % if you wanna thresholded segmentation
        us = max(uu, beta);  % where beta in (0,1)
        % figure, loglog(erriter,'DisplayName','erriterN');
        fig = figure(gcf);
            scrsz = get(0,'ScreenSize'); % get screen size for plotting
            set(fig,  'Position', [0.025*scrsz(3) 0.55*scrsz(4) 0.40*scrsz(3) 0.40*scrsz(4)])
            isosurface(uu,0.5)
        
        % visualize_vesselSegmentation(imageStack, OOF, uu, titleStr, saveOn, options)        
        visualize_vesselSegmentationSlices(imageStack, tubularity, uu, titleStr, saveOn, options)
        
    end
    
    
%% SUBFUNCTION    
    
    