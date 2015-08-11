
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

int main( int, char* [] )
{
    const unsigned char Dimension = 3;
  typedef unsigned int  PixelType;
  typedef itk::Image< PixelType, Dimension > ImageType;
  
typedef itk::ImageFileReader< ImageType >    ReaderType;
  ReaderType::Pointer reader = ReaderType::New();
 reader->SetImageIO(itk::TIFFImageIO::New());  

const char* filename= "/home/highschoolintern/Desktop/CP-20150323-TR70-mouse2-1-son_denoised_onlyOneTimePoint_slices4to16.ome.tif";
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

  typedef itk::BinaryThresholdImageFilter< ImageType, ImageType > BinaryThresholdFilterType;
    BinaryThresholdFilterType::Pointer threshold = BinaryThresholdFilterType::New();


    threshold->SetInput( reader->GetOutput() );
    threshold->SetLowerThreshold(2000);
    threshold->SetUpperThreshold( 4095 );
    threshold->SetOutsideValue( 2 );
    threshold->SetInsideValue(1000);



//std::cout<< "It worked!" << std::endl;
typedef itk::Mesh<int> MeshType;
typedef itk::BinaryMask3DMeshSource< ImageType, MeshType > MeshSourceType;
MeshSourceType::Pointer meshSource = MeshSourceType::New();
const PixelType objectValue = 250;
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


return 0;
}
