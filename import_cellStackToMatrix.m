function [imageStack, labels] = import_cellStackToMatrix(cellStack, metadata, path, options)

    % Name                Size                Bytes     Class     Attributes
    % 
    %   data                1x4             528403396   cell                
    %   cellStack         402x2             210922644   cell                
    %   options             1x1                   721   struct    
    
    disp('  Reshape the import')
    disp(['    * Rearrange the data a bit eventually to make it more compatible with OME-TIFF?'])
    disp(['      check later if this reshaping is actually the most optimal with bfsave()'])       
    
    % PT: Fix when you encounter such files
    if metadata.main.noOfChannels > 1
       error('Code cannot at its current stage handle the number of channels, if it is more than 1, fix here when encountered') 
    end
    
    zstack = 0;
    tstack = 1;
    for i = 1 : metadata.main.numberOfStacks        
        zstack = zstack + 1;   
        % disp([tstack zstack])
       
        % data matrix
        imageStack{tstack}(:,:,zstack) = cellStack{i,1};
        labels{tstack}{zstack} = cellStack{i,2};
                       
        if zstack == metadata.main.stackSizeZ            
            zstack = 0; % reset the counter            
            tstack = tstack + 1; % increment the t-stack
        end
        
        
    end
    
    % Now manually pad with the channel count
    imageStackTmp{1} = imageStack;
    imageStack = imageStackTmp;
    
    labelsTmp{1} = labels;
    labels = labelsTmp;
    
    % size(imageStack),   e.g.      1     1
    % size(imageStack{1}),    e.g.  1     6
    % size(imageStack{1}{1})  e.g.  512   512    67
        
    
    