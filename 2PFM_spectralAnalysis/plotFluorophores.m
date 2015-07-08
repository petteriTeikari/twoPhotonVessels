function plotFluorophores(fluoro, fig, scrsz, fontSize, fontName)
        
    set(fig,  'Position', [0.04*scrsz(3) 0.545*scrsz(4) 0.350*scrsz(3) 0.30*scrsz(4)])

    % EMISSIONS
    field = 'emission';
    normalizeOn = true;

    for i = 1 : length(fluoro)
        if normalizeOn
            p(i) = plot(fluoro{i}.wavelength, fluoro{i}.(field) / max(fluoro{i}.(field)), 'Color', fluoro{i}.plotColor);
        else
            p(i) = plot(fluoro{i}.wavelength, fluoro{i}.(field), 'Color', fluoro{i}.plotColor);
        end
        hold on
        legendStr{i} = fluoro{i}.name;

    end
    hold off

    % annotate
    tit = title('Fluorophore Emission Spectra');
    leg = legend(legendStr);
        legend('boxoff')
    lab(1) = xlabel('Wavelength [nm]');
    lab(2) = ylabel('Normalized emission');

    % style
    set(p, 'LineWidth', 2)
    set(gca, 'XLim', [300 900], 'FontName', fontName, 'FontSize', fontSize)
    set(lab, 'FontName', fontName, 'FontSize', fontSize)
    set(tit, 'FontName', fontName, 'FontSize', fontSize+1, 'FontWeight', 'bold')


    % export to disk
    try
        export_fig(fullfile('figuresOut','fluorophores.png'), '-r200', '-a1')
    catch err
        err
        warning('plot not saved to disk') 
        % download and add to your path
    end




