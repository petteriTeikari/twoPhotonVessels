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
    
        MDOF = vesselness_MDOF_ImageJ_wrapper(imageStackIn, scales, scaleStep);
        vesselness.data = MDOF;
                
    else
        
    end
       
    %% VESSEL ENHANCEMENT DIFFUSION (VED) 
    if strcmp(options.vesselAlgorithm, 'VED')
    
        % Implementation: ?
        disp('  VED not implemented yet')
            % http://www.mathworks.com/matlabcentral/fileexchange/24409-hessian-based-frangi-vesselness-filter
        
    end
    
    
    
    % TODO: You could check that all the given arguments are found also
    %       e.g. handling typos in cell: options.vesselAlgorithm
    
    %% OTHERS

        % RORPO filter available as C++ implementation
        % Ranking Orientation Responses of Path Openings
        % http://path-openings.github.io/RORPO/
        
        % FibrilTool for ImageJ
        % http://dx.doi.org/10.1038/nprot.2014.024
    
        