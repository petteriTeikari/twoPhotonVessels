function visualize_denoising(imageIn, denoised, stackIndex, timeExecDenoising, fileOutName, t, ch, path, options)

    % Define quality metrics (short inline fucntions)
    mse = @(a,b) (a(:)-b(:))'*(a(:)-b(:))/numel(a);
    snr = @(clean,noisy) 20*log10(mean(noisy(:))/mean(abs(clean(:)-noisy(:))));
        
    scrsz = get(0,'ScreenSize'); % get screen size for plotting
    fig = figure('Color','w');
        set(fig,  'Position', [0.3*scrsz(3) 0.045*scrsz(4) 0.670*scrsz(3) 0.90*scrsz(4)])
        rows = 2;
        cols = 3;

        try
            im = double(imageIn(:,:,stackIndex));
        catch err            
            if strcmp(err.message, 'Index exceeds matrix dimensions.')
                stackIndex = 1;
                im = double(imageIn(:,:,stackIndex));
                warning('stackIndex manually set to 1 as it exceeded matrix size')
            else
                err.identifier
                err.message
                stackIndex = 1;
                im = double(imageIn(:,:,stackIndex));
                warning('some other error')
                
            end
        end
        im_de = double(denoised(:,:,stackIndex));

        import_checkQuality(im, path, options);
        import_checkQuality(im_de, path, options);

        i = 1;
        sp(i) = subplot(rows,cols,i);
            imshow(uint16(im), 'DisplayRange', [0 4095])
            title(['INPUT, slice = ', num2str(stackIndex)])
            colorbar

        i = i+1;
            sp(i) = subplot(rows,cols,i);
            imshow(uint16(max(imageIn,[],3)), 'DisplayRange', [0 4095])
            title('INPUT (MIP)')
            colorbar
            
        i = i+1;
        sp(i) = subplot(rows,cols,i);
            imshow(uint16(abs(im_de-im)), 'DisplayRange', [0 4095])
            title(['Denoised Noise Comp., t_e_x_e_c=', num2str(timeExecDenoising,3), ' s'])
            colorbar
            
        i = i+1;
        sp(i) = subplot(rows,cols,i);
            imshow(uint16(im_de), 'DisplayRange', [0 4095])
            title(['Denoised, mse = ' num2str(mse(im,im_de),2), ', snr = ', num2str(snr(im,im_de),4)])
            colorbar

        i = i+1;
        sp(i) = subplot(rows,cols,i);
            imshow(uint16(max(denoised,[],3)), 'DisplayRange', [0 4095])
            title('Denoised (MIP)')
            colorbar

        i = i+1;
        sp(i) = subplot(rows,cols,i);
            imshow(uint16(abs(im_de-im)), [])
            title(['Noise Component (auto-scale)'])
            colorbar
            
        try 
            export_fig(fullfile('figuresOut', fileOutName), '-r300', '-a1')
        catch err
            if strcmp(err.identifier, 'MATLAB:UndefinedFunction')
               err
               warning('export_fig not found, nothing imported! Have you added to path (export_fig)?')
            else
               err 
               err.message
            end
        end