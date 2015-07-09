 function dataOut = getDataMatrix(data, wavelength, dataWanted, dataType, yType, normalizeOn)
        
    if strcmp(dataType, 'fluoro')
        
        if strcmp(yType, 'emission')
            yFieldName = 'emission';
        elseif strcmp(yType, 'excitation')
            yFieldName = 'excitation';
        else
            disp(['yFieldName = ', yFieldname])
            error('What yType you want, emission/excitation?')
        end
        
    elseif strcmp(dataType, 'filter')
        yFieldName = 'transmittance';
    
    elseif strcmp(dataType, 'light')
        yFieldName = 'irradiance';
        
    else
        disp(['dataType = ', dataType])
        error('What dataType you want, fluoro/filter/light?')
    end

    for i = 1 : length(data)
        names{i,1} = data{i}.name; % might be unnecessary
        dataIn{i} = data{i}.(yFieldName);
        wavelengthIn{i} = data{i}.wavelength;
    end

    for j = 1 : length(dataWanted)
        try
            ind(j) = find(ismember(names, dataWanted{j}));
        catch err
            warning(['You wanted "', num2str(dataWanted{j}), '" but it was not defined. These were found:'])
            disp(names)
        end
    end
    
    % remove the not-found indices
    ind = ind(ind ~= 0);

    % truncate the fluorophore matrix (if needed), a bit of a hassle
    % but maybe better to keep it like this and not throw away the
    % "excess" wavelengths from the start (on disk) if they are later 
    % needed for something
    wavelengthRes = 1; % 1 nm
    wavelength_new = (min(wavelength) : wavelengthRes : max(wavelength))';

        dataNew = zeros(length(wavelength), length(dataIn));
        for ji = 1 : length(dataIn) % how many fluorophores
            % easier variable names for debugging (the changes in import_
            % functions often propagate here apparently)
            x = wavelengthIn{ji}
            y = dataIn{ji}
            whos
            dataNew(:,ji) = interp1(x, y, wavelength_new);
        end

    % get only the wanted fluorophores from the truncated matrix
    matrixOut = zeros(length(wavelength), length(ind)); % preallocate
    
    for k = 1 : length(ind)
        matrixOut(:,k) = dataNew(:,ind(k));
        dataOut.plotColor(k,:) = data{ind(k)}.plotColor;
        dataOut.name{k} = data{ind(k)}.name;
        
        if normalizeOn
            matrixOut(:,k) = matrixOut(:,k) / max(matrixOut(:,k));
        end
    end
    
    % output the actual data as well    
    dataOut.data = matrixOut;
    

    % TODO: Propagate the colors as well    
    
            
   