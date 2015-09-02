function [y, y_sigma, transformLimits] = denoise_anscombeTransform(im, direction, scaleRange, transformLimits)

    % Taken from "Poisson_denoising_Anscombe_exact_unbiased_inverse.m"
    % http://www.cs.tut.fi/~foi/invansc/

    % References:
    % [1] M. Mäkitalo and A. Foi, "On the inversion of the Anscombe transformation in low-count Poisson image denoising", Proc. Int. Workshop on Local and Non-Local Approx. in Image Process., LNLA 2009, Tuusula, Finland, pp. 26-32, August 2009. doi:10.1109/LNLA.2009.5278406
    % [2] M. Mäkitalo and A. Foi, "Optimal inversion of the Anscombe transformation in low-count Poisson image denoising", IEEE Trans. Image Process., vol. 20, no. 1, pp. 99-109, January 2011. doi:10.1109/TIP.2010.2056693
    % [3] F.J. Anscombe, "The transformation of Poisson, binomial and negative-binomial data", Biometrika, vol. 35, no. 3/4, pp. 246-254, Dec. 1948.
    
    if strcmp(direction, 'forward')
        
        %% Apply Anscombe variance-stabilizing transformation        
        y = Anscombe_forward(im);  % Apply Anscombe variance-stabilizing transformation [3]
        y_sigma = 1;   %% this is the standard deviation assumed for the transformed data
    
        %% Scale the image (e.g. BM3D processes inputs in [0,1] range)  (these are affine transformations)
        maxtransformed = max(y(:));   %% first put data into [0,1] ...
        mintransformed = 2*sqrt(0+3/8); % min(transformed(:));
        y = (y-mintransformed) / (maxtransformed-mintransformed);
        transformLimits = [mintransformed maxtransformed];
        y_sigma = y_sigma / (maxtransformed-mintransformed);
        
        scale_shift = (1-scaleRange)/2;
        y = y*scaleRange + scale_shift;
        y_sigma = y_sigma*scaleRange;
        
    elseif strcmp(direction, 'inverse')
        
        % "Re-compute"
        scale_shift = (1-scaleRange)/2;
        mintransformed = transformLimits(1); %% first put data into [0,1] ...
        maxtransformed = transformLimits(2); % min(transformed(:));       
        
        %% Invert scaling back to the initial VST range (these are affine transformations)  
        % one = [min(im(:)) max(im(:))]
        D = (im -scale_shift) / scaleRange;
        % two = [min(D(:)) max(D(:))]
        D = D * (maxtransformed-mintransformed) + mintransformed;
        % three = [min(D(:)) max(D(:))]
        
        %% Inversion of the variance-stabilizing transformation
        disp(' .. exact unbiased inverse')
        y = Anscombe_inverse_exact_unbiased(D);  % apply exact unbiased inverse of the Anscombe variance-stabilizing transformation
        
        y_sigma = [];
        transformLimits = [];
        
        %{
        for slice = 1 : size(D,3)
            y(:,:,slice) = Anscombe_inverse_exact_unbiased(D(:,:,slice));  % apply exact unbiased inverse of the Anscombe variance-stabilizing transformation
        end
        %}
        
        
        % %  The exact unbiased inverse provides superior results than those conventionally obtained using the asymptotically unbiased inverse (D/2).^2 - 1/8
        % disp(' .. asymptotic unbiased inverse')
        % y_hat=Anscombe_inverse_asympt_unbiased(D);  % apply asymptotically unbiased inverse of the Anscombe variance-stabilizing transformation        
        
    end