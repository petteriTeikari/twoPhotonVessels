function [img, vessel, edgeCheat, GVF] = input_segmentationTestData(fileMat, resizeOn, resizeFactor, plotOn)
        
    load(fileMat)   

    vesselness = oof_3D; % or oofOfa_2D
    sliceIndex = 1; % easier to display just one slice than the whole volume

    % resize to speed up things

    if resizeOn

        for i = 1 : size(im,3)
            
            % Denoised with PureDenoise (ImageJ plugin)
            img(:,:,i) = imresize(im(:,:,i), resizeFactor);
            
            % scales = [2 5]; % scales
            vessel(:,:,i) = imresize(oof_3D(:,:,i), resizeFactor);       

            % manually refined edges from Canny, and only for one slice
            % see "createVesselnessMeasuresFromSubstack.m"
            edgeCheat(:,:,i) = imresize(edgesFill, resizeFactor);

            % GVF ( mu 0.01, iter = 512 )
            GVF(:,:,i) = imresize(gvf_OOF(:,:,i), resizeFactor);
                % GVF_im is the GVF of the stack
        end

    else

        img = im;
        vessel = oof_3D;
        edgeCheat = edgesFill;
        GVF = gvf_OOF;

    end
    
    img = double(img);
    
    if plotOn
        
        fig = figure('Color', 'w')
        scrsz = get(0,'ScreenSize'); % get screen size for plotting    
            rows = 4; cols = 2;            
            set(fig,  'Position', [0.12*scrsz(3) 0.05*scrsz(4) 0.30*scrsz(3) 0.90*scrsz(4)])
            
        sliceIndex = 1;
            
        i = 1;
        sp(i) = subplot(rows,cols,i);
            imshow(im(:,:,sliceIndex), []); title(['Input (slice = ', num2str(sliceIndex), ')'])
            colorbar
            
        i = i+1;
        sp(i) = subplot(rows,cols,i);
            imshow(oof_3D(:,:,sliceIndex), []); title(['3D OOF'])
            colorbar
            drawnow
          
        i = i+1;
        sp(i) = subplot(rows,cols,i);
            imshow(edges(:,:,sliceIndex), []); title(['Edges (from Canny)'])
            colorbar
            
        i = i+1;
        sp(i) = subplot(rows,cols,i);
            imshow(edgesFill(:,:,sliceIndex), []); title(['Edges Filled'])
            colorbar
            
        i = i+1;
        sp(i) = subplot(rows,cols,i);
            imshow(gvf_OOF(:,:,sliceIndex), []); title(['GVF 3D (OOF)'])
            colorbar
            
        i = i+1;
        sp(i) = subplot(rows,cols,i);
            imshow(gvf_im(:,:,sliceIndex), []); title(['GVF 3D (Input)'])
            colorbar
            
        i = i+1;
        sp(i) = subplot(rows,cols,i);
            gvfIm = gvf_im(:,:,sliceIndex); gvfIm = gvfIm / max(gvfIm(:));
            gvfOOF = gvf_OOF(:,:,sliceIndex); gvfOOF = gvfOOF / max(gvfOOF(:));
            
            diff = abs(gvfIm - gvfOOF);
            imshow(diff, []); title(['abs[norm(GVF Input - GVF OOF)]'])
            colorbar
        
        export_fig(fullfile('testData', 'inputPlot.png'), '-r300', '-a1')
            
    end