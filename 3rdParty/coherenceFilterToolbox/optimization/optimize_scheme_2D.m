% This script finds optimized kernel values for in the novel discretization
% scheme. With the options_opt.alpha, you can change the balance between
% edge preserving properties and gaussian smoothing in uniform regions.
%
% This script takes a long time to converge

functionname='optimize_scheme_2D.m';
functiondir=which(functionname);
functiondir=functiondir(1:end-length(functionname));
addpath([functiondir '../functions2D'])
addpath([functiondir '../functions3D'])
addpath([functiondir '../functions'])


%% Initial values for unknowns in optimal derivative kernels
par=[0.007520981141059, 0.049564810649554, 0.031509665995882, ...
	 0.037869547950557, 0.111394943940548, 0.448053798986724, ...
	 0.081135611356868,	0.333881751894069, 0.936734100573009, ...
	 0.000936487500442,	0.027595332069424, 0.194217089668822, ...
	 0.006184018622016, 0.948352724021832];

%% Make a test image with, circles of different spatial frequencies
[x,y]=ndgrid(-128:128); 
x=1.1*x/12.7; y=1.1*y/12.7;
u_perfect=sin(x.^2+y.^2);
u_noise=u_perfect+rand(size(u_perfect))*0.04-0.020;

%% Optimization options
options_opt.dt=0.5;
options_opt.alpha=50000;
options_opt.itt1=5;
options_opt.itt2=5;
options_opt.verbose=false;

%% Make the Diffusion kernel eigenvectors
Options=struct('sigma', 1, 'rho', 1, 'TensorType', 1, 'eigenmode',4,'C', 1e-10, 'm',1,'alpha',0.001,'lambda_e',0.02,'lambda_c',0.02,'lambda_h',0.5,'RealDerivatives',false);

% Gaussian smooth the image, for better gradients
usigma=imgaussian(u_noise,Options.sigma,4*Options.sigma);

% Calculate the gradients
ux=derivatives(usigma,'x'); 
uy=derivatives(usigma,'y');

% Compute the 2D structure tensors J of the image
[Jxx, Jxy, Jyy] = StructureTensor2D(ux,uy,Options.rho);
% Compute the eigenvectors and values of the strucure tensors, v1 and v2, mu1 and mu2
[mu1,mu2,v1x,v1y,v2x,v2y]=EigenVectors2D(Jxx,Jxy,Jyy);
% Gradient magnitude squared
gradA=ux.^2+uy.^2;
% Construct the edge preserving diffusion tensors D = [Dxx,Dxy;Dxy,Dyy]
[Dxx,Dxy,Dyy]=ConstructDiffusionTensor2D(mu1,mu2,v1x,v1y,v2x,v2y,gradA,Options);


%% Find the optimal derivative values
for i=1:10,
    par= fminlbfgs (@(x)error_diffusion_scheme_2D(u_perfect,u_noise,Dxx,Dxy,Dyy,x,options_opt),par,struct('Display','iter','MaxIter',5000,'TolX',1e-6));
    par= fminsearch(@(x)error_diffusion_scheme_2D(u_perfect,u_noise,Dxx,Dxy,Dyy,x,options_opt),par,struct('Display','iter','MaxIter',1000,'TolX',1e-6));
end

par=abs(par);

%% Show the results
options_opt.verbose=true;
error_diffusion_scheme_2D(u_perfect,u_noise,Dxx,Dxy,Dyy,par,options_opt)


