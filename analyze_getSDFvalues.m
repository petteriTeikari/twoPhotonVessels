 % Uses command-line CGAL implementation of SHAPE DIAMETER FUNCTION (SDF)
function [diameterVals, segmentIDs] = analyze_getSDFvalues(fileNameForMesh, options)

    if nargin == 2
        disp('"options" is a lazy placeholder if we need to pass some parameters eventually')
    elseif nargin == 1
        options = [];
    elseif nargin == 0
        options = [];
        fileNameForMesh = fullfile('tempData', 'test2.off');
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
    
    fileNameForSDFs = fullfile(fileSavelocation, 'SDF_out.txt');
    fileNameForSDF_segments = fullfile(fileSavelocation, 'SDF_ids.txt');

    % Getting SDF Vals
    functionName = 'compute_SDF';
    functionCall = fullfile('.', 'CGAL', functionName, 'build', functionName);
    
    param.SDF.cone_angle = 2.0 / 3.0 * pi();
    param.SDF.number_of_rays = 25;
    param.SDF.number_of_clusters = 5;
    param.SDF.smoothing_lambda = 0.26;
    param.SDF.postprocess = true;
    
    parameters = mesh_constructCGALparameters(param.SDF);    
    
    command = [functionCall, parameters, ...
                             ' ', fileNameForMesh,  ' ', fileSavelocation, ...
                             ' ', fileNameForSDFs,  ' ', fileNameForSDF_segments];
        
    % the call on terminal to compute the SDFs
    tic;
    disp('Computing SDF Values (using CGAL via system command)')
    [status, cmdout] = system(command);
    mesh_checkCGALSystemOutput(cmdout, status, 'SDF')  
    timing_SDF = toc; disp([' ... took ', num2str(timing_SDF), ' seconds'])
        
    % try to open the SDF file
    % txtFilepath = fullfile(fileSavelocation, fileNameForSDFs);
    txtFilepath = fileNameForSDFs;
    diameterVals = returnValues(txtFilepath, fileNameForSDFs);
    
    % try to open the SDF segments file
    % txtFilepath = fullfile(fileSavelocation, fileNameForSDF_segments);
    txtFilepath = fileNameForSDF_segments;
    segmentIDs = returnValues(txtFilepath, fileNameForSDF_segments);
    
    whos('diameterVals', 'segmentIDs')
    pause
    
end

function values = returnValues(txtFilepath, fileName)
        
    fileID = fopen(txtFilepath,'r');

        if fileID == -1
            disp(['The file could not be found from: ', txtFilepath])
            disp('  .. trying to open from current directory')
            % get the current path (where this .m file is)
            fileName = mfilename; fullPath = mfilename('fullpath');
            pathCode = strrep(fullPath, fileName, '');
            if ~isempty(pathCode); cd(pathCode); end
            txtFilepath= fullfile(pathCode, fileName);
            fileID = fopen(txtFilepath,'r');
            if fileID == -1
                error('Still not working with the current working directory, fix the paths?')            
            else
                disp(['   -> which was successful, file found from: ', txtFilepath])
            end
        end

        formatSpec = '%f';
        values = fscanf(fileID,formatSpec);
        fclose(fileID);

end
