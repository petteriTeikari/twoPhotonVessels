function visualize_vesselSegmentation(imageStack, tubularity, segmentation, titleString, saveOn, options)

    if nargin == 0
        load testVisualize3Dsegmentation.mat
        close all
        whos
    else
        save testVisualize3Dsegmentation.mat
    end
    
    % Init figure
    fig = figure('Name', titleString);
        rows = 2;
        cols = 3;
        drawnow
    
        % INPUT
        i=1;
        sp(i) = subplot(rows,cols,i);
            slice_wrapper(imageStack, i, 'Input')
            
            sp(i+cols) = subplot(rows,cols, i+cols);
                mip_wrapper(imageStack, i, 'Input') % MIP
                
        % TUBULARITY
        i=2;
        sp(i) = subplot(rows,cols,i);
            slice_wrapper(tubularity, i, 'Tubularity')
            
            sp(i+cols) = subplot(rows,cols, i+cols);
                mip_wrapper(tubularity, i, 'Tubularity') % MIP
            
        % SEGMENTATION
        i=3;
        sp(i) = subplot(rows,cols,i);
            slice_wrapper(segmentation, i, titleString)
            
            sp(i+cols) = subplot(rows,cols, i+cols);
                 mip_wrapper(segmentation, i, titleString) % MIP

        % Use subfunction for saving
        if saveOn
            save_plotToDisk(fig, fileNameOut, options)
        end
        
        
    function slice_wrapper(stack, i, titleString)
        sizeIn = size(stack);
        contourslice(stack, [], [], [1:size(stack,3)]);    
            view(3);            
            titStr = sprintf('%s\n%s', titleString, ['Range: ', num2str(min(stack(:))), ':', num2str(max(stack(:)))]);
            title(titStr)
            axis tight; axis square;
            drawnow
        
    function mip_wrapper(stack, i, titleString)
        sizeIn = size(stack);
        try
            imshow(mip(stack, 'z', 'max'), 'DisplayRange', [min(stack(:)) max(stack(:))])
        catch err
            warning(err.message)
            imshow(mip(stack, 'z', 'max'))
        end
        axis tight; axis square;
        drawnow