function imTest = reshapeImageForNoiseTest(im, options)

    [rows,cols] = size(im);
    
    rows_numberOfFiveBlocks = floor(rows/5);
    cols_numberOfFiveBlocks = floor(cols/5);
    
    rows_new = rows_numberOfFiveBlocks * 5;
    cols_new = cols_numberOfFiveBlocks * 5;
    
    % simply crop
    imTest = im(1:rows_new, 1:cols_new);