function vesselness_demoOofOfa_2D_v2()

    %% INPUT
    
      
        % load(fullfile('..', 'debugMATs', 'importTemp.mat'))
        load(fullfile('segmentationDemo', 'testData', 'slices10_16_timepoint3_denoised_NLMeansPoisson.mat')); imageStack{1}{1} = im(:,:,1:3);
        slice = 2;

        testImage_2D = double(imageStack{1}{1}(:,:,slice));
        testStack_3D = double(imageStack{1}{1}(:,:,slice-1:slice+1));
        whos
        

    %% COMPUTATIONS
        
        range = {1:2; 1:3; 1:5};
        % range = {1:3};
        opts.responsetype=0; % l1; (default, for OOF)

        disp('Computing OOF and OOF-OFA')
        for i = 1 : length(range)

            disp(['   ', num2str(i), ' / ', num2str(length(range))])
            
            tic
            oof_ofa{i} = oofofa2(testImage_2D, range{i});
            tim_oofOfa(i) = toc;

            tic
            % Requires 3D input so we have stack as an argument, and then
            % we display the same slice as for OOF-OFA 2D
            oof{i} = oof3response(testStack_3D, range{i}(1):range{i}(end), opts);  
            tim_oof3(i) = toc;
            
            tic
            % Requires 3D input so we have stack as an argument, and then
            % we display the same slice as for OOF-OFA 2D
            Options.FrangiScaleRange = range{i};
            Options.FrangiScaleRatio = 1; % step size
            Options.FrangiC = 250; % default 500;
            Options.BlackWhite = 'false'; % white ridges with "false"
            [frangi{i}, Scale{i}, Vx{i}, Vy{i}, Vz{i}] = FrangiFilter3D(testStack_3D, Options);  
            tim_frangi(i) = toc;
                % TODO: check the scale definitions of Frangi, all values
                %       seem the same
            
            tic
            % Requires 3D input so we have stack as an argument, and then
            % we display the same slice as for OOF-OFA 2D
            scaleStep = Options.FrangiScaleRatio;
            mdof{i} = vesselness_MDOF_ImageJ_wrapper(testStack_3D, range{i}, scaleStep);  
            tim_mdof(i) = toc;
                % TODO: check the scale definitions of MDOF, all values
                %       seem the same
            
        end
    
    %% PLOT
    
        close all
        
        % enhance MDOF & FRANGI
        for i = 1 : length(range)
            MDOFenh{i} = mdof{i}(:,:,slice); FRANGIenh{i} = frangi{i}(:,:,slice); % init
            MDOFenh{i} = enhance_clipAboveLevel(MDOFenh{i});            
                % MDOFenh{i} = enhance_clipAboveLevel(MDOFenh{i}); % repeat once
            FRANGIenh{i} = enhance_clipAboveLevel(FRANGIenh{i});
                % FRANGIenh{i} = enhance_clipAboveLevel(FRANGIenh{i}); % repeat once
        end
        
        disp('Plotting the results')
        fig = figure('Color','w');

            scrsz = get(0,'ScreenSize'); % get screen size for plotting 
            set(fig,  'Position', [0.03*scrsz(3) 0.045*scrsz(4) 0.85*scrsz(3) 0.90*scrsz(4)])

            rows = 4;
            cols = length(range) + 1;

        % INPUT
        subplot(rows,cols,1)
            imshow(testImage_2D, [])
            title('Input')

            % OOF
            for i = 1 : length(range)
                subplot(rows,cols,1+i)
                    imshow(oof{i}(:,:,slice),[])
                    title(['OOF, r = ', num2str(range{i}(1)), '-', num2str(range{i}(end)),...
                            ', t = ', num2str(tim_oof3(i),2), 's'])
                    drawnow
            end

            % OOF-OFA
            for i = 1 : length(range)
                subplot(rows,cols,cols+1+i)
                    imshow(oof_ofa{i},[])
                    title(['OOF&OFA, r = ', num2str(range{i}(1)), '-', num2str(range{i}(end)),...
                            ', t = ', num2str(tim_oofOfa(i),2), 's'])
                    drawnow
            end

            % MDOF
            for i = 1 : length(range)
                subplot(rows,cols,2*cols+1+i)
                    imshow(MDOFenh{i},[])
                    title(['MDOF, r = ', num2str(range{i}(1)), '-', num2str(range{i}(end)),...
                            ', t = ', num2str(tim_mdof(i),2), 's'])
                    drawnow
            end
            
            % FRANGI
            for i = 1 : length(range)
                subplot(rows,cols,3*cols+1+i)
                    imshow(FRANGIenh{i},[])
                    title(['FRANGI, r = ', num2str(range{i}(1)), '-', num2str(range{i}(end)),...
                            ', t = ', num2str(tim_frangi(i),2), 's'])
                    drawnow
            end
            
        % write to disk the comparison
        export_fig(fullfile('..', 'figuresOut', 'vesselness2D_comparisonDemo.png'), '-r300', '-a1')