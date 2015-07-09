function lightSources = import_lightSources(wavelength, peakWavelength, FWHM)

    % We are using the tunable MaiTai, SpectraPhysics laser, we can
    % synthetize the spectral power distribution assuming that the shape is
    % Gaussian (check later how valid is this assumption, and whether
    % half-bandwidth (hbw)for example changes as a function of peak wavelength?)   
    SPD = estimate_laserSPDasGaussian(wavelength, peakWavelength, FWHM);
    
    ind = 1;
    lightSources{ind}.name = 'Laser';
    lightSources{ind}.description = ['MaiTai_', num2str(peakWavelength), '_nm_hbw', num2str(FWHM), 'nm'];
    lightSources{ind}.wavelength = wavelength;
    lightSources{ind}.irradiance = SPD;
    lightSources{ind}.plotColor = [0 0 0];
    
        % for 2-PM excitation spectra, see e.g.
        
            % OGB, SR-101, Rhodamines, Alexas etc.
            % Mütze J, Iyer V, Macklin JJ, Colonell J, Karsh B, Petrášek Z, Schwille P, Looger LL, Lavis LD, Harris TD. 2012. 
            % Excitation Spectra and Brightness Optimization of Two-Photon Excited Probes. Biophys J 102:934–944. 
            % http://dx.doi.org/10.1016/j.bpj.2011.12.056.            
            
            % Fluorescent Probes for Two-Photon Microscopy—Note 1.5
            % https://www.lifetechnologies.com/ca/en/home/references/molecular-probes-the-handbook/technical-notes-and-product-highlights/fluorescent-probes-for-two-photon-microscopy.html
            
            % No excitation spectrum, but of an interest probably still
            
                % Cheng L-C, Horton NG, Wang K, Chen S-J, Xu C. 2014. 
                % Measurements of multiphoton action cross sections for multiphoton microscopy. 
                % Biomedical Optics Express 5:3427. 
                % http://dx.doi.org/10.1364/BOE.5.003427.



    
    ind = 2;
    % quick'n'dirty 1-photon equivalent, same shape but divide the
    % wavelength vector by 2. In practice probably a bit useless this fix.
    % We can just use the original laser SPD and try to find 2-PM
    % excitation spectra for our probes
    
    % In practice, the absorption spectrum should get broader with 2-photon
    % excitation compared to 1-photon excitation, but how much?
    lightSources{ind}.name = '1PMequivalent';
    lightSources{ind}.description = ['MaiTai_1PMequiv', num2str(peakWavelength/2), '_nm_hbw', num2str(FWHM), 'nm'];
    lightSources{ind}.wavelength = wavelength / 2;
    lightSources{ind}.irradiance = SPD; % check the shape later, and hbw when halving the peak
    lightSources{ind}.plotColor = [0 0 0]; % if you want to get fancy, 
                                           % you could pick the color depending on the peak wavelength here
    
    
    %% Subfunctions    
    function SPD = estimate_laserSPDasGaussian(wavelength, peakWavelength, FWHM)
        
        % "Fork" from "lightLab", monochromaticLightAsGaussian.m
        
        % sigma / deviation of the gaussian is defined as a function of FWHM
        sigma = (FWHM*2) / 2.355; % e.g., http://cp.literature.agilent.com/litweb/pdf/5980-0746E.pdf    
      
        f = gauss_distribution(wavelength, peakWavelength, sigma);
        SPD = f / max(f); % normalize
        
    function f = gauss_distribution(x, mu, s)
   
        % x         x vector (i.e. wavelength)
        % mu        mean / peak nm
        % sigma     standard deviation        
        p1 = -.5 * ((x - mu)/s) .^ 2;
        p2 = (s * sqrt(2*pi));
        f = exp(p1) ./ p2;  
        