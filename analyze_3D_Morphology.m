function out = analyze_3D_Morphology(mesh, options, visualizeOn)

    

    %% BACKGROUND
    
        % "quantitative morphology"
        
    
        % 2D Vessel diameter estimation
        % ---
            
            % Accuracy and precision of vessel area assessment: 
            % manual versus automatic lumen delineation based on full-width at half-maximum
            % http://dx.doi.org/10.1002/jmri.23752
            
            % Blood Vessel Diameter Estimation System Using Active Contours
            % http://dx.doi.org/10.1109/IMVIP.2011.40            
            
            % Automatic model-based tracing algorithm for vessel segmentation and diameter estimation.
            % http://dx.doi.org/10.1016/j.cmpb.2010.03.004
            
            % Improvement of retinal blood vessel detection using morphological component analysis.
            % http://dx.doi.org/10.1016/j.cmpb.2015.01.004
            
            % Blood vessel segmentation and width estimation in 
            % ultra-wide field scanning laser ophthalmoscopy.
            % http://dx.doi.org/10.1364%2FBOE.5.004329
            

        % 3D Vessel diameter estimation
        % ---
        
            % A 3D MRA Segmentation Method Based on Tubular NURBS Model 
            % http://cds.ismrm.org/protected/09MProceedings/files/03829.pdf
            
            % Accurate Vessel Segmentation With Constrained B-Snake
            % http://dx.doi.org/10.1109/TIP.2015.2417683
            
            % Angiographic Image Analysis
            % http://dx.doi.org/10.1007/978-1-4419-9779-1_6
            
            
            
        
        % 3D Shape Quantitative Analysis
        % ---
        
            % Computational Geometry in MATLAB R2009a
            % http://blogs.mathworks.com/loren/2009/07/15/computational-geometry-in-matlab-r2009a-part-i/
            
            % Computer Graphics Research Software
            % Helping you avoid re-inventing the wheel since 2009!
            % http://www.dgp.toronto.edu/~rms/links.html
            
            % van Dalen and Koster: 2D & 3D particle size analysis of micro-CT images 
            % http://www.skyscan.be/company/UM2012/31.pdf
            
            % GEOMETRY is a MATLAB library which carries out geometric calculations in 2, 3 and N space.
            % http://people.sc.fsu.edu/~jburkardt/m_src/geometry/geometry.html
            
            % The Computational Geometry Algorithms Library (C++ library)
            % http://www.cgal.org/
            
                % CGAL/cgal-swig-bindings
                % https://github.com/CGAL/cgal-swig-bindings/wiki
                % The CGAL Bindings project allows to use some packages of CGAL, 
                % the Computational Algorithms Library, in languages other than C++, 
                % as for example Java and Python. The bindings are implemented with SWIG.
                
                % Introduction to the Computational Geometry Algorithms Library
                % https://www-sop.inria.fr/geometrica/courses/slides/CGAL_intro-12-13.pdf
                
                % MATLAB with CGAL
                
                    % ISO2Mesh: a free 3D surface and volumetric mesh generator for Matlab/Octave
                    % http://iso2mesh.sourceforge.net/cgi-bin/index.cgi?Home
                    
                    % MATLAB mex files with CGAL
                    % http://cgal-discuss.949826.n4.nabble.com/MATLAB-mex-files-with-CGAL-td2534578.html

                    % CGAL_TRI_SIMPLIFY
                    % This function provides a Matlab interface to Fernando Cacciola's edge
                    % collapse method to simplify a triangulated surface mesh available in CGAL

            % Computational Morphology and Format Conversion | Software
            % http://home.earthlink.net/~perlewitz/sftwr.html#morphology        

            % Py3DN Beta
            % Morphometric analysis and visualization of the 3D structure of neurons
            % http://sourceforge.net/projects/py3dn/
            % http://dx.doi.org/10.1007/s12021-013-9188-z
            
            % TREES toolbox provides:
            % "Tools to automatically reconstruct neuronal branching from microscopy image stacks 
            % and to generate synthetic axonal and dendritic trees."
            %    - optional Python wrapper written by Eilif Müller.
                
            % NeuroMorph
            % A toolset for the morphometric analysis and visualization of 3D models 
            % derived from electron microscopy image stacks, as a set of add-ons for Blender
            % http://cvlab.epfl.ch/NeuroMorph
            
            % The Shape-Diameter Function (SDF) 
            % SDF is a scalar function defined on the mesh surface. 
            % It expresses a measure of the diameter of the object's volume in the neighborhood 
            % of each point on the surface.
            % http://www.cs.tau.ac.il/~liors/research/projects/sdf/
            
                % Fast approximation of the shape diameter function
                % http://www.researchgate.net/profile/Riccardo_Scateni/publication/228342563_Fast_approximation_of_the_shape_diameter_function/links/0fcfd50530c5521a4e000000.pdf
                
                % More details on the Shape Diameter Function filter in MeshLab
                % http://3dgraphicsprogramming.blogspot.ca/2011/08/meshlab-plugin-development-depth.html

                % Parallelization of Shape Diameter Function Computation using OpenCL
                % http://www.cescg.org/CESCG-2014/papers/Kamenicky-Parallelization_of_Shape_Diameter_Function_Computation_using_OpenCL.pdf
                
                % Triangulated Surface Mesh Segmentation
                % http://doc.cgal.org/latest/Surface_mesh_segmentation/index.html
                % http://doc.cgal.org/latest/Surface_mesh_segmentation/group__PkgSurfaceSegmentation.html
                    % Depends on: "3D Fast Intersection and Distance
                    % Computation", http://doc.cgal.org/latest/AABB_tree/index.html#Chapter_3D_Fast_Intersection_and_Distance_Computation
                
            % Convex hull algorithms (in general)
            % http://en.wikipedia.org/wiki/Convex_hull_algorithms
            
                % Efficient algorithm for finding spheres farthest apart in large collection
                % http://stackoverflow.com/questions/2276488/efficient-algorithm-for-finding-spheres-farthest-apart-in-large-collection
                
            % 4D Shape Encoding 
            % http://www.cbica.upenn.edu/sbia/Elena.Bernardis/paperi/cardiac_miccai2012.pdf
            
                
        % CLUSTERING
        
            % 3D Shape Partition via Multi-class Spectral Graph Clustering
            % http:/dx.doi.org/10.12733/jics20102475

            % Multiclass Total Variation Clustering     (2013)
            % https://9d5b76582b7871444743f5d0bbd439c802a638d7.googledrive.com/host/0B3BTLeCYLunCc1o4YzV1Ui1SeVE/codes.html
            
            % Fast and efficient spectral clustering
            % http://www.mathworks.com/matlabcentral/fileexchange/34412-fast-and-efficient-spectral-clustering
                % - Ulrike von Luxburg, "A Tutorial on Spectral Clustering", Statistics and Computing 17 (4), 2007

            % Co-segmentation of 3D shapes via multi-view spectral clustering
            % http://dx.doi.org/10.1007/s00371-013-0824-2

      
        % More SEGMENTATION
        
            % Multiple hypothesis template tracking of small 3D vessel structures
            % http://dx.doi.org/10.1016/j.media.2009.12.003

            % Efficient Monte Carlo Image Analysis for the Location of Vascular Entity 
            % http://dx.doi.org/10.1109/TMI.2014.2364404



    
    %% CODE

        if nargin == 0
            load('./debugMATs/testMorphology.mat')        
        else
            save('./debugMATs/testMorphology.mat')    
        end
        out = [];
        imSize = [512 512 67] % manual definition
        mesh
        whos
        disp(' - Analyze the 3D Morphology, e.g. vessel diameters (dummy)')
    
    % DISPLAY THE INPUT    
        % vol3d('CDATA', uint8(volume))    
        % view(3)
    