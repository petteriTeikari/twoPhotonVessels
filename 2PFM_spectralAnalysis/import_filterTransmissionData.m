function filters = import_filterTransmissionData()

    % extracted with Matlab "extractDataFromGraph" graphically from the plotted curves there:
    % https://pixel.univ-rennes1.fr/pdf/Light%20Pathway.pdf (pg. 3)
    % Transmission curves | OLYMPUS FV1000MPE
    % the grid was removed in GIMP with Dilate+Erode

    noOfHeaders = 1;
    delim = '\t'; % tab-delimited

    % DM485
    % FV10MP-MV/G

        i = 1;
        filters.emissionDichroic{i}.name = 'DM485';
            fileName = 'fv1000mpe_olympus_dm485_0-100%transmittance_400-700nm_DM_interpData.txt';
            tmp = importdata(fullfile('data',fileName), delim, noOfHeaders);
            filters.emissionDichroic{i}.wavelength = tmp.data(:,1);
            filters.emissionDichroic{i}.transmittance = tmp.data(:,2);
            filters.emissionDichroic{i}.plotColor = 'b';

        j = 1;
        filters.emissionFilter{j}.name = 'BA495-540HQ';
            fileName = 'fv1000mpe_olympus_dm485_0-100%transmittance_400-700nm_BA495-540HQ_interpData.txt';
            tmp = importdata(fullfile('data',fileName), delim, noOfHeaders);
            filters.emissionFilter{j}.wavelength = tmp.data(:,1);
            filters.emissionFilter{j}.transmittance = tmp.data(:,2);
            filters.emissionFilter{j}.plotColor = [0 1 1];

        j = j + 1;
        filters.emissionFilter{j}.name = 'BA420-460';
            fileName = 'fv1000mpe_olympus_dm485_0-100%transmittance_400-700nm_BA420-460_interpData.txt';
            tmp = importdata(fullfile('data',fileName), delim, noOfHeaders);
            filters.emissionFilter{j}.wavelength = tmp.data(:,1);
            filters.emissionFilter{j}.transmittance = tmp.data(:,2);
            filters.emissionFilter{j}.plotColor = [0.75 0 0.75];


    % DM505
    % FV10MP-MC/Y

        i = i + 1;
        filters.emissionDichroic{i}.name = 'DM505';
            fileName = 'fv1000mpe_olympus_dm505_0-100%transmittance_400-700nm_DM_interpData.txt';
            tmp = importdata(fullfile('data',fileName), delim, noOfHeaders);
            filters.emissionDichroic{i}.wavelength = tmp.data(:,1);
            filters.emissionDichroic{i}.transmittance = tmp.data(:,2);
            filters.emissionDichroic{i}.plotColor = 'g';

        j = j + 1;
        filters.emissionFilter{j}.name = 'BA515-560';
            fileName = 'fv1000mpe_olympus_dm505_0-100%transmittance_400-700nm_BA515-560_interpData.txt';
            tmp = importdata(fullfile('data',fileName), delim, noOfHeaders);
            filters.emissionFilter{j}.wavelength = tmp.data(:,1);
            filters.emissionFilter{j}.transmittance = tmp.data(:,2);
            filters.emissionFilter{j}.plotColor = [0 1 0];

        j = j + 1;
        filters.emissionFilter{j}.name = 'BA460-510';
            fileName = 'fv1000mpe_olympus_dm505_0-100%transmittance_400-700nm_BA460-510_interpData.txt';
            tmp = importdata(fullfile('data',fileName), delim, noOfHeaders);
            filters.emissionFilter{j}.wavelength = tmp.data(:,1);
            filters.emissionFilter{j}.transmittance = tmp.data(:,2);
            filters.emissionFilter{j}.plotColor = [0 0 1];


    % DM570
    % FV10MP-MG/R

        i = i + 1;
        filters.emissionDichroic{i}.name = 'DM570';
            fileName = 'fv1000mpe_olympus_dm570_0-100%transmittance_400-700nm_DM_interpData.txt';
            tmp = importdata(fullfile('data',fileName), delim, noOfHeaders);
            filters.emissionDichroic{i}.wavelength = tmp.data(:,1);
            filters.emissionDichroic{i}.transmittance = tmp.data(:,2);
            filters.emissionDichroic{i}.plotColor = 'r';

        j = j + 1;
        filters.emissionFilter{j}.name = 'BA570-625HQ';
            % replicate plot of of "BA495-540HQ"
            fileName = 'fv1000mpe_olympus_dm570_0-100%transmittance_400-700nm_BA570-625HQ_interpData.txt';
            tmp = importdata(fullfile('data',fileName), delim, noOfHeaders);
            filters.emissionFilter{j}.wavelength = tmp.data(:,1);
            filters.emissionFilter{j}.transmittance = tmp.data(:,2);
            filters.emissionFilter{j}.plotColor = [1 0 0];


    % Now the values were in percent, easier to scale to 0:1 for
    % following computations
    for i = 1 : length(filters.emissionDichroic)
        filters.emissionDichroic{i}.transmittance = filters.emissionDichroic{i}.transmittance / ...
            max(filters.emissionDichroic{i}.transmittance);
    end

    for j = 1 : length(filters.emissionFilter)
        filters.emissionFilter{j}.transmittance = filters.emissionFilter{j}.transmittance / ...
            max(filters.emissionFilter{j}.transmittance);
    end