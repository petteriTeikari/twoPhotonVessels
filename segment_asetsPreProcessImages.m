function [imageStack, fusionImageStack, fusionImageStackBright, vesselnessStack, edges, edgesSigmoid, im_bias_corrected] ...
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
        
        % try to correct the "uneven illumination"
        im_bias_corrected = zeros(size(imageStack));
        im_bias = zeros(size(imageStack));
        for i = 1 : size(imageStack, 3)
            
            % 1st guess with manually-tuned operator
            % http://www.mathworks.com/help/images/examples/correcting-nonuniform-illumination.html
            background = imopen(fusionImageStackBright(:,:,1),strel('disk',75));
            fusionImageBackgroundRemoved(:,:,i) = fusionImageStackBright(:,:,i) - background;

            % 2nd Guess with the bias corrector
            % http://www.mathworks.com/matlabcentral/fileexchange/27315-nu-corrector
            [im_bias_corrected(:,:,i), im_bias(:,:,i)] = biasCorrection_bipoly_PT(fusionImageStackBright(:,:,i), 5);
            im_bias_corrected(:,:,i) = im_bias_corrected(:,:,i) - min(min(im_bias_corrected(:,:,i)));
            im_bias_corrected(:,:,i) = im_bias_corrected(:,:,i) / max(max(im_bias_corrected(:)));

            % do not allow the image to be brightened
            whos
            brightMask = im_bias_corrected(:,:,i) > fusionImageStackBright(:,:,i);
            imBiasTemp = im_bias_corrected(:,:,i);
            fusionTemp = fusionImageStackBright(:,:,i);
            imBiasTemp(brightMask) = fusionTemp(brightMask);
            im_bias_corrected(:,:,i) = imBiasTemp;
            im_bias_corrected(:,:,i) = im_bias_corrected(:,:,i) + vesselnessStackPositive(:,:,i);

            % im_bias_corrected2 = fusionImageStackBright(:,:,1) - double(im_bias);
            
        end
        
        %{
        subplot(1,3,1);
        imshow(fusionImageStackBright(:,:,1), [])
        subplot(1,3,2);
        imshow(im_bias,[])
        subplot(1,3,3);
        imshow(im_bias_corrected,[])
        %}
        
        