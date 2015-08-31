 % Uses command-line CGAL implementation
function diameterVals = analyze_getSDFvalues(fileNameForMesh, options)

    if nargin == 2
        disp('"options" is a lazy placeholder if we need to pass some parameters eventually')
    elseif nargin == 1
        options = [];
    end

    % SHAPE DIAMETER FUNCTION (SDF)
    % the full path to the .off file is save in "reconstructMeshFromSegmentation.m"    
    % or you can use whatever .off file that you wish
    if isunix || ismac
        fileSavePathCell = strsplit(fileNameForMesh, '/');
    else
        fileSavePathCell = strsplit(fileNameForMesh, '\');
    end    
    fileSavePath = fileSavePathCell{end};
    fileSavelocation = strrep(fileNameForMesh, fileSavePath, '');     

    % Getting SDF Vals
    command = [fullfile('.', 'CGAL', 'SDFRetrival', 'build', 'PropertyVals'), ' ', fileNameForMesh,  ' ', fileSavelocation];
    
    % the call on terminal to compute the SDFs
    [status, cmdout] = system(command);    
    check_CGALSystemOutput(cmdout, status, 'SDF')   
    
    % read the values then from disk back to Matlab
    txtFilepath= fullfile(fileSavelocation, 'SDFVals.txt');
    fileID = fopen(txtFilepath,'r');
    formatSpec = '%f';
    diameterVals = fscanf(fileID,formatSpec);
    fclose(fileID);
    
end

function check_CGALSystemOutput(cmdout, status, filterName)

    % Check that everything went ok
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
        cmdout
    end
end