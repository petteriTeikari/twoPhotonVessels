% Check for NaN and Inf values      
function imageMatrixStack = import_checkQuality(imageMatrixStack, path, options)

    
    if nargin == 0
        load testQuality.mat
    else
        % save testQuality.mat
    end    

    % check the quality of the input image
    nanIndices = find(isnan(imageMatrixStack) == 1);
    infIndices = find(isnan(imageMatrixStack) == 1);

    noOfNANs = length(nanIndices);       
    noOfInfs = length(infIndices);

    if noOfNANs > 0

        warning(['Input contain NaN-values (n = ', num2str(noOfNANs), ')'])
        noOfIter = 100;
        disp('Inpaint the missing data (too slow now, just replace with a zero)')
        
        imageMatrixStack(isnan(imageMatrixStack)) = 0;

        %{
        try
            tic

            inPaintTime = toc
            disp(['     ... inpainting took ', num2str(inPaintTime,4), ' seconds'])
        catch err
            if strcmp(err.identifier, 'MATLAB:UndefinedFunction')
                warning('Download inpaintn, http://www.mathworks.com/matlabcentral/fileexchange/27994-inpaint-over-missing-data-in-1-d--2-d--3-d--n-d-arrays')
            else
                err
            end
        end
        %}

    elseif noOfInfs > 0
        warning(['Input contain Inf-values (n = ', num2str(noOfInfs), ')'])
    end
    
    
