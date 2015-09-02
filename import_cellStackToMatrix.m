function [imageStack, labels] = import_cellStackToMatrix(cellStack, metadata, path, options)

    % Name                Size                Bytes     Class     Attributes
    % 
    %   data                1x4             528403396   cell                
    %   cellStack         402x2             210922644   cell                
    %   options             1x1                   721   struct    
   
    %{
    if nargin == 0
        load('tempImport.mat')
        %          MAIN SPECIFICATIONS (from import_parseMetadata)
        %                   stackSizeX: 512
        %                   stackSizeY: 512
        %                   stackSizeZ: 81
        %                 noOfChannels: 3
        %               numberOfStacks: 243
        %     numberOfStacksPerChannel: 81
        %               noOfTimePoints: 1
    else
        save('tempImport.mat')
    end
    %}
    
    disp('  Reshape the import')
    disp(['    * Rearrange the data a bit eventually to make it more compatible with OME-TIFF?'])
    disp(['      check later if this reshaping is actually the most optimal with bfsave()'])       
       
    zstack = 0;
    zPerCh = [1 1 1];
    tstack = 1;
    chIndex = 0;
    for i = 1 : metadata.main.numberOfStacks        
          
        zstack = zstack + 1;
        chIndex = chIndex + 1;
        % disp([tstack zstack])
       
        % data matrix
        imageStack{chIndex}{tstack}(:,:,zPerCh(chIndex)) = cellStack{i,1};
        labels{chIndex}{tstack}{zstack} = cellStack{i,2};
             
        % disp(size(imageStack{chIndex}{tstack}))
        % disp([zPerCh chIndex tstack zstack]) 
        
        zPerCh(chIndex) = zPerCh(chIndex) + 1;
        
        if chIndex == metadata.main.noOfChannels
            chIndex = 0;            
        end
        
        if zstack == metadata.main.stackSizeZ            
            zstack = 0;  % reset the counter    
        end
        
        % TODO: check whether works for multi-channel and multi time-point
        if zPerCh == metadata.main.numberOfStacksPerChannel * metadata.main.noOfChannels
            zPerCh = [1 1 1];
            tstack = tstack + 1; % increment the t-stack
        end        
        
        % debugVisualize
        %{
        if rem(i,3) == 0        
            subplot(1,3,1); imshow(cellStack{i,1},[]); title(num2str(i)); % RED
            subplot(1,3,2); imshow(cellStack{i-1,1},[]); % GREEN
            subplot(1,3,3); imshow(cellStack{i-2,1},[]); % BLUE
            pause            
        end
        %}
                
    end
    
    % debugVisualize
    %{
    size(labels{1}{1})
    size(imageStack{1}{1})
    size(imageStack{1}{1},3)
    size(imageStack)
    for slice = 1 : size(imageStack{1}{1},3)
        
        subplot(1,3,1); imshow(imageStack{1}{1}(:,:,slice),[]); title(num2str(slice));
        subplot(1,3,2); imshow(imageStack{2}{1}(:,:,slice),[]);
        subplot(1,3,3); imshow(imageStack{3}{1}(:,:,slice),[]);
        pause
        
    end
    %}
    
    % THIS FIXED
    %{
    % Now manually pad with the channel count
    imageStackTmp{1} = imageStack;
    imageStack = imageStackTmp;
    
    labelsTmp{1} = labels;
    labels = labelsTmp;
    
    % size(imageStack),   e.g.      1     1
    % size(imageStack{1}),    e.g.  1     6
    % size(imageStack{1}{1})  e.g.  512   512    67
    %}
    
   