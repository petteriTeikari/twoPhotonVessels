 % Uses command-line CGAL implementation
function diameterVals = analyze_getSDFvalues(fileNameForMesh, options)

    % SHAPE DIAMETER FUNCTION (SDF)

    % the full path to the .off file is save in "reconstructMeshFromSegmentation.m"
    
    
    fileSavePathCell = strsplit(fileNameForMesh, '/');
    fileSavePath = fileSavePathCell{end}
    fileSavelocation = strrep(fileNameForMesh, fileSavePath, '');
     

    % Getting SDF Vals 
%     try 
%         command = ['./PropertyVals ' [path, 'out', [options.reconstructFileNameOut, '.off']] ' ' fileSavelocation]
%     whos
%     catch err
%         err
%         err.message
%         error('Petteri: Some error with the command definiton?')
%     end

% command = ['./PropertyVals ' [path, 'out', [options.reconstructFileNameOut, '.off']] ' ' fileSavelocation]

command = ['./PropertyVals /home/highschoolintern/Desktop/TestReconstruction2/testReconstruction_4slicesPhysical_reconstruction_isolatedRemoved_decimated.off ' fileSavelocation];
whos

[status, cmdout] = system(command);
disp(cmdout); 
txtFilepath= [fileSavelocation '/SDFVals.txt'];
fileID = fopen(txtFilepath,'r');
formatSpec = '%f';
diameterVals = fscanf(fileID,formatSpec);
fclose(fileID);
end