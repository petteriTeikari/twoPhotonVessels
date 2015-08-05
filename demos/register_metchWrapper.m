function [A, b, points_after_proj] = register_metchWrapper(V1, V2, F1, F2, options)

    % if using the original variable names:
    % pt = V2
    % no = V1
    % el = F1

    % Transpose inputs
    V1 = V1';
    V2 = V2';
    F1 = F1';
    F2 = F2';
    
    % modified from: demo_registration_ex1.m    
    pnum=size(V2,1);

    %% Find corresponding points (initial guess)
        
        % select 4 land-marks on the mesh (vertices) to be registered
        ptidx=[4 107 1 190];
        ptselected=V2(ptidx,:);

        % find the corresponding land-marks on the mesh
        meshidx=ptidx; % add 
        meshselected=V1(meshidx,:);
        
            % PT NOTE!

                % Instead of manually defining the points to start with, one
                % could use some feature descriptor such as ROPS or 3D-SIFT to
                % get good initial guesses?

                % In the example the authors had "cheated" and new the roughly
                % corresponding points
        
        % calculate the affine mapping using these point pairs
        [A0,b0] = affinemap(ptselected,meshselected);
        
            % PT: we can cheat here and input the A0 and b0 from ICP to
            %     test the algorithm
            A0 =   [0.9924    0.0868   -0.0872; ...
                    -0.0793    0.9931    0.0868; ...
                    0.0941   -0.0793    0.9924];
            b0 = 1.0e-04 * [-0.1381; -0.0778; -0.1186];
                
        % a rough registration from the selected point pairs
        disp('   rough registration of selected point pairs')
        points_after_initmap=(A0*V2'+repmat(b0(:),1,pnum))';
        plot3(points_after_initmap(:,1),points_after_initmap(:,2),points_after_initmap(:,3),'r.');
        A0
        b0
        
    %% Refine registration
    
        % set pmask: if pmask(i) is -1, it is a free nodes to be optimized
        %            if pmask(i) is 0, it is fixed
        %            if pmask(i) is a positive number, it is the index of 
        %               the mesh node to map to

        pmask=-1*ones(pnum,1);
        % pmask(ptidx)=meshidx;

        % perform mesh registration with Gauss-Newton method using A0/b0 
        % as initial guess
        disp('    mesh registration with Gauss-Newton-Method using the initial guesses')
        maxIter = 10;
        [A,b,newpos]=regpt2surf(V1,F1,V2,pmask,A0,b0,ones(12,1),maxIter);
        
        % display transformation / translation matrices/vectors
        A
        b
        
        % update point cloud with the optimized mapping
        points_after_optimize=(A*V2'+repmat(b(:),1,pnum))';
        plot3(points_after_optimize(:,1),points_after_optimize(:,2),points_after_optimize(:,3),'g+');
        
    %% Display
    
        % project the optimized point cloud onto the surface, and make
        % sure the comformity

        nv=nodesurfnorm(V1,F1);
        [d2surf,cn]=dist2surf(V1,nv,points_after_optimize);
        [points_after_proj eid weights]=proj2mesh(V1,F1,points_after_optimize,nv,cn);
        
        plot3(points_after_proj(:,1),points_after_proj(:,2),points_after_proj(:,3),'c*');
        legend('surface mesh','points after initial map','points after optimized map',...
               'points after projection');