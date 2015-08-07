function centerline = extractCenterline(reconstruction, binaryStack, centerlineAlgorithm, options, t, ch)

    % Direct import from .mat file if needed
    if nargin == 0
        
        close all
        [~, name] = system('hostname');
        name = strtrim(name); % remove white space
        if strcmp(name, 'C7Pajek') % Petteri   
            path = fullfile('/home', 'petteri', 'Desktop', 'testPM', 'out');
            load(fullfile(path, 'reconstructionOut_4slices_binarySegmentationMask.mat'))
        elseif strcmp(name, '??????') % Sharan
            path = fullfile('/home', 'petteri', 'Desktop', 'testPM');
            load(fullfile(path, 'reconstructionOut_4slices_binarySegmentationMask.mat'))        
            %load(fullfile(path, 'testReconstruction_halfRes_4slicesOnly.mat'))        
        end
    else
        % nothing if you use input arguments
    end
    
    % TODO: centerline from mesh (reconstruction variable) at some point?
    
    %% INPUT CHECKING
    
        options.centerlineFileNameOut = ['centerline_', options.segmentationAlgorithm '_ch', num2str(ch), '_t', num2str(t)];
                
    
    %% CENTERLINE EXTRACTION ALGORITHMS
    
        if strcmp(centerlineAlgorithm, 'fastMarchingKroon')

            % Multistencils second order Fast Marching
            % by Dirk-Jan Kroon
            % http://www.mathworks.com/matlabcentral/fileexchange/24531-accurate-fast-marching
            verbose = true;
            centerline = skeleton(binaryStack, verbose);
            
                % PT: Freezes and does not work that well with "too
                % bloated" binaries at least. Use rather the Skeleton3D

        elseif strcmp(centerlineAlgorithm, 'parallelMedialAxisThinning')
            
            % Skeleton3D
            % by Philip Kollmannsberger
 
            % Calculates the 3D skeleton of an arbitrary binary volume using parallel medial axis thinning.
            centerline = Skeleton3D(binaryStack);
            
        else

            algWanted = centerlineAlgorithm
            error('What centerline algorithm did you want?')

        end
        
    %% VISUALIZE
    
        visualizeON = true;
        if visualizeON
           
            figure,
            FV = isosurface(binaryStack, 0.5);
            patch(FV,'facecolor',[1 0 0],'facealpha',0.3,'edgecolor','none');
            view(3)
            camlight

            if strcmp(centerlineAlgorithm, 'fastMarchingKroon')
            
                % Display the skeleton
                hold on;
                for i=1:length(centerline)
                    L=centerline{i};
                    plot3(L(:,2),L(:,1),L(:,3),'-','Color',rand(1,3));
                end
            
            elseif strcmp(centerlineAlgorithm, 'parallelMedialAxisThinning')
            
                hold on;
                w=size(centerline,1);
                l=size(centerline,2);
                h=size(centerline,3);
                [x,y,z] = ind2sub([w,l,h],find(centerline(:)));
                plot3(y,x,z,'square','Markersize',4,'MarkerFaceColor','r','Color','r');            
                set(gcf,'Color','white');
                
            end
            
            export_fig(fullfile('figuresOut', [options.centerlineFileNameOut, '.png']), '-r300', '-a2')
        end