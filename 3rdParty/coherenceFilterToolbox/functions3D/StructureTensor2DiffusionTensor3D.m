function [Dxx,Dxy,Dxz,Dyy,Dyz,Dzz]=StructureTensor2DiffusionTensor3D(Jxx,Jxy,Jxz,Jyy,Jyz,Jzz,gradA,Options)
% From Structure Tensor to Diffusion Tensor
%
% [Dxx,Dxy,Dxz,Dyy,Dyz,Dzz]=StructureTensor2DiffusionTensor3DJxx,Jxy,Jxz,Jyy,Jyz,Jzz,gradA,Options)
% 
% Function is written by D.Kroon University of Twente (November 2009)

% Compute the eigenvectors and values of the structure tensors, v1, v2
% and v3, mu1, mu2 and mu3
[mu1,mu2,mu3,v3x,v3y,v3z,v2x,v2y,v2z,v1x,v1y,v1z]=EigenVectors3D(Jxx, Jxy, Jxz, Jyy, Jyz, Jzz);

[Dxx,Dxy,Dxz,Dyy,Dyz,Dzz]=ConstructDiffusionTensor3D(v1x,v1y,v1z,v2x,v2y,v2z,v3x,v3y,v3z,gradA,mu1,mu2,mu3,Options);

function  [Dxx,Dxy,Dxz,Dyy,Dyz,Dzz]=ConstructDiffusionTensor3D(v1x,v1y,v1z,v2x,v2y,v2z,v3x,v3y,v3z,gradA,mu1,mu2,mu3,Options)
% Construct the edge preserving diffusion tensors D = [Dxx,Dxy,Dxz;Dxy,Dyy,Dyz;Dxz,Dyz,Dzz]

% Scaling of diffusion tensors
if(Options.eigenmode==0) % Weickert line shaped 
    di=(mu1-mu3); di((di<1e-15)&(di>-1e-15))=1e-15;
    lambda1 = Options.alpha + (1 - Options.alpha)*exp(-Options.C./di.^(2*Options.m)); 
    lambda2 = Options.alpha; 
    lambda3 = Options.alpha;
elseif(Options.eigenmode==1) % Weickert plane shaped 
    di=(mu1-mu3); di((di<1e-15)&(di>-1e-15))=1e-15;
    lambda1 = Options.alpha + (1 - Options.alpha)*exp(-Options.C./di.^(2*Options.m)); 
    di=(mu2-mu3); di((di<1e-15)&(di>-1e-15))=1e-15;
    lambda2 = Options.alpha + (1 - Options.alpha)*exp(-Options.C./di.^(2*Options.m)); 
    lambda3 = Options.alpha;
elseif(Options.eigenmode==2) % EED
    lambda3 = 1 - exp(-3.31488./(gradA./Options.lambda_e^2).^4);
    lambda3(gradA<1e-15)=1;
    lambda2 = 1;
    lambda1 = 1;
elseif(Options.eigenmode==3) % CED
    lambda3 = Options.alpha;
    lambda2 = Options.alpha;
    lambda1= Options.alpha + (1.0- Options.alpha)*exp(-0.6931*Options.lambda_c^2./(mu2./(Options.alpha+mu3)).^4);
    lambda1((mu2<1e-15)&(mu2>-1e-15))=0;
    lambda1((mu3<1e-15)&(mu3>-1e-15))=0;
elseif(Options.eigenmode==4) % Hybrid Diffusion with Continous Switch
    lambdae3 = 1 - exp(-3.31488./(gradA./Options.lambda_e^2).^4);
    lambdae3(gradA<1e-15)=1;
    lambdae2 = 1;
    lambdae1 = 1;

    lambdac3 = Options.alpha;
    lambdac2 = Options.alpha;
    lambdac1= Options.alpha + (1.0- Options.alpha)*exp(-0.6931*Options.lambda_c^2./(mu2./(Options.alpha+mu3)).^4);
    lambdac1((mu2<1e-15)&(mu2>-1e-15))=0;
    lambdac1((mu3<1e-15)&(mu3>-1e-15))=0;

    xi= ( (mu1 ./ (Options.alpha + mu2)) - (mu2 ./ (Options.alpha + mu3) ));
    di=2.0*Options.lambda_h^4;
    epsilon = exp(mu2.*(Options.lambda_h^2.*(xi-abs(xi))-2.0*mu3)./di);

    lambda1 = (1-epsilon) .* lambdac1 + epsilon .* lambdae1;
    lambda2 = (1-epsilon) .* lambdac2 + epsilon .* lambdae2;
    lambda3 = (1-epsilon) .* lambdac3 + epsilon .* lambdae3;
end
    
% Construct the tensors
Dxx = lambda1.*v1x.^2   + lambda2.*v2x.^2   + lambda3.*v3x.^2;
Dyy = lambda1.*v1y.^2   + lambda2.*v2y.^2   + lambda3.*v3y.^2;
Dzz = lambda1.*v1z.^2   + lambda2.*v2z.^2   + lambda3.*v3z.^2;

Dxy = lambda1.*v1x.*v1y + lambda2.*v2x.*v2y + lambda3.*v3x.*v3y;
Dxz = lambda1.*v1x.*v1z + lambda2.*v2x.*v2z + lambda3.*v3x.*v3z;
Dyz = lambda1.*v1y.*v1z + lambda2.*v2y.*v2z + lambda3.*v3y.*v3z;

