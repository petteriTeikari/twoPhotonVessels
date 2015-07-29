function demo_segmentationMethods()

    clear all; close all;


    %% INPUT DATA
    
        fileName = 'slices10_16_wVesselnessEdgesGVF.mat';
        fileMat = fullfile('testData', fileName);
        resizeOn = true;
        resizeFactor = 1/16;
        plotOn = false;
        [img, vessel, edges, GVF] = input_segmentationTestData(fileMat, resizeOn, resizeFactor, plotOn);
 
        saveAs_MHD = false;
        if saveAs_MHD            
            % save as MHD so for example OpenCL segmentations can be run
            % write_mhd_wrapper(strrep(fileMat, '_wVesselnessEdgesGVF.', '.mhd'), img)
        end
        
    %% SEGMENT
    
        sliceIndex = 1;
    
        %% 3D Level set        
        
            % asets_demoWrapper_3D(img, vessel, edges, sliceIndex)

        %% 3D Snake
        
            % create a mesh from vesselness image
            debugPlot = false;
            isoValue = 0.1; % relative to max
            downSampleFactor = [1 1]; % [xy z] downsample to get less vertices/faces
            physicalScaling = [1 1 1]; % physical units of FOV
            [FV.faces,FV.vertices] = reconstruct_marchingCubes_wrapper(vessel, isoValue, downSampleFactor, physicalScaling, debugPlot);
            FV
            
            Options.Mu = 0.2; % Trade of between real edge vectors, and noise vectors,
                              % default 0.2. (Warning setting this to high >0.5 gives an instable Vector Flow)            
            Options.GIterations = 0; % Number of GVF iterations, default 0
            Options.Sigma3 = 1.0; % Sigma used to calculate the laplacian in GVF, default 1.0
            % OV = Snake3D(img, FV, Options);
        
        
    
    
    
    
function write_mhd_wrapper(fileOut, img)

    % would require some metadata for the img
    % write_mhd(fileOut, img)
    
