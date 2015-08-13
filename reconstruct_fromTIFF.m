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
        
        imageStack(:,:,k) = double(tmpRead(1:dimXY, 1:dimXY));
        
    end

    % we assume that the TIFF has been already segmented
    segmentation = imageStack;
    
    % placeholder
    options = [];
    t = 1; ch = 1;
    
    segmentationAlgorithm = 'fromTIFF';
    reconstructionAlgorithm = 'marchingCubes';
    isoValue = 0.1;
    
    reconstruction = reconstructMeshFromSegmentation(imageStack, path, ...
                            segmentationAlgorithm, reconstructionAlgorithm, isoValue, options, t, ch);
    whos