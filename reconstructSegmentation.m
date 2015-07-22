function reconstruction = reconstructSegmentation(imageStack, segmentation, options)

    % Direct import from .mat file if needed
    if nargin == 0
        close all
        load(fullfile('/home', 'petteri', 'Desktop', 'testPM', 'testReconstruction_fullResolution.mat'))        
        %load(fullfile('/home', 'petteri', 'Desktop', 'testPM', 'testReconstruction_halfRes_4slicesOnly.mat'))        
    else
        save(fullfile('/home', 'petteri', 'Desktop', 'testPM', 'testReconstruction.mat'));        
    end
    whos
    
    % See PDF for details
    
    % this at the moment requires the most work, or literature review. This
    % step can also be very time-consuming so we might want to think of
    % ways of how to batch process so that the analysis part could be done
    % for example for batch-processed reconstructions   

    disp('3D Reconstruction (dummy)')
    
    % min-max values of the segmented data
    minIn = min(segmentation(:)); maxIn = max(segmentation(:));
    
    reconstruction = segmentation;    
    
    % if you just want to write the segmented version here to disk, and to
    % imported by a 3rd party software, you can use the export_stack_toDisk
    % which saves the stack as non-OME multilayer TIFF file (.tif),
    % converts to 16-bit and scales the maximum intensity value to 65,535
    % disp('Writing the segmented stack to disk as a TIFF file')
    % export_stack_toDisk(fullfile('figuresOut', 'segmentedStack.tif'), segmentation)
    
    % whos   
    %       Name                  Size                 Bytes  Class     Attributes
    % 
    %   imageStack          256x256x4            2097152  double              
    %   options               1x1                   3931  struct              
    %   reconstruction      256x256x4            1048576  single              
    %   segmentation        256x256x4            1048576  single              
    
    % quick'n'dirty plot of the input
    %{
    fig = figure('Color','w');
    
        % Maximum Intensity projections of the test stack
        subplot(1,2,1)
            imshow(max(imageStack,[],3),[])
            title('Denoised stack (non-segmented')
        subplot(1,2,2)    
            imshow(max(segmentation,[],3),[])
            title('Segmented stack')
    %}

    debugPlot = false
    
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
    
    %% EXTRACT THE MESH (Standard isosurface)

        % Horribly slow (20x slower than the Marching Cubes below) 
        % especially for large stacks (i.e. 512 x 512 x 67),
        % Do not use!
    
        % extract from the volumetric segmentation data
        % http://www.mathworks.com/help/matlab/ref/isosurface.html
        %{
        isovalue = 0.1 * maxIn;
        tic;
        [f,v] = isosurface(segmentation,isovalue);
        time.isosurface = toc;
        
        isosurf_numberOfFaces = length(f);
        isosurf_numberOfVertices = length(v);

        % plot the vertices
        subplot(1,3,2)
        patch('Faces',f,'Vertices',v, ...            
                'edgecolor', 'none', ...
                'facecolor', 'red');
            
            view(34,-38);
            daspect([1,1,0.1]); axis tight
            camlight 
            lighting gouraud
            xlabel('X'); ylabel('Y'); zlabel('Z')
            titStr = sprintf('%s\n%s\n%s', ['"isosurface" (isovalue = ', num2str(isovalue,4), ') with a lighting'], ...
                             ['no of faces = ', num2str(isosurf_numberOfFaces), ', no of vertices = ', num2str(isosurf_numberOfVertices)], ...
                             ['computation time = ', num2str(time.isosurface,3), ' sec']);
            title(titStr)
        %}

    %% EXTRACT THE MESH #2
    
        % Using Marching Cubes algorithm from Matlab FEX
        % http://www.mathworks.com/matlabcentral/fileexchange/32506-marching-cubes
        
        % Note that even though the name of the algorithm is Marching
        % Cubes, it can be implemented differently still in different
        % programs, see for example Wiemann et al. (2015), 
        % http://dx.doi.org/10.1007/s10846-014-0155-1
        xgv = 1:size(segmentation,1);
        ygv = 1:size(segmentation,2);
        zgv = 1:size(segmentation,3);
        [X,Y,Z] = meshgrid(xgv,ygv,zgv);        
        
        tic;
        isovalue = 0.1 * maxIn;
        [F,V] = MarchingCubes(X,Y,Z,segmentation,isovalue);
        time.marchingCubes = toc;
        
            % Optional arguments COLORS ans COLS can be used to produce 
            % interpolated mesh face colors. For usage, see Matlab's isosurface.m. 
            % [F,V,col] = MarchingCubes(x,y,z,c,iso,colors)
        
        cubes_numberOfFaces = length(F);
        cubes_numberOfVertices = length(V);

        if debugPlot
            subplot(1,2,2)
            patch('Faces',F,'Vertices', V, ...            
                    'edgecolor', 'none', ...
                    'facecolor', 'red');

                view(34,-38);
                daspect([1,1,0.1]); axis tight
                camlight 
                lighting gouraud
                xlabel('X'); ylabel('Y'); zlabel('Z')
                titStr2 = sprintf('%s\n%s\n%s', ['"Marching Cubes" (isovalue = ', num2str(isovalue,4), ') with a lighting'], ...
                                 ['no of faces = ', num2str(cubes_numberOfFaces), ', no of vertices = ', num2str(cubes_numberOfVertices)], ...
                                 ['computation time = ', num2str(time.marchingCubes,3), ' sec']);
                title(titStr2)

            % save the figure
            % export_fig(fullfile('figuresOut', 'reconstructionTesting.png'), '-r300', '-a1')
            
        end
           
    
    %% Condition data

        % triangulate the faces, vertices
        % http://www.mathworks.com/matlabcentral/answers/25865-how-to-export-3d-image-from-matlab-and-import-it-into-maya
        % see also : 
        tr = triangulation(F, V);

        % Delauney
        DT = delaunayTriangulation(tr.Points); 

        % save the reconstruction out as .mat file
        save(fullfile('debugMATs', 'reconstructionOut.mat'), 'F', 'V');

    %% External formats
    
        % STLWrite
        % http://www.mathworks.com/matlabcentral/fileexchange/20922-stlwrite-filename--varargin-
        stlwrite(fullfile('figuresOut', 'testReconstruction.stl'), F, V)
    
        % Write to OFF (or PLY, SMF, WRL, OBJ) using the Toolbox Graph by 
        write_mesh(fullfile('figuresOut', 'reconstructionOut.off'), V, F)
        
        % Paraview export (VTK)
        % http://www.mathworks.com/matlabcentral/fileexchange/47814-export-3d-data-to-paraview-in-vtk-legacy-file-format
        whos
        x = 1:1:size(imageStack,1); y = 1:1:size(imageStack,2); z = 1:1:size(imageStack,3);
        size(DT.ConnectivityList)
        % vtkwrite(fullfile('debugMATs', 'reconstructionOut.vtk'), 'polydata','tetrahedron',x,y,z,DT.ConnectivityList);

       


        % as a Wavefront/Alias Obj file
        % http://www.aleph.se/Nada/Ray/matlabobj.html
