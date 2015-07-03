function err=error_diffusion_scheme_2D(u_perfect,u_noise,Dxx,Dxy,Dyy,par,options)
% Parameters must be positive. Otherwise the kernels will go to a more
% cubic like interpolation, which gives artifacts.
par=abs(par);

% Filter the circle image
u = u_noise;
for i=1:options.itt1,
    u=diffusion_scheme_2D_novel(u,Dxx,Dxy,Dyy,options.dt,par);
end
err_test1=sum(abs(u_perfect(:)-u(:)));
if(options.verbose), figure, imshow(u); end


% Heat diffusion test image
u=zeros([65 65]); u(33,33)=1;

% Uniform smoothing eigen values
Dxx=ones(size(u)); Dyy=ones(size(u)); Dxy=zeros(size(u));

% Filter the point image
for j=1:options.itt2
    u=diffusion_scheme_2D_novel(u,Dxx,Dxy,Dyy,options.dt,par);
end
err_test2=fitgaussian(u,0.33,options.dt*options.itt2);
if(options.verbose), figure, imshow(u,[]); end

% Sum the total error
err=err_test1+err_test2*options.alpha;

if(~isfinite(err)), err=10e6+rand; end
