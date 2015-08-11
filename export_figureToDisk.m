% Export figures to disk using some 3rd party writers
function export_figureToDisk(fig, fileNameOut, format, resolution, antiAliasLevel)

    % PNG
    % Slightly nicer rendering than with the default Matlab PNG writer
    if strcmp(format, 'png')
        export_fig(fileNameOut, resolution, antiAliasLevel)
    end
    
    % SVG
    % Supports alpha channels if you have transparency in your figure
    if strcmp(format, 'svg')
        % 
    end