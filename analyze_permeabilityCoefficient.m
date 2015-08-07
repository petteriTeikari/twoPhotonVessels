function P = analyze_permeabilityCoefficient(intensityStack, segmentationMask, options)

    disp(' - Compute permeability coefficient (dummy)')
    P = [];
    % whos
    
    for t = 1 : length(options.tP)
        extraVascularIntensity{options.tP(t)} = intensityStack{options.tP(t)};
            extraVascularIntensity{options.tP(t)}(segmentationMask{options.tP(t)}) = 0;
        intraVascularIntensity{options.tP(t)} = intensityStack{options.tP(t)}; 
            intraVascularIntensity{options.tP(t)}(segmentationMask{options.tP(t)}) = 1;
    end

    % see pg. 244 of 
    % Burgess A, Nhan T, Moffatt C, Klibanov AL, Hynynen K. 2014. 
    % Analysis of focused ultrasound-induced blood–brain barrier permeability 
    % in a mouse model of Alzheimer’s disease using two-photon microscopy. 
    % Journal of Controlled Release 192:243–248. 
    % http://dx.doi.org/10.1016/j.jconrel.2014.07.051

    