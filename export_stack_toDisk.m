function export_stack_toDisk(fileOut, im)

        %{
        disp(['Writing ', fileOut, ' to disk as .nrrd'])
        
            
            pixelspacing = [1 1 1];
            origin = [0,0,0];
            encoding = 'raw';
            ok = nrrdWriter(fileOut, im, pixelspacing, origin, encoding);
                % pixelspacing - boxel size
                % origin    - point from the image is generated
                % encoding  - raw, ascii, gzip
            %}

        fileOut = strrep(fileOut, '.nrrd', '.tif');
        disp([' .. Writing ', fileOut, ' to disk as multilayer 16-bit TIF'])
        
        % whos
        % [min(im(:)) max(im(:))]     
        im = im - min(im(:));        
        im = im / max(im(:));        
        imOut = uint16(im * 65535);
        
        %uniqueValues = length(unique(im))
        %uniqueValuesOut = length(unique(imOut))
        
        %{
        whos
        figure
        imshow(im(:,:,1)); drawnow()
        figure
        imshow(im(:,:,1)); drawnow()
        %}
        
        imwrite(imOut(:,:,1), fileOut, 'tif', 'Compression', 'lzw')
        for k = 2:size(imOut,3)
            imwrite(imOut(:,:,k), fileOut, 'tif', 'writemode', 'append', 'Compression', 'lzw');
        end
                
        %{
        % http://stackoverflow.com/questions/874461/read-mat-files-in-python
        fileOut = strrep(fileOut, '.tif', '.mat');
        disp(['   .. Writing ', fileOut, ' to disk as MAT file (with -7.3 flag)'])
            save(fileOut, 'im', '-v7.3')
                
            %{
            fileOut = strrep(fileOut, '.tif', '.h5');
            disp(['   .. Writing ', fileOut, ' to disk as HDF5'])

                hdf5write(fileOut, '/dataset1', im)
            %}
        %}