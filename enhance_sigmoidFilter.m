function imOut = enhance_sigmoidFilter(im, gain, cutoff)

    im = im / max(im(:));
    im = im*255;

    if nargin == 1
        gain = 0.2; cutoff = 0.025;   
    end
    
    % Apply Sigmoid function
    if length(size(im)) == 2
        imOut =  1./(1 + exp(gain*(cutoff-im)));  
        maxValue = max(imOut(:));
        
    elseif length(size(im)) == 3
        imOut = zeros(size(im));
        for i = 1 : size(im,3)
            imOut(:,:,i) =  1./(1 + exp(gain*(cutoff-im(:,:,i))));  
        end
        maxValue = max(imOut(:));
    end
    
    % normalize
    imOut = imOut - min(imOut(:));
    imOut = imOut / maxValue;