function centerline = extractCenterline(reconstruction, segmentation, options)

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
    whos
    centerline = [];
    options.centerlineAlgorithm = 'parallelMedialAxisThinning';
    
    %% CENTERLINE EXTRACTION ALGORITHMS
    
        if strcmp(options.centerlineAlgorithm, 'fastMarchingKroon')

            % Multistencils second order Fast Marching
            % by Dirk-Jan Kroon
            % http://www.mathworks.com/matlabcentral/fileexchange/24531-accurate-fast-marching
            verbose = true;
            S = skeleton(segmentation, verbose);
            
                % PT: Freezes and does not work that well with "too
                % bloated" binaries at least. Use rather the Skeleton3D

        elseif strcmp(options.centerlineAlgorithm, 'parallelMedialAxisThinning')
            
            % Skeleton3D
            % by Philip Kollmannsberger
 
            % Calculates the 3D skeleton of an arbitrary binary volume using parallel medial axis thinning.
            S_3D = Skeleton3D(segmentation)
            
        else

            algWanted = options.centerlineAlgorithm
            error('What centerline algorithm did you want?')

        end
        
    %% VISUALIZE
    
        visualizeON = true;
        if visualizeON
           
            figure,
            FV = isosurface(segmentation, 0.5);
            patch(FV,'facecolor',[1 0 0],'facealpha',0.3,'edgecolor','none');
            view(3)
            camlight

            if strcmp(options.centerlineAlgorithm, 'fastMarchingKroon')
            
                % Display the skeleton
                hold on;
                for i=1:length(S)
                    L=S{i};
                    plot3(L(:,2),L(:,1),L(:,3),'-','Color',rand(1,3));
                end
            
            elseif strcmp(options.centerlineAlgorithm, 'parallelMedialAxisThinning')
            
                hold on;
                w=size(S_3D,1);
                l=size(S_3D,2);
                h=size(S_3D,3);
                [x,y,z]=ind2sub([w,l,h],find(S_3D(:)));
                plot3(y,x,z,'square','Markersize',4,'MarkerFaceColor','r','Color','r');            
                set(gcf,'Color','white');
                
            end
        end