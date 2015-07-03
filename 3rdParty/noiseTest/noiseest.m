% noiseest.m
%
% An implementation of noise estimation according to
%
% S.-M. Yang and S.-C. Tai:
% "Fast and reliable image-noise estimation using a hybrid approach"
% Journal of Electronic Imaging 19(3), pp. 033007-1--15, 2010.
%
% The image size is assumed to be divisible by 5!
%
% Parameters:
% img        Image array
% valrange   Value range of the image type for clipped pixel identification.
%            Default: 256 (8 bit images)
% p          Percentile value for automated thresholding. Default: 0.1
%
% Chris Schwemmer, Universität Erlangen-Nürnberg
% chris.schwemmer@cs.fau.de

function result = noiseest(img, valrange, p)

if (nargin < 1)
    error('Invalid arguments')
end
if (nargin < 2)
    valrange = 256;
end
if (nargin < 3)
    p = 0.1;
end

% Filter masks
Wb = 5;
S_v = [1 2 0 -2 -1 ; 4 8 0 -8 -4 ; 6 12 0 -12 -6 ; 4 8 0 -8 -4 ; 1 2 0 -2 -1];
S_h = [1 4 6 4 1 ; 2 8 12 8 2 ; 0 0 0 0 0 ; -2 -8 -12 -8 -2 ; -1 -4 -6 -4 -1];
L_A = [1 -2 1 ; -2 4 -2 ; 1 -2 1];

sz = size(img);

if (mod(sz(1), 5) ~= 0) ||(mod(sz(2), 5) ~= 0)
    error('Image size not divisible by 5')
end

% Clipping parameters
minVal = 0.0625 * valrange;
maxVal = 0.91796875 * valrange;

% Block grid
numBlocksX = sz(2) / Wb;
numBlocksY = sz(1) / Wb;
numBlocks = numBlocksX * numBlocksY;
clipThreshold = floor(0.5 * Wb^2);

blocklist = ones(numBlocksY, numBlocksX);
G_blocks = zeros(numBlocksY, numBlocksX);

% Find non-clipped blocks and calculate homogeneity measure
bY = 0;
bX = 0;
for y = 1:Wb:sz(1)
    bY = bY + 1;
    
    for x = 1:Wb:sz(2)
        bX = bX + 1;
        
        vals = img(y:y + 4, x:x + 4);
        
        % Count clipped values
        nonclipped = (vals >= minVal) & (vals <= maxVal);
        if (sum(nonclipped(:)) <= clipThreshold)
            blocklist(bY, bX) = 0;
            continue;
        end
        
        % Calculate gradient magnitude
        G_v = S_v .* vals;
        G_h = S_h .* vals;
        G_blocks(bY, bX) = abs(sum(G_v(:))) + abs(sum(G_h(:)));
    end
    bX = 0;
end

% Determine automatic threshold
grange = max(G_blocks(:)) - min(G_blocks(:)) + 1;
[h,hloc] = hist(G_blocks(blocklist > 0), grange);
hloc = ceil(hloc + 0.5);
h = cumsum(h);

% This value is calculated differently to the original publication,
% because the largest entry in the cumulative histogram is nBlocks,
% the number of non-clipped blocks, and not the number of all
% possible blocks (width * height) / (Wb * Wb).
k = floor(p * sum(blocklist(:)));
G_th = hloc(find(h >= k, 1));

% Identify non-homogeneous blocks
for b = 1:numBlocks
    if (blocklist(b) > 0 && G_blocks(b) >= G_th)
        blocklist(b) = 0;
    end
end

% Normalisation factor
Nh = sum(blocklist(:)) * Wb^2;
fac = sqrt(pi / 2) / (6 * Nh);
sigma = 0;

% Calculate laplacian of the original image
tmp = conv2(img, L_A, 'valid');
l = zeros(sz);
l(2:end-1, 2:end-1) = tmp;

% Evaluate noise measure on remaining blocks
bY = 0;
bX = 0;
for y = 1:Wb:sz(1)
    bY = bY + 1;
    
    for x = 1:Wb:sz(2)
        bX = bX + 1;
        
        if (blocklist(bY, bX) == 0)
            continue;
        end
        
        vals = l(y:y + 4, x:x + 4);
        sigma = sigma + sum(abs(vals(:)));
    end
    bX = 0;
end

result = fac * sigma;
