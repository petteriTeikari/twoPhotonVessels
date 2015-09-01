function mesh_checkCGALSystemOutput(cmdout, status, filterName)

    if status == 139
        error('Segmentation fault? Why? The file could not be processed')
    end

    % Check that everything went ok
    if status == 1
        if strcmp(cmdout, 'Not a valid off file.')
            warning('CGAL does not seem to think that this is a valid .OFF file, even though you can probably open it in Meshlab?')
            return
        end
    end
    
    if strfind(cmdout, 'error while loading shared libraries')
        if strfind(cmdout, 'libCGAL')
            cmdout
            error('CGAL Library not found! Did you build from the source yourself?')
        else
            cmdout
            error('here2')
        end
    elseif strfind(cmdout, 'No such file or directory')
        cmdout
        error(['Folder not found, have you built the ',  filterName, ' filter already?'])
    else
        % cmdout
    end
end