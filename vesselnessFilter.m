function vesselness = vesselnessFilter(imageStack, algorithm, scales, options, t, ch)

    % We apply here a "vesselness filter" that should enhance the vessels
    % in relation to the background making their segmentation easier later
    % in the workflow, in practice we don't use the old "Hessian"-filter
    % such as Frangi Vesselness filter, but rather the more recent Optimal
    % Oriented Flow (OOF) variants such as plain OOF, OOF-OFA, and MDOF

    % TODO?: No if / elseif / else -structure now as previously one could
    %        compute various vesselness measures at once
    
    %% INPUT CHECKS
    
        if nargin == 3
            disp('   no "options" provided for vesselnessFilter, using defaults then')
        end
        
        % note also that some algorithms want the scales with a bit
        % different syntax
        
        vesselness.extraParam.scaleStep = scales(2) - scales(1);
        vesselness.extraParam.dummy = []; % algorithm specific values

        sizeIn = size(imageStack);
        if length(sizeIn) < 3
            warning('Input is only a 2D image')
        end
        
    %% VESSELNESS FILTERING
    
        % For a review of different algorithm, see for example
        % Türetken E, Becker C, Glowacki P, Benmansour F, Fua P. 2013. 
        % "Detecting Irregular Curvilinear Structures in Gray Scale and Color Imagery Using Multi-directional Oriented Flux." 
        % In: . 2013 IEEE International Conference on Computer Vision (ICCV) p. 1553–1560. 
        % http://dx.doi.org/10.1109/ICCV.2013.196.    
        
        %% OPTIMALLY ORIENTED FLUX (OOF)
        if strcmp(options.vesselAlgorithm, 'OOF')

            % OOF Matlab: http://www.mathworks.com/matlabcentral/fileexchange/41612-optimally-oriented-flux--oof--for-3d-curvilinear-structure-detection
            
            % Law MWK, Chung ACS. 2008. 
            % Three Dimensional Curvilinear Structure Detection Using Optimally Oriented Flux. 
            % In: Forsyth, D, Torr, P, Zisserman, A, editors. Computer Vision – ECCV 2008. Springer Berlin Heidelberg. Lecture Notes in Computer Science 5305 p. 368–382. 
            % http://dx.doi.org/10.1007/978-3-540-88693-8_27.
            
            % which eigenvalues of OOF tensor to return
            opts.responsetype = 1; %  l1+l2; TODO: pass from outside
            opts.displayOn = false;
                
            disp([' OOF filter to enhance vessels with radii from ', ...
                num2str(options.scales(1)), ' to ', num2str(options.scales(end))]);
            
            % actuall call
            vesselness.data = vesselness_OOF_wrapper(double(imageStack), [scales(1) scales(end)], opts);
            vesselness.extraParam.OOF_responseType = opts.responsetype;
            
    
        %% OPTIMALLY ORIENTED FLUX (OOF) with OFA (Oriented Flux Asymmetry)
        elseif strcmp(options.vesselAlgorithm, 'OOF_OFA')
    
            % Implementation: 2D from Dr. Max Law (pers.comm.)
            
            % Law MWK, Chung ACS. 2010. 
            % An Oriented Flux Symmetry Based Active Contour Model for Three Dimensional Vessel Segmentation. 
            % In: Daniilidis, K, Maragos, P, Paragios, N, editors. Computer Vision – ECCV 2010. Springer Berlin Heidelberg. Lecture Notes in Computer Science 6313 p. 720–734. 
            % http://dx.doi.org/10.1007/978-3-642-15558-1_52.
            
            disp('3D OOF-OFA not implemented yet, using 2D per-slice approach')
            disp([' OOF-OFA filter to enhance vessels with radii from ', ...
                num2str(options.scales(1)), ' to ', num2str(options.scales(end))]);
            oofOFA = vesselness_OofOFA_wrapper(double(imageStack), scales);

            vesselness.data = oofOFA;        
    

        %% MDOF : Multi-Directional Oriented Flux         
        elseif strcmp(options.vesselAlgorithm, 'MDOF')
    
            % Türetken E, Becker C, Glowacki P, Benmansour F, Fua P. 2013. 
            % "Detecting Irregular Curvilinear Structures in Gray Scale and Color Imagery Using Multi-directional Oriented Flux." 
            % In: . 2013 IEEE International Conference on Computer Vision (ICCV) p. 1553–1560. 
            % http://dx.doi.org/10.1109/ICCV.2013.196.            
            
            MDOF = vesselness_MDOF_ImageJ_wrapper(imageStack, [scales(1) scales(end)], vesselness.extraParam.scaleStep);
            vesselness.data = MDOF;            
 
       
        %% VESSEL ENHANCEMENT DIFFUSION (VED) 
        elseif strcmp(options.vesselAlgorithm, 'VED')
    
            % Implementation: ?
            disp('  VED not implemented yet')
                % http://www.mathworks.com/matlabcentral/fileexchange/24409-hessian-based-frangi-vesselness-filter
        
        elseif strcmp(options.vesselAlgorithm, 'someCoolOne')
            
            %
                
        else
            
            error('what vesselness filter?')
                
        end