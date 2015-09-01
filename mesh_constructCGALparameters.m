function parameters = mesh_constructCGALparameters(paramIn)
            
    fieldNames = fieldnames(paramIn);
    for i = 1 : length(fieldNames)
        if i == 1
            parameters = [' ', num2str(paramIn.(fieldNames{i})), ' '];
        else
            parameters = [parameters, num2str(paramIn.(fieldNames{i})), ' '];
        end

    end