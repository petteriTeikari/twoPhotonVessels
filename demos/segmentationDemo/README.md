# Segmentation Test

## Debug input data

from "CP-20150323-TR70-mouse2-1-son.oib", slices 10-16

![Plot](https://raw.githubusercontent.com/petteriTeikari/twoPhotonVessels/master/demos/segmentationDemo/testData/inputPlot_init.png)

![Variables](https://raw.githubusercontent.com/petteriTeikari/twoPhotonVessels/master/demos/segmentationDemo/testData/inputVariables.png)

edges     - manually refined from Canny output

edgesFill - filled semi-automatically using some of the edge linking functions from Peter Kovesi (http://www.peterkovesi.com/matlabfns/index.html#edgelink)

gvf_OOF   - 3D Gradient Vector Flow of OOF, using the code from Erik Smistad: https://github.com/smistad/3D-Gradient-Vector-Flow-for-Matlab

gvf_im    - 3D Gradient Vector Flow of actual image stack

im        - input image stack, from 2-PM

OOF-3D    - Optimally Oriented Flux (OOF) of the input, http://www.mathworks.com/matlabcentral/fileexchange/41612-optimally-oriented-flux--oof--for-3d-curvilinear-structure-detection

## ASETS Level-sets for binary segmentation (2D)
https://github.com/ASETS/asetsMatlabLevelSets

We can test the segmentation algorithm with various refined images (see Segment - Pre-Process in <code>demo_segmentationMethods.m</code>), and speed functions (e.g. output of an OOF or GVF) to drive the active contours

![Test Images ASETS 2D](https://raw.githubusercontent.com/petteriTeikari/twoPhotonVessels/master/demos/segmentationDemo/demoFiguresOut/asets_2D_input.png)

Which can give us for example the following segmentation (see <code>asets_demoWrapper_2D.m</code> using the "fusion" image as the input, and the manually refined edgeFill as the speed function (both inputs kinda cheating as there has been manual labor):

![Test Output ASETS 2D](https://raw.githubusercontent.com/petteriTeikari/twoPhotonVessels/master/demos/segmentationDemo/demoFiguresOut/asets_2D_exampleOutput.png)

The evolution can be visualized with an animated gif (export_fig in Matlab, and ImageMagick in Ubuntu):

![Test Output ASETS 2D](https://raw.githubusercontent.com/petteriTeikari/twoPhotonVessels/master/demos/segmentationDemo/demoFiguresOut/anim_asets2D_squareInitSmall.gif)
