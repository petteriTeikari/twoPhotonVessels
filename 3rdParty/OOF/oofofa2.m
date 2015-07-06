% 2D Implementation of the OOF (Optimally Oriented Flux) - OFA (oriented flux antisymmetry) 
% vesselness operator for enhancement of tubular (i.e. vessels) structures
% proposed by Max K. Law and ACS Chung (http://www.cse.ust.hk/~maxlawwk)

% Law MWK, Chung ACS. 2008. 
% Three Dimensional Curvilinear Structure Detection Using Optimally Oriented Flux. 
% In: Forsyth, D, Torr, P, Zisserman, A, editors. Computer Vision – ECCV 2008. 
% Springer Berlin Heidelberg. Lecture Notes in Computer Science 5305 p. 368–382. 
% http://dx.doi.org/10.1007/978-3-540-88693-8_27.

% Law MWK, Chung ACS. 2010. 
% An Oriented Flux Symmetry Based Active Contour Model for Three Dimensional Vessel Segmentation. 
% In: Daniilidis, K, Maragos, P, Paragios, N, editors. Computer Vision – ECCV 2010. 
% Springer Berlin Heidelberg. Lecture Notes in Computer Science 6313 p. 720–734. 
% http://dx.doi.org/10.1007/978-3-642-15558-1_52.


function [output] = oofofa2( image, range, sigma )
% image:    input image (2D)
% range:    A set of range for OOF/OFA computation (R in Eq. 5 of ECCV 2010),
%           e.g. 1:10.
% sigma:    Optional, the sigma for computation of OOF/OFA (\sigma in Eq.8 of ECCV 2008), default is 1.
%           Beware of the FFT wrap-around artifact.
% output:   output image (2D) with the vessels enhanced 

% for demo of the use see: "vesselness_demoOofOfa_2D.m", 
% and for example output see: % "OOF_OOF-OFA_comparisonDemo.png"

if exist('sigma', 'var')~=1
    sigma=1;
end


fftshiftdummy=image*0;
fftshiftdummy(1,1)=1;
[DCIndexRow,DCIndexCol] = find(fftshift(fftshiftdummy));

imgfreq=fftshift(fft2(image));
[frequ,freqv]=coormatrix(size(image));
frequ=(frequ-DCIndexRow)/size(image,1)+image(1)*0;
freqv=(freqv-DCIndexCol)/size(image,2)+image(1)*0;

% Setting up the oversampling variables to reduce numerical error, see
% Max W. K. Law and Albert C. S. Chung, 
% �Efficient Implementation for Spherical Flux Computation and Its Application to Vascular Segmentation�,
% IEEE Transactions on Image Processing, (TIP� 2009), Volume 18, No. 3, pages 596 � 612
frequo(:,:,3)=frequ+1;
frequo(:,:,2)=frequ;
frequo(:,:,1)=frequ-1;


freqvo(:,:,3)=freqv+1;
freqvo(:,:,2)=freqv;
freqvo(:,:,1)=freqv-1;
% End of setting up the oversampling variables to reduce numerical error


output=image*0;


if (length(sigma)>1)
    sigma = min(sigma)*((max(sigma)/min(sigma)).^(((1:length(sigma))-1)/(length(sigma)-1)));
end
% If there are multiple sigma, we calculate Hessian matrix instead of
% OOF tensor, and the first derivatives of Gaussian instead of OFA. For
% experiments and comparison only.


% Loop through all scales
for i=1:max(length(sigma), length(range))

    if length(sigma)==1
        [freq_11,freq_12,freq_22,freq_1,freq_2]= of(frequo, freqvo, range(i), sigma);
    else
        [freq_11,freq_12,freq_22,freq_1,freq_2]= of(frequo, freqvo, sigma(i));
    end
    
   oof11=ifft2(ifftshift(imgfreq.*  freq_11), 'symmetric');
   oof12=ifft2(ifftshift(imgfreq.*  freq_12), 'symmetric');
   oof22=ifft2(ifftshift(imgfreq.*  freq_22), 'symmetric');
   
   ofa1 = ifft2(ifftshift(imgfreq.*  freq_1), 'symmetric');
   ofa2 = ifft2(ifftshift(imgfreq.*  freq_2), 'symmetric');

   %   oof11 oof12
   % [             ] is the OOF tensor at the current scale
   %   oof12 oof22
   % ofa1 and ofa2 is the OFA vector at the current scale
   
   % This is an example of fast computation of OOF eigenvalues and
   % eigenvectors. Remove them if they are not needed
    tmp=real(sqrt(4*oof12.^2+(oof22-oof11).^2)/2);
    eigenvalue1=(oof11+oof22)/2 - tmp;
    eigenvalue2=(oof11+oof22)/2 + tmp;

    eigenvector1_1=-oof12;    eigenvector1_2=oof11-eigenvalue1;

    
    mag=real(sqrt(eigenvector1_1.^2+eigenvector1_2.^2))+1e-15;
    eigenvector1_1=eigenvector1_1./mag;
    eigenvector1_2=eigenvector1_2./mag;
  % End of eigendecomposition
  
    clear mag 
  % Sort the eigenvector/value pairs according to eigenvalue magnitude    
    condition = (abs(eigenvalue1) >abs(eigenvalue2));
        
    tmpe=eigenvector1_1;
    eigenvector1_1(~condition)= -eigenvector1_2(~condition);    %swap the eigenvector
    eigenvector1_2(~condition)= tmpe(~condition);               %swap the eigenvector    
    tmpe=eigenvalue1;
    eigenvalue1(~condition)=eigenvalue2(~condition);            %swap the eigenvalue
    eigenvalue2(~condition)=tmpe(~condition);                   %swap the eigenvalue
    
  % End of sorting
    
    % Fill in your code to compute the final responses. Here I just return the
    % largest magnitude eigenvalue among scales as the final output. Revise
    % this code according to your need.

    if i==1
        condition = true(size(image));
    else
        condition = (abs(eigenvalue1)>abs(output)); 
    end
    output(condition)=eigenvalue1(condition);
    
end
% End of the loop


  % End of the code. Perform postprocessing of the features if you need.
end

% Max W. K. Law and Albert C. S. Chung, 
% "An Oriented Flux Symmetry based Active Contour Model for Three
% Dimensional Vessel Segmentation"
% The Eleventh European Conference on Computer Vision, (ECCV� 2010),
% Hersonissos, Heraklion, Crete, Greece, September 5 � 11, 2010, LNCS 6313, pp. 720 � 734.

% Max W. K. Law and Albert C. S. Chung, 
% �Three Dimensional Curvilinear Structure Detection using Optimally Oriented Flux�
% The Tenth European Conference on Computer Vision, (ECCV� 2008),
% Marseille, France, October 12 � 18, 2008, LNCS 5305, pp. 368 � 382.
function [oof11, oof12, oof22, ofa1, ofa2] = of(frequo, freqvo, range, sigma)

   oof11= zeros([size(frequo,1) size(freqvo, 2)]);
   oof12= zeros([size(frequo,1) size(freqvo, 2)]);
   oof22= zeros([size(frequo,1) size(freqvo, 2)]);
   ofa1 = zeros([size(frequo,1) size(freqvo, 2)]);
   ofa2 = zeros([size(frequo,1) size(freqvo, 2)]);
   
    if exist('sigma', 'var') == 1   
       for or=1:3
           for oc=1:3

               frequ=frequo(:,:,or);
               freqv=freqvo(:,:,oc);
               radialDistance=sqrt(frequ.^2+freqv.^2)+1e-15;
               
               % http://www.mathworks.com/help/distcomp/gather.html
               % twoPiScaleR = gather(2*pi*range*radialDistance);
               twoPiScaleR = 2*pi*range*radialDistance;
               
               besseljBuffer = exp((-radialDistance.^2).*sigma.*sigma.*2.*pi.*pi) .* ..........
                                besselj(1, twoPiScaleR)./radialDistance..........
                                /(besselj(1, 2*pi*range*1e-15)/1e-15)*pi*range*range/2/pi/range*sqrt(range);

                    oof11=oof11+......
                                4*pi*pi*(frequ.^2 ).* besseljBuffer;
                    oof12=oof12+......
                                4*pi*pi*(frequ.*freqv).* besseljBuffer;
                    oof22=oof22+......
                                4*pi*pi*(freqv.^2).* besseljBuffer;
                    ofa1=ofa1-......
                                2*pi*(frequ ).* besseljBuffer * sqrt(-1);
                    ofa2=ofa2-......
                                2*pi*(freqv ).* besseljBuffer * sqrt(-1);
           
           end  
       end
    else
        
       frequ=frequo(:,:,2);
       freqv=freqvo(:,:,2);
       radialDistance=sqrt(frequ.^2+freqv.^2);
       besseljBuffer = exp((-radialDistance.^2).*range.*range.*2.*pi.*pi) *range^2; 

            oof11=oof11+......
                        4*pi*pi*(frequ.^2 ).* besseljBuffer;
            oof12=oof12+......
                        4*pi*pi*(frequ.*freqv).* besseljBuffer;
            oof22=oof22+......
                        4*pi*pi*(freqv.^2).* besseljBuffer;
            ofa1=ofa1-......
                        2*pi*(frequ ).* besseljBuffer * sqrt(-1);
            ofa2=ofa2-......
                        2*pi*(freqv ).* besseljBuffer * sqrt(-1);
    
    end
end

