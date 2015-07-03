function u = CoherenceFilter(u,Options)
% This function COHERENCEFILTER will perform Anisotropic Diffusion of a
% 2D gray/color image or 3D image volume, Which will reduce the noise in
% an image while preserving the region edges, and will smooth along
% the image edges removing gaps due to noise.
%
% Don't forget to compile the c-code by executing compile_c_files.m
% 
% Iout = CoherenceFilter(Iin, Options)
%
% inputs,
%   Iin : 2D gray/color image or 3D image volume. Use double datatype in 2D
%            and single data type in 3D.  Range of image data must 
%            be approximately [0 1]
%   Options : Struct with filtering options
%   
% outputs,
%   Iout : The anisotropic diffusion filtered image
%
% Options,
%   Options.Scheme :  The numerical diffusion scheme used
%                     'R', Rotation Invariant, Standard Discretization 
%                          (implicit) 5x5 kernel (Default)
%                     'O', Optimized Derivative Kernels
%                     'I', Implicit Discretization (only works in 2D)
%                     'S', Standard Discretization
%                     'N', Non-negativity Discretization
%   Options.T  :      The total diffusion time (default 5)
%   Options.dt :      Diffusion time stepsize, in case of scheme H,R or I
%                     defaults to 1, in case of scheme S or N defaults to
%                     0.15. 
%   Options.sigma :   Sigma of gaussian smoothing before calculation of the
%                     image Hessian, default 1.                   
%   Options.rho :     Rho gives the sigma of the Gaussian smoothing of the 
%                     Hessian, default 1.
%   Options.verbose : Show information about the filtering, values :
%                     'none', 'iter' (default) , 'full'
%   Options.eigenmode : There are many different equations to make an diffusion tensor,
%						this value (only 3D) selects one.
%					    0 (default) : Weickerts equation, line like kernel
%						1 : Weickerts equation, plane like kernel
%						2 : Edge enhancing diffusion (EED)
%						3 : Coherence-enhancing diffusion (CED)
%						4 : Hybrid Diffusion With Continuous Switch (HDCS)
%
% Constants which determine the amplitude of the diffusion smoothing in 
% Weickert equation
%   Options.C :     Default 1e-10
%   Options.m :     Default 1
%   Options.alpha : Default 0.001
% Constants which are needed with CED, EED and HDCS eigenmode
%   Options.lambda_e : Default 0.02, planar structure contrast
%   Options.lambda_c : Default 0.02, tube like structure contrast
%   Options.lambda_h : Default 0.5 , treshold between structure and noise
%                     
%
% The basis of the method used is the one introduced by Weickert:
%   1, Calculate Hessian from every pixel of the gaussian smoothed input image
%   2, Gaussian Smooth the Hessian, and calculate its eigenvectors and values
%      (Image edges give large eigenvalues, and the eigenvectors corresponding
%         to those large eigenvalues describe the direction of the edge)
%   3, The eigenvectors are used as diffusion tensor directions. The 
%      amplitude of the diffusion in those 3 directions is determined
%      by equations below.
%   4, An Finite Difference scheme is used to do the diffusion
%   5, Back to step 1, till a certain diffusion time is reached.
%
% Weickert equation 2D:
%    lambda1 = alpha + (1 - alpha)*exp(-C/(mu1-mu2).^(2*m)); 
%    lambda2 = alpha;
%
% 0 : 3D, Weickerts equation, plane line like kernel
%    lambda1 = alpha + (1 - alpha)*exp(-C/(mu1-mu3).^(2*m)); 
%    lambda2 = alpha;
%    lambda3 = alpha;
%   (with mu1 the largest eigenvalue and mu3 the smallest)
% 1 : 3D, Weickerts equation, plane line like kernel
%    lambda1 = alpha + (1 - alpha)*exp(-C/(mu1-mu3).^(2*m)); 
%    lambda2 = alpha + (1 - alpha)*exp(-C/(mu2-mu3).^(2*m)); 
%    lambda3 = alpha;
%   (with mu1 the largest eigenvalue and mu3 the smallest)
% 2 : 3D, Edge Enhancing diffusion
%    lambda3e = 1;
%    lambda2e = 1;
%    lambda1e = 1 - exp(-3.31488 / (Gradient_Magnitude_Squared / lambda_e^2)^4);
% 3 : 3D, Coherence Enhancing diffusion
%    lambda1c = alpha + (1 - alpha)*exp(-ln(2)*lambda_c^2/(mu2/(alpha+mu3))^4)); 
%    lambda2c = alpha;
%    lambda3c = alpha;
% 4 :  Hybrid Diffusion With Continuous Switch
%	Xi : = (mu1 / (alpha+mu2)) - (mu2 / (alpha+mu3))
%	epsilon = exp ( mu2*(lambda_h^2(Xi-abs(Xi)-2*mu3) )/ ( 2 * lambda_h^4) )
%	lambda1 = (1 -epsilon) * lambda1c + epsilon *lambda1e;
%	lambda2 = (1 -epsilon) * lambda2c + epsilon *lambda2e;
%	lambda3 = (1 -epsilon) * lambda3c + epsilon *lambda3e;
%
% Notes:
% - The standard and non-negative discretization only allow small time
%   steps before they become unstable. The Implicit discretization 
%   was introduced to allow larger diffusion time steps. 
%   Previous schemes were not rotational invariant, under certain angles
%   edges blur away. Thus Weickert introduced a rotational invariant scheme.
%   His scheme sufferes from checkerboard artifacts, due to the central
%   differences used. This code contains our own improved version of his 
%   scheme in which  the data is upsampled before calculating the image 
%   derivatives for the diffusion flux, to prevent those checkerboard artifacts.
%  
% - If the time step is choosing to large the scheme becomes unstable, this
%   can be seen by setting verbose to 'full'. The image variance has to
%   decrease every itteration if the scheme is stable.
%
% Literature used (for the full list see my own paper):
%  - Weickert : "A Scheme for Coherence-Enhancing Diffusion Filtering
%                   with Optimized Rotation Invariance"
%  - Mendrik et al, "Noise Reduction in Computed Tomography Scans Using
%					3-D Anisotropic Hybrid Diffusion With Continuous 
%					Switch", October 2009
%  - Weickert : "Anisotropic Diffusion in Image Processing", Thesis 1996
%  - Laura Fritz : "Diffusion-Based Applications for Interactive Medical
%                   Image Segmentation"
%  - Siham Tabik, et al. : "Multiprocessing of Anisotropic Nonlinear
%                          Diffusion for filtering 3D image"
%  
% example 2d,
%   I = im2double(imread('images/sync_noise.png'));
%   JS = CoherenceFilter(I,struct('T',15,'rho',10,'Scheme','S'));
%   JN = CoherenceFilter(I,struct('T',15,'rho',10,'Scheme','N'));
%   JR = CoherenceFilter(I,struct('T',15,'rho',10,'Scheme','R'));
%   JI = CoherenceFilter(I,struct('T',15,'rho',10,'Scheme','I'));
%   JO = CoherenceFilter(I,struct('T',15,'rho',10,'Scheme','O'));
%   figure, 
%   subplot(2,3,1), imshow(I), title('Before Filtering');
%   subplot(2,3,2), imshow(JI), title('Standard Scheme');
%   subplot(2,3,3), imshow(JN), title('Non Negative Scheme');
%   subplot(2,3,4), imshow(JI), title('Implicit Scheme');
%   subplot(2,3,5), imshow(JR), title('Rotation Invariant Scheme');
%   subplot(2,3,6), imshow(JO), title('Optimized Scheme');
% 
% example 2d, color HDCS 2D not in literature
%   I = im2double(imread('images/lena.jpg'));
%   I = I+(rand(size(I))-0.5)*0.3;
%   JO =      CoherenceFilter(I,struct('T',1,'dt',0.1,'rho',4,'Scheme','O','eigenmode',0));
%   JO_EED =  CoherenceFilter(I,struct('T',1,'dt',0.1,'rho',4,'Scheme','O','eigenmode',2));
%   JO_HDCS = CoherenceFilter(I,struct('T',1,'dt',0.1,'rho',4,'Scheme','O','eigenmode',4));
%   JS_HDCS = CoherenceFilter(I,struct('T',1,'dt',0.1,'rho',4,'Scheme','S','eigenmode',4));
%   JR_HDCS = CoherenceFilter(I,struct('T',1,'dt',0.1,'rho',4,'Scheme','R','eigenmode',4));
%
%   figure, 
%   subplot(2,3,1), imshow(I), title('Before Filtering');
%   subplot(2,3,2), imshow(JO), title('Optimized Scheme');
%   subplot(2,3,3), imshow(JO_EED), title('Edge Enhancing Optimized Scheme');
%   subplot(2,3,4), imshow(JO_HDCS), title('HDCS Optimized Scheme');
%   subplot(2,3,5), imshow(JS_HDCS), title('HDCS Standard Scheme');
%   subplot(2,3,6), imshow(JR_HDCS), title('Rotation invariant Scheme');
%
% example 3d,
%	% First compile the c-code by executing compile_c_files.m
%   load('images/sphere');
%   showcs3(V);
%   JR = CoherenceFilter(V,struct('T',50,'dt',2,'Scheme','R'));
%   showcs3(JR);
%
% example 3d, Mendrik : Hybrid Diffusion October 2009
%   load('images/sphere');
%   showcs3(V);
%   JS = CoherenceFilter(V,struct('T',5,'dt',0.15,'Scheme','S','eigenmode',4));
%   JO = CoherenceFilter(V,struct('T',5,'dt',0.50,'Scheme','O','eigenmode',4));
%   showcs3(JS);
%   showcs3(JO);
%
% Written by D.Kroon University of Twente (February 2010)

