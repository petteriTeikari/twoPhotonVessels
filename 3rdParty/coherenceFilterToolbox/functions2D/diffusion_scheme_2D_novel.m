function u=diffusion_scheme_2D_novel(u,Dxx,Dxy,Dyy,dt,par)
Dxx=repmat(Dxx,[1 1 size(u,3)]);
Dxy=repmat(Dxy,[1 1 size(u,3)]);
Dyy=repmat(Dyy,[1 1 size(u,3)]);

if(nargin<6)
%     par=[0.007520981141059, 0.049564810649554, 0.031509665995882, ...
%          0.037869547950557, 0.111394943940548, 0.448053798986724, ...
%          0.081135611356868,	0.333881751894069, 0.936734100573009, ...
%          0.000936487500442,	0.027595332069424, 0.194217089668822, ...
%          0.006184018622016, 0.948352724021832];
par=[0.00549691757211334,4.75686155670860e-10,3.15405721902292e-11,0.00731109320628158,1.40937549145842e-10,0.0876322157772825,0.0256808495553998,5.87110587298283e-11,0.171008417902939,3.80805359553021e-12,9.86953381462523e-12,0.0231020787600445,0.00638922328831119,0.0350184289706385];

end


Mxx =[par(1)  par(2)  par(3)  par(2)  par(1);
      par(4)  par(5)  par(6)  par(5)  par(4); 
     -par(7) -par(8) -par(9) -par(8) -par(7);
      par(4)  par(5)  par(6)  par(5)  par(4); 
      par(1)  par(2)  par(3)  par(2)  par(1)];
Myy=Mxx';

Mxy=[par(10) par(11)   0    -par(11) -par(10);
     par(11) par(12)   0    -par(12) -par(11);
       0        0      0        0       0
    -par(11) -par(12)  0    par(12) par(11);
    -par(10) -par(11)  0    par(11) par(10)];

Mx= [par(13)  par(14)  par(13); 
		0 	    0 	      0; 
	-par(13) -par(14) -par(13)];
My= Mx';

ux=imfilter(u,Mx,'conv','same','replicate');
uy=imfilter(u,My,'conv','same','replicate');
div1=imfilter(Dxx,Mx,'conv','same','replicate')+imfilter(Dxy,My,'conv','same','replicate');
div2=imfilter(Dxy,Mx,'conv','same','replicate')+imfilter(Dyy,My,'conv','same','replicate');
du1= div1.*ux+div2.*uy;

clear ux uy div1 div2

uxx=imfilter(u,Mxx,'conv','same','replicate');
uxy=imfilter(u,Mxy,'conv','same','replicate');
uyy=imfilter(u,Myy,'conv','same','replicate');
du2=uxx.*Dxx+2*uxy.*Dxy + uyy.*Dyy;

clear uxx uxy uyy Dxx Dxy Dyy

du=du1+du2;

u=u+du*dt;

u(~isfinite(u))=0;


	