function analyzeSpectralCharacteristics_FV1000MPE()

    %% Import data
    
        % FLUOROPHORES
        fluoro = import_fluorophoreData();
        
        % Olympus FV100MPE filters
        filters = import_filterTransmissionData();

            
    %% PLOT
    
        fontSize = 9;
        fontName = 'Helvetica';
        scrsz = get(0,'ScreenSize'); % get screen size for plotting
    
        close all

        fig1 = figure('Color', 'w', 'Name', 'Fluorophore Emission Spectra');       
            plotFluorophores(fluoro, fig1, scrsz, fontSize, fontName)
            
        fig2 = figure('Color', 'w', 'Name', 'Olympus Filter Transmittance');       
            plotFilters(filters, fig2, scrsz, fontSize, fontName)
        
        fig3 = figure('Color', 'w', 'Name', 'Olympus Filter #2');       
            plotExternalPMTfilterSets(filters, fig3, scrsz, fontSize, fontName)
            
    
            
   