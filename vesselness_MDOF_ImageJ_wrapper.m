function MDOF = vesselness_MDOF_ImageJ_wrapper(imageStackIn, scales, scaleStep)
        
    disp('  MDOF for vesselness')
    % ITK implementation: https://github.com/fethallah/ITK-TubularGeodesics
    % Fiji Plugin: http://cvlab.epfl.ch/software/delin/index.php

    % Use the Fiji plugin via the MIJ        
    command = 'MultiScale Oriented-Flux Tubularity Measure';
    nOfScales = 1 + (scales(2) - scales(1))/scaleStep;
    minScale = scales(1);
    maxScale = scales(2);
    % run("MultiScale Oriented-Flux Tubularity Measure", "number=1 minimum=0.000001 maximum=0.000001 
    % save=/home/petteri/Desktop/CP-20150323-TR70-mouse2-1-son_denoised_onlyOneTimePoint.ome.oof.oof.nrrd");
    arguments = ['number=', num2str(nOfScales), ' minimum=', num2str(minScale), ' maximum=', num2str(maxScale)];
    disp(['MDOF Arguments = ', arguments])

    % ImageJ filtering via MIJ

        % Now the MDOF filter implementation only accepts 8-bit images so
        % we cast it as 8-bit grayscale (imageStackIn is now double)
        imageStackIn_8bit = uint8(255 * imageStackIn / max(imageStackIn(:)));
        options.saveImageJ_outputAsImage = false;        

        [MDOF, timeExecMDOF] = MIJ_wrapper(imageStackIn_8bit(:,:,:), command, arguments, options);                    

        % pack to output
        % vesselness.data = tubularValue_MDOF;

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