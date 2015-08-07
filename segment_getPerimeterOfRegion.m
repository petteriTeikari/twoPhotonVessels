function edgesPerim = segment_getPerimeterOfRegion(region, removeBorders)
        
        se = strel('square', 3);
        BWerode = imerode(region, se);
        edgesPerim = logical(abs(imsubtract(BWerode, region)));
        
        if removeBorders
           
            regionMask = ones(size(region));
            ind1 = floor(0.05*size(region,1)); ind2 = ceil(0.95*size(region,1));
            regionMask(ind1:ind2, ind1:ind2, :) = 0;
            edgesPerim = regionMask .* edgesPerim;
        end