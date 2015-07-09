function fluoro = import_fluorophoreData()

    %% FLUORESCENT MARKERS

        % OGB
        % https://www.lifetechnologies.com/order/catalog/product/O6807
        tmpOGB = importdata(fullfile('data','OregonGreen488_BAPTA.csv'), ',', 1);
            fluoro{1}.wavelength = tmpOGB.data(:,1);
            fluoro{1}.wavelengthRes = fluoro{1}.wavelength(2) - fluoro{1}.wavelength(1);
            fluoro{1}.excitation = tmpOGB.data(:,2);
            fluoro{1}.emission = tmpOGB.data(:,3);
            fluoro{1}.name = 'OGB-1 488';
            fluoro{1}.plotColor = [0 1 0];

        % SR-101
        % http://omlc.org/spectra/PhotochemCAD/html/012.html
        tmpSR101abs = importdata(fullfile('data','SR101_012-abs.txt'), '\t', 23);
        tmpSR101ems = importdata(fullfile('data','SR101_012-ems.txt'), '\t', 23);

            % combine the wavelength vectors (use resolution of OGB)            
            fluoro{2}.wavelength = (ceil(min(tmpSR101abs.data(:,1))) ...
                        : fluoro{1}.wavelengthRes : ....
                        floor(max(tmpSR101ems.data(:,1))))';
            fluoro{2}.wavelengthRes = fluoro{2}.wavelength(2) - fluoro{2}.wavelength(1);

            % Interpolate
            fluoro{2}.excitation = interp1(tmpSR101abs.data(:,1), tmpSR101abs.data(:,2), fluoro{2}.wavelength);
            fluoro{2}.emission = interp1(tmpSR101ems.data(:,1), tmpSR101ems.data(:,2), fluoro{2}.wavelength);
            fluoro{2}.name = 'SR-101';
            fluoro{2}.plotColor = [1 0 0];

    %% AUTOFLUORESCENCE
    
        % How much spectral cross-talk from autofluorescence?
    
        % Astroglial autofluorescence, e.g. Fig. 2 of Oheim et al. (2014)
        % http://dx.doi.org/10.1016/j.bbamcr.2014.03.010
        
        % NADH
        
        % Baraghis E, Devor A, Fang Q, Srinivasan VJ, Wu W, Lesage F, Ayata C, Kasischke KA, Boas DA, Sakadžić S. 2011. 
        % Two-photon microscopy of cortical NADH fluorescence intensity changes: correcting contamination from the hemodynamic response. 
        % J. Biomed. Opt 16:106003–106003–13. 
        % http://dx.doi.org/10.1117/1.3633339.
        
        % Pu Y, Sordillo LA, Alfano RR. 2015. 
        % Nonnegative constraint analysis of key fluorophores within human breast cancer using 
        % native fluorescence spectroscopy excited by selective wavelength of 300 nm. 
        % In: Vol. 9318, p. 93180V–93180V–11. 
        % http://dx.doi.org/10.1117/12.2076102.

        
        
        