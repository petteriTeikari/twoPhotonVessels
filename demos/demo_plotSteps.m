function demo_plotSteps()

    path = '/home/petteri/Desktop/testPM/out/CP-20150323-TR70-mouse2-1-son';
    load(fullfile(path, 'matrices_timepoint1.mat'))
    
    % normalize inputs
    im = double(im) / max(double(im(:)));
    vessel = vessel / max(vessel(:));
    denoised = denoised / max(denoised(:));
    whos
    
    %% Maximum Intensity Projections
    fig = figure('Color', 'w');
    
        % layout
        rows = 1; cols = 4;

        i = 1;
        sp(i) = subplot(rows,cols,i);
            MIP_im = max(im, [], 3);
            p(i) = imshow(MIP_im, []);
            t(i) = title('Input');


        i = i+1;
        sp(i) = subplot(rows,cols,i);
            MIP_denoised = max(denoised, [], 3);
            p(i) = imshow(MIP_denoised, []); 
            t(i) = title('Denoised');


        i = i+1;
        sp(i) = subplot(rows,cols,i);
            MIP_vessel = max(vessel, [], 3);
            p(i) = imshow(MIP_vessel, []);
            t(i) = title('Vesselness');


        i = i+1;
        sp(i) = subplot(rows,cols,i);
            MIP_mask = max(mask, [], 3);
            p(i) = imshow(MIP_mask, []);
            t(i) = title('Segmentation');

        % Style
        set(t, 'FontSize', 10, 'FontWeight', 'bold')
        
        % Save to disk
        export_fig(fullfile('.', 'MIPs.png'), '-r300', '-a2')
        

    %% PER SLICE
    fig2 = figure('Color', 'w');
            
        for i = 1 : size(im,3)
           p2(i) = imshow(im(:,:,i), []); tit2(i) = title(['Slice = ', num2str(i)]);
           drawnow
           export_fig(fullfile('.', ['slice_', num2str(i), '.png']), '-r150', '-a2')
           pause(0.25)
        end
        
    %% ISOSURFACES
    fig3 = figure('Color', 'w');
    
        % Using Marching Cubes algorithm from Matlab FEX
        % http://www.mathworks.com/matlabcentral/fileexchange/32506-marching-cubes

        isoValue = 0.1;
        downSampleFactor = [1 1]; % [xy z] downsample to get less vertices/faces
        physicalScaling = [1 1 5]; % physical units of FOV
                                   % TODO, make automagic from metadata
        debugPlot = true;
        [F,V] = reconstruct_marchingCubes_wrapper(double(im), isoValue, downSampleFactor, physicalScaling, debugPlot);
        %[F2,V2] = reconstruct_marchingCubes_wrapper(vessel, isoValue, downSampleFactor, physicalScaling, debugPlot);
        %[F3,V3] = reconstruct_marchingCubes_wrapper(denoised, isoValue, downSampleFactor, physicalScaling, debugPlot);
        %[F4,V4] = reconstruct_marchingCubes_wrapper(mask, isoValue, downSampleFactor, physicalScaling, debugPlot);

        % output the faces and vertices
        reconstruction.faces = F;
        reconstruction.vertices = V;
        
        % Write to OFF (or PLY, SMF, WRL, OBJ) using the Toolbox Graph by 
        % http://www.mathworks.com/matlabcentral/fileexchange/5355-toolbox-graph
        reconstructFileNameOut = 'meshOut';
        try
            reconstruction.meshOnDisk = fullfile('.', [reconstructFileNameOut, '.off']);
            write_mesh(reconstruction.meshOnDisk, V, F)
        catch err
            err
            warning('?')
        end
    
    %% VISUALIZE NOISE REMOVAL
    
        % layout
        rows = 2;
        cols = 3;
        fig4 = figure('Color','w');
            scrsz = get(0,'ScreenSize');    
            set(fig4,  'Position', [0.25*scrsz(3) 0.3*scrsz(4) 0.6*scrsz(3) 0.5*scrsz(4)])
        
        for i = 1 : size(im,3)
            
            % SLICES
            j = 1;
            sp3(j) = subplot(rows,cols,j);
                p3(j) = imshow(im(:,:,i),[]); tit3(j) = title(['Input, slice = ', num2str(i)]);
            
            j = j +1;
            sp3(j) = subplot(rows,cols,j);
                p3(j) = imshow(denoised(:,:,i),[]); tit3(j) = title(['Denoised, slice = ', num2str(i)]);
                
            j = j +1;
            sp3(j) = subplot(rows,cols,j);
                p3(j) = imshow(abs(im(:,:,i)-denoised(:,:,i)),[]); tit3(j) = title(['Noise, slice = ', num2str(i)]);
                
            % MIP
                
                % compute MIPs
                mip_im = max(im(:,:,1:i), [], 3);
                mip_denoised = max(denoised(:,:,1:i), [], 3);
                mip_diff = abs(mip_im - mip_denoised);
           
                j = j + 1;
                sp3(j) = subplot(rows,cols,j);
                    p3(j) = imshow(mip_im,[]); tit3(j) = title('Input, MIP');

                j = j +1;
                sp3(j) = subplot(rows,cols,j);
                    p3(j) = imshow(mip_denoised,[]); tit3(j) = title('Denoised, MIP');

                j = j +1;
                sp3(j) = subplot(rows,cols,j);
                    p3(j) = imshow(mip_diff,[]); tit3(j) = title('Noise, MIP');

            set(tit3, 'FontSize', 10, 'FontWeight', 'bold')
 
            drawnow               
            export_fig(fullfile('.', ['denoisingAnim_', num2str(i), '.png']), '-r150', '-a2')
            pause(0.2)
                
        end
        
    %% VISUALIZE VESSEL ENHANCEMENT
    
        % layout
        rows = 1;
        cols = 3;
        fig5 = figure('Color','w');
            scrsz = get(0,'ScreenSize');    
            set(fig5,  'Position', [0.15*scrsz(3) 0.2*scrsz(4) 0.6*scrsz(3) 0.5*scrsz(4)])
        
        transitionSteps = 20;
        
        for i = 1 : size(im,3)            
            for j = 1 : transitionSteps
                
                vFraction = j / transitionSteps;
                
                k = 1;
                if j == 1
                    sp5(k) = subplot(rows,cols,k);
                        p5(k) = imshow(im(:,:,i), []); title(['Input, slice = ', num2str(i)])
                end
                
                k = k + 1;
                sp5(k) = subplot(rows,cols,k);                    
                    vesselness = (1-vFraction)*im(:,:,i) + vFraction*abs(vessel(:,:,i));
                    p5(k) = imshow(vesselness, []); title(['Vesselness, slice = ', num2str(i)])               
                
                
                if i > 1
                    MIPprev = max(abs(vessel(:,:,1:i-1)), [], 3);
                else
                    MIPprev = zeros(size(vessel,1), size(vessel,2));
                end
                k = k + 1;
                sp5(k) = subplot(rows,cols,k);
                    MIPthis = max(abs(vessel(:,:,1:i)), [], 3);
                    vesselness_MIP = (1-vFraction)*MIPprev + vFraction*MIPthis;
                    p5(k) = imshow(vesselness_MIP); title(['Vesselness, MIP slices = [', num2str(1), ':', num2str(i), ']'])          
                    
                    
                drawnow
                % pause(0.05)
                
                export_fig(fullfile('.', ['vesselnessAnim_', num2str(i), '_', num2str(j), '.png']), '-r150', '-a2')

                
            end            
        end
