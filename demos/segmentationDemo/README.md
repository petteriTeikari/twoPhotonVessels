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

