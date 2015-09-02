function [denoised, fileOutName] = denoise_guidedFilterWrapper(imageIn, guide, ...
            epsilon, win_size, NoOfIter, guidedType, subsampleFactor, options)

    % Guided Image Filtering
    % Kaiming He, Microsoft Research
    % http://research.microsoft.com/en-us/um/people/kahe/eccv10/
    
    % preallocate
    denoised = zeros(size(imageIn));
    
    if strcmp(guidedType, 'original')
        
        disp('Denoising the stack using Guided Filter')
        disp(' from: http://research.microsoft.com/en-us/um/people/kahe/eccv10/')
        disp(['  - iter = ', num2str(NoOfIter), ', w = ', num2str(win_size), ', \epsilon = ', num2str(epsilon)])
        disp('SLICE:')
        
        % The Original code published back in 2010
        % Guided Image Filtering, by Kaiming He, Jian Sun, and Xiaoou Tang, in ECCV 2010
        for slice = 1 : size(imageIn, 3)       
            fprintf('%d ', slice)
            im = imageIn(:,:,slice);
            g = guide(:,:,slice);
            for i = 1 : NoOfIter                
                im = guided_filter(im, g, epsilon, win_size);
                g = im;
            end        
            denoised(:,:,slice) = im;
        end
        
        fileOutName = [options.denoisingAlgorithm, '_iter', num2str(NoOfIter), ...
            '_w', num2str(win_size), '_eps', num2str(epsilon), ...            
            '_DenoisingWholeStack.png'];
        
    elseif strcmp(guidedType, 'fast')
        
        % 10x faster implementation with some subsampling (According to the
        % authors that is, in practice you get rouglhy the following for
        % our images (512 x 512 double) 
        % s = 1, 5x speedup
        % s > 1, bunch of "Warning: Size input contains non-integer values. This will error in a future release. Use
        %        FLOOR to convert to integer values. "
        % Figure out later why the subsample does not give proper sizes
        disp('Denoising the stack using Fast Guided Filter')
        disp(' from: http://research.microsoft.com/en-us/um/people/kahe/eccv10/')
        disp(['  - iter = ', num2str(NoOfIter), ', w = ', num2str(win_size), ', \epsilon = ', num2str(epsilon), ', s = ', num2str(subsampleFactor)])
        disp('SLICE:')
        
        % Fast Guided Filter, by Kaiming He and Jian Sun, in arXiv 2015.
        for slice = 1 : size(imageIn, 3)       
            fprintf('%d ', slice)
            im = imageIn(:,:,slice);
            g = guide(:,:,slice);
            for i = 1 : NoOfIter
                im = fastguidedfilter(im, g, win_size, epsilon, subsampleFactor);
                g = im;
            end        
            denoised(:,:,slice) = im;
        end
        
        fileOutName = ['fastGuidedFilter', '_iter', num2str(NoOfIter), ...
            '_w', num2str(win_size), '_eps', num2str(epsilon), '_s', num2str(subsampleFactor), ...            
            '_DenoisingWholeStack.png'];        
    else       
        error(['Only "original" and "fast" implemented now. You tried with: ', guidedType])        
    end