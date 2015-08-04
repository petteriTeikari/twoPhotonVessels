function centerline = extractCenterline(reconstruction, segmentation, options)

    % Direct import from .mat file if needed
    if nargin == 0
        
        close all
        [~, name] = system('hostname');
        name = strtrim(name); % remove white space
        if strcmp(name, 'C7Pajek') % Petteri   
            path = fullfile('/home', 'petteri', 'Desktop', 'testPM', 'out');
            load(fullfile(path, 'reconstructionOut_4slices_binarySegmentationMask.mat'))
        elseif strcmp(name, '??????') % Sharan
            path = fullfile('/home', 'petteri', 'Desktop', 'testPM');
            load(fullfile(path, 'reconstructionOut_4slices_binarySegmentationMask.mat'))        
            %load(fullfile(path, 'testReconstruction_halfRes_4slicesOnly.mat'))        
        end
    else
        % nothing if you use input arguments
    end
    whos