function reconstruction = reconstructSegmentation(imageStack, segmentation, options)

    % Direct import from .mat file if needed
    if nargin == 0
        close all
        load(fullfile('/home', 'petteri', 'Desktop', 'testPM', 'testReconstruction.mat'))        
    else
        save(fullfile('/home', 'petteri', 'Desktop', 'testPM', 'testReconstruction.mat'));        
    end
    
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

    %% EXTRACT THE CONTOURS
    
        close all % close all open figures
        fig = figure('Color', 'w');
            scrsz = get(0,'ScreenSize'); % get screen size for plotting 
            set(fig,  'Position', [0.03*scrsz(3) 0.045*scrsz(4) 0.9*scrsz(3) 0.50*scrsz(4)])
    
        sliceVector = 1:size(segmentation,3);
        numberOfContourLevelsPerSlice = 16;
        
        subplot(1,3,1)
        
        % this does not actually return anything, it just visualizes the
        % volumetric data
        % http://www.mathworks.com/help/matlab/ref/contourslice.html
        contourslice(segmentation, [], [], sliceVector, numberOfContourLevelsPerSlice);
            view(34,-38);
            daspect([1,1,0.01]); axis tight
            xlabel('X'); ylabel('Y'); zlabel('Z')
            title(['Contours (n=', num2str(numberOfContourLevelsPerSlice), ') of each slice'])            
        
        % if you want to interface with Point Cloud Library (PCL), see:
        % MATLAB to Point Cloud Library by Peter Corke 
        % http://au.mathworks.com/matlabcentral/fileexchange/40382-matlab-to-point-cloud-library
    
    %% EXTRACT THE MESH 

        % extract from the volumetric segmentation data
        % http://www.mathworks.com/help/matlab/ref/isosurface.html
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
        [F,V] = MarchingCubes(X,Y,Z,segmentation,isovalue);
        time.marchingCubes = toc;
        
        cubes_numberOfFaces = length(F);
        cubes_numberOfVertices = length(V);

        subplot(1,3,3)
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
        export_fig(fullfile('figuresOut', 'reconstructionTesting.png'), '-r300', '-a1')