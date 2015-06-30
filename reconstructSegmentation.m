function reconstruction = reconstructSegmentation(segmentation, options)

    disp('3D Reconstruction (dummy)')
    reconstruction = segmentation;
    
    % See PDF for details
    
    % this at the moment requires the most work, or literature review. This
    % step can also be very time-consuming so we might want to think of
    % ways of how to batch process so that the analysis part could be done
    % for example for batch-processed reconstructions
