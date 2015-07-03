function u=diffusion_scheme_3D_novel_getUpdate(u,Dxx,Dxy,Dxz,Dyy,Dyz,Dzz,Mx,My,Mz,Mxx,Myy,Mzz,Mxy,Mxz,Myz,dt)
Mx=double(Mx);
My=double(My);
Mz=double(Mz);
Mxx=double(Mxx);
Myy=double(Myy);
Mzz=double(Mzz);
Mxy=double(Mxy);
Mxz=double(Mxz);
Myz=double(Myz);

div1=imfilter(u,Mx,'conv','same','replicate').*(imfilter(Dxx,Mx,'conv','same','replicate')+imfilter(Dxy,My,'conv','same','replicate')+imfilter(Dxz,Mz,'conv','same','replicate'));
div2=imfilter(u,My,'conv','same','replicate').*(imfilter(Dxy,Mx,'conv','same','replicate')+imfilter(Dyy,My,'conv','same','replicate')+imfilter(Dyz,Mz,'conv','same','replicate'));
div3=imfilter(u,Mz,'conv','same','replicate').*(imfilter(Dxz,Mx,'conv','same','replicate')+imfilter(Dyz,My,'conv','same','replicate')+imfilter(Dzz,Mz,'conv','same','replicate'));
du1= div1+div2+div3;

clear div1 div2 div3;

uxx=imfilter(u,Mxx,'conv','same','replicate');
uyy=imfilter(u,Myy,'conv','same','replicate');
uzz=imfilter(u,Mzz,'conv','same','replicate');
uxy=imfilter(u,Mxy,'conv','same','replicate');
uxz=imfilter(u,Mxz,'conv','same','replicate');
uyz=imfilter(u,Myz,'conv','same','replicate');
du2 = Dxx.*uxx + Dyy.*uyy + Dzz.*uzz + 2* Dxy.*uxy +  2*Dxz.*uxz + 2*Dyz.*uyz;

clear uxx uyy uzz uxy uxz uyz;

du=du2+du1;
u=u+du*dt;
