function visualize_vesselSegmentationSlices(imageStack, tubularity, segmentation, titleString, saveOn, options)

    if nargin == 0
        load testVisualize3DsegmentationSlices.mat
        close all
        whos
    else
        save testVisualize3DsegmentationSlices.mat
    end
    
    % Init figure
    fig = figure('Name', titleString);
        scrsz = get(0,'ScreenSize'); % get screen size for plotting
        set(fig,  'Position', [0.39*scrsz(3) 0.25*scrsz(4) 0.60*scrsz(3) 0.60*scrsz(4)])
        rows = 2;
        cols = 2;
        drawnow
    
        slice = 1:4; % size(imageStack,3); % slices 7-11 from debug file
        
            for i = 1 : length(slice)
                
                % subplot
                sp(i) = subplot(rows,cols,i); 
                
                % image
                imshow(imageStack(:,:,slice(i)),[]); hold on; 
                
                % contours
                c = contours(segmentation(:,:,i),[0,0]);
                
                try
                    zy_plot_contours(c,'linewidth',1);
                catch err
                    err
                    error('Download the toolbox and add to path: http://www.mathworks.com/matlabcentral/fileexchange/24998-2d-3d-image-segmentation-toolbox')
                end
                
                % styling
                title(['Slice: ', num2str(slice(i))])
                drawnow
                
            end