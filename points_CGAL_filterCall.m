function [variables, outputMesh, timing] = points_CGAL_filterCall(functionFolder, inputMesh, param, timing)

    variables.null = [];
    
    parameters = mesh_constructCGALparameters(param.(functionFolder));        

    pathFull = fullfile(param.CGALpath, functionFolder, 'build');
    fName = functionFolder; % try to keep the same name  
    outputMesh = strrep(inputMesh, '.xyz', ['_', functionFolder, '.xyz']);
    
    % try to build similar filters with similarish syntax
    if strcmp(functionFolder, 'analyzePoints')
        command = [fullfile(pathFull, fName), parameters, inputMesh]; % construct the call
        
    else
        command = [fullfile(pathFull, fName), parameters, inputMesh, ' ', outputMesh]; % construct the call       
    end

    disp([' -> ', command]); 
    
    tic;
    [status, cmdout] = system(command); % return average spacing
    mesh_checkCGALSystemOutput(cmdout, status, fName)  
    timing.(functionFolder) = toc;
    
    if strcmp(functionFolder, 'analyzePoints')
        variables.averageSpacing = cmdout;
    end