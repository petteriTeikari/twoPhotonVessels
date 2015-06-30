 % check that the import was okay
function options = import_checkImportedData(data, metadata, extraString, options)

    options.imageSize = size(data{1, 1}{1, 1});
    options.numberOfStacks = size(data{1}, 1);
    options.numberOf_tPlanes = 6; % fixed now, maybe from metadata at some point
    options.numberOf_zStacks = options.numberOfStacks / options.numberOf_tPlanes; 

    disp(extraString)
    disp(['   - xy size: ', num2str(options.imageSize(1)), 'x', num2str(options.imageSize(2)), ...
          ', no stacks = ', num2str(options.numberOfStacks), ', no of z stacks = ', ...
          num2str(options.numberOf_zStacks), ', no of t-planes = ', num2str(options.numberOf_tPlanes), ' (fixed)'])
