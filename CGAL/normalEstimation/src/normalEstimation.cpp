#include <CGAL/Exact_predicates_inexact_constructions_kernel.h>
#include <CGAL/pca_estimate_normals.h>
#include <CGAL/mst_orient_normals.h>
#include <CGAL/property_map.h>
#include <CGAL/IO/read_xyz_points.h>
#include <CGAL/IO/write_xyz_points.h>
#include <utility> // defines std::pair
#include <list>
#include <fstream>

// Types
typedef CGAL::Exact_predicates_inexact_constructions_kernel Kernel;
typedef Kernel::Point_3 Point;
typedef Kernel::Vector_3 Vector;

// Point with normal vector stored in a std::pair.
typedef std::pair<Point, Vector> PointVectorPair;

int main(int argc, char** argv)
{
 
    // INIT
    
        // EAR is WLOP + Bilateral Smoothing + Edge-Aware Resampling
        // http://doc.cgal.org/latest/Point_set_processing_3/

        // parse the input (just to check)
        // std::cout << "Have " << argc << " arguments:" << std::endl;
        // for (int i = 0; i < argc; ++i) {
        //      std::cout << argv[i] << std::endl;
        // } 

        // Default parameters
        // if (argc==1){		
        //                 
        //         std::cerr << "Error: No Input arguments " << std::endl;
        //         
        //     }else {

        // Parameters
        const int nb_neighbors = atoi(argv[1]); // K-nearest neighbors = 3 rings
        
        // Filenames    
        const char* input_filename = argv[2];
        const char* output_filename = argv[3];

       // Reads a .xyz point set file in points[].
        std::list<PointVectorPair> points;
        std::ifstream stream(input_filename);
        if (!stream ||
            !CGAL::read_xyz_points(stream,
                                   std::back_inserter(points),
                                   CGAL::First_of_pair_property_map<PointVectorPair>()))
        {
          std::cerr << "Error: cannot read file " << input_filename<< std::endl;
            return EXIT_FAILURE;
        }
        
    // COMPUTATIONS
        
        // Estimates normals direction.
        // Note: pca_estimate_normals() requires an iterator over points
        // as well as property maps to access each point's position and normal.        
        CGAL::pca_estimate_normals(points.begin(), points.end(),
                                   CGAL::First_of_pair_property_map<PointVectorPair>(),
                                   CGAL::Second_of_pair_property_map<PointVectorPair>(),
                                   nb_neighbors);
        
        // Orients normals.
        // Note: mst_orient_normals() requires an iterator over points
        // as well as property maps to access each point's position and normal.
        std::list<PointVectorPair>::iterator unoriented_points_begin =
            CGAL::mst_orient_normals(points.begin(), points.end(),
                                     CGAL::First_of_pair_property_map<PointVectorPair>(),
                                     CGAL::Second_of_pair_property_map<PointVectorPair>(),
                                     nb_neighbors);
        
        // Optional: delete points with an unoriented normal
        // if you plan to call a reconstruction algorithm that expects oriented normals.
        points.erase(unoriented_points_begin, points.end());
       
    // EXPORT
        
        std::ofstream out(output_filename);   
        std::cout << "Creating and Saving file......." ;
        if (!out ||
          !CGAL::write_xyz_points_and_normals(
          out, points.begin(), points.end(),
          CGAL::First_of_pair_property_map<PointVectorPair>(),
          CGAL::Second_of_pair_property_map<PointVectorPair>()))

        {
        std::cout<<"something went wrong? \n";
        return EXIT_FAILURE;
        }

        
}
