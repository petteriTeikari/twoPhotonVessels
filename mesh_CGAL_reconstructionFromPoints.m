function mesh = mesh_CGAL_reconstructionFromPoints(pointsOut, normalsOut, fileIn, paramOut, param)

    if nargin == 0
        load('reconTemp.mat')
    else
        save('reconTemp.mat')
    end

    mesh = [];
    paramOut
    

    % re-define the parameters, and make them adaptive
    param.poissonReconstruction
    
    
    % call the CGAL implementation
    timing = [];
    functionFolder = 'poissonReconstruction';
    [~, outputMesh, timing] = points_CGAL_filterCall(functionFolder, fileIn, param, timing);