function [regReconstruction, transformMatrix] = registerTheMeshes(modelMesh, reconstruction, registrationAlgorithm, modelIndex, timePoints, options, t, ch)

    disp('3D Registration of the reconstructed 3D mesh')
    regReconstruction = []; 
    transformMatrix = [];
    
    %% Input checking
            
        dataIndices = ones(size(timePoints));
        dataIndices(modelIndex) = 0;
    
        % for the model, no registration is done
        if modelIndex == t           
            disp(['  TimePoint = ', num2str(timePoints(t)), ' is the model mesh, no registration done'])
            regReconstruction = reconstruction;
            transformMatrix.TR = [1 1 1; 1 1 1; 1 1 1];
            transformMatrix.TT = [1 1 1]';
            return
        else
            disp(['   Registering timePoint = ', num2str(timePoints(t)), ' to the model mesh (timePoint = ', num2str(timePoints(modelIndex)), ')'])
        end
    
    %% REGISTER
    
        if strcmp(registrationAlgorithm, 'ICP')
            
            % http://www.mathworks.com/matlabcentral/fileexchange/24301-finite-iterative-closest-point
            model = modelMesh.vertices;
            data = reconstruction.vertices;
            
            [TR,TT,dataOut]=icp(model,data); % Least squares criterion   
                disp('   ICP Least Squares'); 
                [TRdeg, rot] = register_displayMatrixInDegrees(TR,TT,timePoints(t));               
                visualize_plotICP(model,data,TR,TT,dataOut, 'LeastSquares')   
            
            % [TR2,TT2,dataOut2]=icp(model,data,[],[],4); % Welsh criterion   
            %    disp('   ICP Welsh'); ; [TRdeg2, rot2] = register_displayMatrixInDegrees(TR2,TT2,t);         
            % visualize_plotICP(model,data,TR2,TT2,dataOut2, 'Welsh')
            
            % OUTPUT
            regReconstruction = dataOut;
            transformMatrix.TR = TR;
            transformMatrix.TT = TT;
            
        elseif strcmp(registrationAlgorithm, 'somethingElse')            
            % put something here
            
        else
            error([registrationAlgorithm, ' | no such registration algorithm implemented'])            
        end
        
        
    %% SUBFUNCTIONS
    
        % Plot ICP algorithm
        function visualize_plotICP(model, data, TR, TT, dataOut, titleStrBase)

            fig = figure('Color', 'w', 'Name', titleStrBase);
            plot3(model(1,:),model(2,:),model(3,:),'r.',dataOut(1,:),dataOut(2,:),dataOut(3,:),'g.')
            hold on, axis equal
            plot3([1 1 0],[0 1 1],[0 0 0],'r-',[1 1],[1 1],[0 1],'r-','LineWidth',2)
            title([titleStrBase, ': Transformed data points (green) and model points (red)'])
            drawnow
        
            
        % Display transformation matrix (in degrees)
        function [TRdeg,rot] = register_displayMatrixInDegrees(TR, TT, t)
            
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

        disp(['   TimePoint = ', num2str(t), ' | TRANSFORMATION of the DATA to register it to the MODEL:'])
            disp(['    Rotation: ', num2str(rot.x,4), 'deg (x), ', num2str(rot.y,4), 'deg (y), ', num2str(rot.z,4), 'deg (z)'])
            disp(['    Translation: ', num2str(trans.x,4), 'px (x), ', num2str(trans.y,4), 'px (y), ', num2str(trans.z,4), 'px (z)'])
            disp(['    Scale: ', num2str(100*scale.x), '% (x), ', num2str(100*scale.y), '% (y), ', num2str(100*scale.z), '% (z)'])
            disp(' ')

