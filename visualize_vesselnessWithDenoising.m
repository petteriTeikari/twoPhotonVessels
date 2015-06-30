function visualize_vesselnessWithDenoising(imageStack, tubularity, denoisedImageStack, denoisingAlgorithm, vesselAlgorithm, options)
        
    if nargin == 0
        disp('Running LOCALLY')
        path = '/home/petteri/Desktop/testPM/';
        load(fullfile(path, 'testVesselnessVisualization.mat'))
        close all
    else
        stackReduced = double(imageStack(:, :, 1:end)); % you can reduce if you want

        % run vesselness filter for the input as well
        disp('Run VESSELNESS again for non-denoised stack')
        options.vesselAlgorithm = 'OOF';
        tubularityRaw.(options.vesselAlgorithm) = vesselnessFilter(stackReduced, options);
        path = '/home/petteri/Desktop/testPM/';
        try
            save(fullfile(path, 'testVesselnessVisualization.mat'))
        catch err
            if strcmp(err.identifier, 'MATLAB:save:permissionDenied')
               warning(['Problem with the write permission (no .mat file written) of: ', path]) 
            else                
                err
            end
        end
    end

    % number of different vesselness measures computed
    tubeFieldNames = fieldnames(tubularity); % OOF, etc.
    noOfVesselness = length(tubeFieldNames);
    if noOfVesselness > 2
        warning(['Plot may look a bit tight with so many vesselness measures (=', num2str(noOfVesselness), ') computed'])
    end
   
    
    %% Figure 1
    
        fig = figure('Color','w');
        scrsz = get(0,'ScreenSize'); % get screen size for plotting    
            rows = 2; cols = 1 + (2*noOfVesselness);
            widthMultiplier = cols * 0.16;
            if widthMultiplier > 0.95; widthMultiplier = 0.95; end
            set(fig,  'Position', [0.03*scrsz(3) 0.145*scrsz(4) widthMultiplier*scrsz(3) 0.70*scrsz(4)])

            stackInd = 9;

            % Input
            i = 1;
            subplot(rows,cols,i)
                imshow(uint16(max(stackReduced,[],3)), 'DisplayRange', [0 4095]); 
                title('In (MIP)')

                % VESSELNESS
                for indNames = 1 : noOfVesselness            
                    i = fig1_loop(i, rows, cols, tubularityRaw.(tubeFieldNames{indNames}), stackInd);
                end

            % Denoised
            i = i + 1;
            subplot(rows,cols,i)
                imshow(uint16(max(denoisedImageStack,[],3)), 'DisplayRange', [0 4095]); 
                title('Denoised (MIP)')

                % VESSELNESS
                for indNames = 1 : noOfVesselness            
                    i = fig1_loop(i, rows, cols, tubularity.(tubeFieldNames{indNames}), stackInd);
                end

            nameOut = [denoisingAlgorithm, '_Denoising_w', 'Vesselness', ...
                       '_scales', num2str(options.scales(1)), '-', num2str(options.scales(2)), ...
                       '.png'];

            % external file
            export_fig(fullfile('figuresOut', nameOut), '-r300', '-a1')
        
        %% FIGURE 2: MIP DIFFERENCES
        
            fig2 = figure('Color','w');
            set(fig2,  'Position', [0.45*scrsz(3) 0.045*scrsz(4) 0.50*scrsz(3) 0.90*scrsz(4)])
                rows = 3; cols = 2;

                for indNames = 1 : noOfVesselness      
                
                    % The data
                    mip_raw = max(stackReduced,[],3);
                    mip_denoised = max(denoisedImageStack,[],3);

                    mip_OOF_raw = max(tubularityRaw.(tubeFieldNames{indNames}).data,[],3);
                    mip_OOF_denoised = max(tubularity.(tubeFieldNames{indNames}).data,[],3);

                    try
                        mipDiff = (mip_raw - mip_denoised);
                    catch err
                        whos
                        err
                        % error once with the other being double, and the other
                        % uint16, harmonize later maybe or not. double()-conversion
                        % done above
                    end

                    mip_OOF_Diff = (mip_OOF_raw - mip_OOF_denoised);

                    % Display
                    i = 0;

                    i = i + 1;
                    subplot(rows,cols,i)          
                        imshow(mip_raw, []); title('Image In')

                    i = i + 1;
                    subplot(rows,cols,i)
                        imshow(mip_OOF_raw, []); title([tubularity.(tubeFieldNames{indNames}).method, ' for In'])

                    i = i + 1;
                    subplot(rows,cols,i)          
                        imshow(mip_denoised, []); title('Image Denoised')

                    i = i + 1;
                    subplot(rows,cols,i)
                        imshow(mip_OOF_denoised, []); title([tubularity.(tubeFieldNames{indNames}).method, ' for Denoised'])

                    i = i + 1;
                    subplot(rows,cols,i)          
                        imshow(mipDiff, []); 
                        titStr = sprintf('%s\n%s', 'Image, abs(in-denoised)', ...
                                    ['Range: [', num2str(min(mipDiff(:))) ':', num2str(max(mipDiff(:))), ']']);
                        title(titStr)

                    i = i + 1;
                    subplot(rows,cols,i)
                        imshow(mip_OOF_Diff, []);
                        titStr = sprintf('%s\n%s', [tubularity.(tubeFieldNames{indNames}).method, ' abs(in-denoised)'], ...
                                    ['Range: [', num2str(min(mip_OOF_Diff(:))) ':', num2str(max(mip_OOF_Diff(:))), ']']);
                        title(titStr)

                    nameOut2 = strrep(nameOut, 'Vesselness', tubularity.(tubeFieldNames{indNames}).method);

                    % external file
                    export_fig(fullfile('figuresOut', nameOut2), '-r300', '-a1')
                
                end
            
            
     
    
     function i = fig1_loop(i, rows, cols, vesselness, stackInd)
        
        % MIP
        i = i + 1;
        subplot(rows,cols,i)
        imshow(uint16(max(vesselness.data,[],3)), []); 

        scaleStep = vesselness.scaleStep;
        scales = vesselness.scales;

        titStr = sprintf('%s\n%s', [vesselness.method, ' (MIP)'], ...
            ['Scales = ', num2str(scales(1)), '-', num2str(scales(2))]);
        title(titStr)

        % SLICE
        i = i + 1;
        subplot(rows,cols,i)
        try
            imshow(uint16(vesselness.data(:,:,stackInd)), []);
        catch err
            stackInd = 1;
            imshow(uint16(vesselness.data(:,:,stackInd)), []);
        end
        title(['OOF (Slice = ', num2str(stackInd), ')'])