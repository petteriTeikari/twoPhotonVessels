function [x11,x12,x22]=hessian(x)

%m11=(1/8)*[1 6 1;-2 -12 -2; 1 6 1]';
%m22=(1/8)*[1 6 1;-2 -12 -2; 1 6 1];
%m12=1/4*[1 0 -1; 0 0 0; -1 0 1];

% m11= [ 0.0491  0.0778  0.0491; 
%       -0.0982 -0.1556 -0.0982; 
%        0.0491  0.0778 0.0491];
% m12=[ 0.0495 0 -0.0495; 
%       0      0       0;
%      -0.0495 0  0.0495];
% m22=m11';

x12=derivatives(derivatives(x,'x'),'y');
xL=imresize2(x);
xL1=derivatives(xL,'x');
xL2=derivatives(xL,'y');
xL11=derivatives(xL1,'x');
xL22=derivatives(xL2,'y');
x11=xL11(1:2:end,1:2:end);
x22=xL22(1:2:end,1:2:end);


%x11=imfilter(x,m11,'conv','same','replicate');
%x12=imfilter(x,m12,'conv','same','replicate');
%x22=imfilter(x,m22,'conv','same','replicate');


