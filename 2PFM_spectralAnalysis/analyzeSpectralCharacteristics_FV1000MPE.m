function analyzeSpectralCharacteristics_FV1000MPE()

    %% Import data   
    
        % "Master" wavelength vector. We now have spectral measurement with
        % various wavelengths, we just pad those with NaN values for easier
        % handling
        nmRes = 1; % [nm]
        wavelength = (300 : nmRes : 1100)'; 
                 
        % FLUOROPHORES
        [fluoro, fluoro2PM] = import_fluorophoreData(wavelength);                
        
        % Olympus FV100MPE filters
        filters = import_filterTransmissionData(wavelength);

        % Laser lines, light sources, etc.
        peakWavelength = 900;
        FWHM = 10; % [nm], check whether 10 nm is true for our system
        lightSources = import_lightSources(wavelength, peakWavelength, FWHM);
            % later define the "action spectrum" taking into an account the
            % excitation spectrum of the fluorophores to get the
            % excitationMatrix out of lightSources     
    
        
            
    %% PLOT INPUTs
    
        fontSize = 9;
        fontName = 'Helvetica';
        scrsz = get(0,'ScreenSize'); % get screen size for plotting    
        close all

        plotOn = false; % true/false
        
        if plotOn
            
            % fig1 = figure('Color', 'w', 'Name', 'Light Sources');       
                % plotFluorophores(lightSources, fig1, scrsz, fontSize, fontName)
                % not implemented at the moment
                
            fig2 = figure('Color', 'w', 'Name', 'Fluorophore Emission Spectra');       
                plotFluorophores(fluoro, fig2, scrsz, fontSize, fontName)

            fig3 = figure('Color', 'w', 'Name', 'Olympus Filter Transmittance');       
                plotFilters(filters, fig3, scrsz, fontSize, fontName)

            fig4 = figure('Color', 'w', 'Name', 'Olympus Filter #2');       
                plotExternalPMTfilterSets(filters, fig4, scrsz, fontSize, fontName)
        end
            
    
    %% Spectral separability analysis           
    
        % this requires three 2D matrices (has to be the same length as the
        % wavelength vector        
        normalizeOn = true; % normalize now everything
        
        % Light source
        lightsWanted = {'Laser'}; % {'1PMequivalent'};
        excitationMatrix = getDataMatrix(lightSources, wavelength, lightsWanted, 'light', [], normalizeOn);
        
        % Fluorophores
        fluorophoresWanted = {'OGB-1'; 'SR-101'};
        absType = '2PM'; % or '1PM'
        yType = 'emission';
        fluoroEmissionMatrix = getDataMatrix(fluoro2PM, wavelength, fluorophoresWanted, 'fluoro', yType, normalizeOn);
        yType = 'excitation';
        fluoroExcitationMatrix = getDataMatrix(fluoro2PM, wavelength, fluorophoresWanted, 'fluoro', yType, normalizeOn);
                
        % Microscope filters
        filtersWanted = {'BA570-625HQ'; 'BA495-540HQ'};
        filterMatrixEmission = getDataMatrix(filters.emissionFilter, wavelength, filtersWanted, 'filter', [], normalizeOn);
        filtersWanted = {'DM570'};
        filterDichroicMatrix = getDataMatrix(filters.emissionDichroic, wavelength, filtersWanted, 'filter', [], normalizeOn);

        % See the light path diagram of the 2-PM system 
        % to add the dichroic filter?
        filterMatrix = filterMatrixEmission; % for testing
        
        % compute the spectral separability matrix, X_{ijk} 
        % e.g. Fig 3 of Oheim et al. (2014), http://dx.doi.org/10.1016/j.bbamcr.2014.03.010        
        Xijk = computeSpectralSeparabilityMatrix(excitationMatrix, fluoroEmissionMatrix, fluoroExcitationMatrix, filterMatrix, 'specificity');
        
        % as well as the E_{ijk} for relative brightness values (that takes
        % into account the molecular brightness and absolute fluorescence
        % collected fraction, for some details see Oheim et al. (2014), and
        % wait for the upcoming "M. Oheim, M. van't Hoff, Xijk — a figure of merit 
        % and software tool for evaluating spectral cross-talk in multi-channel fluorescence,"
        Eijk = computeSpectralSeparabilityMatrix(excitationMatrix, fluoroEmissionMatrix, fluoroExcitationMatrix, filterMatrix, 'relative');
        
        
    %% Plot spectral separability analysis
    
        options = [];
        fig5 = figure('Color', 'w', 'Name', 'Spectral Separability Analysis');
        plotSpectralSeparability(fig5, scrsz, wavelength, excitationMatrix, fluoroEmissionMatrix, fluoroExcitationMatrix, filterMatrix, Xijk, Eijk, options)
        
    
    %% Spectral unmixing 
    
        % placeholder now, to be implemented later
        out = computeSpectralMixing(excitationMatrix, fluoroEmissionMatrix, fluoroExcitationMatrix, filterMatrix, Xijk, Eijk, options);
        