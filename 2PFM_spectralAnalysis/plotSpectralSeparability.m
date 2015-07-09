function plotSpectralSeparability(fig, scrsz, wavelength, excitationMatrix, fluoroEmissionMatrix, fluoroExcitationMatrix, filterMatrix, Xijk, Eijk, options)

    set(fig,  'Position', [0.04*scrsz(3) 0.305*scrsz(4) 0.880*scrsz(3) 0.40*scrsz(4)])

    rows = 1; cols = 3;
        % add later the rows when you implement the Xijk and Eijk
    
    % Excitation (i) : Light Sources
    ind = 1;  excitInd = ind; fluoExcitInd = ind;
    sp(ind) = subplot(rows, cols, ind);
        
        size(excitationMatrix.data)
        size(wavelength)
        size(fluoroExcitationMatrix.data)
        
        p{ind} = plot(wavelength, excitationMatrix.data, wavelength, fluoroExcitationMatrix.data);
        legStr = [excitationMatrix.name; fluoroExcitationMatrix.name'];
        leg(ind) = legend(legStr);
            legend('boxoff');
        title('Light Sources + Excitation Spectra, "i of X_i_j_k"')
        lab(ind,1) = xlabel('Wavelength [nm]');
        lab(ind,2) = ylabel('Normalized Irradiance');
    
    % Fluorophores (j) : Fluorophores
    ind = ind+1; fluoEmisInd = ind;
    sp(ind) = subplot(rows, cols, ind);
        % size(fluoroMatrix.data)
        p{ind} = plot(wavelength, fluoroEmissionMatrix.data);
            % fluoroMatrix.plotColor, add later
        leg(ind) = legend(fluoroEmissionMatrix.name);
            legend('boxoff');
        title('Fluorophores (emission), j of X_i_j_k')
        lab(ind,1) = xlabel('Wavelength [nm]');
        lab(ind,2) = ylabel('Normalized fluorescence');
    
    % Channels (k)
    ind = ind+1; filterInd = ind;
    sp(ind) = subplot(rows, cols, ind);
        % size(filterMatrix.data)
        p{ind} = plot(wavelength, filterMatrix.data);
        leg(ind) = legend(filterMatrix.name);
            legend('boxoff');
        title('Filters/Channels, k of X_i_j_k')
        lab(ind,1) = xlabel('Wavelength [nm]');
        lab(ind,2) = ylabel('Normalized transmittance');
        
    % style 
    set(sp(1:ind), 'XLim', [350 750], 'YLim', [0 1])
    set(sp(1), 'XLim', [700 1100]) % add some switch later
    
    % correct colors
    for i = 1 : size(excitationMatrix.data,2)
        set(p{excitInd}(i), 'Color', 'k')
    end    
    
    for i = 1 : size(fluoroExcitationMatrix.data,2)
        offset = 1; % number of light sources before (kinda non-elegant)
        set(p{fluoExcitInd}(offset+i), 'Color', fluoroExcitationMatrix.plotColor(i,:))
    end
    
    for i = 1 : size(fluoroEmissionMatrix.data, 2)
        set(p{fluoEmisInd}(i), 'Color', fluoroEmissionMatrix.plotColor(i,:))
    end
    
    for i = 1 : size(filterMatrix.data,2)
        set(p{filterInd}(i), 'Color', filterMatrix.plotColor(i,:))
    end
    
    % export_fig(fullfile('figuresOut', 'Xijk_plot.png'), '-r200', '-a1')
        
    