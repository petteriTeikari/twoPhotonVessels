function [Lambda1,Lambda2,I2x,I2y,I1x,I1y]=EigenVectors2D(Dxx,Dxy,Dyy)
% This function computes the eigenvectors and eigen values of the 2D image
% Hessian
%
% [mu1,mu2,v1x,v1y,v2x,v2y]=EigenVectors2D(Jxx,Jxy,Jyy)
%
% inputs, 
%   Jxx, Jxy and Jyy : Matrices with the values of the Hessian tensors
% 
% outputs,
%   mu1, mu2 : Matrices with eigen values
%   v1x, v1y, v2x, v2y : Matrices with the eigen vectors
% 
% Function is written by D.Kroon University of Twente (September 2009)

% Compute the eigenvectors of J, v1 and v2
tmp = sqrt((Dxx - Dyy).^2 + 4*Dxy.^2);
v2x = 2*Dxy; v2y = Dyy - Dxx + tmp;

% Normalize
mag = sqrt(v2x.^2 + v2y.^2); i = (mag ~= 0);
v2x(i) = v2x(i)./mag(i);
v2y(i) = v2y(i)./mag(i);

% The eigenvectors are orthogonal
v1x = -v2y; 
v1y = v2x;

% Compute the eigenvalues
mu1 = 0.5*(Dxx + Dyy + tmp);
mu2 = 0.5*(Dxx + Dyy - tmp);

% Sort eigen values by absolute value abs(Lambda1)<abs(Lambda2)
check=abs(mu1)>abs(mu2);

Lambda1=mu1; Lambda1(check)=mu2(check);
Lambda2=mu2; Lambda2(check)=mu1(check);

I1x=v1x; I1y=v1y; I2x=v2x; I2y=v2y; 
I1x(check)=v2x(check); I1y(check)=v2y(check);
I2x(check)=v1x(check); I2y(check)=v1y(check);

