function ima_lambda_fil = diskconvolution(ima_nse, hK)

    K = 2*hK +1;
    kernel = ones(K,K)/(K*K);
    [x, y] = meshgrid(-hK:hK, -hK:hK);
    kernel(x.^2 + y.^2 > hK^2) = 0;
    kernel = kernel / sum(sum(kernel));
    norm = ...
        conv2(ones(size(ima_nse)), kernel, 'same');
    ima_lambda_fil = ...
        conv2(ima_nse, kernel, 'same') ./ norm;
    ima_lambda_fil(ima_lambda_fil == 0) = ...
        min(min(ima_lambda_fil(ima_lambda_fil > 0)));