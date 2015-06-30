 function [imFiltered, timeExec] = MIJ_wrapper(imageIn, command, arguments, options)
        
    % Input check
    
        % might work without this, debug later
        if strcmp(command, 'PureDenoise ...')        
            windowToExport = 'Denoised-Import from Matlab';
        elseif strcmp(command, 'MultiScale Oriented-Flux Tubularity Measure')        
            windowToExport = 'Tubularity';
            % https://github.com/fethallah/tubularity/blob/master/FijiITKInterface/OOFTubularityMeasure_Plugin.java, line 193
        elseif strcmp(command, 'OME-TIFF...')
            windowToExport = 'Import from Matlab';
            imFiltered = [];
        else
            warning('command?')
            
        end
    
        % check if all the options exist
        if ~isfield(options, 'saveImageJ_outputAsImage')
            options.saveImageJ_outputAsImage = false;
            warning('save as image flag was not provided, set to "false"')
        end
 
    % Start MIJ

        % A Java package for running ImageJ and Fiji within Matlab
        % http://bigwww.epfl.ch/sage/soft/mij/

        disp('Starting MIJ | ImageJ-Matlab bridge');
        % http://bigwww.epfl.ch/sage/soft/mij/        

        % these need to be copied manually to your Matlab folder
        javaaddpath('/usr/local/MATLAB/R2013a/java/mij.jar') % MIJ
        javaaddpath('/usr/local/MATLAB/R2013a/java/ij.jar') % comes with ImageJ

        try 
            MIJ.start('/home/petteri/Fiji.app')
                % see http://bigwww.epfl.ch/sage/soft/mij/doc/MIJ.html
        catch err
            if strcmp(err.identifier, 'MATLAB:UndefinedFunction')
               error('MIJ(.jar) not found? Have you downloaded MIJ.jar and IJ.jar and copied them to the "java" folder of your MATLAB?')
            else
               err 
            end            
        end

    % PureDenoise                        

        % Automatic estimation of noise parameter estimation used, so
        % no sigma or any other noise parameters needed, only the
        % following:          
        
            % Adjustable trade-off between output quality and processing time: 
            % increasing the number of cycle-spins and/or the number of adjacent frames 
            % used to estimate the current frame improves the denoising quality, 
            % but also increases (roughly linearly) the computation time.
            % see: http://bigwww.epfl.ch/algorithms/denoise/

        % disp(['Denoising the stack with PureDenoise ImageJ plugin');
        % disp(['  would like to pass these eventually: cycle spins = ', num2str(cycles), ', multiframe = ', num2str(frames)])
        % http://bigwww.epfl.ch/algorithms/denoise/           

        close all
        MIJ.closeAllWindows            
        MIJ.createImage(imageIn) % export the imageStack to ImageJ

        [x,y,z] = size(imageIn);
        bytesPerValue = 2; % 16-bit grayscale
        memoryNeeded = bytesPerValue * x*y*z / 1024 / 1024; % in MBs
        disp(['   -- input image takes ', num2str(memoryNeeded), ' MB of memory'])            

        tic;
        try 
            
            % how to get working the plugin:
            % Open in ImageJ (the .java), and save then to the Plugins folder
            % http://rsb.info.nih.gov/ij/docs/menus/plugins.html
            % otherwise not recognized by Matlab, see for example in
            % Fiji/ImageJ by pressing "L" and search for Pure Denoiser

            % see "Macro-Example-PureDenoise.txt" for examples of
            % calling the plugin

            % Syntax of PureDenoise call from a macro
            % // Automatic mode:
            % // run("PureDenoise ", "parameters='nf cs' estimation='Auto Global' ");
            % // where nf is an integer (odd) value representing the number of frames
            % // and cs the number of cycle-spins [1..10].
            % see some more help from:
            % https://groups.google.com/forum/#!topic/fiji-devel/RnVgeAYfBZY

                MIJ.run(command, arguments)  
                
                MIJ.getCurrentTitle; % kinda useless, but it was a bit unpredictable the bridge behavior as well
                MIJ.selectWindow(windowToExport)
                
                imFiltered = MIJ.getCurrentImage;
                if options.saveImageJ_outputAsImage
                    % save here to disk as OME-TIFF
                    % ADD CODE LATER
                    warning('save as TIFF not implemented yet')
                end
                MIJ.closeAllWindows
                MIJ.exit % closes ImageJ/Fiji


        catch err
            
            if strcmp(err.identifier, 'MATLAB:UndefinedFunction')
               err
               if strcmp(err.message, '')
                    error('You need to download PureDenoise also and place it to your ImageJ plugins directory, http://bigwww.epfl.ch/algorithms/denoise/')
               end

            % Some JAVA-error, in other words ImageJ fails
            elseif strcmp(err.identifier, 'MATLAB:Java:GenericException')                    

               exceptionObject = err.ExceptionObject
               logString = char(MIJ.getLog) % we need to convert the Java string to Matlab string

               if strcmp(err.ExceptionObject, 'java.lang.RuntimeException: Macro canceled')                        

                    if ~isempty(strfind(logString, '<Out of memory>'))
                        warning('Not enough memory, increase Java Heap size, e.g. Preferences - General - Java Heap Memory (to 1,024 MB e.g.)')
                        warning('Or modify the java.opts e.g. from /usr/local/MATLAB/R2013a/bin/glnxa64')                       

                    else                            
                        % if you get Matlab error
                        % "java.lang.OutOfMemoryError: GC overhead limit exceeded"
                        % see: http://www.mathworks.com/matlabcentral/answers/100335-why-do-i-receive-an-error-when-i-execute-the-fetch-statement-on-a-sql-server-database-using-database

                    end

               elseif strcmp(err.ExceptionObject, 'java.lang.NullPointerException')

                    warning('PT: I do not really know why this occurs?')
               end

               warning('ImageJ could not filter the image, no denoising done')
               imFiltered = imageIn;
               MIJ.closeAllWindows
               MIJ.exit % closes ImageJ/Fiji

            else
               err 
            end
        end
        
        timeExec = toc;