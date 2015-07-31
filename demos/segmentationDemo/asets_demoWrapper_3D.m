function region = asets_demoWrapper_3D(img, vessel, edges, sliceIndex, visualize3D, visualizeON, fileOutBase)

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
   
        % default definition
        region = zeros(size(img_n),'like', img_n);
        ind1 = floor(0.1*size(img_n,1)); ind2 = ceil(0.9*size(img_n,1));
        region(ind1:ind2, ind1:ind2, :) = 1;
        regionType = 'binary';
        
        % PT: added
        % region = edges;
        
        % use the vesselness as the speed field 
        absNormVessels = abs(vessel/max(vessel(:)));
        meanShiftedVessels = vessel - min(vessel(:));
            meanShiftedVessels = meanShiftedVessels / max(meanShiftedVessels(:));
        region = absNormVessels; regionType = 'continuous';

        
    % visualize initial region    
    fig = figure('Color', 'w');        
        
        scrsz = get(0,'ScreenSize'); % get screen size for plotting
        if visualizeON
            if ~visualize3D

                set(fig,  'Position', [0.01*scrsz(3) 0.05*scrsz(4) 0.95*scrsz(3) 0.90*scrsz(4)])
                rows = 4; cols = 4;
                i = 1;
                subplot(rows,cols,i); imshow(img_n(:,:,sliceIndex),[]);
                hold on; contour(region(:,:,sliceIndex),'r'); hold off;
                title('Initial region');
                drawnow

                ind = i;

            else       

                set(fig,  'Position', [0.05*scrsz(3) 0.025*scrsz(4) 0.7*scrsz(3) 0.95*scrsz(4)])
                rows = 4; cols = 6;

                % create a mesh from input
                debugPlot = false;
                isoValue = 0.1; % relative to max
                downSampleFactor = [2 1]; % [xy z] downsample to get less vertices/faces
                physicalScaling = [1 1 1]; % physical units of FOV
                [F,V] = reconstruct_marchingCubes_wrapper(img, 2.5*isoValue, downSampleFactor, physicalScaling, debugPlot);
                [F2,V2] = reconstruct_marchingCubes_wrapper(region, isoValue, downSampleFactor, physicalScaling, debugPlot);

                i = 1; width = 2;
                sp(i) = subplot(rows,cols,[i i+1 i+cols i+1+cols]);

                    ptchIn = patch('Faces',F,'Vertices', V, ...            
                                    'edgecolor', 'none', ...
                                    'facecolor', 'red', 'FaceAlpha', 0.3);
                    hold on

                    ptchIn2 = patch('Faces',F2,'Vertices', V2, ...            
                                    'edgecolor', 'none', ...
                                    'facecolor', 'blue', 'FaceAlpha', 0.3);

                    hold off

                    az = -20; el = 60;
                    view(az,el);
                    daspect([1,1,0.05]); axis tight
                    % xlabel('X'); ylabel('Y'); zlabel('Z')
                    tit(i) = title('Input Stack');
                    camlight 
                    lighting gouraud

                    imH(i) = 0; % no handle

                i = i+1; ind = i + (width-1);
                sp(i) = subplot(rows,cols,ind);

                    MaxIP_in = max(img_n, [], 3);     
                    maxIP_limits = [min(MaxIP_in(:)) max(MaxIP_in(:))];
                    imH(i) = imshow(MaxIP_in, 'DisplayRange', maxIP_limits); tit(i) = title('MaxIP Input');


                i = i+1; ind = ind + 1;
                sp(i) = subplot(rows,cols,ind);

                    MinIP_in = min(img_n, [], 3);                
                    minIP_limits = [min(MinIP_in(:)) max(MinIP_in(:))];
                    imH(i) = imshow(MinIP_in, 'DisplayRange', maxIP_limits); tit(i) = title('MinIP Input');

                i = i+1; ind = ind + 1;
                sp(i) = subplot(rows,cols,ind);

                    imH(i) = imshow(ones(size(MinIP_in)), 'DisplayRange', maxIP_limits); tit(i) = title('Cs');

                i = i+1; ind = ind + 1;
                sp(i) = subplot(rows,cols,ind);

                    imH(i) = imshow(ones(size(MinIP_in)), 'DisplayRange', maxIP_limits); tit(i) = title('Ct');


                % "Line Change"
                i = i+1; ind = width + ind + (width-1);
                sp(i) = subplot(rows,cols,ind);            

                    imH(i) = imshow(ones(size(MinIP_in)),[]); tit(i) = title('Intensity inside');
                    axis off

                i = i+1; ind = ind + 1;
                sp(i) = subplot(rows,cols,ind);            

                    imH(i) = imshow(ones(size(MinIP_in)),[]); tit(i) = title('Intensity outside');
                    axis off

                i = i+1; ind = ind + 1;
                sp(i) = subplot(rows,cols,ind);

                    imH(i) = imshow(ones(size(MinIP_in)), 'DisplayRange', maxIP_limits); tit(i) = title('Speed inside');

                i = i+1; ind = ind + 1;
                sp(i) = subplot(rows,cols,ind);

                    imH(i) = imshow(ones(size(MinIP_in)), 'DisplayRange', maxIP_limits); tit(i) = title('Speed outside');

                i = i+1; ind = ind + 1;
                sp(i) = subplot(rows,cols,[ind ind+1 ind+cols ind+1+cols]);

                    ptchIn3 = patch('Faces',F2,'Vertices', V2, ...            
                                    'edgecolor', 'none', ...
                                    'facecolor', 'blue', 'FaceAlpha', 0.3);
                    view(az,el);1
                    daspect([1,1,0.05]); axis tight
                    %xlabel('X'); ylabel('Y'); zlabel('Z')
                    tit(i) = title('Contour Init');
                    camlight 
                    lighting gouraud
                    xlim([1 size(img,1)]); ylim([1 size(img,2)]); zlim([1 size(img,3)]);
                    drawnow

                    imH(i) = 0; % no handle

            end
            iStatic = i;
            indStatic = ind;
        else
            iStatic = 1;
            indStatic = 1;1
        end

    % 4. Construct an s-t graph:
    [sx, sy, sz] = size(img_n);

    Cs = zeros(sx,sy,sz);
    Ct = zeros(sx,sy,sz);

    % allocate alpha(x), the regularization weight at each node x
    alpha = zeros(sx,sy,sz);

    % 5. Set up parameters and start level set iterations:
    maxLevelSetIterations = 4; % number of maximum time steps
    tau = 500; % speed parameter
    w1 = 0.8; % weight parameter for intensity data term
    w2 = 0.2; % weight parameter for the speed data term
    
    for t=1:maxLevelSetIterations

        i = iStatic;
        ind = indStatic;
        
        % 6. Compute a speed data term based on the current region
        if strcmp(regionType, 'continuous')
            
            %d_speed_inside = 1 - region;
            %d_speed_outside = region;
            d_speed_inside = 1 - region;                
                
            d_speed_outside = region;
                %d_speed_outside(d_speed_outside > 1) = 0;
                %d_speed_outside = d_speed_outside - min(d_speed_outside(:));
                
            % 7. Compute a intensity data term (PT: quick fix) 
            thresholdIntensity = 0.5; % graythresh(img_n(:));
            m_int_inside = mean(mean(mean(img_n(region > thresholdIntensity))));
            m_int_outside =  mean(mean(mean(img_n(region <= thresholdIntensity))));
            
        else % binary 
            d_speed_inside = bwdist(region == 1,'Euclidean');
            d_speed_outside = bwdist(region == 0,'Euclidean');
           1
            % 7. Compute a intensity data term based on the L1 distance to the
            % mean7
            m_int_inside = mean(mean(mean(img_n(region == 1))));
            m_int_outside =  mean(mean(mean(img_n(region == 0))));
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
        regWeight = 1;
        alpha = absNormVessels.^2 .* regWeight .* ones(sx,sy,sz);
        % alpha = regWeight .* ones(sx,sy,sz);

        % 6. Set up the parameters for the max flow optimizer:
        % [1] graph dimension 1
        % [2] graph dimension 2
        % [3] number of maximum iterations for the optimizer (default 200)
        % [4] an error bound at which we consider the solver converged (default
        %     1e-5)
        % [5] c parameter of the multiplier (default 0.2)
        % [6] step 7size for the gradient descent step when calulating the spatial
        %     flows p(x) (default 0.16)
        maxIter = 200;
        errorBound = 1e-5;
        cMultiplier = 0.2;
        stepSize = 0.16;
        pars = [sx; sy; sz; maxIter; errorBound; cMultiplier; stepSize];

        % 7. Call the binary max flow optimizer with Cs, Ct, alpha and pars to obtain
        % the continuous labelling function u, the convergence over iterations
        % (conv), the number of iterations (numIt) and the run time (time);
        [u, conv, numIt, time] = asetsBinaryMF3D(Cs, Ct, alpha, pars);

        % 8. Threshold the continuous labelling function u to obtain a discrete
        % segmentation result
        region = u > 0.5;

        
        % Visualize the costs (2D)
        if visualizeON
            tic
            if ~visualize3D
                i = i+1; subplot(rows,cols,i); loglog(conv, 'Color', [0 .7 1]); title(['convergence(',num2str(t),')']); axis square;
                    text(0.5*maxIter, 10*errorBound, ['no of iter = ', num2str(numIt)], 'HorizontalAlignment', 'right');
                    xlim([0 maxIter]); ylim([errorBound 0.001])
                    text(0.5*maxIter, 2*errorBound, ['time/iter = ', num2str(time,3), 's'], 'HorizontalAlignment', 'right');

                i = i+1; subplot(rows,cols,i); imshow(d_int_inside(:,:,sliceIndex), []); title(['Intensity IN']);
                i = i+1; subplot(rows,cols,i); imshow(d_int_outside(:,:,sliceIndex), []); title(['Intensity OUT']);
                i = i+1; subplot(rows,cols,i); imshow(d_speed_inside(:,:,sliceIndex), []); title(['Speed IN']);
                i = i+1; subplot(rows,cols,i); imshow(d_speed_outside(:,:,sliceIndex), []); title(['Speed OUT']);
                i = i+1; subplot(rows,cols,i); imshow(Ct(:,:,sliceIndex), []); title(['Ct']);
                i = i+1; subplot(rows,cols,i); imshow(Cs(:,:,sliceIndex), []); title(['Cs']);
                % i = i+1; subplot(rows,cols,i); imshow(u, []); title(['u, \tau = ']);            

                i = i+1; subplot(rows,cols,[i i+1 i+cols i+cols+1]); imshow(Cs(:,:,sliceIndex)-Ct(:,:,sliceIndex),[]); title(['Cs-Ct (w1=', num2str(w1), ', w2=', num2str(w2), ')']);
                i = i+2; subplot(rows,cols,[i i+1 i+cols i+cols+1]); imshow(img(:,:,sliceIndex),[]); title(['r(',num2str(t),'), \alpha = ', num2str(regWeight), ', \tau =', num2str(tau)]); hold on; contour(region,'r'); hold off;

                drawnow();

            else
                
                % update 3D Contour
                [F3,V3] = reconstruct_marchingCubes_wrapper(region, isoValue, downSampleFactor, physicalScaling, debugPlot);
                % set(ptchIn3,'Faces', [], 'Vertices', []) % not sure if really needed, test later
                set(ptchIn3,'Faces', F3, 'Vertices', V3)

                titStr = sprintf('%s\n%s', ['\tau=', num2str(tau), ', ', ...
                                 'w1=', num2str(w1), ', ', ...
                                 'w2=', num2str(w2), ', ', ...
                                 '\alpha=', num2str(regWeight)], ...
                                 ['c= ', num2str(cMultiplier), ', ', ...
                                  'stepSize= ', num2str(stepSize), ', ', ...
                                  'iter= ', num2str(t)]);

                set(tit(i), 'String', titStr)

                % Update Cs
                
                    MIP_Cs = max(Cs, [], 3);                    
                    axes(sp(i-6))                   
                        
                        imshow(MIP_Cs, 'DisplayRange', [0 1])
                        % set(imH(i-2), 'CData', MIP_int)
                        tit(i-6) = title('Cs');
                
                % Update Ct
                    MIP_Ct = max(Ct, [], 3); 

                    axes(sp(i-5))
                        imshow(MIP_Ct, 'DisplayRange', [0 1])
                        % set(imH(i-2), 'CData', MIP_int)
                        tit(i-5) = title('Ct');
                
                % Update Intensity Inside
                    MIP_intIn = max(d_int_inside, [], 3);
                    %[min(MIP_intIn(:)) max(MIP_intIn(:))];
    
                    axes(sp(i-4))
                        imshow(MIP_intIn, 'DisplayRange', [0 1])
                        % set(imH(i-2), 'CData', MIP_int)
                        tit(i-4) = title('Intensity inside');

                % Update Intensity Outside
                    MIP_intOut = max(d_int_outside, [], 3);

                    axes(sp(i-3))
                        imshow(MIP_intOut, 'DisplayRange', [0 1])
                        % set(imH(i-2), 'CData', MIP_int)
                        tit(i-3) = title('Intensity outside');
                      
                % Update Speed d_speed_inside(d_speed_inside < 0) = 0;Inside
                    MIP_speedIn = max(d_speed_inside, [], 3);
                    [min(MIP_speedIn(:)) max(MIP_speedIn(:)) min(MIP_intOut(:)) max(MIP_intOut(:))]

                    axes(sp(i-2))
                        imshow(MIP_speedIn, []) % 'DisplayRange', [-1 1]/tau)                
                        % set(imH(i-1), 'CData', MIP_speed)
                        tit(i-2) = title('Speed inside');
                        
                % Update Speed Outside
                    MIP_speedOut = max(d_speed_outside, [], 3);
                    %[min(MIP_speedOut(:)) max(MIP_speedOut(:))];      

                    axes(sp(i-1))
                        imshow(MIP_speedOut, []) % 'DisplayRange', [0 1])                
                        % set(imH(i-1), 'CData', MIP_speed)
                        tit(i-1) = title('Speed outside');

                % Convergence
                i = i+1; ind = ind + 1 + (width-1);
                sp(i) = subplot(rows,cols,ind); 
                % note! loglogd_speed_inside(d_speed_inside < 0) = 0;() destroys alpha from patches
                iterVec = (1:1:length(conv))';
                plot(log10(iterVec), log10(conv), 'Color', [0 .7 1]); title(['convergence(',num2str(t),')']); axis square;                    
                    text(0.5*maxIter, 10*errorBound, ['no of iter = ', num2str(numIt)], 'HorizontalAlignment', 'right');
                    xlim([0 log10(maxIter)]); ylim(log10([errorBound 0.1]))
                    text(0.5*maxIter, 2*errorBound, ['time/iter = ', num2str(time,3), 's'], 'HorizontalAlignment', 'right');

                    
                    
                    
                % Cs-Ct
                i = i+1; ind = ind + 1;
                sp(i) = subplot(rows,cols,ind);
             
                    [F4,V4] = reconstruct_marchingCubes_wrapper((Cs-Ct), isoValue, downSampleFactor, physicalScaling, debugPlot);
                    ptchIn4 = patch('Faces',F4,'Vertices', V4, ...            
                                    'edgecolor', 'none', ...
                                    'facecolor', 'k', 'FaceAlpha', 0.3);
                    view(az,el);
                    daspect([1,1,0.05]); axis tight
                    %xlabel('X'); ylabel('Y'); zlabel('Z')
                    tit(i) = title('Cs-Ct');
                    camlight 
                    lighting gouraud
                    xlim([1 size(img,1)]); ylim([1 size(img,2)]); zlim([1 size(img,3)]);                     
                    
                % Cs-Ct (MIP)
                i = i+1; ind = ind + 1;
                sp(i) = subplot(rows,cols,ind);

                    
                    % view(az,el);
                    imH(i) = imshow(MIP_Cs - MIP_Ct, 'DisplayRange', [0 1]); tit(i) = title('MIP (Cs-Ct)');                

                i = i+1; ind = ind + 1;
                sp(i) = subplot(rows,cols,ind);

                    alphaMIP = max(alpha, [], 3);
                    imH(i) = imshow(alphaMIP, 'DisplayRange', [0 max(alpha(:))]); tit(i) = title('Alpha');  


                % "LINE CHANGE"
                i = i+1; ind = width + ind + (width-1);
                subplot(rows,cols,ind);

                    img_outFgMax = img_n;
                    img_outFgMax(~region) = 0;
                    MaxIP_fg_out = max(img_outFgMax, [], 3);
                    imH(i) = imshow(MaxIP_fg_out, 'DisplayRange', maxIP_limits); tit(i) = title('MaxIP fg out');

                i = i+1; ind = ind + 1;
                subplot(rows,cols,ind);

                    img_outBgMax = img_n;
                    img_outBgMax(region) = 0;
                    MaxIP_bg_out = max(img_outBgMax, [], 3);
                    imH(i) = imshow(MaxIP_bg_out, 'DisplayRange', maxIP_limits); tit(i) = title('MaxIP bg out');

                i = i+1; ind = ind + 1;
                sp(i) = subplot(rows,cols,ind);

                    imH(i) = imshow(ones(size(MinIP_in))); tit(i) = title(' ');                

                i = i+1; ind = ind + 1;
                sp(i) = subplot(rows,cols,ind);

                    imH(i) = imshow(ones(size(MinIP_in))); tit(i) = title(' ');    

                drawnow();            
                

            end

            if t < 10
                index = ['0', num2str(t)];
            else
                index = num2str(t);
            end

            timePlotUpdate2 = toc;
            disp(['  plot update took: ', num2str(timePlotUpdate2,3), ' seconds'])
            export_fig([fileOutBase, '_', num2str(index), '.png'], '-r100', '-a2')
        
        end % end visualizeON
        
    end