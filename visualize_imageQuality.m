function [mse_out, snr_out, psnr_out] = visualize_imageQuality(im, imFiltered, peakVal)

    % MSE
    mse_out = (im(:)-imFiltered(:))'*(im(:)-imFiltered(:))/numel(im);
        
    % SNR
    snr_out = 20*log10(mean(im(:))/mean(abs(imFiltered(:)-im(:))));
    
            
    % Peak SNR
    psnr_out = 10 * ...
              log(peakVal^2 / mean2((imFiltered - im).^2)) ...
              / log(10);
          
    % Image Enhancement Factor?
      % IEF = Image Enhancement Factor
      % http://www.mathworks.com/matlabcentral/fileexchange/46561-bilateral-filter
