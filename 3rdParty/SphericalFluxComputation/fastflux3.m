function outputfeature = fastflux3( image, ranges, sigma, pixelspacing)
% Compute the analytical 3D multi-radii spherical flux responses for 
% curvilinear structure segmentation. Offer up to 1000 times speed up 
% compared to spatial domain implementation. Support GPU computation for 
% further speed improvement. Implementation based on,
% [1] M.W.K. Law and A.C.S. Chung, ``Efficient Implementation for Spherical 
% Flux Computation and Its Application to Vascular Segmentation``, TIP 
% 2009, 18(3), pp. 596--612.
%
% and see the following regarding the details of level-set segmentation 
% using the spherical flux response,
% [2] A. Vasilevskiy and K. Siddiqi, ``Flux Maximizing Geometric Flows``, 
% PAMI 2002, 24(12), pp. 1565--1578.
%
% The boundary of the segmentation target can be found based on the
% zero-crossing of the response map. 
% Syntax: 
%  outputresponse = fastflux3(image, radii, sigma, pixelspacing)
% Explanation:
%  outputresponse: The final output response. 3D matrix, 
%       size(outputresponse) equals to size(image).
%  image: The original image. (3D matrix)
%  radii: A vector containing all interested radii for computation of 3D
%  spherical flux. (N-D vector)
%  sigma: For image smoothing in during the computation of spherical flux. 
%  (Scalar, optional, default value = 1)
%  pixelspacing: It specifies the pixel size of the input image. This
%  parameter can be omitted if the values of radii and sigma are given in the
%  unit of pixel-length. The pixel spacing can be anisotropic. (Optional, 
%  default value = 1; Scalar for isotropic pixel size; 3D vector, given in 
%  [x-length,y-length,
%  z-length] for anisotropic pixels)
%
%  Example:
%  result = fastflux3(I, 1:5, 1);
%  Return the result computed from the radii {1,2,3,4,5} on image I.
%
%  result = fastflux3(I, 0.4:0.4:2.8, 1, 0.4);
%  Return the result computed from the radii (0.4mm,0.8mm,1.2mm,1.6mm,2mm,2.4mm,
%  2.8mm}, where the each pixel is 0.4mmx0.4mm
%
%  result = fastflux3(I, 2:5, 1, [1 1 1.4]);
%  Return the result computed from the raddi {2mm,3mm,4mm,5mm}, where each pixel
%  has a size of 1mm x 1mm x 1.4mm (w x l x h).
%
%  To workaround the Fourier wrap around artifact, use the command 
%  "padarray". The return value of this function is the analytical version 
%  of the maximum magnitude outward flux computed among the spheres with 
%  multiple radii (Section 3.2, first paragraph in pp.1572 in [2]). In [2], 
%  this response is adopted directly on a level set segmentation framework 
%  ("F" in pp.1573).
%
%  Technical details: 
%  The return value of this function is the "Output the multicale spherical
%  flux" stage in Fig. 4b in [1]. This code uses Subband_1.5 Fourier
%  oversampling technique for better computation accuracy.
%
%  The following variables used in this code correspond to the symbols 
%  used in [1]:
%  image -> I (After Equation 10)
%  ranges -> M (Equation 29)
%  sigma -> \sigma (Equation 7)
%  pixelspacing -> This is a new feature that is not mentioned in [1].
%  Note1 : This implementation is based on Subband_1.5 as stated in Fig. 2
%  in [1]
%  Note2 : An undersize \sigma value (<0.9 voxel-length) may cause inaccurate 
%          computation. Please refer to pp.599-601 in [1] for details.
%  Note3 : Owing to the exceeding memory requirement, the technique of 
%          coefficient buffering [1] is not implemented. 
%  Note4 : fftn in MatLab does not support compact transform (i.e. omitting
%          the conjugate half of Fourier coefficient). Thus, redundant 
%          coefficient elimination is not supported.
%  Note5 : GPU computation is automatically enabled if "image" is a
%          gpuArray.
%  Note6 : The peak memory comsumption is around 11 times of the input image.
%          The precision (double/single) of all variables follows the type of
%          "image". Generally, single precision strike the balance between 
%          memory comsumption and computation accuracy for segmentation.
%  Note7 : Comment Block2 to rewind back to Subband_1. It significantly 
%          increases the computation speed and reduces memory usage in the
%          cost of computation accuracy. See [1] for more details.
% Please kindly cite the following paper if you use this program, or any 
% code extended from this program. 
% Max W. K. Law and Albert C. S. Chung, "Efficient Implementation for Spherical 
% Flux Computation and Its Application to Vascular Segmentation�, IEEE 
% Transactions on Image Processing, 2009, Volume 18(3), 596�612.
%
% Author: Max W.K. Law 
% Email: max.w.k.law@gmail.com 
% Page: http://www.cse.ust.hk/~maxlawwk/

    if exist('sigma', 'var')~=1
        sigma=1;
    end
    if exist('pixelspacing', 'var')~=1
        pixelspacing=[1 1 1];
    end
    if length(pixelspacing)==1
        pixelspacing = [pixelspacing pixelspacing pixelspacing];  
    end


