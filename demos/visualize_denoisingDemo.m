function visualize_denoisingDemo(d_cell, timing, title1st, sigma)
        
        % save(fullfile('debugMATs', 'resultsSoFarGuided.mat'))
        warning on
        whos
        
        im = d_cell{1};
        
        % define the data to be plotted
        noOfDenoisedImages = length(d_cell) - 1;
            
        % define subplot
        rows = 4; cols = noOfDenoisedImages + 1;
            zoomWindow_x = 11:150; zoomWindow_y = 12:141;
            % zoomWindow_x = 1:size(im,1); zoomWindow_y = 1:size(im,2);
                
        % define figure
        close all
        fig = figure;
            scrsz = get(0,'ScreenSize');
            set(fig,  'Position', [0.05*scrsz(3) 0.0245*scrsz(4) 0.94*scrsz(3) 0.95*scrsz(4)])
            
            % Go through the denoised images
            for ind = 1 : noOfDenoisedImages + 1
               
                % easier variable name
                d = d_cell{ind};                
                
                % denoised
                sp(ind) = subplot(rows,cols,ind);
                imshow(d, [])
                titStr = sprintf('%s\n %s\n %s', title1st{ind}, ...
                                                       [num2str(timing(ind),3), ' sec'], ...
                                                       ['mse = ' num2str(mse(im,d), 2)]);
                tit(ind) = title(titStr);

                    
                % difference (normalized)
                j = ind + cols;
                sp(j) = subplot(rows,cols,j);
                imshow(abs(im-d), [])
                    
                peakVal = 2^12 - 1; % we have 12-bit microscopy images
                resPSNR(ind) = psnr(d, im, 4095);  
                if ind == 1
                    titStr = sprintf('%s\n %s\n', ['\sigma_t_e_s_t = ', num2str(sigma.Noise_test,4)], ...
                                                  ['\sigma_t_e_s_t_R_e_f_i_n_e_d = ', num2str(sigma.Noise_test_refined,4)]);
                else
                    titStr = sprintf('%s\n %s\n', ['psnr = ', num2str(resPSNR(ind),4), ' dB'], ...
                                                 ['snr = ', num2str(snr(im,d),4), ' dB']);
                end
                tit(j) = title(titStr);
                
                % difference (zoom)
                jk = j + cols;
                sp(j) = subplot(rows,cols,jk);
                    diff = abs(im-d);
                    imshow(diff(zoomWindow_x, zoomWindow_y),[])                    
                    limits = [min(diff(:)) max(diff(:))];
                    tit(jk) = title(num2str(limits,3));
                          
                % Zoom
                k = jk + cols;
                sp(j) = subplot(rows,cols,k);
                imshow(d(zoomWindow_x, zoomWindow_y), [])                    
                tit(j) = title('Zoomed View');
                    
            end
            
            % export_fig(fullfile('figuresOut', 'denoiseComparison.png'), '-r300', '-a1')

%% QUALITY METRICS as subfunctions

    function mse_out = mse(a,b) 
        mse_out = (a(:)-b(:))'*(a(:)-b(:))/numel(a);
        
    function snr_out = snr(clean,noisy) 
        snr_out = 20*log10(mean(noisy(:))/mean(abs(clean(:)-noisy(:))));
    
            
    % Peak SNR
    function res = psnr(hat, star, std)

        if nargin < 3
            std = std2(star);
        end

        res = 10 * ...
              log(std^2 / mean2((hat - star).^2)) ...
              / log(10);
          
  % Image Enhancement Factor?
      % IEF = Image Enhancement Factor
      % http://www.mathworks.com/matlabcentral/fileexchange/46561-bilateral-filter
