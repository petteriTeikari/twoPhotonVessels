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
    
    ind = 2;
    % quick'n'dirty 1-photon equivalent, same shape but divide the
    % wavelength vector by 2
    
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
        