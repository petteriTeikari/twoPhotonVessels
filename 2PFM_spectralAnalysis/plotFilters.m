function plotFilters(filters, fig, scrsz, fontSize, fontName)

    set(fig,  'Position', [0.4*scrsz(3) 0.545*scrsz(4) 0.580*scrsz(3) 0.30*scrsz(4)])

    % use shorter variable names (field names)        
    x = 'wavelength'; y = 'transmittance';

    rows = 1; cols = 2;

    ind = 1;
    typeOfFilter = 'emissionDichroic';
    sp(ind) = subplot(rows,cols,ind);
        for i = 1 : length(filters.(typeOfFilter))
            hold on
            p{ind}(i) = plot(filters.(typeOfFilter){i}.(x), filters.(typeOfFilter){i}.(y), ...
                'Color', filters.(typeOfFilter){i}.plotColor);                
            legendStr.(typeOfFilter){i} = filters.(typeOfFilter){i}.name;

        end
        hold off

        % annotate
        tit(ind) = title('Emission Dichroics');
        leg(ind) = legend(legendStr.(typeOfFilter));
            legend('boxoff')
        lab(ind,1) = xlabel('Wavelength [nm]');
        lab(ind,2) = ylabel('Normalized transmittance');


    ind = 2;
    typeOfFilter = 'emissionFilter';
    sp(ind) = subplot(rows,cols,ind);
        for j = 1 : length(filters.(typeOfFilter))
            hold on
            p{ind}(j) = plot(filters.(typeOfFilter){j}.(x), filters.(typeOfFilter){j}.(y), ...
                'Color', filters.(typeOfFilter){j}.plotColor); 
            legendStr.(typeOfFilter){j} = filters.(typeOfFilter){j}.name;
        end
        hold off

        % annotate
        tit(ind) = title('Emission Filters');
        leg(ind) = legend(legendStr.(typeOfFilter));
            legend('boxoff')
        lab(ind,1) = xlabel('Wavelength [nm]');
        lab(ind,2) = ylabel('Normalized transmittance');

    % style
    set(p{1}, 'LineWidth', 2)
    set(p{2}, 'LineWidth', 1)
    set(leg, 'Location', 'SouthEast', 'FontName', fontName, 'FontSize', fontSize-1)
    set(sp, 'XLim', [350 750], 'FontName', fontName, 'FontSize', fontSize)
    set(lab, 'FontName', fontName, 'FontSize', fontSize)
    set(tit, 'FontName', fontName, 'FontSize', fontSize+1, 'FontWeight', 'bold')
            
    % export to disk
    try
        export_fig(fullfile('figuresOut','olympusFilters.png'), '-r200', '-a1')
    catch err
        err
        warning('plot not saved to disk') 
        % download and add to your path
    end
    