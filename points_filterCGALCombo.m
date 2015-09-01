function [pointsOut, normalsOut] = points_filterCGALCombo(meshIn, param)
        
        % For the workflow see:
        % http://doc.cgal.org/latest/Point_set_processing_3/#Point_set_processing_3
        CGALpath = fullfile(fullfile('.', 'CGAL'));
        
        %% we need to first write the input mesh to disk as .xyz file
        
            pathOut = 'tempData';
            meshFilename = 'test.xyz';
            inputMesh = fullfile(pathOut, meshFilename);

                % write using a subfunction
                point_num = length(meshIn.vertices);
                xyz = meshIn.vertices;
                % need to be 2000 x 3, and not 3 x 2000
                if size(xyz, 1) < size(xyz, 2); 
                    xyz = xyz'; 
                    transposedTrue = true;
                else
                    transposedTrue = false;
                end
                xyz_write (inputMesh, point_num, xyz)                
        
        
        %% Analyze the mesh
        
            functionFolder = 'analyzePoints'; 
            parameters = mesh_constructCGALparameters(param.(functionFolder));        
            pathFull = fullfile(CGALpath, functionFolder, 'build');
            fName = functionFolder; % try to keep the same name        
            command = [fullfile(pathFull, fName), parameters, inputMesh]; % construct the call

                disp('Compute average spacing of the vertices:'); disp(command); tic;
                [status, cmdout] = system(command); % return average spacing
                mesh_checkCGALSystemOutput(cmdout, status, fName)  
                timing.averageSpacing = toc;
                averageSpacing = cmdout;
        
        %% Remove outliers
        
            functionFolder = 'removeOutliers'; 
            parameters = mesh_constructCGALparameters(param.(functionFolder));        
            pathFull = fullfile(CGALpath, functionFolder, 'build');
            fName = functionFolder; % try to keep the same name  
            outputMesh = strrep(inputMesh, '.xyz', ['_', functionFolder, '.xyz']);
            command = [fullfile(pathFull, fName), parameters, inputMesh, ' ', outputMesh]; % construct the call

                disp('Remove outliers from the vertex point cloud:'); disp(command); tic;
                [status, cmdout] = system(command); % return average spacing
                mesh_checkCGALSystemOutput(cmdout, status, fName)  
                timing.outlierRemoval = toc;
        
        %% Simplify with WLOP        
        
            % re-define the input mesh, using the output of the outline
            % removal algorithm
            inputMesh_WLOP = outputMesh;
        
            functionFolder = 'WLOP'; 
            parameters = mesh_constructCGALparameters(param.(functionFolder));        
            pathFull = fullfile(CGALpath, functionFolder, 'build');
            fName = functionFolder; % try to keep the same name  
            outputMesh = strrep(inputMesh, '.xyz', ['_', functionFolder, '.xyz']);
            command = [fullfile(pathFull, fName), parameters, inputMesh_WLOP, ' ', outputMesh]; % construct the call

                disp('WLOP:'); disp(command); tic;
                [status, cmdout] = system(command); % return average spacing
                mesh_checkCGALSystemOutput(cmdout, status, fName)  
                timing.WLOP = toc;
        
        %% Estimate Normals
        
            inputMesh_normals = outputMesh;
            
            functionFolder = 'normalEstimation'; 
            parameters = mesh_constructCGALparameters(param.(functionFolder));        
            pathFull = fullfile(CGALpath, functionFolder, 'build');
            fName = functionFolder; % try to keep the same name  
            outputMesh = strrep(inputMesh, '.xyz', ['_', functionFolder, '.xyz']);
            command = [fullfile(pathFull, fName), parameters, inputMesh_normals, ' ', outputMesh]; % construct the call

                disp('normalEstimation:'); disp(command); tic;
                [status, cmdout] = system(command); % return average spacing
                mesh_checkCGALSystemOutput(cmdout, status, fName)  
                timing.normalEstimation = toc;
        
        %% Bilateral Smoothing
        
            inputMesh_smoothing = outputMesh;
            
            functionFolder = 'bilateralSmoothing'; 
            parameters = mesh_constructCGALparameters(param.(functionFolder));        
            pathFull = fullfile(CGALpath, functionFolder, 'build');
            fName = functionFolder; % try to keep the same name  
            outputMesh = strrep(inputMesh, '.xyz', ['_', functionFolder, '.xyz']);
            command = [fullfile(pathFull, fName), parameters, inputMesh_smoothing, ' ', outputMesh]; % construct the call

                disp('bilateralSmoothing:'); disp(command); tic;
                [status, cmdout] = system(command); % return average spacing
                mesh_checkCGALSystemOutput(cmdout, status, fName)  
                timing.bilateralSmoothing = toc;
        
        
        %% Edge-Aware Resampling (EAR)
            
            inputMesh_EAR = outputMesh;
        
            functionFolder = 'EAR'; 
            parameters = mesh_constructCGALparameters(param.(functionFolder));        
            pathFull = fullfile(CGALpath, functionFolder, 'build');
            fName = functionFolder; % try to keep the same name  
            outputMesh = strrep(inputMesh, '.xyz', ['_', functionFolder, '.xyz']);
            command = [fullfile(pathFull, fName), parameters, inputMesh_EAR, ' ', outputMesh]; % construct the call

                disp('EAR:'); disp(command); tic;
                [status, cmdout] = system(command); % return average spacing
                mesh_checkCGALSystemOutput(cmdout, status, fName)  
                timing.EAR = toc;
            
        averageSpacing
        timing
        
        % read the output point cloud
        point_num = xyz_header_read (outputMesh);
        pointsOut = xyz_data_read (outputMesh, point_num);
        
        % this actually reads in the same as the above two lines, now with
        % the normals stored in columns 4 -> 6
        normalsRaw = dlmread(outputMesh, ' ');
        normalsOut = normalsRaw(:, 4:6);
        
        % transpose back if needed
        if transposedTrue
            pointsOut = pointsOut';
            xyz = xyz';
        end
        whos