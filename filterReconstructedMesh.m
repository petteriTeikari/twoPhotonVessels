function reconstructionOut = filterReconstructedMesh(reconstruction, operation, options, t, ch)

    disp('    -- mesh filter dummy')
    reconstructionOut = reconstruction;
    
    if strcmp(operation, 'repair')
    
        % repair something
        
    elseif strcmp(operation, 'simplification')
        
        % do something
        
    elseif strcmp(operation, 'smoothing')
        
        % do something else
       
    else
        
        error('this kind of doing not implemented')
        
    end