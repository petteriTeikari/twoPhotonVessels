function reconstructionOut = mesh_filterMain(reconstruction, operation, algorithm, options, t, ch, param)
    
    %% INPUT CHECK

        % debug
        if nargin == 0

            % get the current path (where this .m file is)
            fileName = mfilename; fullPath = mfilename('fullpath');
            pathCode = strrep(fullPath, fileName, '');
            if ~isempty(pathCode); cd(pathCode); end

            load(fullfile('testData', 'testMeshFilter.mat'))
            operation = 'simplification'; % sequential, on top of previous
            algorithm = 'CGALcombo';
            options = [];
            t = 1;
            ch = 1;            
            param = mesh_setCGALFilterDefaultParam(); % set default parameter values
            
        else
            % save(fullfile('testData', 'testMeshFilter.mat'), 'reconstruction')
        end
        reconstructionOut = reconstruction;
    
    %% FILTERING
    
    
        if strcmp(operation, 'repair')

            % repair something
            if strcmp(algorithm, 'Basic')
                disp('Some "basic" repair functions to automatically fix the mesh, like in Meshlab')

            else
                error(['You wanted algorithm: "', algorithm, '" which is not implemented'])
            end

        elseif strcmp(operation, 'simplification')

            % do something, e.g. WLOP
            if strcmp(algorithm, 'WLOP')
                disp('CGAL WLOP call here')

            elseif strcmp(algorithm, 'Outlier removal')
               disp('CGAL Outlier Removal call here')

            elseif strcmp(algorithm, 'CGALcombo')
                disp('Simplify the mesh via point cloud operations')                
                source = 'matlabMesh';
                [pointsOut, normalsOut, paramOut] = points_filterCGALCombo(reconstruction, param, source);
                
                disp('Reconstruct mesh from the simplified point cloud')
                reconstructionOut = mesh_CGAL_reconstructionFromPoints(pointsOut, normalsOut, paramOut, param);
               
            else
                error(['You wanted algorithm: "', algorithm, '" which is not implemented'])
            end


        elseif strcmp(operation, 'smoothing')

            % do something else, e.g. BILATERAL SMOOTHING
            if strcmp(algorithm, 'Bilateral')
                disp('CGAL Bilateral Smoothing  call here')

            else
                error(['You wanted algorithm: "', algorithm, '" which is not implemented'])
            end

        else

            error('this kind of doing not implemented')

        end