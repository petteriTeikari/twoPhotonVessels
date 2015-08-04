function init_parallelComputing(noOfCores)

    % from
    % http://www.mathworks.com/products/parallel-computing/examples.html?file=/products/demos/shipping/distcomp/paralleldemo_parfor_bobsled.html

    try
        poolSize = matlabpool('size');
            % check versions also, as matlabpool -> parpool in 2013b and
            % later, http://www.mathworks.com/matlabcentral/answers/92124-why-am-i-unable-to-use-matlabpool-or-parpool-with-the-local-scheduler-or-validate-my-local-configura
    catch err
        if strcmp(err.identifier, 'MATLAB:UndefinedFunction')
            warning('Forget about "parfor" loops as you do not probably have licence for Parallel Computing Toolbox!')
            return
        else
            err
            error('see mesg')
        end
    end
    
    if poolSize == 0
        warning('parallel:demo:poolClosed', ...
                'Initializing the matlabpool as it was not running');
        
        matlabpool(noOfCores)
        
    elseif poolSize ~= noOfCores
        
        warning('Changing the number of cores used')
        matlabpool close % stop
        matlabpool(noOfCores) % restart
        
    end
    
    % fprintf('This demo is running on %d MATLABPOOL workers.\n', matlabpool('size'));