function vesselness = vesselnessFilter(imageStackIn, options)

    % We apply here a "vesselness filter" that should enhance the vessels
    % in relation to the background making their segmentation easier later
    % in the workflow, in practice we don't use the old "Hessian"-filter
    % such as Frangi Vesselness filter, but rather the more recent Optimal
    % Oriented Flow (OOF) variants such as plain OOF, OOF-OFA, and MDOF

    % TODO?: No if / elseif / else -structure now as previously one could
    %        compute various vesselness measures at once
    
    % INIT
    vesselness.method = options.vesselAlgorithm;
    vesselness.scales = options.scales;
    vesselness.scaleStep = options.scaleStep;
    vesselness.extraParam.dummy = []; % algorithm specific values
        
        % for debugging purposes
        if nargin == 0
            disp('Running LOCALLY the VESSELNESS FILTERING from DEBUGGING .MAT')
            load('debugMATs/testVesselness.mat')
            close all
        else
            save('debugMATs/testVesselness.mat')
        end

        sizeIn = size(imageStackIn);
        if length(sizeIn) < 3
            warning('Input is only a 2D image')
        end
        

    %% OPTIMALLY ORIENTED FLUX (OOF)
    % OOF Matlab: http://www.mathworks.com/matlabcentral/fileexchange/41612-optimally-oriented-flux--oof--for-3d-curvilinear-structure-detection
    
        % This is in practice quite out-dated already and should be
        % replaced by OOF-OFA extension or optimally with the MDOF
        opts.responsetype = 1; %  l1+l2;
        opts.displayOn = false;
        
        if strcmp(options.vesselAlgorithm, 'OOF')
            disp([' OOF filter to enhance vessels with radii from ', ...
                num2str(options.scales(1)), ' to ', num2str(options.scales(2))]);
            
            % actuall call
            tubularValue_OOF = vesselness_OOF_wrapper(double(imageStackIn), options.scales, opts);
            vesselness.extraParam.OOF_responseType = opts.responsetype;
            
            % pack to output
            vesselness.data = tubularValue_OOF;
            
        else

        end        
        

    %% OOF - Oriented Flux Antisymmetric (OOF-OFA)
    if strcmp(options.vesselAlgorithm, 'OOF-OFA')
    
        % Implementation: ?
        disp('  OOF-OFA not implemented yet')
        
    end
        

    %% MDOF : Multi-Directional Oriented Flux 
    % Turetken et al., 2013, http://dx.doi.org/10.1109/ICCV.2013.196    
    if strcmp(options.vesselAlgorithm, 'MDOF')
    
        disp('  MDOF for vesselness')
        % ITK implementation: https://github.com/fethallah/ITK-TubularGeodesics
        % Fiji Plugin: http://cvlab.epfl.ch/software/delin/index.php
        
        % Use the Fiji plugin via the MIJ        
        command = 'MultiScale Oriented-Flux Tubularity Measure';
        nOfScales = 1 + (options.scales(2) - options.scales(1))/options.scaleStep;
        minScale = options.scales(1);
        maxScale = options.scales(2);
        % run("MultiScale Oriented-Flux Tubularity Measure", "number=1 minimum=0.000001 maximum=0.000001 
        % save=/home/petteri/Desktop/CP-20150323-TR70-mouse2-1-son_denoised_onlyOneTimePoint.ome.oof.oof.nrrd");
        arguments = ['number=', num2str(nOfScales), ' minimum=', num2str(minScale), ' maximum=', num2str(maxScale)];
        disp(['MDOF Arguments = ', arguments])
        
        % ImageJ filtering via MIJ
        
            % Now the MDOF filter implementation only accepts 8-bit images so
            % we cast it as 8-bit grayscale (imageStackIn is now double)
            imageStackIn_8bit = uint8(255 * imageStackIn / max(imageStackIn(:)));
            options.saveImageJ_outputAsImage = false;        
        
            [tubularValue_MDOF, timeExecMDOF] = MIJ_wrapper(imageStackIn_8bit(:,:,:), command, arguments, options);                    
           
            % pack to output
            vesselness.data = tubularValue_MDOF;
            
            % save('vesselness_test.mat', 'tubularValue_OOF', 'tubularValue_MDOF')
            % visualize_vesselnessFilter(imageStackIn_8bit, tubularValue_OOF, options)
            % visualize_vesselnessFilter(imageStackIn_8bit, tubularValue_MDOOF, options)
            
            % NOTE! / TODO
            % Now the Plugin is constructed so that the saveas dialog is
            % always opened (?), see call on "https://github.com/fethallah/tubularity/blob/master/FijiITKInterface/OOFTubularityMeasure_Plugin.java" 
            % at line 172:
            % "	String outputFilename = getSavePath( Info ); "
                        
            % The output is now unsigned and cannot be used as a speed
            % field (signed distance function as it is) at least for the
            % older active contour implementations (e.g. Chan-Vese)
            
                % There are apparently ways to use non-signed functions as
                % well with level-sets, see e.g. "Signing the Unsigned:
                % Robust Surface Reconstruction from Raw Pointsets"
                % http://www.geometry.caltech.edu/pubs/MDDCA10.pdf
                
                % and goes towards computer graphics and surface
                % reconstructions for point clouds
                % e.g. Fernando de Goes' code
                % http://fernandodegoes.org/
                
    else
        
    end
       
    %% VESSEL ENHANCEMENT DIFFUSION (VED) 
    if strcmp(options.vesselAlgorithm, 'VED')
    
        % Implementation: ?
        disp('  VED not implemented yet')
        
    end
    
    
    
    % TODO: You could check that all the given arguments are found also
    %       e.g. handling typos in cell: options.vesselAlgorithm
    
    %% OTHERS

        % RORPO filter available as C++ implementation
        % Ranking Orientation Responses of Path Openings
        % http://path-openings.github.io/RORPO/
        
        % FibrilTool for ImageJ
        % http://dx.doi.org/10.1038/nprot.2014.024
    
        