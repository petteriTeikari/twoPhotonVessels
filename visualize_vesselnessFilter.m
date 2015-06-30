function visualize_vesselnessFilter(imageStack, OOF, MDOF, options)

    if nargin == 0
        % load vesselVisualization.mat
        close all
        whos
    else
        % save vesselVisualization.mat
    end
    
    
    subplot(2,2,1)
        I = max(imageStack,[],3);
        imshow(I, []); title('Input MIP')
    
    subplot(2,2,2)
        I = max(OOF,[],3);
        imshow(I, []); title('OOF MIP')
        
    subplot(2,2,3)
        I = max(MDOF,[],3);
        imshow(I, []); title('MDOF MIP')
      
    subplot(2,2,4)
        [I, tubularity] = segment_enhanceTubularityForImage(I);
        imshow(I, []); title('MDOF MIP (sigmoid enhanced)')  
    
        whos