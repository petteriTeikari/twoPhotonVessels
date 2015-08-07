function [imageStack, fusionImageStack, fusionImageStackBright, vesselnessStack, edges, edgesSigmoid] ...
            = segment_asetsPreProcessImages(imageStack, vesselnessStack)
        
        % normalize inputs (just to be sure)
        imageStack = imageStack / max(imageStack(:));
        vesselnessStack = vesselnessStack / max(vesselnessStack(:));

        % find edges from vesselness stack that could be used as
        % regularization term for the segmentation
        edges = zeros(size(vesselnessStack));
        for i = 1 : size(vesselnessStack,3)
            edges(:,:,i) = segment_findEdges(vesselnessStack(:,:,i), 0);
        end        
        edges = abs(vesselnessStack);
        edges = edges / max(edges(:));            
        
        % boosts mid-tones up
        edgesSigmoid = enhance_sigmoidFilter(edges);

        % fusion image
        vesselnessStackPositive = vesselnessStack;
        vesselnessStackPositive(vesselnessStackPositive > 1) = 1; % clip

        % add only if vesselnessStackPositive is larger than img
        largerMask = vesselnessStackPositive > imageStack;
        vesselnessStackPositive(~largerMask) = 0;
        fusionImageStack = imageStack + vesselnessStackPositive;
        fusionImageStack(fusionImageStack > 1) = 1; % clip      
        
        % clip above threshold to boost mid-tones again
        fusionImageStackBright = enhance_brightenVessels(fusionImageStack);