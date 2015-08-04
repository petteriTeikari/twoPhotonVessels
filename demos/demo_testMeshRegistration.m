function demo_testMeshRegistration()

    %% import test data
    
        % define file names
        mesh1 = fullfile('..', 'testData', 'testReconstruction_physicDimensions_6-25perc_decimated.ply');
        mesh2 = fullfile('..', 'testData', 'testReconstruction_physicDimensions_6-25perc_decimated_allAxes45degRotated.ply');
        
        % read in, from Toolbox Graph: 
        % http://www.mathworks.com/matlabcentral/fileexchange/5355-toolbox-graph
        [vertex1,face1] = read_ply(mesh1);
        [vertex2,face2] = read_ply(mesh2);
        
        % plot input
        plotON = false;
        if plotON
            figure('Color', 'w')
            subplot(1,2,1); displayMesh(vertex1, face1)
            subplot(1,2,2); displayMesh(vertex2, face2)
        end
        
    %% try different algorithms
    
        
    
    
        
    % subfunction to display mesh    
    function displayMesh(V, F)
        
        patch('Faces',F,'Vertices', V, ...            
                'edgecolor', 'none', ...
                'facecolor', 'red');

        view(3);
        daspect([1,1,0.1]); 
        axis tight
        camlight 
        lighting gouraud