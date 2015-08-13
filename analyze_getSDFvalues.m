 % Uses command-line CGAL implementation
function diameterVals = analyze_getSDFvalues(fileNameForMesh)

    % SHAPE DIAMETER FUNCTION (SDF)

    % the full path to the .off file is save in "reconstructMeshFromSegmentation.m"
    fileSavelocation = strrep(fileNameForMesh, '.off', '_SDF.txt')

    % Getting SDF Vals 
    try 
        Command= ('./PropertyVals' (path, 'out', [options.reconstructFileNameOut, '.off']) fileSavelocation)
    catch err
        err
        err.message
        error('Petteri: Some error with the command definiton?')
    end
    [status,cmdout]= system(command);
    txtFilepath= [filesavelocation '/SDFVals.txt'];
    fileID = fopen(txtFilepath,'r');
    formatSpec = '%f'
    diameterVals = fscanf(fileID,formatSpec);
    fclose(fileID);