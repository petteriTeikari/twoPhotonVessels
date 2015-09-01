function param = mesh_setCGALFilterDefaultParam()
            
    % Define the parameters
    % ---------------------
    param.CGALpath = fullfile(fullfile('.', 'CGAL'));
    
    
    % NOTE! need to be in the order that the function is actually called!
    % check the behavior of mesh_constructCGALparameters()

    % NOTE2! the first fieldname must match the name of the filter
    % (folder and the filename.cpp)

    %% POINT CLOUD OPERATIONS
    
        % get average spacing
        param.analyzePoints.nb_neighbors = 6;

        % remove outliers
        param.removeOutliers.removed_percentage = 5;
        param.removeOutliers.nb_neighbors = 24;

        % WLOP simplification (consolidation)
        param.WLOP.retain_percentage = 20;  % percentage of points to retain.
        param.WLOP.neighbor_radius = 0.5;   % neighbors size.

        % normal estimation
        param.normalEstimation.nb_neighbors = 18; % K-nearest neighbors = 3 rings

        % bilateral smoothing
        param.bilateralSmoothing.sharpness_angle = 20; % control sharpness of the result.
                                                       % The bigger the smoother the result will be
        param.bilateralSmoothing.iter_number = 2;      % number of times the projection is applied
        param.bilateralSmoothing.k = 75;               % size of neighborhood. The bigger, the smoother the result will be.
                                                       % This value should bigger than 1.

        % Edge-Aware Resampling (EAR)
        param.EAR.sharpness_angle = 25;         % control sharpness of the result, e.g. 25
        param.EAR.edge_sensitivity = 0;         % higher values will sample more points near the edges, e.g. 0
        param.EAR.neighbor_radiusEAR = 0.25;    % initial size of neighborhood, e.g. 0.25
        param.EAR.resamplingFactor = 0.5;       % smaller than 1 for downsampling
        
        
    %% MESH OPERATIONS
    
        % these could be re-defined after the point cloud simplification
        param.poissonReconstruction.sm_angleangle = 20; % 20, Min triangle angle in degrees.
        param.poissonReconstruction.sm_radius = 30; % 30, Max triangle size w.r.t. point set average spacing.
        param.poissonReconstruction.sm_distance = 0.375; % 0.375, Surface Approximation error w.r.t. point set average spacing.
        param.poissonReconstruction.sm_sphere_radiusMultiplier = 5; % 5, multiply sphere radius
        param.poissonReconstruction.nb_neighbors = param.analyzePoints.nb_neighbors; % same as for analyzePoints.cpp
        param.poissonReconstruction.averageSpacing = 0; % calculated later
        