% example: edge-preserving smoothing

close all;

I = double(imread(fullfile('img_smoothing','cat.bmp'))) / 255; % this image is too small to fully unleash the power of Fast GF
p = I;
r = 4;
eps = 0.1^2; % try eps=0.1^2, 0.2^2, 0.4^2

for i = 1 : 20

    tic;
    q = guidedfilter(I, p, r, eps);
    t1(i) = toc;

    s = 1; % sampling ratio
    tic;
    q_sub = fastguidedfilter(I, p, r, eps, s);
    t2(i) = toc;

end
    
mean_original = mean(t1)*1000;
mean_fast = mean(t2)*1000;
disp(['Original, execution time = ', num2str(mean_original,4), ' ms'])
disp(['FAST (subsampled), execution time = ', num2str(mean_fast,4), ' ms'])
disp(['    ', num2str(mean_original/mean_fast), 'x change with sub-sampling ratio = ', num2str(s)])

figure();
imshow([I, q, q_sub, imadjust(abs(q-q_sub))], [0, 1]);
title('Input; Original; Fast; imadjust(abs(Original-Fast))')
