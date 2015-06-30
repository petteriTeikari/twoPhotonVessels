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
        im = im / max(im(:));
        im = uint16((im * 2^16) -1);
        
            imwrite(im(:,:,1), fileOut)
                for k = 2:size(im,3)
                    imwrite(im(:,:,k), fileOut, 'writemode', 'append');
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