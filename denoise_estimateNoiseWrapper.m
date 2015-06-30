function [sigma, fitparams, p, q] = denoise_estimateNoiseWrapper(im, options)
    
    % IMPLEMENTATION 1

        % S. M. Yang and S. C. Tai: "Fast and reliable image-noise estimation using a hybrid approach". Journal of Electronic Imaging 19(3), pp. 033007-1–15, 2010. 
        % http://dx.doi.org/10.1117/1.3476329
        % MATLAB CODE: http://www5.informatik.uni-erlangen.de/fileadmin/Persons/SchwemmerChris/noiseest_matlab.zip

        % the input image needs to be divisible by 5 to work with the noise
        % test       
        imTest = reshapeImageForNoiseTest(im, options);

        valrange = 4096; % 12-bit input
        p = 0.1; % 0.1 default value
        sigma.Noise_test = noiseest(imTest, valrange, p);
        sigma.Noise_test_refined = refinednoiseest(imTest, valrange);

    % IMPLEMENTATION 2

        % To estimate poisson noise, see e.g. 
        % http://stackoverflow.com/questions/18813068/estimate-poisson-noise-in-matlab
        % http://www.numerical-tours.com/matlab/denoisingwav_5_data_dependent/
        % http://www.cs.tut.fi/~foi/sensornoise.html

            % Foi, A., S. Alenius, V. Katkovnik, and K. Egiazarian, 
            % "Noise measurement for raw-data of digital imaging sensors by automatic segmentation of non-uniform targets", 
            % IEEE Sensors Journal, vol. 7, no. 10, pp. 1456-1461, October 2007.
            % ClipPoisGaus_stdEst2D
            % Poissonian-Gaussian noise estimation for single-image raw-data
            % http://www.cs.tut.fi/~foi/ClipPoisGaus_stdEst2D_v232.zip

        % ALGORITHM MAIN PARAMETERS
        %                                %  the standard-deviation function has the form \sigma=(a*y^polyorder+b*y^(polyorder-1)+c*y^(polyorder-2)+...).^(variance_power/2), where y is the unclipped noise-free signal.
        polyorder=1;                     %  order of the polynomial model to be estimated [default 1, i.e. affine/linear]  Note: a large order results in overfitting and difficult and slow convergence of the ML optimization.
        variance_power=1;                %  power of the variance [default 1, i.e. affine/linear variance]
        %                                %   The usual Poissonian-Gaussian model has the form \sigma=sqrt(a*y+b), which follows from setting polyorder=1 and variance_power=1.

        median_est=1;                    %  0: sample standard deviation;  1: MAD   (1)
        LS_median_size=1;                %  size of median filter for outlier removal in LS fitting (enhances robustness for initialization of ML) 0: disabled  [default 1 = auto]
        tau_threshold_initial=1;         %  (initial) scaling factor for the tau threshold used to define the set of smoothness   [default 1]

        % prior_density=0; %(SET BELOW)  %  type of prior density to use for ML    (0)
        %                                %    0: zero_infty uniform prior density (R+);  (default, use this for raw-data)
        %                                %    1: zero_one uniform prior density [0,1];
        %                                %    2: -infty_infty uniform prior density (R);

        level_set_density_factor=1;      %   density of the slices in for the expectations   [default 1 ( = 600 slices)]   (if image is really small it should be reduced, say, to 0.5 or less)
        integral_resolution_factor=1;    %   integral resolution (sampling) for the finite sums used for evaluatiing the ML-integral   [default 1]
        speed_factor=1;                  %   factor controlling simultaneously density and integral resolution factors  [default 1] (use large number, e.g. 1000, for very fast algorithm)

        text_verbosity=1;                %  how much info to print to screen 0: none, 1: little, 2: a lot
        figure_verbosity=0;              %  show/keep figures?        [default 3]
        %                                     0: no figures
        %                                     1: only figure with final ML result is shown and kept
        %                                     2: few figures are shown during processing but none kept
        %                                     3: few figures are shown but only figure with final ML result is kept
        %                                     4: show and keep all figures
        lambda=1;                        %  [0,1]:  models the data distribution as a mixture of Gaussian and Cauchy PDFs (each with scale parameter sigma), with mixture parameters lambda and (1-lambda): p(x) = (1-lambda)*N(x,y,sigma^2)+lambda*Cauchy(x,y,sigma)     [default 1]
        auto_lambda=1;                   %  include the mixture parameter lambda in the maximization of the likelihood   [default 1]
        %                                     0: lambda is fixed equal to its input value and not optimized
        %                                     1: lambda is optimized (the input value of lambda is used as initial value for the optimization)


        clipping_below  = 1;  %%%% on off  %% RAW-DATA IS ASSUMED TO BE CLIPPED FROM ABOVE AND BELOW
        clipping_above  = 1;  %%%% on off
        prior_density   = 0;

        % CALL ESTIMATION FUNCTION WITH GIVEN OBSERVATION AND PARAMETERS
        z = im;
        fitparams = function_ClipPoisGaus_stdEst2D(z,polyorder,variance_power,clipping_below,clipping_above, ...
                                                prior_density,median_est,LS_median_size,tau_threshold_initial,...
                                                level_set_density_factor,integral_resolution_factor,speed_factor,...
                                                text_verbosity,figure_verbosity,lambda,auto_lambda);

        if polyorder==1&&variance_power==1
            q = sqrt(fitparams(1));
            p = -fitparams(2)/fitparams(1);
        end