function asets_demoWrapper_3D(img, vessel, edges, sliceIndex)

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
    
    %% 1) LOAD IMAGE
    
        % done in the main

    %% 2. Normalize the image intensity to [0,1]:
    img = single(img);
    img_n = (img - min(img(:))) / (max(img(:)) - min(img(:)));

    % 3. Initialize a region as initialization for the zero level set
    %region = zeros(size(img_n),'like', img_n);
    %region(64:100,64:100, 1:size(img,3)) = 1;
    
        speedFieldIsBinary = true;
        if speedFieldIsBinary
            region = single(edges);

        else        
            region = single(vessel);

            [min(region(:)) max(region(:))]
            modeOfVesselness = mode(region(:))
            subplot(1,3,1); imshow(region(:,:,sliceIndex),[]); colormap('jet'); colorbar

            max(region(:))
            region = region / max(region(:));    
            subplot(1,3,2); imshow(region(:,:,sliceIndex),[]); colormap('jet'); colorbar

            region = region / 2;
            region = region - min(region(:));
            region = region / max(region(:));
            subplot(1,3,3); imshow(region(:,:,sliceIndex),[]); colormap('jet'); colorbar
        end

    
    % visualize initial region
    figure('Color', 'w');
    rows = 2; cols= 3;
    subplot(rows,cols, 1)
    imshow(img(:,:,sliceIndex), []); title('Input image')

    subplot(rows,cols, 2)
    imshow(vessel(:,:,sliceIndex), []); title('Vessel (norm.)')
    hold on; contour(edges(:,:,sliceIndex),'r'); hold off;

    subplot(rows,cols, 3); imshow(img_n(:,:,sliceIndex),[]);
    hold on; contour(region(:,:,sliceIndex),'r'); hold off;
    title('Initial region');
    drawnow;
    
    % 4. Construct an s-t graph:
    [sx, sy, sz] = size(img_n);

    Cs = zeros(sx, sy, sz);
    Ct = zeros(sx, sy, sz);

    % allocate alpha(x), the regularization weight at each node x
    alpha = zeros(sx, sy, sz);

    %% 5. Set up parameters and start level set iterations:
    maxLevelSetIterations = 20; % number of maximum time steps
    tau = 50; % speed parameter
    w1 = 0.8; % weight parameter for intensity data term
    w2 = 0.2; % weight parameter for the speed data term

    for t=1:maxLevelSetIterations

        % 6. Compute a speed data term based on the current region    
        if speedFieldIsBinary
            d_speed_inside = bwdist(region == 1,'Euclidean');
            d_speed_outside = bwdist(region == 0,'Euclidean');
        else
            warning('Not working properly')
            d_speed_inside = 1 - region;
            d_speed_outside = region;
        end

            % debug plot
            if t == -2
                figure
                subplot(1,2,1)
                imshow(d_speed_inside(:,:,sliceIndex))
                subplot(1,2,2)
                imshow(d_speed_outside(:,:,sliceIndex))
                whos
                pause
            end

        % 7. Compute a intensity data term based on the L1 distance to the
        % mean
        m_int_inside = mean(mean(img_n(region == 1)));
        m_int_outside =  mean(mean(img_n(region == 0)));

        d_int_inside = abs(img_n - m_int_inside);
        d_int_outside = abs(img_n - m_int_outside);

        % 8. Compute speed data term as in Tutorial 01:
        d_speed_inside = ((1-region).*d_speed_inside)./tau;
        d_speed_outside = (region.*d_speed_outside)./tau;

        % 7. Weight the contribution of both costs and assign them as source 
        % and sink capacities Cs, Ct in the graph
        Cs = w1.*d_int_outside + w2.*d_speed_outside;
        Ct = w1.*d_int_inside + w2.*d_speed_inside;

        [min(Cs(:)) max(Cs(:)) min(Ct(:)) max(Ct(:))]

        % Assign a regularization weight (equivalent to pairwise terms) for each
        % node x. Here we employ a constant regularization weight alpha. The higher
        % alpha is, the more smoothness penalty is assigned.
        alpha = 1.5.*ones(sx,sy,sz);

        % 6. Set up the parameters for the max flow optimizer:
        % [1] graph dimension 1
        % [2] graph dimension 2
        % [3] graph dimension 3
        % [4] number of maximum iterations for the optimizer (default 200)
        % [5] an error bound at which we consider the solver converged (default
        %     1e-5)
        % [6] c parameter of the multiplier (default 0.2)
        % [7] step size for the gradient descent step when calulating the spatial
        %     flows p(x) (default 0.16)
        pars = [sx; sy; sz; 200; 1e-5; 0.2; 0.16];

        % 7. Call the binary max flow optimizer with Cs, Ct, alpha and pars to obtain
        % the continuous labelling function u, the convergence over iterations
        % (conv), the number of iterations (numIt) and the run time (time);
        [u, conv, numIt, time] = asetsBinaryMF3D(Cs, Ct, alpha, pars);

        % 8. Threshold the continuous labelling function u to obtain a discrete
        % segmentation result
        region = u > 0.5;

        %% visualize the costs   
        subplot(rows,cols,4); imshow(Cs(:,:,sliceIndex)-Ct(:,:,sliceIndex)); title('Cs-Ct');
        
        % contour extremely slow if you get improperly defined contours
        % subplot(rows,cols,5); imshow(img(:,:,sliceIndex),[]); title(['r(',num2str(t),')']); hold on; contour(region(:,:,sliceIndex),'r'); hold off;
        subplot(rows,cols,5); imshow(region(:,:,sliceIndex), [])
        subplot(rows,cols,6); loglog(conv); title(['convergence(',num2str(t),')']);
        drawnow();

        % export_fig(['vesselProgress_t', num2str(t), '.png'], '-r150', '-a1')

    end


