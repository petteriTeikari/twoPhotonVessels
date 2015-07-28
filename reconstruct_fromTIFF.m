function reconstruct_fromTIFF(fileName)

    if nargin == 0
        fileName = fullfile('/home/petteri/Desktop','CroppedImage.tif');
    end

    info = imfinfo(fileName);
    num_images = numel(info);
    for k = 1:num_images
        
        tmpRead = imread(fileName, k);
        
        % Marching cubes want the x and y dimensions to be the same, fix
        % quickly
        [yRes,xRes] = size(tmpRead);
        dimXY = min([yRes xRes]);
        
        imageStack(:,:,k) = tmpRead(1:dimXY, 1:dimXY);
        
    end

    % we assume that the TIFF has been already segmented
    segmentation = imageStack;
    
    % placeholder
    options = [];

    reconstruction = reconstructSegmentation(imageStack, segmentation, options);
    whos