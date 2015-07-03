clear all

% Poisson NL means (by Charles Deledalle)
% email: deledalle@telecom-paristech.fr

%%% Load noise-free image
ima_ori = cast(imread('peppers.tif'), 'double');

%%% Apply poisson noise
Q = max(max(ima_ori)) / 20;   % reducing factor of underlying luminosity
ima_lambda = ima_ori / Q;
ima_lambda(ima_lambda == 0) = min(min(ima_lambda(ima_lambda > 0)));
ima_nse = poissrnd(ima_lambda);

%%% Parameters
hW = 10;                % search window of size (2hW+1)^2
hB = 3;                 % patches of size (2hW+1)^2
hK = 6;                 % pre-filtering with convolution by a disk
                        % of radius 2hK+1
tol = 0.001/mean2(Q);   % stopping criteria |CSURE(i) - CSURE(i-1)| < tol


%%% Pre-filtering with convolution by a disk of radius 2hK+1
ima_lambda_ma = diskconvolution(ima_nse, hK);

%%% Sure-NL Poisson
ima_lambda_pnl = poisson_nlmeans(ima_nse, ...
                                 ima_lambda_ma, ...
                                 hW, hB, ...
                                 tol);

%%% Show results
figure,
ax(1) = subplot(1, 3, 1);
plotimage(Q * ima_nse);
title(sprintf('Noisy PSNR = %f', ...
              psnr(Q*ima_nse, Q*ima_lambda, 255)));
ax(2) = subplot(1, 3, 2);
plotimage(Q * ima_lambda_ma);
title(sprintf('MA filter PSNR = %f', ...
              psnr(Q*ima_lambda_ma, Q*ima_lambda, 255)));
ax(3) = subplot(1, 3, 3);
plotimage(Q * ima_lambda_pnl);
title(sprintf('NL Poisson PSNR = %f', ...
              psnr(Q*ima_lambda_pnl, Q*ima_lambda, 255)));
linkaxes(ax);
