function reconstruction = reconstructSegmentation(imageStack, segmentation, options)

    % Direct import from .mat file if needed
    if nargin == 0
        
        close all
        [~, name] = system('hostname');
        name = strtrim(name); % remove white space
        if strcmp(name, 'C7Pajek') % Petteri   
            path = fullfile('/home', 'petteri', 'Desktop', 'testPM');
            load(fullfile(path, 'testReconstruction_fullResolution.mat'))        
            load(fullfile(path, 'testReconstruction_halfRes_4slicesOnly.mat'))        
        elseif strcmp(name, '??????') % Sharan
            path = fullfile('/home', 'petteri', 'Desktop', 'testPM');
            load(fullfile(path, 'testReconstruction_fullResolution.mat'))        
            %load(fullfile(path, 'testReconstruction_halfRes_4slicesOnly.mat'))        
        end
    else
        [~, name] = system('hostname');
        name = strtrim(name); % remove white space
        if strcmp(name, 'C7Pajek') % Petteri    
            path = fullfile('/home', 'petteri', 'Desktop', 'testPM');
            save(fullfile(path, 'testReconstruction.mat'));     
        elseif strcmp(name, '??????') % Sharan
            path = fullfile('/home', 'petteri', 'Desktop', 'testPM');
            save(fullfile(path, 'testReconstruction.mat'));
        end
        
        % if you wanna write to disk
        % export_stack_toDisk(fullfile('figuresOut', 'fullResolution_67slices.tif'), segmentation)
        
    end

    disp('Mesh Reconstruction from Volumetric Image')    
    
    %% INPUT CHECKING
    
        debugPlot = false;
    
    %% MESH RECONSTRUCTION
    
    
    
    
    
    %% EXTRACT THE CONTOURS
       
        % we don't really need these for anymore, but might be good for
        % visualization
    
        if debugPlot
            fig = figure('Color', 'w');
                scrsz = get(0,'ScreenSize'); % get screen size for plotting 
                set(fig,  'Position', [0.3*scrsz(3) 0.545*scrsz(4) 0.7*scrsz(3) 0.40*scrsz(4)])
                
            sliceVector = 1:size(segmentation,3);
            numberOfContourLevelsPerSlice = 16;
            subplot(1,2,1)
            
            % this does not actually return anything, it just visualizes the
            % volumetric data
            % http://www.mathworks.com/help/matlab/ref/contourslice.html
            contourslice(segmentation, [], [], sliceVector, numberOfContourLevelsPerSlice);
            view(34,-38);
            daspect([1,1,0.01]); axis tight
            xlabel('X'); ylabel('Y'); zlabel('Z')
            title(['Contours (n=', num2str(numberOfContourLevelsPerSlice), ') of each slice'])            
        end
    
        
    %% EXTRACT POINT CLOUD
        
        % if you want to interface with Point Cloud Library (PCL), see:
        % MATLAB to Point Cloud Library by Peter Corke 
        % http://au.mathworks.com/matlabcentral/fileexchange/40382-matlab-to-point-cloud-library
    
   

    %% EXTRACT THE MESH
    
        % Using Marching Cubes algorithm from Matlab FEX
        % http://www.mathworks.com/matlabcentral/fileexchange/32506-marching-cubes
        isoValue = 0.1;
        downSampleFactor = [1 1]; % [xy z] downsample to get less vertices/faces
        physicalScaling = [1 1 5]; % physical units of FOV
        [F,V] = reconstruct_marchingCubes_wrapper(segmentation, isoValue, downSampleFactor, physicalScaling, debugPlot);
        
        % output the faces and vertices
        reconstruction.faces = F;
        reconstruction.vertices = V;
    
    %% Condition data

        % triangulate the faces, vertices
        % http://www.mathworks.com/matlabcentral/answers/25865-how-to-export-3d-image-from-matlab-and-import-it-into-maya
        % tr = triangulation(F, V);

        % Delauney
        % DT = delaunayTriangulation(tr.Points); 

        % save the reconstruction out as .mat file
        save(fullfile(path, 'out', 'reconstructionOut.mat'), 'F', 'V', 'mask');

    %% External formats
    
        % STLWrite
        % http://www.mathworks.com/matlabcentral/fileexchange/20922-stlwrite-filename--varargin-
        try
            stlwrite(fullfile(path, 'out', [options.reconstructFileNameOut, '.stl']), F, V)
        catch err
            err
            warning('?')
        end
    
        % Write to OFF (or PLY, SMF, WRL, OBJ) using the Toolbox Graph by 
        % http://www.mathworks.com/matlabcentral/fileexchange/5355-toolbox-graph
        try
            write_mesh(fullfile(path, 'out', [options.reconstructFileNameOut, '.off']), V, F)
        catch err
            err
            warning('?')
        end
        
        
        
        % Paraview export (VTK)
        % http://www.mathworks.com/matlabcentral/fileexchange/47814-export-3d-data-to-paraview-in-vtk-legacy-file-format
        x = 1:1:size(imageStack,1); y = 1:1:size(imageStack,2); z = 1:1:size(imageStack,3);
        % size(DT.ConnectivityList)
        % vtkwrite(fullfile('debugMATs', 'reconstructionOut.vtk'), 'polydata','tetrahedron',x,y,z,DT.ConnectivityList);
     
        % as a Wavefront/Alias Obj file
        % http://www.aleph.se/Nada/Ray/matlabobj.html
       
