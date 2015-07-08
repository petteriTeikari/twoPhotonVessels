function fluoro = import_fluorophoreData()

        % OGB
        % https://www.lifetechnologies.com/order/catalog/product/O6807
        tmpOGB = importdata(fullfile('data','Oregon Green 488 BAPTA.csv'), ',', 1);
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
