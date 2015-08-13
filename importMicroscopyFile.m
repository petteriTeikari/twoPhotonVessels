function [data, imageStack, metadata, options] = importMicroscopyFile(fileName, path, tiffPath, options)

    %% DEVELOPMENT ACCELERATION

        if options.skipImportBioFormats
            try
                load(fullfile('debugMATs', 'importTemp.mat')) % devel/debug MAT
                return
            catch err
                err
                warning('no debug .mat found')
            end
        end
        
    %% INPUT CHECKING

    
        % construct the full path for the OME-TIFF file
        if ~isempty(strfind(fileName, 'ome.tif')) % if the input is already the TIFF file
            tiffFull = fullfile(path, fileName);
        else
            tiffFile = strrep(fileName, '.oib', '_denoised.ome.tif');
            tiffFull = fullfile(tiffPath, tiffFile);
        end        
        
        % check if there is already a OME-TIFF even though the input has
        % been .oib-file
        filenameFull = fullfile(path, fileName);
        if exist(tiffFull, 'file') == 2
            disp(['OME-TIFF (', tiffFull, ') found'])
           
        else
            % problem with the paths, OR you have never yet imported this
            % .OIB file so no matching OME-TIFF could be found anyway
            disp(['No corresponding denoised OME-TIFF was found to match the input (yet?): ', filenameFull])
        end
       
        % check if the file exists, and you have specified the path
        % correctly
        if exist(filenameFull, 'file') == 2
           % file found
        else           
           error([filenameFull, 'The Input file is not found!'])           
        end

        
        
            
    %% Import from file using Bio-Formats
    
        try            
            tic
            if options.loadFromTIFF
                fileInfo = dir(tiffFull); % file info
                fileSize = fileInfo.bytes / (1024 * 1024); % in MBs
                data = bfopen(tiffFull); % read call
                
                % output to options
                options.input_file = tiffFile;
                options.input_path = tiffPath;
                options.input_fileFull = tiffFull;                 
                
            else
                fileInfo = dir(filenameFull); % file info
                fileSize = fileInfo.bytes / (1024 * 1024); % in MBs
                data = bfopen(filenameFull); % read call
 
                % output to options
                options.input_file = fileName;
                options.input_path = path;
                options.input_fileFull = filenameFull;         
            end
            timeImport = toc;
            
        catch err            
            err
            % err.message
            if strcmp(err.identifier, 'MATLAB:UndefinedFunction')
                error('bfopen not found, nothing imported! Have you added Bio-Formats "bfmatlab"-folder to path?')
            elseif strcmp(err.identifier, 'MATLAB:undefinedVarOrClass')                
                warning('BioFormats not installed properly?')
                warning('Edit your "classpath.txt')
                file = which('classpath.txt')
                edit(file)
                warning('https://www.openmicroscopy.org/site/support/bio-formats5.1/users/matlab/index.html')
                warning('remember to restart Matlab as well')
                error('loci not found, you have not added Bio-Formats to Java path?')
            elseif strcmp(err.identifier, 'MATLAB:minrhs') && strcmp(err.message, 'Not enough input arguments.')
                err
                error(['Not enough input arguments on line = ', num2str(line)])
            else
                err 
                err.message
                err.stack
                err.cause
                warning('some yet uncountered error?')
            end
        end
        
        disp([' Imported data from: ', fileName, ' (in ', num2str(timeImport), ' seconds, ', ...
                 num2str(fileSize / timeImport, 3), ' MB/s)'])        
      
             
    %% METADATA HANDLING
    
        metadata = import_parseMetadata(data, options);
        
        disp('    MAIN SPECIFICATIONS (from import_parseMetadata)')
        disp(metadata.main)
        
        % Check the imported data (to verify that everything went okay)
        % options = import_checkImportedData(data, metadata, 'After initial import:', options);
        % import_displayImportedDataDebug(data) % for debug
     
        
    %% RESHAPE        

        [imageStack, metadata.labels] = import_cellStackToMatrix(data{1,1}, metadata, path, options);
        % imageStack 1x6 210764448  cell   
        % imageStack{tStack}(yRes,xRes,zStacks)        
        
        
    %% DATA INTEGRITY / QUALITY
        
        % One should check the data integrity as some test files contained
        % NaN-values. Even one value can ruin some subsequent analysis,
        % like FFT-based filters for example (which happened during
        % testing, as for some reason there was one NaN)
        
        options.missingValuesMethod = 'inpaint'; % not really inpainting at the moment (PT)      
        disp('  Check the data quality (for Inf, NaN)')
        for ch = 1 : length(imageStack)
            for t = 1 : length(imageStack{1})
                imageStack{ch}{t}(:,:,:) = import_checkQuality(imageStack{ch}{t}(:,:,:), path, options);
            end
        end
        
        
    %% FOR QUICKER DEVELOPMENT
    
        % only the first time point, and the first channel        
        if options.useOnlyFirstTimePoint
            disp(['Using now only the first time point (1st channel also)'])
            
            imageStackOut{1}{1} = imageStack{1}{1}(:,:,:);
            imageStack = imageStackOut;
               
        end
        
        % reduce number of stacks
        if options.useOnlySubsetOfStack
            disp(' Only a subset of the imported image stack is used for accelerated development')
            for ch = 1 : length(imageStack)
                for t = 1 : length(imageStack{1})
                    imageStackOut2{ch}{t} = imageStack{ch}{t}(:,:, 11:14);
                end
            end
            imageStack = imageStackOut2;
        end

        % 2D downsampling of each stack
        if options.resizeStacks2D
            disp('  Stack is 2D-resized stack-by-stack to accelerate development')            
            disp(['    .. new size = ', num2str(options.resize2D_factor*metadata.main.stackSizeX), ...
                  'x', num2str(options.resize2D_factor*metadata.main.stackSizeY), ' (xy)'])
              
            for ch = 1 : length(imageStack)
                for t = 1 : length(imageStack{1})
                    for z = 1 : size(imageStack{1}{1},3)
                        imageStackTmp{ch}{t}(:,:,z) = imresize(imageStack{ch}{t}(:,:,z), options.resize2D_factor);
                    end
                end
            end
            imageStack = imageStackTmp;
        end 
        
    %% FINAL CHECKs
    
        % note that now not necessarily the same as in the input image
        % imported as we have might tossed away a lot of data in order
        % to make the development faster
        options.noOfChannels = length(imageStack);
        options.noOfTimePoints = length(imageStack{1});
        
        if ~options.manualTimePoints
            options.tP = 1 : 1 : options.noOfChannels;
            disp('    ... options.manualTimePoints = false | Manual time points not used, using all timepoints')
        else
            disp('    ... options.manualTimePoints = true | Manual time points used')

        end
        
        if options.noOfTimePoints < options.tP(end)
            options.tP(2) = options.noOfTimePoints;
            warning(['Only ', num2str(options.noOfTimePoints), ' input time points, need to reduce the limit to that'])
        end
        
        disp(' ')
        disp('IMPORT DONE')
        disp(' ')



    