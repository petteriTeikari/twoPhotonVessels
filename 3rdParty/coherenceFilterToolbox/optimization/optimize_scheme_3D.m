functionname='optimize_scheme_3D.m';
functiondir=which(functionname);
functiondir=functiondir(1:end-length(functionname));
addpath([functiondir '../functions2D'])
addpath([functiondir '../functions3D'])
addpath([functiondir '../functions'])

%% Initial values for unknowns in optimal derivative kernels
par =[0.029180542350452,0.051009964656270,0.056702441663829,0.000006816925755, ...
          0.000008999487006,0.000009650996104,0.004751977565242,0.000082895902805, ...
          0.000000310453682,0.002474067467941,0.000007941958352,0.004974632072065, ...
          0.000174128474993,0.004854111687777,0.090614087403327,0.000116874531236, ...
          0.005034186669466,0.000373963590204,0.017456316783794,0.000008810909572, ...
          0.194390591201552,0.000005600928728,0.000003816386672,0.000003302536833, ...
          0.000014736927086,0.000000132136404,0.000005381620877,0.000003078916993, ...
          0.000005671182049,0.000004345622765,0.000004236931951,0.000002758996948, ...
          0.043827391390423];
      
%% Make a test image with, circles of different spatial frequencies
n=60; a=8;  
[x,y,z]=ndgrid(-n:n,-n:n,-n:n);
x=1.1*x/(n/a); 
y=1.1*y/(n/a);  
z=1.1*z/(n/a);
r=sqrt(sqrt(x.^2+y.^2+z.^2))*(n/a)^2;
u_perfect=sin(r);

u_noise=u_perfect+rand(size(u_perfect))*0.05-0.025;
u_perfect=single(u_perfect);
u_noise=single(u_noise);
%% Optimization options
options_opt.dt=0.5;
options_opt.alpha=50000;
options_opt.itt1=30;
options_opt.itt2=5;
options_opt.verbose=false;

%% Make the Diffusion kernel eigenvectors
Options=struct('sigma', 1, 'rho', 1, 'TensorType', 1, 'eigenmode',0,'C', 1e-10, 'm',1,'alpha',0.001,'lambda_e',0.02,'lambda_c',0.02,'lambda_h',0.5,'RealDerivatives',false);

% Gaussian smooth the image, for better gradients
usigma=imgaussian(u_perfect,Options.sigma,4*Options.sigma);

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

%% Find the optimal derivative values
for i=1:10,
    par= fminlbfgs (@(x)error_diffusion_scheme_3D(u_perfect,u_noise,Dxx,Dxy,Dxz,Dyy,Dyz,Dzz,x,options_opt),par,struct('Display','iter','MaxIter',1000,'TolX',1e-6));
    par= fminsearch(@(x)error_diffusion_scheme_3D(u_perfect,u_noise,Dxx,Dxy,Dxz,Dyy,Dyz,Dzz,x,options_opt),par,struct('Display','iter','MaxIter',1000,'TolX',1e-6));
    save('par3d');
end

%% Show the results
error_diffusion_scheme_3D(u_perfect,u_noise,Dxx,Dxy,Dxz,Dyy,Dyz,Dzz,par,options_opt)
