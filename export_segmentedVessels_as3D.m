function export_segmentedVessels_as3D(uu, options)

    if nargin == 0
        close all
        load testExport3D.mat
    else
        save testExport3D.mat
    end
    
    % RESOURCES   
    
        % Exporting an STL from Matlab
        % http://jmumakerlab.blogspot.ca/2013/11/exporting-stl-from-matlab.html

        % stlwrite, Export a variety of inputs (patch, surface) to an STL triangular mesh
        % http://www.mathworks.com/matlabcentral/fileexchange/20922-stlwrite-filename--varargin-

        % stlwrite - Write binary or ascii STL file
        % http://www.mathworks.com/matlabcentral/fileexchange/36770-stlwrite-write-binary-or-ascii-stl-file
        
        % surf2solid
        % http://imageprocessingblog.com/surf2solid-a-tool-for-3d-printing/

        % MATLAB + Grasshopper
        % http://www.grasshopper3d.com/profiles/blogs/matlab-grasshopper
        
        % Notes on 3D printing
        % Mathematica, Shapeways, Rhino
        % http://www.segerman.org/3d_printing_notes.html
        % Henry Segerman: 3D Printing for Mathematical Visualisation
        % dx.doi.org/10.1007/s00283-012-9319-7
    
    
    % 1) Construct the mesh
    mesh = export_constructMesh(uu);
    
    % 2) Write to disk then
        
        % BINARY
        stlwrite('testVessels.stl', mesh) % Save to binary .stl 
    
    
    function mesh = export_constructMesh(im)
        
        % see e.g. http://www.mathworks.com/matlabcentral/fileexchange/20922-stlwrite-filename--varargin-
        mesh = isosurface(im, 0.5);
    
    
    
    
    
    
    