% add all needed function paths
try
    functionname='CoherenceFilter.m';
    functiondir=which(functionname);
    functiondir=functiondir(1:end-length(functionname));
    addpath([functiondir '/functions2D'])
    addpath([functiondir '/functions3D'])
    addpath([functiondir '/functions'])
catch me
    disp(me.message);
end

% Default parameters
defaultoptions=struct('T',2,'dt',[],'sigma', 1, 'rho', 1, 'TensorType', 1, 'eigenmode',0,'C', 1e-10, 'm',1,'alpha',0.001,'lambda_e',0.02,'lambda_c',0.02,'lambda_h',0.5,'RealDerivatives',false,'Scheme','R','verbose','iter');

if(~exist('Options','var')),
    Options=defaultoptions;
else
    tags = fieldnames(defaultoptions);
    for i=1:length(tags)
        if(~isfield(Options,tags{i})),  Options.(tags{i})=defaultoptions.(tags{i}); end
    end
    if(length(tags)~=length(fieldnames(Options))),
        warning('CoherenceFilter:unknownoption','unknown options found');
    end
end

if(isempty(Options.dt))
    switch lower(Options.Scheme)
      case 'r', Options.dt=0.15;
      case 'o', Options.dt=0.15;
      case 'i', Options.dt=0.15;
      case 's', Options.dt=0.15;
      case 'n', Options.dt=0.15;
      otherwise
        error('CoherenceFilter:unknownoption','unknown scheme');
    end
