 % Uses command-line CGAL implementation of SHAPE DIAMETER FUNCTION (SDF)
function diameterVals = analyze_getSDFvalues(fileNameForMesh, options)

    if nargin == 2
        disp('"options" is a lazy placeholder if we need to pass some parameters eventually')
    elseif nargin == 1
        options = [];
    end
    
    % the full path to the .off file is save in "reconstructMeshFromSegmentation.m"    
    % or you can use whatever .off file that you wish
    if isunix || ismac
        fileSavePathCell = strsplit(fileNameForMesh, '/');
    else % Windows
        fileSavePathCell = strsplit(fileNameForMesh, '\');
    end    
    fileSavePath = fileSavePathCell{end};
    fileSavelocation = strrep(fileNameForMesh, fileSavePath, '');    

    % Getting SDF Vals
    command = [fullfile('.', 'CGAL', 'SDFRetrival', 'build', 'PropertyVals'), ' ', fileNameForMesh,  ' ', fileSavelocation];
        
    % the call on terminal to compute the SDFs
    tic;
    disp('Computing SDF Values (using CGAL via system command)')
    [status, cmdout] = system(command);
    check_CGALSystemOutput(cmdout, status, 'SDF')  
    timing_SDF = toc; disp([' ... took ', num2str(timing_SDF), ' seconds'])
    
    % read the values then from disk back to Matlab
    fileOut = 'SDFVals.txt'; % add input argument so this would not be static?
                             % would need to be given in CGAL as well, you
                             % could also just rename on the disk
        
    % try to open the file
    txtFilepath= fullfile(fileSavelocation, fileOut);
    fileID = fopen(txtFilepath,'r');
    
    if fileID == -1
        disp(['The file could not be found from: ', txtFilepath])
        disp('  .. trying to open from current directory')
        % get the current path (where this .m file is)
        fileName = mfilename; fullPath = mfilename('fullpath');
        pathCode = strrep(fullPath, fileName, '');
        if ~isempty(pathCode); cd(pathCode); end
        txtFilepath= fullfile(pathCode, fileOut);
        fileID = fopen(txtFilepath,'r');
        if fileID == -1
            error('Still not working with the current working directory, fix the paths?')            
        else
            disp(['   -> which was successful, file found from: ', txtFilepath])
        end
    end
    formatSpec = '%f';
    diameterVals = fscanf(fileID,formatSpec);
    fclose(fileID);
    
end

function check_CGALSystemOutput(cmdout, status, filterName)

    if status == 139
        error('Segmentation fault? Why?')
    end

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