function analysis = analyzeSegmentedImage(regReconstruction, segmentation, denoisedImageStack, options)

    if nargin == 0        
        
        % forget about the input arguments now, and we can work locally
        
        % The Faces are vertices
        
            load(fullfile('.', 'debugMATs', 'reconstructionOut_fullResolution.mat'))
            stlFile = fullfile('.', 'figuresOut', 'testReconstruction_fullResolution.stl');
                % F            1728980x3             41495520  double              
                % V            1184768x3             28434432  double

            %load(fullfile('.', 'debugMATs', 'reconstructionOut_halfRes_4slicesOnly.mat'))
            %stlFile = fullfile('.', 'figuresOut', 'testReconstruction_4slicesOnly.stl');
                % F            43468x3             1043232  double              
                % V            34093x3              818232  double 
        
        % ImageStack if you need 
        
            load(fullfile('/home', 'petteri', 'Desktop', 'testPM', 'testReconstruction_fullResolution.mat'))        
            %load(fullfile('/home', 'petteri', 'Desktop', 'testPM', 'testReconstruction_halfRes_4slicesOnly.mat'))
                
    else
        save('./debugMATs/testAnalysis.mat')
    end
    
    disp('Analysis of the segmented and reconstructed image')
    
    %% Permeability coefficient
    
        % not that urgent
        % analysis.P = analyze_permeabilityCoefficient(segmentation, denoisedImageStack, options);

    %% Computational 3D Morphology
        
        visualizeOn = true;
        reconst.F = F; % faces
        reconst.V = V; % vertices
        
        out = analyze_3D_Morphology(reconst, options, visualizeOn);
    
   
    
   