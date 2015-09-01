function [pointsOut, normalsOut, fileOut, paramOut] = points_filterCGALCombo(meshIn, param, source)
        
        % For the workflow see:
        % http://doc.cgal.org/latest/Point_set_processing_3/#Point_set_processing_3
        
        
        %% we need to first write the input mesh to disk as .xyz file
        
            pathOut = 'tempData';
            meshFilename = 'test.xyz';
            inputMesh = fullfile(pathOut, meshFilename);

            if strcmp(source, 'matlabMesh')
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
            
            elseif strcmp(source, 'meshFile')
                
                
            elseif strcmp(source, 'pointCloudFile')
                
            else
                error(['Source: "', source, '", not defined!']) 
            end
            
        
        %% Computations
        
            timing = [];
        
            % Get average spacing (Input)
            functionFolder = 'analyzePoints';
            [pointAnalysis, ~, timing] = points_CGAL_filterCall(functionFolder, inputMesh, param, timing);
                timing.analyzePointsInput = timing.(functionFolder);
        
            % Remove outliers
            functionFolder = 'removeOutliers'; 
            [~, outputMesh_outlier, timing] = points_CGAL_filterCall(functionFolder, inputMesh, param, timing);
            
            % Simplify with WLOP     
            functionFolder = 'WLOP';            
            [~, outputMesh_WLOP, timing] = points_CGAL_filterCall(functionFolder, outputMesh_outlier, param, timing);
            
            % Estimate normals
            functionFolder = 'normalEstimation';
            [~, outputMesh_normals, timing] = points_CGAL_filterCall(functionFolder, outputMesh_WLOP, param, timing);
            
            % Bilateral Smoothing
            functionFolder = 'bilateralSmoothing'; 
            [~, outputMesh_bilateral, timing] = points_CGAL_filterCall(functionFolder, outputMesh_normals, param, timing);
            
            % Edge-Aware Resampling (EAR)            
            functionFolder = 'EAR';
            [~, outputMesh_EAR, timing] = points_CGAL_filterCall(functionFolder, outputMesh_bilateral, param, timing);
            
            % Get average spacing (Output)
            functionFolder = 'analyzePoints';
            [pointAnalysisPost, ~, timing] = points_CGAL_filterCall(functionFolder, outputMesh_EAR, param, timing);
            
            
        %% Return variables
        
            fileOut = outputMesh_EAR;
        
            paramOut.averageSpacingPre = pointAnalysis.averageSpacing;
            paramOut.averageSpacingPost = pointAnalysisPost.averageSpacing;
            paramOut.timing = timing;

            % read the output point cloud
            point_num = xyz_header_read (outputMesh_EAR);
            pointsOut = xyz_data_read (outputMesh_EAR, point_num);

            % this actually reads in the same as the above two lines, now with
            % the normals stored in columns 4 -> 6
            normalsRaw = dlmread(outputMesh_EAR, ' ');
            normalsOut = normalsRaw(:, 4:6);

            % transpose back if needed
            if transposedTrue
                pointsOut = pointsOut';
                xyz = xyz';
            end