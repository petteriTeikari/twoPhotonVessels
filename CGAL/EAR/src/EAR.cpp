#include <CGAL/Simple_cartesian.h>
#include <CGAL/edge_aware_upsample_point_set.h>
#include <CGAL/IO/read_xyz_points.h>
#include <CGAL/IO/write_xyz_points.h>
#include <vector>
#include <fstream>

// types
typedef CGAL::Simple_cartesian<double> Kernel;
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
        std::cout << "Have " << argc << " arguments:" << std::endl;
        for (int i = 0; i < argc; ++i) {
                std::cout << argv[i] << std::endl;
        } 

        // Default parameters
        // if (argc==1){		
        //                 
        //         std::cerr << "Error: No Input arguments " << std::endl;
        //         
        //     }else {

        // Edge-Aware Resampling parameters
        const double sharpness_angleEAR = atof(argv[1]);    // control sharpness of the result, e.g. 25
        const double edge_sensitivity = atof(argv[2]);      // higher values will sample more points near the edges, e.g. 0
        const double neighbor_radiusEAR = atof(argv[3]);    // initial size of neighborhood, e.g. 0.25

        const double resamplingFactor = atof(argv[4]);      

        // Filenames    
        const char* input_filename = argv[5];
        const char* output_filename = argv[6];

        // Reads a .xyz point set file in points[], *with normals*.
        std::vector<PointVectorPair> points;
        std::ifstream stream(input_filename);
        
        if (!stream ||
          !CGAL::read_xyz_points_and_normals(stream,
                            std::back_inserter(points),
                            CGAL::First_of_pair_property_map<PointVectorPair>(),
                            CGAL::Second_of_pair_property_map<PointVectorPair>()))
        {
        std::cerr << "Error: cannot read file " << input_filename << std::endl;
        return EXIT_FAILURE;
        }

    // Edge-Aware Resampling
        
        const unsigned int number_of_output_points = points.size() * resamplingFactor;
        
            // Note that the CGAL example is doing upsampling whereas we have so much point
            // that we want to downsample rather than the upsampling typically done for
            // range images
    
   //Run algorithm 
   CGAL::edge_aware_upsample_point_set(
            points.begin(), 
            points.end(), 
            std::back_inserter(points),
            CGAL::First_of_pair_property_map<PointVectorPair>(),
            CGAL::Second_of_pair_property_map<PointVectorPair>(),
            sharpness_angleEAR, 
            edge_sensitivity,
            neighbor_radiusEAR,
            number_of_output_points);
   
  // Saves point set.
  std::ofstream out(output_filename);  
  if (!out ||
     !CGAL::write_xyz_points_and_normals(
      out, points.begin(), points.end(), 
      CGAL::First_of_pair_property_map<PointVectorPair>(),
      CGAL::Second_of_pair_property_map<PointVectorPair>()))
  {
    return EXIT_FAILURE;
  }
  return EXIT_SUCCESS;
}