end
    

% Initialization
dt_max = Options.dt; t = 0;

% In case of 3D use single precision to save memory
if(size(u,3)<4), u=double(u); else u=single(u); end 

% Process time
process_time=tic;

% Show information 
switch lower(Options.verbose(1))
case 'i'
    disp('Diffusion time   Sec. Elapsed');
case 'f'
    disp('Diffusion time   Sec. Elapsed   Image mean    Image variance');
end        


% Anisotropic diffusion main loop
while (t < (Options.T-0.001))
    % Update time, adjust last time step to exactly finish at the wanted
    % diffusion time
    Options.dt = min(dt_max,Options.T-t); t = t + Options.dt;
    tn=toc(process_time);
    switch lower(Options.verbose(1))
    case 'n'
    case 'i'
        s=sprintf('    %5.0f        %5.0f    ',t,round(tn)); disp(s);
    case 'f'
        s=sprintf('    %5.0f        %5.0f      %13.6g    %13.6g ',t,round(tn), mean(u(:)), var(u(:))); disp(s);
    
    end        
   
    % Options.Scheme
    if(size(u,3)<4) % Check if 2D or 3D
        % Do a diffusion step
        if(strcmpi(Options.Scheme,'R')&&(Options.eigenmode==0)&&(exist('CoherenceFilterStep2D')==3))
            u=CoherenceFilterStep2D(u,Options);
        else
            u=Anisotropic_step2D(u,Options);
        end
    else
        % Do a diffusion step
        if(strcmpi(Options.Scheme,'R'))
            u=CoherenceFilterStep3D(u,Options);
        else
            u=Anisotropic_step3D(u,Options);
        end
    end
end

