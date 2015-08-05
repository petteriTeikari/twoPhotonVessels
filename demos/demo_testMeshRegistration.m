function demo_testMeshRegistration()

    %% import test data
    
        % define file names
        mesh1 = fullfile('..', 'testData', 'testReconstruction_physicDimensions_6-25perc_decimated_v2segmentation.off');
        mesh2 = fullfile('..', 'testData', 'testReconstruction_physicDimensions_6-25perc_decimated_v2segmentation_allAxes5degRotated.off');
        
            % mesh2 should have 3 rotations about x,y and z axes and no
            % translations. To test the robustness of the algorithm, you
            % could add noise at this point to either or both meshes, see
            % e.g. http://www.mathworks.com/matlabcentral/fileexchange/5355-toolbox-graph/content/toolbox_graph/html/content.html#11
            
            % First we create a noisy mesh by displacement of the vertices along the normal direction (those are the most distructive displacements).
                % normals = compute_normal(vertex,faces);
                % rho = randn(1,size(vertex,2))*.02;
                % vertex1 = vertex + repmat(rho,3,1).*normals;
            
            
        % read in, from Toolbox Graph: 
        % http://www.mathworks.com/matlabcentral/fileexchange/5355-toolbox-graph
        [vertex1,face1] = read_off(mesh1);
        [vertex2,face2] = read_off(mesh2);
        
        % plot input
        plotON = false;
        if plotON
            figure('Color', 'w')
            subplot(1,2,1); displayMesh(vertex1, face1)
            subplot(1,2,2); displayMesh(vertex2, face2)
        end
        
    %% try different algorithms for rigid registration
    
        % see for example
        % http://stackoverflow.com/questions/9065156/how-to-align-two-meshes
        whos
      
        
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