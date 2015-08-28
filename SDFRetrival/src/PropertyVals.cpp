#include <CGAL/Exact_predicates_inexact_constructions_kernel.h>
#include <CGAL/boost/graph/graph_traits_Polyhedron_3.h>
#include <CGAL/Polyhedron_items_with_id_3.h>
#include <CGAL/IO/Polyhedron_iostream.h>
#include <CGAL/mesh_segmentation.h>
#include <CGAL/property_map.h>
#include <iostream>
#include <fstream>
#include <string>

typedef CGAL::Exact_predicates_inexact_constructions_kernel K;
typedef CGAL::Polyhedron_3<K, CGAL::Polyhedron_items_with_id_3>  Polyhedron;

// Property map associating a facet with an integer as id to an
// element in a vector stored internally
template<class ValueType>
struct Facet_with_id_pmap
    : public boost::put_get_helper<ValueType&,
             Facet_with_id_pmap<ValueType> >
{
    typedef Polyhedron::Facet_const_handle key_type;
    typedef ValueType value_type;
    typedef value_type& reference;
    typedef boost::lvalue_property_map_tag category;

    Facet_with_id_pmap(
      std::vector<ValueType>& internal_vector
    ) : internal_vector(internal_vector) { }
    reference operator[](key_type key) const
    { return internal_vector[key->id()]; }
private:
    std::vector<ValueType>& internal_vector;
};



int main(int argc,char* argv[])
{
	typedef Polyhedron::Facet_iterator                   Facet_iterator;
    typedef Polyhedron::Halfedge_around_facet_circulator Halfedge_facet_circulator;


std::string location;
std::string filePath;
    // create and read Polyhedron
    if (argc==1){
    	location= "/home/highschoolintern/Desktop/TestReconstruction2/testReconstruction_4slicesPhysical_reconstruction_isolatedRemoved_decimated.off";
    	filePath= "/home/highschoolintern/Desktop/SDFPropertyMap/build";

    }else {
    	location= argv[1];
    	filePath= argv[2];
    }

   std::cout << location.c_str() << "\n";

   Polyhedron mesh;
    std::ifstream input(location.c_str());
    if ( !input || !(input >> mesh) || mesh.empty() ) {
      std::cerr << "Not a valid off file." << std::endl;
      
      return EXIT_FAILURE;
    }


    // assign id field for each facet
    std::size_t facet_id = 0;
    for(Polyhedron::Facet_iterator facet_it = mesh.facets_begin();
      facet_it != mesh.facets_end(); ++facet_it, ++facet_id) {
        facet_it->id() = facet_id;

    }



    for (  Facet_iterator i = mesh.facets_begin(); i != mesh.facets_end(); ++i) {
        Halfedge_facet_circulator j = i->facet_begin();
        // Facets in polyhedral surfaces are at least triangles.
        CGAL_assertion( CGAL::circulator_size(j) >= 3);
        //std::cout << CGAL::circulator_size(j) << ' ';
        do {
           // std::cout << ' ' << std::distance(mesh.vertices_begin(), j->vertex());

        } while ( ++j != i->facet_begin());
        //std::cout << std::endl;
    }




// create a property-map for SDF values
    std::vector<double> sdf_values(mesh.size_of_facets());
    Facet_with_id_pmap<double> sdf_property_map(sdf_values);
    CGAL::sdf_values(mesh, sdf_property_map);




// access SDF values (with constant-complexity)
std::ofstream SDF(filePath.c_str());
SDF.open("SDFVals.txt");

    for(Polyhedron::Facet_const_iterator facet_it = mesh.facets_begin();
      facet_it != mesh.facets_end(); ++facet_it) {
        std::cout << sdf_property_map[facet_it] << " \n";
   SDF << sdf_property_map[facet_it] << std::endl;
    }
    SDF.close();
    std::cout << std::endl;





    std::ofstream SDFfile;


    // create a property-map for segment-ids
    std::vector<std::size_t> segment_ids(mesh.size_of_facets());
    Facet_with_id_pmap<std::size_t> segment_property_map(segment_ids);
    CGAL::segmentation_from_sdf_values(mesh, sdf_property_map, segment_property_map);

    // access segment-ids (with constant-complexity)
    for(Polyhedron::Facet_const_iterator facet_it = mesh.facets_begin();
      facet_it != mesh.facets_end(); ++facet_it) {
        std::cout << segment_property_map[facet_it] << " ";
    }
    std::cout << std::endl;

    SDFfile.close();

}


