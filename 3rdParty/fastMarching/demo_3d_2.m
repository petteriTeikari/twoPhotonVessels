function demo_3d_2()

    %% Read Blood vessel image
    
        load('images/vessels3d');
        % Note, this data is pre-processed from Dicom ConeBeam-CT with
        % V = imfill(Vraw > 30000,'holes');
        whos

    %% Use fastmarching to find the skeleton
        
        S=skeleton(V);


    %% Show the iso-surface of the vessels
    
        figure,
        FV = isosurface(V,0.5)
        patch(FV,'facecolor',[1 0 0],'facealpha',0.3,'edgecolor','none');
        view(3)
        camlight

        % Display the skeleton
        hold on;
        for i=1:length(S)
            L=S{i};
            plot3(L(:,2),L(:,1),L(:,3),'-','Color',rand(1,3), 'LineWidth', 2);
        end