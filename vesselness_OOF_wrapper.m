function tubularValue = vesselness_OOF_wrapper(imageStackIn, radius, opts)

    tic
    %opts.responsetype=0; % l1; (default)
    %opts.responsetype=1; % l1 + l2;
    tubularValue = oof3response(imageStackIn, radius(1):radius(2), opts);
    timeTook = toc;
    disp(['   .. done in ', num2str(timeTook,4), ' seconds']);


    % do some checking of the output as during testing, the output the 
    % was occasionally all zeroes while subsets of slices did not
    % produce this behavior
    if min(tubularValue(:)) == 0 && max(tubularValue(:)) == 0
        warning('the OOF response produced stack full of zeroes, input contains NaN/Inf? -> "imgfft = fftn(image)" fails')
    end