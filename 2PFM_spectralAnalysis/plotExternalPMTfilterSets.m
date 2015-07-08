 function plotExternalPMTfilterSets(filters, fig, scrsz, fontSize, fontName)
        
    set(fig,  'Position', [0.04*scrsz(3) 0.105*scrsz(4) 0.880*scrsz(3) 0.30*scrsz(4)])

    % use shorter variable names      
    x = filters.emissionDichroic{1}.wavelength; % same for all

    rows = 1; cols = 3;

    ind = 1;
    sp(ind) = subplot(rows,cols,ind);

        % DM485
        % FV10MP-MV/G
        i = 1;

            p(ind,:) = plot(x, filters.emissionDichroic{i}.transmittance, ...
                            x, filters.emissionFilter{1}.transmittance, ...
                            x, filters.emissionFilter{2}.transmittance);

        % annotate
        tit(ind) = title('FV10MP-MV/G');
        leg(ind) = legend('DM485', 'BA495-540HQ', 'BA420-460');
            legend('boxoff')
        lab(ind,1) = xlabel('Wavelength [nm]');
        lab(ind,2) = ylabel('Normalized transmittance');


    ind = 2;
    sp(ind) = subplot(rows,cols,ind);

        i = 2;           
            p(ind,:) = plot(x, filters.emissionDichroic{i}.transmittance, ...
                            x, filters.emissionFilter{3}.transmittance, ...
                            x, filters.emissionFilter{4}.transmittance);



        % annotate
        tit(ind) = title('FV10MP-MC/Y');
        leg(ind) = legend('DM485', 'BA515-560', 'BA460-510');
            legend('boxoff')
        lab(ind,1) = xlabel('Wavelength [nm]');
        lab(ind,2) = ylabel('Normalized transmittance');

    ind = 3;
    sp(ind) = subplot(rows,cols,ind);

        i = 3;
            p(ind,:) = plot(x, filters.emissionDichroic{i}.transmittance, ...
                            x, filters.emissionFilter{5}.transmittance, ...
                            x, filters.emissionFilter{4}.transmittance);

        % annotate
        tit(ind) = title('FV10MP-MG/R');
        leg(ind) = legend('DM570', 'BA570-625HQ', 'BA495-540HQ');
            legend('boxoff')
        lab(ind,1) = xlabel('Wavelength [nm]');
        lab(ind,2) = ylabel('Normalized transmittance');

    % style
    set(p, 'LineWidth', 1)
    set(p(:,1), 'Color', 'k')
    set(p(:,2), 'Color', 'r')
    set(p(:,3), 'Color', 'b')

    set(leg, 'Location', 'SouthEast', 'FontName', fontName, 'FontSize', fontSize-1)
    set(sp, 'XLim', [350 750], 'FontName', fontName, 'FontSize', fontSize)
    set(lab, 'FontName', fontName, 'FontSize', fontSize)
    set(tit, 'FontName', fontName, 'FontSize', fontSize+1, 'FontWeight', 'bold')

    % export to disk
    try
        export_fig(fullfile('figuresOut','olympusFilters2.png'), '-r200', '-a1')
    catch err
        err
        warning('plot not saved to disk') 
        % download and add to your path
    end