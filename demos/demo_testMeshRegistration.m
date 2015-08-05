function demo_testMeshRegistration()

    close all

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
        
            % faces are the same, check for example
            diffOfFaces = sum(sum(face1 - face2)) % should be zero
           
                % whereas the vertices have been rotated, and we need to find
                % the rotations  
        
        % plot input
        plotON = false;
        if plotON
            % figure('Color', 'w')
            %subplot(1,2,1); displayMesh(vertex1, face1)
            %subplot(1,2,2); displayMesh(vertex2, face2)
            displayVertices(vertex1, vertex2)
        end
        
    %% try different algorithms for rigid registration
    
        % see for example
        % http://stackoverflow.com/questions/9065156/how-to-align-two-meshes
        
        options.registerAlgorithm = 'ICP';
        options.registerAlgorithm = 'metch';
                
        % ICP
        if strcmp(options.registerAlgorithm, 'ICP')

            % http://www.mathworks.com/matlabcentral/fileexchange/24301-finite-iterative-closest-point
            model = vertex1;
            data = vertex2;
            [TR,TT,dataOut]=icp(model,data); % Least squares criterion   
                TR
                TT
                disp('Least Squares'); [TRdeg, rot] = displayMatrixInDegrees(TR,TT);
            [TR2,TT2,dataOut2]=icp(model,data,[],[],4); % Welsh criterion   
                disp('Welsh'); [TRdeg2, rot2] = displayMatrixInDegrees(TR2,TT2);

            plotICP(model,data,TR,TT,dataOut, 'LeastSquares')            
            plotICP(model,data,TR2,TT2,dataOut2, 'Welsh')

        % METCH     
        elseif strcmp(options.registerAlgorithm, 'metch')
              
            options = [];
            [A, b, points_after_proj] = register_metchWrapper(vertex1, vertex2, face1, face2, options);
            disp('Metch'); [Adeg, rot] = displayMatrixInDegrees(A,b);
            whos
            
        else
            error([options.registerAlgorithm, '? No such registration algorithm!'])            
        end
       
      
    %% SUBFUNCTIONS
    
    
        % subfunction to display input mesh    
        function displayMesh(V, F)

            patch('Faces',F,'Vertices', V, ...            
                    'edgecolor', 'none', ...
                    'facecolor', 'red');

            view(3);
            daspect([1,1,0.1]); 
            axis tight
            camlight 
            lighting gouraud
            
        % display input vertices
        function displayVertices(vertex1, vertex2)
            
            fig = figure('Color','w', 'Name', 'Input Vertices');
            plot3(vertex1(1,:),vertex1(2,:),vertex1(3,:),'r.',vertex2(1,:),vertex2(2,:),vertex2(3,:),'g.')
            legend('Vertex1 (model)', 'Vertex2 (data)'); legend('boxoff')
            title('Input Vertices')
            drawnow
            
        % Plot ICP algorithm
        function plotICP(model, data, TR, TT, dataOut, titleStrBase)

            fig = figure('Color', 'w', 'Name', titleStrBase);
            plot3(model(1,:),model(2,:),model(3,:),'r.',dataOut(1,:),dataOut(2,:),dataOut(3,:),'g.')
            hold on, axis equal
            plot3([1 1 0],[0 1 1],[0 0 0],'r-',[1 1],[1 1],[0 1],'r-','LineWidth',2)
            title([titleStrBase, ': Transformed data points (green) and model points (red)'])
            drawnow
        
        function [TRdeg,rot] = displayMatrixInDegrees(TR, TT)
            
            % Display transformation matrix
            
                % see e.g. https://en.wikipedia.org/wiki/Kinematics#Matrix_representation
                %          https://en.wikipedia.org/wiki/Rotation_matrix#Basic_rotations
                %          http://www.mathworks.com/help/phased/ref/rotx.html

                % TR % A0: a 3x3 matrix, affine A matrix (rotation&scaling), "rotation matrix"

                % Radians
                TRrad = [acos(TR(1,1)) -asin(TR(1,2)) asin(TR(1,3)); ...
                         asin(TR(2,1)) acos(TR(2,2)) -asin(TR(2,3)); ...
                         -asin(TR(3,1)) asin(TR(3,2)) acos(TR(3,3))];

                % from radians to degrees
                TRdeg = (TRrad / pi) * 180; 

                % get the scale
                scale.x = sqrt(sum(TR(1,:).^2));
                scale.y = sqrt(sum(TR(2,:).^2));
                scale.z = sqrt(sum(TR(3,:).^2));

                % get rotation per axis
                rotRad.x = atan2(TR(3,2)/scale.z, TR(3,3)/scale.z);
                rotRad.y = -asin(TR(3,1)/scale.z);
                rotRad.z = atan2(TR(2,1)/scale.y, TR(1,1)/scale.x);
                
                rot.x = rotRad.x / pi * 180;
                rot.y = rotRad.y / pi * 180;
                rot.z = rotRad.z / pi * 180;
                
            % Display translation vector
            
                % see e.g. http://demonstrations.wolfram.com/Understanding3DTranslation/
                %          TT - translation in pixels
                % TT % b0: a 3x1 vector, affine b vector (translation), "translation"
                trans.x = TT(1);
                trans.y = TT(2);
                trans.z = TT(3);
            
            disp('  TRANSFORMATION of the DATA to register it to the MODEL:')
                disp(['    Rotation: ', num2str(rot.x,4), 'deg (x), ', num2str(rot.y,4), 'deg (y), ', num2str(rot.z,4), 'deg (z)'])
                disp(['    Translation: ', num2str(trans.x,4), 'px (x), ', num2str(trans.y,4), 'px (y), ', num2str(trans.z,4), 'px (z)'])
                disp(['    Scale: ', num2str(100*scale.x), '% (x), ', num2str(100*scale.y), '% (y), ', num2str(100*scale.z), '% (z)'])
                disp(' ')