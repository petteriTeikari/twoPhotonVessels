#include "mex.h"
#include "math.h"
#define CLAMPD(x, low, high)  (((x) > (high)) ? (high) : (((x) < (low)) ? (low) : (x)))
#define MAXD(a, b)  (((a) > (b)) ? (a) : (b))
#define MIND(a, b)  (((a) < (b)) ? (a) : (b))

void diffusion_scheme_3D_novel_getUpdate(float *u,float *Dxx,float *Dxy,float *Dxz,float *Dyy,float *Dyz,float *Dzz,float *Mx,float *My,float *Mz,float *Mxx,float *Myy,float *Mzz,float *Mxy,float *Mxz,float *Myz,float dt, int *sizeI)
{
    int x,y,z;
    int sz=sizeI[0]*sizeI[1];
    int sy=sizeI[0];
    int index, indexc, indexk;
    int kx, ky, kz, zk, yk, xk;
    float div1a, div1b, div2a, div2b, div3a, div3b;
    float uxx, uyy, uzz, uxy, uxz, uyz;
    float du1, du2, du;
    for(z=0;z<sizeI[2];z++)
    {
        for(y=0;y<sizeI[1];y++)
        {
            for(x=0;x<sizeI[0];x++)
            {
                indexc=z*sz+y*sy+x;

                div1a=0; div1b=0;
                div2a=0; div2b=0;
                div3a=0; div3b=0;

                for(kz=-1;kz<2; kz++)
                {
                    zk=CLAMPD(z+kz,0,sizeI[2]-1);
                    for(ky=-1;ky<2; ky++)
                    {
                        yk=CLAMPD(y+ky,0,sizeI[1]-1);
                        for(kx=-1;kx<2; kx++)
                        {
                            xk=CLAMPD(x+kx,0,sizeI[0]-1);

                            indexk=(kz+1)*9+(ky+1)*3+(kx+1);
                            index=zk*sz+yk*sy+xk;
                            div1a+=u[index]*Mx[indexk];
                            div2a+=u[index]*My[indexk];
                            div3a+=u[index]*Mz[indexk];
                            div1b+=Dxx[index]*Mx[indexk]+Dxy[index]*My[indexk]+Dxz[index]*Mz[indexk];
                            div2b+=Dxy[index]*Mx[indexk]+Dyy[index]*My[indexk]+Dyz[index]*Mz[indexk];
                            div3b+=Dxz[index]*Mx[indexk]+Dyz[index]*My[indexk]+Dzz[index]*Mz[indexk];
                        }
                    }
                }
                du1= div1a*div1b+div2a*div2b+div3a*div3b;

                uxx=0; uyy=0;
                uzz=0; uxy=0;
                uxz=0; uyz=0; 

                for(kz=-2;kz<3; kz++)
                {
                    zk=CLAMPD(z+kz,0,sizeI[2]-1);
                    for(ky=-2;ky<3; ky++)
                    {
                        yk=CLAMPD(y+ky,0,sizeI[1]-1);
                        for(kx=-2;kx<3; kx++)
                        {
                            xk=CLAMPD(x+kx,0,sizeI[0]-1);

                            indexk=(kz+2)*25+(ky+2)*5+(kx+2);
                            index=zk*sz+yk*sy+xk;

                            uxx+=u[index]*Mxx[indexk];
                            uyy+=u[index]*Myy[indexk];
                            uzz+=u[index]*Mzz[indexk];
                            uxy+=u[index]*Mxy[indexk];
                            uxz+=u[index]*Mxz[indexk];
                            uyz+=u[index]*Myz[indexk];
                        }
                    }
                }

                du2 = Dxx[indexc]*uxx + Dyy[indexc]*uyy + Dzz[indexc]*uzz + 2* Dxy[indexc]*uxy +  2*Dxz[indexc]*uxz + 2*Dyz[indexc]*uyz;

                du=du2+du1; 
                u[indexc]+=du*dt;
            }
        }
    }
}

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] ) {
    float *Uin, *Uout;
    float *Dxx, *Dxy, *Dxz, *Dyy, *Dyz, *Dzz;
    float *Mx, *My, *Mz, *Mxx, *Myy, *Mzz, *Mxy, *Mxz, *Myz;
    float *DT;        
    
    const mwSize *dimsu_const;
    int dimsu[3];
    int npixels;
    Uin=(float *)mxGetData(prhs[0]); 
    
    Dxx=(float *)mxGetData(prhs[1]); 
    Dxy=(float *)mxGetData(prhs[2]); 
    Dxz=(float *)mxGetData(prhs[3]); 
    Dyy=(float *)mxGetData(prhs[4]); 
    Dyz=(float *)mxGetData(prhs[5]); 
    Dzz=(float *)mxGetData(prhs[6]); 
    
    Mx=(float *)mxGetData(prhs[7]); 
    My=(float *)mxGetData(prhs[8]); 
    Mz=(float *)mxGetData(prhs[9]); 
    
    Mxx=(float *)mxGetData(prhs[10]); 
    Myy=(float *)mxGetData(prhs[11]); 
    Mzz=(float *)mxGetData(prhs[12]); 
    Mxy=(float *)mxGetData(prhs[13]); 
    Mxz=(float *)mxGetData(prhs[14]); 
    Myz=(float *)mxGetData(prhs[15]); 

    DT=(float *)mxGetData(prhs[16]); 
   
    dimsu_const = mxGetDimensions(prhs[0]);
    dimsu[0]=dimsu_const[0]; dimsu[1]=dimsu_const[1]; dimsu[2]=dimsu_const[2];
    npixels=dimsu[0]*dimsu[1]*dimsu[2];
    
    plhs[0] = mxCreateNumericArray(3, dimsu, mxSINGLE_CLASS, mxREAL);
    Uout= (float *)mxGetData(plhs[0]);

    memcpy (Uout,Uin,npixels*sizeof(float));

    diffusion_scheme_3D_novel_getUpdate(Uout,Dxx,Dxy,Dxz,Dyy,Dyz,Dzz,Mx,My,Mz,Mxx,Myy,Mzz,Mxy,Mxz,Myz,DT[0],dimsu);
}
