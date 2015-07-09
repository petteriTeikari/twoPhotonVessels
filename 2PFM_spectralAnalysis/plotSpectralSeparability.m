function plotSpectralSeparability(fig, scrsz, wavelength, excitationMatrix, fluoroMatrix, filterMatrix, Xijk, Eijk, options)

    set(fig,  'Position', [0.04*scrsz(3) 0.305*scrsz(4) 0.880*scrsz(3) 0.40*scrsz(4)])

    rows = 1; cols = 3;
        % add later the rows when you implement the Xijk and Eijk
    
    % Excitation (i) : Light Sources
    ind = 1;  excitInd = ind;
    sp(ind) = subplot(rows, cols, ind);
        % size(excitationMatrix.data)
        p{ind} = plot(wavelength, excitationMatrix.data);
        leg(ind) = legend(excitationMatrix.name);
            legend('boxoff');
        title('Light Sources, i of X_i_j_k')
        lab(ind,1) = xlabel('Wavelength [nm]');
        lab(ind,2) = ylabel('Normalized Irradiance');
    
    % Fluorophores (j) : Fluorophores
    ind = ind+1; fluoInd = ind;
    sp(ind) = subplot(rows, cols, ind);
        % size(fluoroMatrix.data)
        p{ind} = plot(wavelength, fluoroMatrix.data);
            % fluoroMatrix.plotColor, add later
        leg(ind) = legend(fluoroMatrix.name);
            legend('boxoff');
        title('Fluorophores, j of X_i_j_k')
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
    set(sp(1:ind), 'XLim', [350 750])
    
    % correct colors
    for i = 1 : size(excitationMatrix.data,2)
        set(p{excitInd}(i), 'Color', 'k')
    end
    
    for i = 1 : size(fluoroMatrix.data,2)
        set(p{fluoInd}(i), 'Color', fluoroMatrix.plotColor(i,:))
     end
    
    for i = 1 : size(filterMatrix.data,2)
        set(p{filterInd}(i), 'Color', filterMatrix.plotColor(i,:))
    end
        
    