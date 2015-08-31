#include <CGAL/Simple_cartesian.h>
#include <CGAL/wlop_simplify_and_regularize_point_set.h>
#include <CGAL/IO/read_xyz_points.h>
#include <CGAL/IO/write_xyz_points.h>
#include <vector>
#include <fstream>

// types
typedef CGAL::Simple_cartesian<double> Kernel;
typedef Kernel::Point_3 Point;
int main(int argc, char** argv)
{
    
    // parse the input (just to check)
    // std::cout << "Have " << argc << " arguments:" << std::endl;
    // for (int i = 0; i < argc; ++i) {
    //        std::cout << argv[i] << std::endl;
    //    } 
    
    // Default parameters
    // if (argc==1){		
    //                 
    //         std::cerr << "Error: No Input arguments " << std::endl;
    //         
    //     }else {
        
    // WLOP parameters
    double retain_percentage = atof(argv[1]);   // percentage of points to retain.
    double neighbor_radius = atof(argv[2]);   // neighbors size.

    const char* input_filename = argv[3];
    const char* output_filename = argv[4];

    // Reads a .xyz point set file in points[]
    std::vector<Point> points;
    std::ifstream stream(input_filename);
    if (!stream || !CGAL::read_xyz_points(stream, std::back_inserter(points)))
    {
        std::cerr << "Error: cannot read file " << input_filename  << std::endl;
        return EXIT_FAILURE;
    }else{
    	 std::cout << "Reading the input file" << " \n";
    }

    std::vector<Point> output;
    
    //parameters
    CGAL::wlop_simplify_and_regularize_point_set
                              <CGAL::Parallel_tag> // parallel version
                              (points.begin(), 
                               points.end(),
                               std::back_inserter(output),
                               retain_percentage,
                               neighbor_radius
                           );
  
    std::cout << "Writing the output file" << " \n";
    std::ofstream out(output_filename);
    if (!out || !CGAL::write_xyz_points(
          out, output.begin(), output.end()))
    {
        return EXIT_FAILURE;
    }
    return EXIT_SUCCESS;
    }
