function vesselness_demoOofOfa_2D()

    %% INPUT
    
        close all
        load(fullfile('..', 'debugMATs', 'importTemp.mat'))
        slice = 2;

        testImage_2D = double(imageStack{1}{1}(:,:,slice));
        testStack_3D = double(imageStack{1}{1}(:,:,slice-1:slice+1));

    %% COMPUTATIONS
        
        range = {1:2; 1:3; 1:5; 1:10; 1:20};
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
        end
    
    %% PLOT

        disp('Plotting the results')
        fig = figure('Color','w');

            scrsz = get(0,'ScreenSize'); % get screen size for plotting 
            set(fig,  'Position', [0.03*scrsz(3) 0.045*scrsz(4) 0.85*scrsz(3) 0.90*scrsz(4)])

            rows = 3;
            cols = length(range) + 1;

        % INPUT
        subplot(rows,cols,1)
            imshow(testImage_2D, [])
            title('Input')

            % OOF
            for i = 1 : length(range)
                subplot(rows,cols,1+i)
                    imshow(oof{i}(:,:,2),[])
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

            % DIFFERENCE
            for i = 1 : length(range)
                subplot(rows,cols,(cols*2)+1+i)
                    imshow(abs(oof{i}(:,:,2) - oof_ofa{i}),[])
                    title(['diff(OOF-OOF&OFA)'])
                drawnow
            end
            
        % write to disk the comparison
        export_fig(fullfile('..', 'figuresOut', 'OOF_OOF-OFA_comparisonDemo.png'), '-r300', '-a1')