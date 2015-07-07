function reconstruction = reconstructSegmentation(imageStack, segmentation, options)

    % Direct import from .mat file if needed
    if nargin == 0
        close all
        load(fullfile('/home', 'petteri', 'Desktop', 'testPM', 'testReconstruction.mat'))        
    else
        save(fullfile('/home', 'petteri', 'Desktop', 'testPM', 'testReconstruction.mat'));        
    end
    
    % See PDF for details
    
    % this at the moment requires the most work, or literature review. This
    % step can also be very time-consuming so we might want to think of
    % ways of how to batch process so that the analysis part could be done
    % for example for batch-processed reconstructions   

    disp('3D Reconstruction (dummy)')
    reconstruction = segmentation;    
    
    % if you just want to write the segmented version here to disk, and to
    % imported by a 3rd party software, you can use the export_stack_toDisk
    % which saves the stack as non-OME multilayer TIFF file (.tif),
    % converts to 16-bit and scales the maximum intensity value to 65,535
    disp('Writing the segmented stack to disk as a TIFF file')
    export_stack_toDisk(fullfile('figuresOut', 'segmentedStack.tif'), segmentation)
    whos    
    
    %       Name                  Size                 Bytes  Class     Attributes
    % 
    %   imageStack          256x256x4            2097152  double              
    %   options               1x1                   3931  struct              
    %   reconstruction      256x256x4            1048576  single              
    %   segmentation        256x256x4            1048576  single              
    
    % quick'n'dirty ploy
    fig = figure('Color','w');
    
        % Maximum Intensity projections of the test stack
        subplot(1,2,1)
            imshow(max(imageStack,[],3),[])
            title('Denoised stack (non-segmented')
        subplot(1,2,2)    
            imshow(max(segmentation,[],3),[])
            title('Segmented stack')


    
    
    
    
   