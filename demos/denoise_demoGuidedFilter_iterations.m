% Testing whether the quality improves if the filter is iterated
function denoise_demoGuidedFilter_iterations() 
    
    %% Import test data
    load(fullfile('..', 'debugMATs', 'testSlices.mat'))
        % z-slices of 9-11 from first time point of:
        % "CP-20150323-TR70-mouse2-1-son.oib" from Charissa
        
        % we use just one slice for testing
        sliceIndex = 2;
        im = testSlices(:,:,sliceIndex);
        
        % parameters
        computeSlowOnes = true;
            % trilateral filter
            % NL-means for Poisson
        
    %% EVALUATE INPUT NOISE
    
        % S. M. Yang and S. C. Tai: "Fast and reliable image-noise estimation using a hybrid approach". Journal of Electronic Imaging 19(3), pp. 033007-1–15, 2010. 
        % http://dx.doi.org/10.1117/1.3476329
        % MATLAB CODE: http://www5.informatik.uni-erlangen.de/fileadmin/Persons/SchwemmerChris/noiseest_matlab.zip
                
        % the input image needs to be divisible by 5 to work with the noise
        % test
        options = [];       
        imTest = reshapeImageForNoiseTest(im, options);
        
        valrange = 4096; % 12-bit input
        p = 0.1; % 0.1 default value
        sigma.Noise_test = noiseest(imTest, valrange, p);
        sigma.Noise_test_refined = refinednoiseest(imTest, valrange);
        
        
    %% ALGORITHMS
    
        ind = 1;
        d_cell{ind} = im;
        timing(ind) = 0;
        title1st{ind} = 'Input';
        % mse(ind) = 0; snr(ind) = 0; psnr(ind) = 0;
    
        
        %% GUIDED FILTER
        
            disp('Guided Filter')
            [fig, sp, imH, pH, tit] = denoise_initIterFigure(d_cell{ind}, title1st{ind}, sigma, options);
            
                
            % parameters
            % see e.g. Fig 2 of http://dx.doi.org/10.1109/TPAMI.2012.213
            epsilon = 2.^2;
            win_size = 4;
            noOfIter = 60;
            s = 1; % 1, no subsampling
            
            tic;
            for i = 1 : noOfIter
                
                ind = ind + 1;
                
                guide = im;
                d_cell{ind} = fastguidedfilter(im, guide, epsilon, win_size, s);
                
                % IMAGE QUALITY
                peakVal = 2^12 - 1; % we have 12-bit microscopy images
                x(i) = i;
                [mse(i), snr(i), psnr(i)] = visualize_imageQuality(im, d_cell{ind}, peakVal);
                
                % Between start and the very end
                imDiff{ind} = abs(d_cell{1} - d_cell{ind});  
                
                % Between successive frames (mainly for debugging, and
                % seeing incremental changes)
                successiveDiff{ind} = abs(d_cell{ind}-d_cell{ind-1});
                
                % update the images now
                im = d_cell{ind};
                
                % update plot
                updatePlot(sp, pH, imH, fig, tit, d_cell, imDiff, successiveDiff, ind, i, x, mse, snr, psnr, epsilon, win_size)
                  
            end            
            timing = toc / noOfIter;
            
            axes(sp(end))
            titStr = sprintf('%s\n%s', 'Quality', ['t = ', num2str(1000*timing,4), ' ms/iter']);
            legend('MSE', 'SNR', 'PSNR', 'Location', 'Best')
                legend('boxoff')
            title(titStr)
            
            
            % http://www.mathworks.com/matlabcentral/fileexchange/33143-guided-filter
            % a bit like bilateral filter, but behaves better on edges

            % implemented also on recent version of Matlab by default:
            % http://www.mathworks.com/help/images/ref/imguidedfilter.html

            % Kaiming He, Jian Sun, Xiaou Tang, Guided Image Filtering. 
            % IEEE Transactions on Pattern Analysis and Machine Intelligence, Volume 35, Issue 6, pp. 1397-1409, June 2013
            % http://dx.doi.org/10.1109/TPAMI.2012.213

                % See also:
                % "MRT Letter: Guided filtering of image focus volume for
                % 3D shape recovery of microscopic objects"
                % http://dx.doi.org/10.1002/jemt.22438
    
        nameOut = ['guidedDenoisingComparison_eps', num2str(epsilon), '_w', num2str(win_size), '.png'];
        export_fig(fullfile('figuresOut', nameOut), '-r300', '-a1')
    
        
        
    function [fig, sp, imH, pH, tit] = denoise_initIterFigure(imIn, title1st, sigma, options)
        
            close all
            fig = figure;
                scrsz = get(0,'ScreenSize');
                set(fig,  'Position', [0.025*scrsz(3) 0.3745*scrsz(4) 0.49*scrsz(3) 0.6*scrsz(4)])
                rows = 2; cols = 3;
                
                iInd = 1;
                sp(iInd) = subplot(rows,cols,iInd);
                    imH(iInd) = imshow(imIn, []); tit(iInd) = title('Input');
        
                iInd = iInd  + 1;
                sp(iInd) = subplot(rows,cols,iInd );
                    imH(iInd) = imshow(zeros(size(imIn)), []); tit(iInd) = title('Denoised');

                iInd = iInd  + 1;
                sp(iInd) = subplot(rows,cols,iInd );
                    imH(iInd) = imshow(zeros(size(imIn))); tit(iInd) = title('Diff (In-Out)');
                    
                iInd = iInd  + 1;
                sp(iInd) = subplot(rows,cols,iInd );
                    imH(iInd) = imshow(zeros(size(imIn))); tit(iInd) = title('Diff (Successive)');

                iInd = iInd  + 1;
                sp(iInd) = subplot(rows,cols,iInd );
                    imH(iInd) = imshow(zeros(size(imIn))); tit(iInd) = title('Diff (In-Out - Succ.');
                    
                iInd = iInd  + 1;
                sp(iInd) = subplot(rows,cols,[iInd]);
                    hold on
                    pH(1,:) = plot(NaN, NaN, 'ro', NaN, NaN, 'go', NaN, NaN, 'bo');
                    tit(iInd) = title('Quality');
                    set(pH, 'MarkerSize', 3)
                    
                drawnow
         
    function updatePlot(sp, pH, imH, fig, tit, d_cell, imDiff, successiveDiff, ind, i, x, mse, snr, psnr, epsilon, win_size)

        % http://www.mathworks.com/matlabcentral/answers/65521-make-imshow-more-efficent
        
            % Directly writing to cdata will be the fastest way but like you found out, 
            % it does not scale the intensity for each image individually. 
            % You would have to do that in advance and use the same intensity scale all the time. 
            % If you do want to adjust it for each image, then you're back to using a function 
            % that does that like imagesc and imshow and unfortunately you're slower again.

        axes(sp(2)); imshow(d_cell{ind}, [])
            axes(sp(2)); 
            titStr = sprintf('%s\n%s', ['Denoised, iter = ', num2str(i)], ...
                              ['\epsilon = ', num2str(epsilon), ', w = ', num2str(win_size)]);
            % set(tit(2), 'String', titStr)
            title(titStr)
            % set(imH(2), 'CData', d_cell{ind});
            
                % correct the update (with set()) to work correctly with
                % display range at some point
        
        axes(sp(3)); imshow(imDiff{ind}, []); 
            titStr = sprintf('%s\n%s', 'In - Out', ...
                ['Min = ', num2str(min(imDiff{ind}(:)),4), ', Max = ', num2str(max(imDiff{ind}(:)),4)]);
            title(titStr)
            % set(imH(3), 'CData', imDiff{ind});
        
        axes(sp(4)); title('diff(successive frames)')
            % set(imH(4), 'CData', successiveDiff{ind});

        axes(sp(5)); imshow(imDiff{ind} - successiveDiff{ind}, []); title('Succ - |In-Out|')
            % set(imH(5), 'CData', successiveDiff{ind});
        
        set(pH, 'XData', x)
            set(pH(1), 'YData', mse); set(pH(2), 'YData', snr); set(pH(3), 'YData', psnr)
            
            drawnow