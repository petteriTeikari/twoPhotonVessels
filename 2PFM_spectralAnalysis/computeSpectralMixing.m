function results = computeSpectralMixing(excitationMatrix, fluoroEmissionMatrix, fluoroExcitationMatrix, filterMatrix, Xijk, Eijk, options)
    
    results = [];

    % see for example

        % Linear spectral unmixing of Fluorescence spectra
        % Asked by Thomas on 16 Dec 2014
        % http://www.mathworks.com/matlabcentral/answers/166822-linear-spectral-unmixing-of-fluorescence-spectra
        
        % Spectral Bleed-Through Artifacts in Confocal Microscopy
        % http://www.olympusconfocal.com/theory/bleedthrough.html

        % Zimmermann T, Marrison J, Hogg K, O’Toole P. 2014. 
        % Clearing Up the Signal: Spectral Imaging and Linear Unmixing in Fluorescence Microscopy
        % Springer. In: Paddock, SW, editor. Springer New York. Methods in Molecular Biology 1075. 
        % http://dx.doi.org/10.1007/978-1-60761-847-8_5

        % Macháň R, Kapusta P, Hof M. 2014. 
        % Statistical filtering in fluorescence microscopy and fluorescence correlation spectroscopy. 
        % Anal Bioanal Chem 406:4797–4813. 
        % http://dx.doi.org/10.1007/s00216-014-7892-7
        
        % Dao L, Lucotte B, Glancy B, Chang L-C, Hsu L-Y, Balaban R s. 2014. 
        % Use of independent component analysis to improve signal-to-noise ratio in multi-probe 
        % fluorescence microscopy. Journal of Microscopy 256:133–144. 
        % http://dx.doi.org/10.1111/jmi.12167

        % Ikoma H, Heshmat B, Wetzstein G, Raskar R. 2014. 
        % Attenuation-corrected fluorescence spectra unmixing for spectroscopy and microscopy. 
        % Optics Express 22:19469. 
        % https://dx.doi.org/10.1364/OE.22.019469


    % GENERAL

        % Unmixing of hyper/multispectral data
        % https://en.wikipedia.org/wiki/Imaging_spectroscopy#Unmixing

        % Spectral method for mixture models 
        % https://en.wikipedia.org/wiki/Mixture_model#Spectral_method
        

    % Outside fluorescent microscopy

        % Nieves JL, Valero EM, Hernández-Andrés J, Romero J. 2007. 
        % Recovering fluorescent spectra with an RGB digital camera and color filters 
        % using different matrix factorizations. 
        % Appl. Opt. 46:4144–4154. 
        % http://dx.doi.org/10.1364/AO.46.004144

        % Elvidge CD, Keith DM, Tuttle BT, Baugh KE. 2010. 
        % Spectral Identification of Lighting Type and Character. 
        % Sensors 10:3961–3988. 
        % http://dx.doi.org/10.3390/s100403961

        % Peyvandi S, Amirshahi SH. 2011. 
        % Generalized spectral decomposition: a theory and practice to spectral reconstruction. 
        % J. Opt. Soc. Am. A 28:1545–1553. http://dx.doi.org/10.1364/JOSAA.28.001545
        
        
    % MATLAB
    
        % MATLAB Hyperspectral Toolbox
        % https://github.com/isaacgerg/matlabHyperspectralToolbox
        