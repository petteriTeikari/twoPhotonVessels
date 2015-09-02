function metadata = import_parseMetadata(data, options)

    % OME
    % See: http://www.openmicroscopy.org/site/support/bio-formats4/developers/matlab-dev.html
    
    % PT: Check later if this is actually useful
    if options.loadFromTIFF
        % OME metadata is a standardized metadata structure, 
        % which is the same regardless of input file format. 
        % It is stored in the data{s, 4} element of the data structure returned by bfopen, 
        % and contains common metadata values such as physical pixel sizes, instrument settings, and much more.
        metaDataIndex = 4;
    else
        % Original metadata is a set of key/value pairs specific to the input format of the data. 
        % It is stored in the data{s, 2} element of the data structure returned by bfopen.
        metaDataIndex = 2;
    end
    
    % Query some metadata fields (keys are format-dependent)
    metadata.all = data{1, 2};
    metadata.Keys = metadata.all.keySet().iterator();
    
    % Uncomment here if you wanna see all the values in the metadata
    %{
    for i = 1:metadata.all.size()
      key = metadata.Keys.nextElement();
      value = metadata.all.get(key);
      fprintf('%s = %s\n', key, value)
    end
    %}
    
    % Using the OME Meta
    metadata.omeMeta = data{1, 4};
    
        % for all possible values see:
        % http://downloads.openmicroscopy.org/bio-formats/5.0.2/api/loci/formats/meta/MetadataRetrieve.html
    
    % save some key parameters to .main, later all the values can be
    % queried if needed and eventually exported with the output
    
    % Resolution
    metadata.main.stackSizeX = metadata.omeMeta.getPixelsSizeX(0).getValue(); % image width, pixels
    metadata.main.stackSizeY = metadata.omeMeta.getPixelsSizeY(0).getValue(); % image height, pixels
    metadata.main.stackSizeZ = metadata.omeMeta.getPixelsSizeZ(0).getValue(); % number of Z slices
    
    % Physical sizes
    %metadata.main.voxelSizeX = metadata.omeMeta.getPixelsPhysicalSizeX(0).getValue() % in µm
    %metadata.main.voxelSizeY = metadata.omeMeta.getPixelsPhysicalSizeY(0).getValue() % in µm
    %metadata.main.voxelSizeZ = metadata.omeMeta.getPixelsPhysicalSizeZ(0).getValue() % in µm
    
        % FIX: No appropriate method, property, or field getValue for class ome.units.quantity.Length.    
        % a = metadata.omeMeta.getPixelsTimeIncrement(0), NO
    
    % No of Channels (Red, Green, etc.)
    metadata.main.noOfChannels = metadata.omeMeta.getChannelCount(0);
        disp('  .. check stil that the channel count reading works correctly (PT)')
        
    
    % Time points 'how to retrieve from OIB?'
    metadata.main.numberOfStacks = length(data{1,1});
    metadata.main.numberOfStacksPerChannel = metadata.main.numberOfStacks / metadata.main.noOfChannels;
    metadata.main.noOfTimePoints = metadata.main.numberOfStacks / metadata.main.stackSizeZ / metadata.main.noOfChannels;
        disp('   .. no of time points derived from numberOfStacks and stackSizeZ (PT)')

   