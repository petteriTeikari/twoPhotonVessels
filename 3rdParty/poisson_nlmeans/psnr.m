function res = psnr(hat, star, std)

    if nargin < 3
        std = std2(star);
    end

    res = 10 * ...
          log(std^2 / mean2((hat - star).^2)) ...
          / log(10);

end
