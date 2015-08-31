function reconstructionOut = mesh_filterMain(reconstruction, operation, algorithm, options, t, ch)

    disp('    -- mesh filter dummy')
    reconstructionOut = reconstruction;
    
    if strcmp(operation, 'repair')
    
        % repair something
        if strcmp(algorithm, 'Basic')
            disp('Some "basic" repair functions to automatically fix the mesh, like in Meshlab')
            
        else
            error(['You wanted algorithm: "', algorithm, '" which is not implemented'])
        end
        
    elseif strcmp(operation, 'simplification')
        
        % do something, e.g. WLOP
        if strcmp(algorithm, 'WLOP')
            disp('CGAL WLOP call here')
            
        elseif strcmp(algorithm, 'Outlier removal')
           disp('CGAL Outlier Removal call here')
            
        else
            error(['You wanted algorithm: "', algorithm, '" which is not implemented'])
        end
            
        
    elseif strcmp(operation, 'smoothing')
        
        % do something else, e.g. BILATERAL SMOOTHING
        if strcmp(algorithm, 'Bilateral')
            disp('CGAL Bilateral Smoothing call here')
            
        else
            error(['You wanted algorithm: "', algorithm, '" which is not implemented'])
        end
       
    else
        
        error('this kind of doing not implemented')
        
    end