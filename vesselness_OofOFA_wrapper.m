function oofOFA = vesselness_OofOFA_wrapper(imageStackIn, scales)

    oofOFA = zeros(size(imageStackIn));
    fprintf('     OOF-OFA Slice: ')
    for i = 1 : size(imageStackIn,3)
        fprintf('%d ', i)
        oofOFA(:,:,i) = oofofa2(imageStackIn(:,:,i), scales(1):scales(end));
    end
    fprintf('\n ')