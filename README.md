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
For the standard workflow <i>Set Path -> Add with subfolders (./3rdParty)</i>

* EXPORT: export_fig, by Yair Altman, https://github.com/altmany/export_fig
* VESSELNESS: Optimally Oriented Flux (OOF) for 3D Curvilinear Structure Detection, by Max W.K. Law, http://www.mathworks.com/matlabcentral/fileexchange/41612-optimally-oriented-flux--oof--for-3d-curvilinear-structure-detection, along with the oriented flux antisymmetry (OFA) extension.
* SEGMENTATION: Fast Continuous Max-Flow Algorithm to 2D/3D Image Segmentation, by Jing Yua, http://www.mathworks.com/matlabcentral/fileexchange/34126-fast-continuous-max-flow-algorithm-to-2d-3d-image-segmentation
* IMPORT: OME Bio-Formats in MATLAB, https://www.openmicroscopy.org/site/support/bio-formats5.1/developers/matlab-dev.html

# Dependencies Demos (included)

* ImageNoise Estimation, implemented by Chris Schwemmer from Yang and Tai (2010), https://www5.cs.fau.de/our-team/schwemmer-chris/software/
* Coherence Filter Toolbox for anisotropic non-linear diffusion filtering, by Dirk-Jan Kroon, http://www.mathworks.com/matlabcentral/fileexchange/25449-image-edge-enhancing-coherence-filter-toolbox
* (Fast) Guided Filter, He and Sun (2015), http://research.microsoft.com/en-us/um/people/kahe/eccv10/
* Bilateral filter (Robust), by Kunal Chaudhury, http://www.mathworks.com/matlabcentral/fileexchange/50855-robust-bilateral-filter
* Trilateral filter, by Pekka Astola, http://in.mathworks.com/matlabcentral/fileexchange/44613-two-dimensional-trilateral-filter
* FAST NL-Means Denoising (Gaussian noise), by Yue Wu, http://www.mathworks.com/matlabcentral/fileexchange/38200-fast-non-local-mean-image-denoising-implementation
* NL-Means Denoising (Poisson noise), by Charles Deledalle, http://www.math.u-bordeaux1.fr/~cdeledal/poisson_nlmeans.php 
