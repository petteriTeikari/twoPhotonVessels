function analyzeSpectralCharacteristics_FV1000MPE()

    %% Import data
    
        % Laser lines, light sources, etc.
        lightSources = import_lightSources();
            % later define the "action spectrum" taking into an account the
            % excitation spectrum of the fluorophores to get the
            % excitationMatrix out of lightSources
           
    
        % FLUOROPHORES
        fluoro = import_fluorophoreData();            
        
        % Olympus FV100MPE filters
        filters = import_filterTransmissionData();

            
    %% PLOT INPUTs
    
        fontSize = 9;
        fontName = 'Helvetica';
        scrsz = get(0,'ScreenSize'); % get screen size for plotting    
        close all

        plotOn = true; % true/false
        
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
    
        wavelength = filters.emissionDichroic{1}.wavelength; % 400-700 nm
    
        % this requires three 2D matrices (has to be the same length as the
        % wavelength vector        
        normalizeOn = true; % normalize now everything
        
        % Light source
        excitationMatrix.data = ones(length(wavelength),1); % constant now for testing
        excitationMatrix.name = 'dummy';
        
            % implement at some point
            % excitationMatrix = getDataMatrix(lightSources, wavelength, lightsWanted, 'light', normalizeOn);
            %   + lightSources = import_lightSources();
        
        % Fluorophores
        fluorophoresWanted = {'OGB-1 488'; 'SR-101'};
        fluoroMatrix = getDataMatrix(fluoro, wavelength, fluorophoresWanted, 'fluoro', normalizeOn);
                
        % Microscopy filters
        filtersWanted = {'BA570-625HQ'; 'BA495-540HQ'};
        filterMatrixEmission = getDataMatrix(filters.emissionFilter, wavelength, filtersWanted, 'filter', normalizeOn);
        filtersWanted = {'DM570'};
        filterDichroicMatrix = getDataMatrix(filters.emissionDichroic, wavelength, filtersWanted, 'filter', normalizeOn);

        % See the light path diagram of the 2-PM system 
        % to add the dichroic filter?
        filterMatrix = filterMatrixEmission; % for testing
        
        % compute the spectral separability matrix, X_{ijk} 
        % e.g. Fig 3 of Oheim et al. (2014), http://dx.doi.org/10.1016/j.bbamcr.2014.03.010        
        Xijk = computeSpectralSeparabilityMatrix(excitationMatrix, fluoroMatrix, filterMatrix, 'specificity');
        
        % as well as the E_{ijk} for relative brightness values (that takes
        % into account the molecular brightness and absolute fluorescence
        % collected fraction, for some details see Oheim et al. (2014), and
        % wait for the upcoming "M. Oheim, M. van't Hoff, Xijk — a figure of merit 
        % and software tool for evaluating spectral cross-talk in multi-channel fluorescence,"
        Eijk = computeSpectralSeparabilityMatrix(excitationMatrix, fluoroMatrix, filterMatrix, 'relative');
        
        
    %% Plot spectral separability analysis
    
        options = [];
        fig5 = figure('Color', 'w', 'Name', 'Spectral Separability Analysis');
        plotSpectralSeparability(fig5, scrsz, wavelength, excitationMatrix, fluoroMatrix, filterMatrix, Xijk, Eijk, options)
        
    
    %% Spectral unmixing 
    
        % placeholder now, to be implemented later
        out = computeSpectralMixing(excitationMatrix, fluoroMatrix, filterMatrix, Xijk, Eijk, options);
        