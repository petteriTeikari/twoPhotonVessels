
#include "itkImageFileReader.h"
#include "itkBinaryMask3DMeshSource.h"
#include "itkImage.h"
#include <itkTIFFImageIO.h>

#include "itkBinaryThresholdImageFilter.h"
#include "itkBinaryMask3DMeshSource.h"
#include "itkMeshFileWriter.h"
#include "itkMesh.h"
#include <itkVTKImageIO.h>
#include "itkImageFileWriter.h"

int main(int argc,char* argv[])
{

	// We define then the pixel type and dimension of the image from which we are
	// going to extract the surface.
//PixelType objectValue can be changed to gather more/less points 
	const unsigned char Dimension = 3;
  typedef unsigned int  PixelType;
  typedef itk::Image< PixelType, Dimension > ImageType;
  
  //Image type definition
typedef itk::ImageFileReader< ImageType >    ReaderType;
  ReaderType::Pointer reader = ReaderType::New();
 reader->SetImageIO(itk::TIFFImageIO::New());  


 //reading the file type
 const char* filename;
 if (argc==1){

	std::cerr << "Please Insert .tif file" << std::endl;
	return EXIT_FAILURE; 
    }else {
    	 filename= argv[0];
    }

 reader->SetFileName(filename);


try
    {
    reader->Update();
    }
  catch( itk::ExceptionObject & exp )
    {
    std::cerr << "Exception thrown while reading the input file " << std::endl;
    std::cout << filename << std::endl;
    std::cerr << exp << std::endl;
    return EXIT_FAILURE;
    }


 

//mesh extraction
// Uses algorithm similar to Marching Cubes to extract surface
typedef itk::Mesh<int> MeshType;
typedef itk::BinaryMask3DMeshSource< ImageType, MeshType > MeshSourceType;
MeshSourceType::Pointer meshSource = MeshSourceType::New();
//very similar to IsoValue
const PixelType objectValue= 3000;
meshSource->SetObjectValue( objectValue );
meshSource->SetInput( reader->GetOutput() );


std::cout << objectValue << std::endl;


try
  {
  meshSource->Update();
  }
catch( itk::ExceptionObject & exp )
  {
  std::cerr << "Exception thrown during Update() " << std::endl;
  std::cerr << exp << std::endl;
  return EXIT_FAILURE;
  }

std::cout << "Nodes = " << meshSource->GetNumberOfNodes() << std::endl;
std::cout << "Cells = " << meshSource->GetNumberOfCells() << std::endl;


   typedef itk::MeshFileWriter< MeshType > WriterType;
  WriterType::Pointer writer = WriterType::New();
  writer->SetFileName( "outputtedImage.vtk" );
  writer->SetInput( meshSource->GetOutput() );
  try
    {
    writer->Update();

    }
  catch( itk::ExceptionObject & error )
    {
    std::cerr << "Error: " << error << std::endl;
    return EXIT_FAILURE;
    }


  return EXIT_SUCCESS;
}
