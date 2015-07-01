# twoPhotonVessels

The "main" file is <b>process_SingleFile.m</b> which calls the other functions
- Import
- Denoise
- Deconvolve (needed?)
- Vesselness Filter
- Segmentation
- 3D Reconstruction
- Registration
- Analysis
- Export

# Dependencies A (not included)

* Fiji/ImageJ, http://fiji.sc/Fiji
* PureDenoise, http://bigwww.epfl.ch/algorithms/denoise/
* MIJ, Fiji-Matlab bridge, http://bigwww.epfl.ch/sage/soft/mij/

# Dependencies B (included)

* EXPORT: export_fig, by Yair Altman, https://github.com/altmany/export_fig
* VESSELNESS: Optimally Oriented Flux (OOF) for 3D Curvilinear Structure Detection, by Max W.K. Law, http://www.mathworks.com/matlabcentral/fileexchange/41612-optimally-oriented-flux--oof--for-3d-curvilinear-structure-detection
* SEGMENTATION: Fast Continuous Max-Flow Algorithm to 2D/3D Image Segmentation, by Jing Yua, http://www.mathworks.com/matlabcentral/fileexchange/34126-fast-continuous-max-flow-algorithm-to-2d-3d-image-segmentation
* IMPORT: OME Bio-Formats in MATLAB, https://www.openmicroscopy.org/site/support/bio-formats5.1/developers/matlab-dev.html

