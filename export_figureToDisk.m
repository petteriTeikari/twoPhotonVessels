% Export figures to disk using some 3rd party writers
function export_figureToDisk(fig, fileNameOut, format, resolution, antiAliasLevel, options)

    %% INPUT CHECKING
    
        if ispc % Windows
            splitFilePath = strsplit(fileNameOut, '\');
        elseif isunix || ismac % LINUX/UNIX and MAC
            splitFilePath = strsplit(fileNameOut, '/');
        end
        justTheFileName = splitFilePath{end}; % assuming that the filename is the last 
                                              % cell element

        justThePath = [];
        for i = 1 : length(splitFilePath) - 1
            justThePath = fullfile(justThePath, splitFilePath{i});
        end

        disp(['output path = ', justThePath])
        ifExists = exist(justThePath, 'dir')
        
        % check that the folder exists
        if exist(justThePath, 'dir') == 7
            
        else
            % modify path to the default folder
            warning('Directory hassle, you initiated the function from incorrect folder (make more elegant later')
            disp('Hassle continued.. Now the image is going to be exported to the default /figuresOut/ -folder')
            try
                justThePath = options.pathCode;
            catch err
                err
                disp('hardCoded folder')
                justThePath = '/home/petteri/Dropbox/MatlabCode/InDevelopment/2-PM_v2/twoPhotonVessels/figuresOut'
            end
            fileNameOut = fullfile(justThePath, justTheFileName);
            
            if exist(justThePath, 'dir') == 7
                
            else
                warning('The default directory could not be found either? No figure exported')
                justThePath
                fileNameOut
                return
            end
        end
        
        
        
    %% DISK EXPORT

        fileNameOut
    
        % PNG
        % Slightly nicer rendering than with the default Matlab PNG writer
        if strcmp(format, 'png')
            try
                export_fig(fileNameOut, resolution, antiAliasLevel)
            catch err
                err
                err.message
            end
        end

        % SVG
        % Supports alpha channels if you have transparency in your figure
        if strcmp(format, 'svg')
            % 
        end