function u=Anisotropic_step2D(u,Options)
% Perform tensor-driven diffusion filtering update

% Gaussian smooth the image, for better gradients
usigma=imgaussian(u,Options.sigma,4*Options.sigma);


% Calculate the gradients
switch lower(Options.Scheme)
  case {'r','o','i'}
    ux=derivatives(usigma,'x'); uy=derivatives(usigma,'y');
  case {'s','n'}
    [uy,ux]=gradient(usigma);
  otherwise
    error('CoherenceFilter:unknownoption','unknown scheme');
end


% Compute the 2D structure tensors J of the image
[Jxx, Jxy, Jyy] = StructureTensor2D(ux,uy,Options.rho);

% Compute the eigenvectors and values of the strucure tensors, v1 and v2, mu1 and mu2
[mu1,mu2,v1x,v1y,v2x,v2y]=EigenVectors2D(Jxx,Jxy,Jyy);

% Gradient magnitude squared
gradA=ux.^2+uy.^2;

% Construct the edge preserving diffusion tensors D = [Dxx,Dxy;Dxy,Dyy]
[Dxx,Dxy,Dyy]=ConstructDiffusionTensor2D(mu1,mu2,v1x,v1y,v2x,v2y,gradA,Options);

% Do the image diffusion
switch lower(Options.Scheme)
  case 'o'
      u=diffusion_scheme_2D_novel(u,Dxx,Dxy,Dyy,Options.dt);
      %u=diffusion_scheme_2D_high_rotation(u,Dxx,Dxy,Dyy,Options.dt,b);
  case 'r'
      u=diffusion_scheme_2D_rotation_invariant(u,Dxx,Dxy,Dyy,Options.dt);
  case 'i'
      u=diffusion_scheme_2D_implicit(u,Dxx,Dxy,Dyy,Options.dt);
  case 's'
      u=diffusion_scheme_2D_standard(u,Dxx,Dxy,Dyy,Options.dt);
  case 'n'
      u=diffusion_scheme_2D_non_negativity(u,Dxx,Dxy,Dyy,Options.dt);
  otherwise
    error('CoherenceFilter:unknownoption','unknown scheme');
end

function u=Anisotropic_step3D(u,Options)
% Perform tensor-driven diffusion filtering update

% Gaussian smooth the image, for better gradients
usigma=imgaussian(u,Options.sigma,4*Options.sigma);

% Calculate the gradients
ux=derivatives(usigma,'x');
uy=derivatives(usigma,'y');
uz=derivatives(usigma,'z');

% Compute the 3D structure tensors J of the image
[Jxx, Jxy, Jxz, Jyy, Jyz, Jzz] = StructureTensor3D(ux,uy,uz, Options.rho);

% Gradient magnitude squared
gradA=ux.^2+uy.^2+uz.^2;

% Free memory
clear ux; clear uy; clear uz;

% Compute the eigenvectors and eigenvalues of the hessian and directly
% use the equation of Weickert to convert them to diffusion tensors
[Dxx,Dxy,Dxz,Dyy,Dyz,Dzz]=StructureTensor2DiffusionTensor3D(Jxx,Jxy,Jxz,Jyy,Jyz,Jzz,gradA,Options); 

% Free memory
clear J*;

% Do the image diffusion
switch lower(Options.Scheme)
  case 'o'
      u=diffusion_scheme_3D_novel(u,Dxx,Dxy,Dxz,Dyy,Dyz,Dzz,Options.dt);
      %u=diffusion_scheme_3D_high_rotation(u,Dxx,Dxy,Dxz,Dyy,Dyz,Dzz,Options.dt);
  case 'r'
      u=diffusion_scheme_3D_rotation_invariant(u,Dxx,Dxy,Dxz,Dyy,Dyz,Dzz,Options.dt);
  case 'i'
      u=diffusion_scheme_3D_implicit(u,Dxx,Dxy,Dxz,Dyy,Dyz,Dzz,Options.dt);
  case 's'
      u=diffusion_scheme_3D_standard(u,Dxx,Dxy,Dxz,Dyy,Dyz,Dzz,Options.dt);
  case 'n'
      u=diffusion_scheme_3D_non_negativity(u,Dxx,Dxy,Dxz,Dyy,Dyz,Dzz,Options.dt);
  otherwise
    error('CoherenceFilter:unknownoption','unknown scheme');
end




        