% refinednoiseest.m
%
% Refined noise estimation.
% For details, see noiseest.m
%
% Chris Schwemmer, Universität Erlangen-Nürnberg
% chris.schwemmer@cs.fau.de

function result = refinednoiseest(img, valrange)

if (nargin < 1)
    error('Invalid arguments')
end
if (nargin < 2)
    valrange = 256;
end

lowThreshold = 5;
mediumThreshold = 10;
highThreshold = 20;

pLow = 0.03;
pMedium = 0.2;
pHigh = 0.5;

% First round
p = 0.1;
sigma1 = noiseest(img, valrange, p);

% Medium noise -> no refinement
if ((sigma1 > lowThreshold) && (sigma1 <= mediumThreshold))
    result = sigma1;
    return;
end

% Second round
if (sigma1 <= lowThreshold)
    p = pLow;
elseif (sigma1 <= highThreshold)
    p = pMedium;
else
    p = pHigh;
end

sigma2 = noiseest(img, valrange, p);

if (sigma1 <= lowThreshold)
    result = min(sigma1, sigma2);
else
    result = sigma2;
end
