function visualize_meshWithColormap(faces, vertices, colormap, plotType, options)

    %% CHECK INPUTS
    
        % we can later add some specific things here depending on what
        % values we are using as the colormap of the mesh
        if strcmp(plotType, 'SDF')
            titleStr = 'Shape Diameter Function (SDF)';
            
        elseif strcmp(plotType, 'change')

        else

        end

    %% VISUALIZE
    
        % code here
        fig = figure('Color','w');

            p = patch('Faces',     F, ...
                      'Vertices',  V, ...
                      'FaceColor', 'flat', ...
                      'CData',     colorMap, ...
                      'FaceAlpha', 0.3);

            view(3)
            camlight 
            lighting gouraud

            colorbar
            colormap('summer')
            title(titleStr)

            % remove edges
            set(p, 'EdgeColor', 'none')
            title('Removed edges')
    
        
        
    %% SAVE TO DISK 
    
        % export code here
        
        % if you figure out how to export .ply files with the color, it
        % would be great
        
        % e.g. 
        % http://stackoverflow.com/questions/16666308/saving-kinect-reconstructed-3d-view-into-a-file
        % https://social.msdn.microsoft.com/Forums/en-US/88cff0eb-e794-4541-8786-183cda5fd398/kinect-fusion-head-scanning-obj-export-no-texture-map?forum=kinectsdk
            % "Fusion color is done by way of Vertex colors. OBJ doesn't
            % support vertex color, so use the new PLY export option."