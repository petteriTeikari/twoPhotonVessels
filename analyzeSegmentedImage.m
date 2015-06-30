function analysis = analyzeSegmentedImage(regReconstruction, segmentation, denoisedImageStack, options)

    disp('Analysis of the segmented and reconstructed image (dummy)')

    if nargin == 0        
        
        load('./debugMATs/testAnalysis.mat')
        %{
        slicesDebug = [7 10 13 16 19];
        denoisedImageStack = denoisedImageStack(:,:,slicesDebug);
        segmentation = segmentation(:,:,slicesDebug);
        save('./debugMATs/testAnalysis_reduced.mat')
        %}
        % load('./debugMATs/testAnalysis_reduced.mat')
        
    else
        save('./debugMATs/testAnalysis.mat')
    end
    
    %% Permeability coefficient
    
        analysis.P = analyze_permeabilityCoefficient(segmentation, denoisedImageStack, options);

    %% Computational 3D Morphology
        
        visualizeOn = true;
        out = analyze_3D_Morphology(regReconstruction, options, visualizeOn);
    
   
    
   