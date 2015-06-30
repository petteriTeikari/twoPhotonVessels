function segmentation = segmentVessels(imageStack, tubularityIn, options)
    
    if nargin == 0
        
        close all
        %{
        load testSegmentation.mat           
        load('vesselness_test.mat')
        
        % reduce dimension for faster debugging/development
        zSlices = 8:11;
        imageStack = denoisedImageStack(:,:,zSlices);
        MDOF = tubularity(:,:,zSlices);
        OOF = tubularValue_OOF(:,:,zSlices);  
        clear tubularValue_MDOF; clear tubularValue_OOF; 
        clear denoisedImageStack; clear tubularity
        save testSegmentation_reduced.mat
        %}
        % load testSegmentation_reduced.mat
        
        % save just 2D image slices
        %{
        im = imageStack(:,:,end);
        oof = OOF(:,:,end);
        mdof = MDOF(:,:,end);
        save('testVessels2D.mat', 'im', 'oof', 'mdof')
        %}
        
        load(fullfile('/home/petteri/Desktop', 'testSegmentation.mat'))
        
    else
        save(fullfile('/home/petteri/Desktop', 'testSegmentation.mat'));
        % save('debugMATs/testSegmentation.mat')
    end
    %}
     
    % We can use the tubularity image as the "speed field" for e.g.
    % level-set 3D active contour. The OOF is signed, whereas the "more
    % advanced" MDOF is unsigned
    tubularity = tubularityIn.(options.vesselAlgorithm).data;
    
    %% MAX-FLOW Algorithn
    
        % rather than segmenting the input bitmap, segment tubularity and overlay on the input
        useTubularityAsImage = true; 
    
        % http://www.mathworks.com/matlabcentral/fileexchange/34126-fast-continuous-max-flow-algorithm-to-2d-3d-image-segmentation
        visualizeOn = false; saveOn = false;
        [rows, cols, slices] = size(imageStack);
        parameters = [rows; cols; slices; 200; 5e-4; 0.35; 0.11];
            %                para 0,1,2 - rows, cols, heights of the given image
            %                para 3 - the maximum number of iterations
            %                para 4 - the error bound for convergence
            %                para 5 - cc for the step-size of augmented Lagrangian method
            %                para 6 - the step-size for the graident-projection of p
            
        ulab = [0.001 0.4]; % [source sink] empirically set, update for more adaptive later                
        [uu, weighed, uu_binary] = segment_maxFlow_wrapper(imageStack, tubularity, parameters, ulab, visualizeOn, saveOn, useTubularityAsImage, options);
        segmentation = weighed;
        
        % Also see ASETS/asetsMatlabMaxFlow, pretty much the same-looking
        % implementation with CUDA option as well, with time one could see
        % if it is faster or not
        % https://github.com/ASETS/asetsMatlabMaxFlow
        % https://github.com/ASETS/asetsMatlabLevelSets
        
        % play with
        % "t02_binaryLevelSetSegmentation_2PM_batchParameterExploration.m"
        % from asetsMatlabLevelSets
    
    
    %% MATLAB Toolbox(es) : Official 
        
        % Fast Marching
        % http://www.mathworks.com/help/images/ref/imsegfmm.html
    
        
    %% MATLAB Level-Set functions
    
        % lathen/matlab-levelset
        % https://github.com/lathen/matlab-levelset
        
        % ktchu/LSMLIB | Level Set Method Library
        % https://github.com/ktchu/LSMLIB
        
        % 2D/3D image segmentation toolbox
        % http://www.mathworks.com/matlabcentral/fileexchange/24998-2d-3d-image-segmentation-toolbox
        smooth_weight = 0.01; 
        image_weight = 1e-6; 
        delta_t = 4; 
        iterCount = 10; 
        visualizeOn = true;
        % segmentation_ChVese = chenVese_3D_wrapper(imageStack, OOF, MDOF, smooth_weight, image_weight, delta_t, iterCount, visualizeOn, options);

    
        
    %% ITK Functions via Matlab bridge MATITK
    
        % see e.g. http://matitk.cs.sfu.ca/usageguide
        % Segmentation Methods in ITK: http://www.itk.org/CourseWare/Training/SegmentationMethodsOverview.pdf
        % SimpleITK via Python? http://www.simpleitk.org/
        % WrapITK via Python? https://code.google.com/p/wrapitk/
        % MITK, Medical ITK, http://mitk.org/wiki/MITK
            % -> http://mint-medical.de/wp-content/mitk3m3_documentation/org_vesseltreeseg.html
            
            % Use subfunction for easier testing
            % segmentation = itk_segment_wrapper(imageStack, tubularity, options);
            
           
     %% PYTHON
       
    
        % The "easiest way" probably to access ITK functions would be via
        % Python avoiding the ugly C++ hassle, accessing Python from Matlab
        % could be done as following:
        %  + "perl.m" http://www.mathworks.com/matlabcentral/answers/153867-running-python-script-in-matlab
        %  + Since R2014b Matlab knows how to talk with Python
        %  + Matpy, http://algoholic.eu/matpy/
        %  + https://theneural.wordpress.com/2012/02/13/calling-python-from-matlab/
        %     --> https://github.com/pv/pythoncall
        %  + Cython, http://stackoverflow.com/questions/1707780/call-python-function-from-matlab
        %  + pymex, https://github.com/kw/pymex
        
        % Mahotas: Computer Vision in Python
        % http://mahotas.readthedocs.org/en/latest/
        
        % SimpleCV, even more simplified than OpenCV for Python
        % http://simplecv.org/
        
        % COMMAND LINE CALL EXAMPLE
        % itk_pythonSystem_wrapper() % un-comment if you wanna test
        
    
    %% MACHINE LEARNING
    
        % Supervised Filter Learning for Curvilinear Structure Segmentation
        % http://cvlab.epfl.ch/page-108936.html
    
        % Machine learning of hierarchical clustering to segment 2D and 3D images.
        % http://www.ncbi.nlm.nih.gov/pubmed/23977123
        
    
    %% OTHER OPTIONS
    
        % Gebiss, an ImageJ plugin for the specification of ground truth 
        % and the performance evaluation of 3D segmentation algorithms
        % http://www.biomedcentral.com/1471-2105/12/232
    
        % cudaseg - Level Set Segmentation in CUDA
        % Fast Level Set Segmentation of Biomedical Images using Graphics Processing Units
        % https://code.google.com/p/cudaseg/
        
        % A Work-Efficient GPU Algorithm for Level Set Segmentation
        % http://graphics.stanford.edu/~mlrobert/publications/hpg_2010/
        
        % FARSIGHT Toolkit
        % http://www.farsight-toolkit.org/wiki/Vessel_Laminae_Segmentation
        
        % Implementation of graph-based interactive 3D vessel segmentation filter
        % http://www.insight-journal.org/browse/publication/737
        
        % CVonline
        % http://homepages.inf.ed.ac.uk/rbf/CVonline/SWEnvironments.htm
        
        % Graph-based active learning of agglomeration (GALA): a Python library to segment 2D and 3D neuroimages
        % http://dx.doi.org/10.3389%2Ffninf.2014.00034
        
        % A 3D interactive multi-object segmentation tool using local robust statistics driven active contours.
        % http://dx.doi.org/10.1016/j.media.2012.06.002
        
        % See Matlab/C code by Xavier Bresson for various segmentation
        % problems
        % https://9d5b76582b7871444743f5d0bbd439c802a638d7.googledrive.com/host/0B3BTLeCYLunCc1o4YzV1Ui1SeVE/codes.html

        
   