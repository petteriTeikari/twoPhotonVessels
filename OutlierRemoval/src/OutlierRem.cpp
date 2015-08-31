#include <CGAL/Exact_predicates_inexact_constructions_kernel.h>
#include <CGAL/property_map.h>
#include <CGAL/remove_outliers.h>
#include <CGAL/IO/read_xyz_points.h>
#include <CGAL/IO/write_xyz_points.h>
#include <vector>
#include <fstream>
// types
typedef CGAL::Exact_predicates_inexact_constructions_kernel Kernel;
typedef Kernel::Point_3 Point;
typedef Kernel::Vector_3 Vector;
int main(int argc, char*argv[])
{
	// argv[0]= the .xyz file with point cloud information to be inputted
	//argv[1]= the simplified .xyz file with point cloud information to be outputted
	//argv[2]= the percentage of points to be removed
	// argv[3]= the number of neighbouring points that are taken into consideration.


	int percentageRem;
	int neighborPoints;
	 if (argc==1){
	    	const char* fname = "/home/highschoolintern/Desktop/XYZFileWriter/Vertices.xyz";
	  const char* output_filename = "/home/highschoolintern/Desktop/XYZFileWriter/VerticesOutRem.xyz";
		  percentageRem= 95 ;
		  neighborPoints= 24;
	    }else {
	    	const char* fname = argv[0];
	    		  const char* output_filename = argv[1];
	    	int percentageRem=argv[2];
	    	int neighborPoints= argv[3];
	    }



  // Reads a .xyz point set file in points[].
  // The Identity_property_map property map can be omitted here as it is the default value.
  std::vector<Point> points;
  std::ifstream stream(fname);
  if (!stream ||
      !CGAL::read_xyz_points(stream, std::back_inserter(points),
                             CGAL::Identity_property_map<Point>()))
  {
    std::cerr << "Error: cannot read file " << fname << std::endl;
    return EXIT_FAILURE;
  }
  // Removes outliers using erase-remove idiom.
  // The Identity_property_map property map can be omitted here as it is the default value.
  const double removed_percentage = percentageRem; // percentage of points to remove
  const int nb_neighbors = neighborPoints; // considers 24 nearest neighbor points
  points.erase(CGAL::remove_outliers(points.begin(), points.end(),
                                     CGAL::Identity_property_map<Point>(),
                                     nb_neighbors, removed_percentage), 
               points.end());
  // Optional: after erase(), use Scott Meyer's "swap trick" to trim excess capacity
  std::vector<Point>(points).swap(points);



  std::ofstream out(output_filename);
  if (!out || !CGAL::write_xyz_points(
      out, points.begin(), points.end()))
  {
    return EXIT_FAILURE;
  }

  return EXIT_SUCCESS;
}

