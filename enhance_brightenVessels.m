function imOut = enhance_brightenVessels(im)
 
    % quick'n'dirty 
    
    % we clip the "foreground" of Otsu's threshold output (above level)
    % this in practice seems to produce better segmentation results, but we
    % have to see about the robustness of this

    % One slice
    if length(size(im)) == 2    
        im = im / max(im(:));
        level = graythresh(im);
        imOut = im * (1/level);
        imOut(imOut > 1) = 1; % clip
        
    % Stack
    elseif length(size(im)) == 3
        imOut = zeros(size(im));
        for i = 1 : size(im,3)
            imSlice = im(:,:,i);
            imSlice = imSlice / max(imSlice(:));
            level = graythresh(imSlice);
            imSlice = imSlice * (1/level);
            imSlice(imSlice > 1) = 1; % clip
            imOut(:,:,i) = imSlice;
        end
    end
        