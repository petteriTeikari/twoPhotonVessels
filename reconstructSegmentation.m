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
    
    % quick'n'dirty ploy
    fig = figure('Color','w');
    
    % Maximum Intensity projections of the test stack
    subplot(1,2,1)
        imshow(max(imageStack,[],3),[])
    subplot(1,2,2)    
        imshow(max(segmentation,[],3),[])
    
    
    
    
    
    
   