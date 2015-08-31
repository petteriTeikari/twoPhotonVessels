cmake_minimum_required( VERSION 2.8.6 )

project( SurfaceExtraction2 )

find_package( ITK REQUIRED )
include( ${ITK_USE_FILE} )

add_executable( SurfaceExtraction2 Extraction.cxx )
target_link_libraries( SurfaceExtraction2 ${ITK_LIBRARIES} )


