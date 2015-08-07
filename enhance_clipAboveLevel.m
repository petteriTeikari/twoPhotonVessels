function imOut = enhance_clipAboveLevel(im, level)

    % normalize
    im = im / max(im(:));

    % get threshold with Otsu's method
    if nargin == 1
        level = graythresh(im);
    end
    
    % clip values above that
    multiplier = 1 / level;
    
    imOut = im * multiplier;
    imOut(imOut > 1) = 1;
    
    
    