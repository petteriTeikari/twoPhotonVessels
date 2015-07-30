function region = asets_demoWrapper_2D(img, vessel, edges)

    %% Tutorial 02: Time-implicit level set segmentation
    %  Martin Rajchl, Imperial College London, 2015
    %
    %   [1] Rajchl, M.; Baxter, JSH.; Bae, E.; Tai, X-C.; Fenster, A.; 
    %       Peters, TM.; Yuan, J.;
    %       Variational Time-Implicit Multiphase Level-Sets: A Fast Convex 
    %       Optimization-Based Solution
    %       EMMCVPR, 2015.
    %
    %   [2] Ukwatta, E.; Yuan, J.; Rajchl, M.; Qiu, W.; Tessier, D; Fenster, A.
    %       3D Carotid Multi-Region MRI Segmentation by Globally Optimal 
    %       Evolution of Coupled Surfaces
    %       IEEE Transactions on Medical Imaging, 2013
    
    % include max-flow solver
    addpath(fullfile('..', '..', '3rdParty', 'asetsMatlabLevelSets', 'maxflow'));
    addpath(fullfile('..', '..', '3rdParty', 'asetsMatlabLevelSets', 'lib'));
    
    debugPlots = true;
    
    %% 1) LOAD IMAGE
    
        % done in the main
        % imshow(vessel,[])
        

    %% 2. Normalize the image intensity to [0,1]:
    img = single(img);
    img_n = (img - min(img(:))) / (max(img(:)) - min(img(:)));

   % 3. Initialize a region as initialization for the zero level set
   
        % default definition
        region = zeros(size(img_n),'like', img_n);
        ind1 = floor(0.01*size(img_n,1));
        ind2 = ceil(0.99*size(img_n,1));
        region(ind1:ind2, ind1:ind2) = 1;
        
        % PT: added
        % region = edges;
        regionType = 'binary';
        
        region = abs(vessel/max(vessel(:))); regionType = 'continuous';

    % visualize initial region
    fig = figure('Color', 'w');
        rows = 4; cols = 4;
        scrsz = get(0,'ScreenSize'); % get screen size for plotting    
        set(fig,  'Position', [0.2*scrsz(3) 0.05*scrsz(4) 0.7*scrsz(3) 0.90*scrsz(4)])

    i = 1;
    subplot(rows,cols,i); imshow(img_n,[]);
    hold on; contour(region,'r'); hold off;
    title('Initial region');
    drawnow

    % 4. Construct an s-t graph:
    [sx, sy] = size(img_n);

    Cs = zeros(sx,sy);
    Ct = zeros(sx,sy);

    % allocate alpha(x), the regularization weight at each node x
    alpha = zeros(sx,sy);

    % 5. Set up parameters and start level set iterations:
    maxLevelSetIterations = 6; % number of maximum time steps
    tau = 500; % speed parameter
    w1 = 0.95; % weight parameter for intensity data term
    w2 = 0.05; % weight parameter for the speed data term
    
    for t=1:maxLevelSetIterations

        i = 1;
        
        % 6. Compute a speed data term based on the current region
        if strcmp(regionType, 'continuous')
            d_speed_inside = 1 - region;
            d_speed_outside = region;
            
            % 7. Compute a intensity data term (PT: quick fix) 
            m_int_inside = mean(mean(img_n(region >= 0.5)));
            m_int_outside =  mean(mean(img_n(region < 0.5)));
            
        else % binary 
            d_speed_inside = bwdist(region == 1,'Euclidean');
            d_speed_outside = bwdist(region == 0,'Euclidean');
            
            % 7. Compute a intensity data term based on the L1 distance to the
            % mean
            m_int_inside = mean(mean(img_n(region == 1)));
            m_int_outside =  mean(mean(img_n(region == 0)));
        end
        
        d_int_inside = abs(img_n - m_int_inside);
        d_int_outside = abs(img_n - m_int_outside);
        
        % 8. Compute speed data term as in Tutorial 01:
        d_speed_inside = ((1-region).*d_speed_inside)./tau;
        d_speed_outside = (region.*d_speed_outside)./tau;
        
        % 7. Weight the contribution of both costs and assign them as source 
        % and sink capacities Cs, Ct in the graph        
        Cs = w1.*d_int_outside + w2.*d_speed_outside;
        Ct = w1.*d_int_inside + w2.*d_speed_inside;
        
        % Assign a regularization weight (equivalent to pairwise terms) for each
        % node x. Here we employ a constant regularization weight alpha. The higher
        % alpha is, the more smoothness penalty is assigned.
        regWeight = 0.01;
        alpha = regWeight .* ones(sx,sy);

        % 6. Set up the parameters for the max flow optimizer:
        % [1] graph dimension 1
        % [2] graph dimension 2
        % [3] number of maximum iterations for the optimizer (default 200)
        % [4] an error bound at which we consider the solver converged (default
        %     1e-5)
        % [5] c parameter of the multiplier (default 0.2)
        % [6] step size for the gradient descent step when calulating the spatial
        %     flows p(x) (default 0.16)
        maxIter = 200;
        errorBound = 1e-6;
        pars = [sx; sy; maxIter; errorBound; 0.2; 0.08];

        % 7. Call the binary max flow optimizer with Cs, Ct, alpha and pars to obtain
        % the continuous labelling function u, the convergence over iterations
        % (conv), the number of iterations (numIt) and the run time (time);
        [u, conv, numIt, time] = asetsBinaryMF2D(Cs, Ct, alpha, pars);

        % 8. Threshold the continuous labelling function u to obtain a discrete
        % segmentation result
        region = u > 0.5;

        
        % Visualize the costs  
        i = i+1; subplot(rows,cols,i); loglog(conv, 'Color', [0 .7 1]); title(['convergence(',num2str(t),')']); axis square;
            text(0.5*maxIter, 10*errorBound, ['no of iter = ', num2str(numIt)], 'HorizontalAlignment', 'right');
            xlim([0 maxIter]); ylim([errorBound 0.001])
            text(0.5*maxIter, 2*errorBound, ['time/iter = ', num2str(time,3), 's'], 'HorizontalAlignment', 'right');
        
        i = i+1; subplot(rows,cols,i); imshow(d_int_inside, []); title(['Intensity IN']);
        i = i+1; subplot(rows,cols,i); imshow(d_int_outside, []); title(['Intensity OUT']);
        i = i+1; subplot(rows,cols,i); imshow(d_speed_inside, []); title(['Speed IN']);
        i = i+1; subplot(rows,cols,i); imshow(d_speed_outside, []); title(['Speed OUT']);
        i = i+1; subplot(rows,cols,i); imshow(Ct, []); title(['Ct']);
        i = i+1; subplot(rows,cols,i); imshow(Cs, []); title(['Cs']);
        % i = i+1; subplot(rows,cols,i); imshow(u, []); title(['u, \tau = ']);            
        
        i = i+1; subplot(rows,cols,[i i+1 i+cols i+cols+1]); imshow(Cs-Ct,[]); title(['Cs-Ct (w1=', num2str(w1), ', w2=', num2str(w2), ')']);
        i = i+2; subplot(rows,cols,[i i+1 i+cols i+cols+1]); imshow(img,[]); title(['r(',num2str(t),'), \alpha = ', num2str(regWeight), ', \tau =', num2str(tau)]); hold on; contour(region,'r'); hold off;
        
        drawnow();
        
        if t < 10
            index = ['0', num2str(t)];
        else
            index = num2str(t);
        end
        
        % export_fig(['iter_', num2str(index), '.png'], '-r200', '-a2')
     
       
        
    end


