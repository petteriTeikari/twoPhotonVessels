#include <CGAL/Simple_cartesian.h>
#include <CGAL/property_map.h>
#include <CGAL/IO/read_xyz_points.h>
#include <CGAL/IO/write_xyz_points.h>
#include <CGAL/bilateral_smooth_point_set.h>
#include <CGAL/tags.h>
#include <utility> // defines std::pair
#include <fstream>
// Types
typedef CGAL::Simple_cartesian<double> Kernel;
typedef Kernel::Point_3 Point;
typedef Kernel::Vector_3 Vector;
// Point with normal vector stored in a std::pair.
typedef std::pair<Point, Vector> PointVectorPair;
int main(int argc, char*argv[])
{
    
    // e.g. ./BSmoothing 20 2 75 ./dataTest/out.xyz ./dataTest/bsmooth_out.xyz
    // std::cout << "Have " << argc << " arguments:" << std::endl;
    // for (int i = 0; i < argc; ++i) {
    //         std::cout << argv[i] << std::endl;
    // } 
    
    // argv[1]= the control sharpness of the result
    // argv[2]= the number of times the projection is applied
    // argv[3]= neighboorhood size
    // argv[4]= the .xyz file with point cloud information to be inputted
    // argv[5]= the simplified .xyz file with point cloud information to be outputted

    if (argc==1){
         std::cerr << "Error: No Input arguments " << std::endl;
    }

    // PARAMETERS:
    double sharpness_angle = atof(argv[1]);     // control sharpness of the result.
                                                // The bigger the smoother the result will be
    int iter_number = atoi(argv[2]);            // number of times the projection is applied
    int k = atoi(argv[3]);                      // size of neighborhood. The bigger, the smoother the result will be.
                                                // This value should bigger than 1.
    
    //  FILENAMES:
    const char* input_filename  = argv[4];
    const char* output_filename = argv[5];
            
    // Reads a .xyz point set file in points[] * with normals *.
    std::vector<PointVectorPair> points;
    std::ifstream stream(input_filename);
    std::cout<< "reading file.......";
    if (!stream ||
        !CGAL::read_xyz_points_and_normals(stream,
                     std::back_inserter(points),
                     CGAL::First_of_pair_property_map<PointVectorPair>(),
                     CGAL::Second_of_pair_property_map<PointVectorPair>()))
    {
    
    std::cerr << "Error: cannot read file " << input_filename << std::endl;
     return EXIT_FAILURE;
    }else {
        std::cout<< "complete" << "\n" ;
    }
    
  
    // THE SMOOTHING
    std::cout << "Smoothing........";
    for (int i = 0; i < iter_number; ++i)
    {
    /* double error = */
    CGAL::bilateral_smooth_point_set <CGAL::Parallel_tag>(
          points.begin(), 
          points.end(),
          CGAL::First_of_pair_property_map<PointVectorPair>(),
          CGAL::Second_of_pair_property_map<PointVectorPair>(),
          k,
          sharpness_angle);
    }
    std::cout << "complete \n";
  
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

    std::cout << "complete \n";
    return EXIT_SUCCESS;
}

