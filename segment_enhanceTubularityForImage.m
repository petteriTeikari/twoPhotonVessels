function [ur, tubularity] = segment_enhanceTubularityForImage(tubularity)

    tubularity = abs(tubularity / max(tubularity(:))); % normalize

    gain = 5; cutoff = 0.025;  % trial-and-error set
    tubularity =  1./(1 + exp(gain*(cutoff-tubularity)));  % Apply Sigmoid function
        % compress/enhance, e.g. http://bme.med.upatras.gr/improc/matalb_code_toc.htm

    tubularity = tubularity / max(tubularity(:));

    % For "auto-levels", find the stretch limits
    for i = 1 : size(tubularity, 3)
        lims(i,:) = stretchlim(tubularity(:,:,i));            
    end

    %{
    plot(lims(:,1), 'r')
    hold on
    plot(lims(:,2), 'b')
    hold off
    %}

    % now we can use conservative values for the whole stack
    limsStack = [min(lims(:,1)) max(lims(:,2))];

    for i = 1 : size(tubularity, 3)
        tubularity(:,:,i) = imadjust(tubularity(:,:,i), limsStack, []); %"auto-levels" in Photoshop jargon
    end

    % Enhance further the actual input
    ur = tubularity;        
    gain = 5; cutoff = 0.5; % trial-and-error set
    ur =  1./(1 + exp(gain*(cutoff-ur)));  % Apply Sigmoid function
    ur = ur  / max(ur(:));