% Block 1: Get the Fourier coordinates 
    [u,v,w]=ifftshiftedcoormatrix(size(image), image(1)*0);
    u=u/size(image,1)/pixelspacing(1) +image(1)*0;
    v=v/size(image,2)/pixelspacing(2) +image(1)*0;
    w=w/size(image,3)/pixelspacing(3) +image(1)*0;
% End of Block 1    

% Block 2: Get three additional oversampling subband (Subband_{1.5})
     tmp = w + ( 2*(w<0) -1 )*1/pixelspacing(3);
     subband(4).R = sqrt(u.^2 + v.^2 + tmp.^2) + 1e-20;
     tmp = v + ( 2*(v<0) -1 )*1/pixelspacing(2);
     subband(3).R = sqrt(u.^2 + tmp.^2 + w.^2) + 1e-20;
     tmp = u + ( 2*(u<0) -1 )*1/pixelspacing(1);
     subband(2).R = sqrt(tmp.^2 + v.^2 + w.^2) + 1e-20;
     clear tmp;
% End of Block 2
% Note: The subband_1.5 technique gives higher accuracy when
% \sigma<=1.27*l, where l is the shortest voxel length of the image.
% See Equation 20 in 
% Max W. K. Law and Albert C. S. Chung, ``Efficient Implementation 
% for Spherical Flux Computation and Its Application to Vascular 
% Segmentation``, TIP 2009, 18(3). 
%
% This technique require additional memory equal to three copies of 
% the original image. If you are experiencing memory problem, you 
% can pay a bit accuracy by commenting the entire Block 2 to 
% reduce the memory consumption. It is generally acceptable if sigma
% is as small as 1 voxel length. 


% Block 3: Get the original subband coordinate (Subband_1)
    subband(1).R = sqrt(u.^2 + v.^2 + w.^2) + 1e-20;
    clear u v w
% End of Block 3

% Block 4: Iterate through all radius samples and retrieve the maximum
% magnitude flux responses.
    imgfreq=fftn(image);
    outputfeature=image*0;
    for i=1:length(ranges)
       freqcoeff=fluxcoeff(subband, ranges(i), sigma);
       tmp=ifftn(imgfreq.* freqcoeff, 'symmetric');
       condition = (abs(tmp)>abs(outputfeature));
       outputfeature(condition) = tmp(condition);
    end
% End of Block 4:

end


% This is the actual implementation of the fast flux filter. 
% See Equation 9 in
% Max W. K. Law and Albert C. S. Chung, ``Efficient Implementation 
% for Spherical Flux Computation and Its Application to Vascular 
% Segmentation``, TIP 2009, 18(3). 
function featurefreq=fluxcoeff(subband, range, sigma)

    featurefreq = subband(1).R*0;
    normalization = -1;
       
       
    for subbandidx=1:length(subband)    % See Equation 25 for more details
       radialDistance=subband(subbandidx).R;
       featurefreq = featurefreq + .........
                     normalization * exp((-(sigma)^2)*2*pi*pi* (radialDistance.^2)).* ............
                    ( sin(2*pi*range*radialDistance)./(2*pi*range*radialDistance) - cos(2*pi*range*radialDistance)) /range^2; %cancelled terms: ./radialDistance./radialDistance/pi * 4*pi*pi.*radialDistance.*radialDistance /4/pi/range^2
    end
    featurefreq=featurefreq/length(subband);
end


%  varargout=ifftshiftedcoormatrix(dimension)
% The dimension is a vector specifying the size of the returned coordinate
% matrices. The number of output argument is equals to the dimensionality
% of the vector "dimension". All the dimension is starting from "1"
function varargout=ifftshiftedcoormatrix(dimension, accuracysample)
dim=length(dimension);
p = floor(dimension/2);

    for i=1:dim
        a=([p(i)+1:dimension(i) 1:p(i)])-p(i)-1 + accuracysample*0;
        reshapepara=ones(1,dim) + accuracysample*0;
        reshapepara(i)=dimension(i);
        A=reshape(a, reshapepara);
        repmatpara=dimension;
        repmatpara(i)=1;
        varargout{i}=repmat(A, repmatpara);
    end
end
