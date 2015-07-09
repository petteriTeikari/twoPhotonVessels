function Xijk = computeSpectralSeparabilityMatrix(excitation, fluoroEmission, fluoroExcitation, filter, matrixType)

    % Eventually will contain a Matlab implementation of Spectral
    % Separability Index X_{ijk} and later also the relative brightness
    % variant E_{ijk}
    
    % Based on:
    % ---------
    %     Oheim M. 2010. Instrumentation for Live-Cell Imaging and Main Formats - Springer. 
    %     In: Papkovsky, DB, editor. Humana Press. Methods in Molecular Biology 591. 
    %     http://dx.doi.org/10.1007/978-1-60761-404-3_1.
    %     
    %     Oheim M, van ’t Hoff M, Feltz A, Zamaleeva A, Mallet J-M, Collot M. 2014. 
    %     New red-fluorescent calcium indicators for optogenetics, photoactivation and multi-color imaging. 
    %     Biochimica et Biophysica Acta (BBA) - Molecular Cell Research 1843. 
    %     Calcium Signaling in Health and Disease:2284–2306. 
    %     http://dx.doi.org/10.1016/j.bbamcr.2014.03.010. (see Fig. 3)
    %     
    %     M. Oheim, M. van't Hoff, Xijk — a figure of merit and software tool for evaluating
    %     spectral cross-talk in multi-channel fluorescence, 2014. (in preparation).

    if strcmp(matrixType, 'specificity')
        
        % the Xijk (specificity)
        Xijk = [];
        disp('Empty "placeholder" matrix for Xijk returned')
        
    elseif strcmp(matrixType, 'relative')
        
        % the Eijk (relative brightness
        Xijk = [];
        disp('Empty "placeholder" matrix for Xijk returned')
        
    else
        
        error(['Typo probably in your matrixType? (', matrixType, ')'])
        
    end

    