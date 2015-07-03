#include "mex.h"
#include "math.h"
/*   undef needed for LCC compiler  */
#undef EXTERN_C
#ifdef _WIN32
	#include <windows.h>
	#include <process.h>
#else
	#include <pthread.h>
#endif
#include "stdlib.h"
#ifndef min
#define min(a,b)        ((a) < (b) ? (a): (b))
#endif
#ifndef max
#define max(a,b)        ((a) > (b) ? (a): (b))
#endif
#define clamp(a, b1, b2) min(max(a, b1), b2);
#define absd(a) ((a)>(-a)?(a):(-a))
#define pow2(a) (a*a)
#define pow4(a) (pow2(a)*pow2(a))
#define n 3
#define inv3 0.3333333333333333
#define root3 1.7320508075688772
#include "EigenDecomposition3.c"


struct options {
    double T;
    double dt;
    double sigma;
    double rho;
    double C;
    double m;
    double alpha;
    int eigenmode;
	double lambda_e;
    double lambda_h;
    double lambda_c;
};

void setdefaultoptions(struct options* t) {
    t->T=2;
    t->dt=0.1;
    t->sigma=1;
    t->rho=1;
    t->C=1e-10;
    t->m=1;
    t->alpha=0.001;
    t->eigenmode=0;
    t->lambda_e=30;
    t->lambda_h=30;
    t->lambda_c=15;
}

#ifdef _WIN32
  unsigned __stdcall   StructureTensor2DiffusionTensorThread(float **Args)  {
#else
  void StructureTensor2DiffusionTensorThread(float **Args)  {
#endif
    /* Matrices of Eigenvector calculation */
    double Ma[3][3];
    double Davec[3][3];
    double Daeig[3];
    
    /* Eigenvector and eigenvalues as scalars */
    double mu1, mu2, mu3, v1x, v1y, v1z, v2x, v2y, v2z, v3x, v3y, v3z;
    
    /* Magnitude of gradient */
    float *gradA;
    
    /* Amplitudes of diffustion tensor */
    double lambda1, lambda2, lambda3;
    double lambdac1, lambdac2, lambdac3;
    double lambdae1, lambdae2, lambdae3;
          
    /* Eps for finite values */
    const float eps=(float)1e-20;
    
    /* Loop variable */
    int i;
    
    /* Number of pixels */
    int npixels=1;

    /* The diffusion tensors and structure tensors */
    float *Jxx, *Jxy, *Jxz, *Jyy, *Jyz, *Jzz;
    float *Dxx, *Dxy, *Dxz, *Dyy, *Dyz, *Dzz;
    
    int dimsu[3];
    float *dimsu_f, *constants_f, *Nthreads_f, *ThreadID_f;
    
    /* Number of threads */
    int ThreadOffset, Nthreads;
    
    /* Constants */
    double C, m, alpha, lambda_h, lambda_e, lambda_c;

    /* Choice of eigenvalue equation */
    int eigenmode;
    
    /* Temporary variables */
    double di, epsilon, xi;
       
    Jxx=Args[0];
    Jxy=Args[1];
    Jxz=Args[2];
    Jyy=Args[3];
    Jyz=Args[4];
    Jzz=Args[5];
    Dxx=Args[6];
    Dxy=Args[7];
    Dxz=Args[8];
    Dyy=Args[9];
    Dyz=Args[10];
    Dzz=Args[11];
    gradA=Args[12];
    dimsu_f=Args[13];
    constants_f=Args[14];
    ThreadID_f=Args[15];
    Nthreads_f=Args[16];
            
    for(i=0;i<3;i++){ dimsu[i]=(int)dimsu_f[i]; }
    eigenmode=(int)constants_f[0];
    C=(double)constants_f[1]; 
    m=(double)constants_f[2]; 
    alpha=(double)constants_f[3];
    lambda_e=(double)constants_f[4];
    lambda_h=(double)constants_f[5];
    lambda_c=(double)constants_f[6];
    
    
    ThreadOffset=(int)ThreadID_f[0];
    Nthreads=(int)Nthreads_f[0];    
    
    npixels=dimsu[0]*dimsu[1]*dimsu[2];
    
    for(i=ThreadOffset; i<npixels; i=i+Nthreads) {
        /* Calculate eigenvectors and values of local Hessian */
        Ma[0][0]=(double)Jxx[i]+eps; Ma[0][1]=(double)Jxy[i]; Ma[0][2]=(double)Jxz[i];
        Ma[1][0]=(double)Jxy[i]; Ma[1][1]=(double)Jyy[i]+eps; Ma[1][2]=(double)Jyz[i];
        Ma[2][0]=(double)Jxz[i]; Ma[2][1]=(double)Jyz[i]; Ma[2][2]=(double)Jzz[i]+eps;
        eigen_decomposition(Ma, Davec, Daeig);

        /* Convert eigenvector and eigenvalue matrices back to scalar variables */
        mu1=Daeig[2]; 
        mu2=Daeig[1]; 
        mu3=Daeig[0];
        v1x=Davec[0][0]; v1y=Davec[1][0]; v1z=Davec[2][0];
        v2x=Davec[0][1]; v2y=Davec[1][1]; v2z=Davec[2][1];
        v3x=Davec[0][2]; v3y=Davec[1][2]; v3z=Davec[2][2];

        /* Scaling of diffusion tensor */
        if(eigenmode==0) /* Weickert line shaped */
        {
            di=(mu1-mu3);
            if((di<eps)&&(di>-eps)) { lambda1 = alpha; } else { lambda1 = alpha + (1.0- alpha)*exp(-C/pow(di,(2.0*m))); }
            lambda2 = alpha;
            lambda3 = alpha;
        }
        else if(eigenmode==1) /* Weickert plane shaped */
        {
            di=(mu1-mu3);
            if((di<eps)&&(di>-eps)) { lambda1 = alpha; } else { lambda1 = alpha + (1.0- alpha)*exp(-C/pow(di,(2.0*m))); }
            di=(mu2-mu3); 
            if((di<eps)&&(di>-eps)) { lambda2 = alpha; } else { lambda2 = alpha + (1.0- alpha)*exp(-C/pow(di,(2.0*m))); } 
            lambda3 = alpha;
        }
        else if (eigenmode==2) /* EED */
        {
            if(gradA[i]<eps){ lambda3 = 1; } else { lambda3 = 1 - exp(-3.31488/pow4(gradA[i]/pow2(lambda_e))); }
            lambda2 = 1;
            lambda1 = 1;
        }
        else if (eigenmode==3) /* CED */
        {
            lambda3 = alpha;
            lambda2 = alpha;
            if((mu2<eps)&&(mu2>-eps)){ lambda1=1;}
            else if ((mu3<eps)&&(mu3>-eps)) { lambda1=1; }
            else { lambda1= alpha + (1.0- alpha)*exp(-0.6931*pow2(lambda_c)/pow4(mu2/(alpha+mu3)));  }
        }
        else if (eigenmode==4) /* Hybrid Diffusion with Continous Switch */
        {
            if(gradA[i]<eps) { lambdae3 = 1; } else { lambdae3 = 1 - exp(-3.31488/pow4(gradA[i]/pow2(lambda_e))); }
            lambdae2 = 1;
            lambdae1 = 1;

            lambdac3 = alpha;
            lambdac2 = alpha;
            if((mu2<eps)&&(mu2>-eps)){ lambdac1=1;}
            else if ((mu3<eps)&&(mu3>-eps)) { lambdac1=1;}
            else { lambdac1 = alpha + (1.0- alpha)*exp(-0.6931*pow2(lambda_c)/pow4(mu2/(alpha+mu3)));  }

            xi= ( (mu1 / (alpha + mu2)) - (mu2 / (alpha + mu3) ));
            di=2.0*pow4(lambda_h);
            epsilon = exp(mu2*(pow2(lambda_h)*(xi-absd(xi))-2.0*mu3)/di);
            
            
            lambda1 = (1-epsilon) * lambdac1 + epsilon * lambdae1;
            lambda2 = (1-epsilon) * lambdac2 + epsilon * lambdae2;
            lambda3 = (1-epsilon) * lambdac3 + epsilon * lambdae3;
        }


        
          
        /* Construct the diffusion tensor */
        Dxx[i] = (float)(lambda1*v1x*v1x + lambda2*v2x*v2x + lambda3*v3x*v3x);
        Dyy[i] = (float)(lambda1*v1y*v1y + lambda2*v2y*v2y + lambda3*v3y*v3y);
        Dzz[i] = (float)(lambda1*v1z*v1z + lambda2*v2z*v2z + lambda3*v3z*v3z);
        Dxy[i] = (float)(lambda1*v1x*v1y + lambda2*v2x*v2y + lambda3*v3x*v3y);
        Dxz[i] = (float)(lambda1*v1x*v1z + lambda2*v2x*v2z + lambda3*v3x*v3z);
        Dyz[i] = (float)(lambda1*v1y*v1z + lambda2*v2y*v2z + lambda3*v3y*v3z);
    }
    
    /*  explicit end thread, helps to ensure proper recovery of resources allocated for the thread */
    #ifdef _WIN32
	_endthreadex( 0 );
    return 0;
	#else
	pthread_exit(NULL);
	#endif
}


  
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] ) {
    float *Dxx, *Dxy, *Dxz, *Dyy, *Dyz, *Dzz;
    float *Jxx, *Jxy, *Jxz, *Jyy, *Jyz, *Jzz, *gradA;
    
    /* ID of Threads */
    float **ThreadID;
    float *ThreadID1;
    float ***ThreadArgs;
    float **ThreadArgs1;
    float Nthreads_f[1]={0};
    float dimsu_f[3];
    float constants_f[7];
    int Nthreads;
    int i;
    
    /* Handles to the worker threads */
	#ifdef _WIN32
		HANDLE *ThreadList; 
    #else
		pthread_t *ThreadList;
	#endif
	    
    /* Options structure variables */
    mxArray *TempField;
    double *OptionsField;
    int field_num;
    struct options Options;
            
    /* Size input image volume */
    int ndimsu;
    const mwSize *dimsu_const;
    int dimsu[3];
    
     /* Check for proper number of arguments. */
    if(nrhs<7) {
        mexErrMsgTxt("Seven inputs are required.");
    } else if(nlhs!=6) {
        mexErrMsgTxt("Six outputs are required");
    }
    
    for(i=0; i<7; i++) {
        if(!mxIsSingle(prhs[i])){ mexErrMsgTxt("Inputs must be single"); }
    }
    
    /* Set Options struct */
    setdefaultoptions(&Options);
    if(nrhs==8) {
        field_num = mxGetFieldNumber(prhs[7], "T");
        if(field_num>=0) {
            TempField=mxGetFieldByNumber(prhs[7], 0, field_num);
            if(!mxIsDouble(TempField)) { mexErrMsgTxt("aValues in options structure must be of datatype double"); }
            OptionsField=mxGetPr(TempField);
            Options.T=OptionsField[0];
        }
        field_num = mxGetFieldNumber(prhs[7], "dt");
        if(field_num>=0) {
            TempField=mxGetFieldByNumber(prhs[7], 0, field_num);
            if(!mxIsDouble(TempField)) { mexErrMsgTxt("Values in options structure must be of datatype double"); }
            OptionsField=mxGetPr(TempField);
            Options.dt=OptionsField[0];
        }
        field_num = mxGetFieldNumber(prhs[7], "sigma");
        if(field_num>=0) {
            TempField=mxGetFieldByNumber(prhs[7], 0, field_num);
            if(!mxIsDouble(TempField)) { mexErrMsgTxt("Values in options structure must be of datatype double"); }
            OptionsField=mxGetPr(TempField);
            Options.sigma=OptionsField[0];
        }     
        field_num = mxGetFieldNumber(prhs[7], "lambda_e");
        if(field_num>=0) {
            TempField=mxGetFieldByNumber(prhs[7], 0, field_num);
            if(!mxIsDouble(TempField)) { mexErrMsgTxt("Values in options structure must be of datatype double"); }
            OptionsField=mxGetPr(TempField);
            Options.lambda_e=OptionsField[0];
        }     
        field_num = mxGetFieldNumber(prhs[7], "lambda_h");
        if(field_num>=0) {
            TempField=mxGetFieldByNumber(prhs[7], 0, field_num);
            if(!mxIsDouble(TempField)) { mexErrMsgTxt("Values in options structure must be of datatype double"); }
            OptionsField=mxGetPr(TempField);
            Options.lambda_h=OptionsField[0];
        }     
        field_num = mxGetFieldNumber(prhs[7], "lambda_c");
        if(field_num>=0) {
            TempField=mxGetFieldByNumber(prhs[7], 0, field_num);
            if(!mxIsDouble(TempField)) { mexErrMsgTxt("Values in options structure must be of datatype double"); }
            OptionsField=mxGetPr(TempField);
            Options.lambda_c=OptionsField[0];
        }     
        field_num = mxGetFieldNumber(prhs[7], "eigenmode");
        if(field_num>=0) {
            TempField=mxGetFieldByNumber(prhs[7], 0, field_num);
            if(!mxIsDouble(TempField)) { mexErrMsgTxt("Values in options structure must be of datatype double"); }
            OptionsField=mxGetPr(TempField);
            Options.eigenmode=(int)OptionsField[0];
        }     
        field_num = mxGetFieldNumber(prhs[7], "rho");
        if(field_num>=0) {
            TempField=mxGetFieldByNumber(prhs[7], 0, field_num);
            if(!mxIsDouble(TempField)) { mexErrMsgTxt("Values in options structure must be of datatype double"); }
            OptionsField=mxGetPr(TempField);
            Options.rho=OptionsField[0];
        }
        field_num = mxGetFieldNumber(prhs[7], "C");
        if(field_num>=0) {
            TempField=mxGetFieldByNumber(prhs[7], 0, field_num);
            if(!mxIsDouble(TempField)) { mexErrMsgTxt("Values in options structure must be of datatype double"); }
            OptionsField=mxGetPr(TempField);
            Options.C=OptionsField[0];
        }
        field_num = mxGetFieldNumber(prhs[7], "m");
        if(field_num>=0) {
            TempField=mxGetFieldByNumber(prhs[7], 0, field_num);
            if(!mxIsDouble(TempField)) { mexErrMsgTxt("Values in options structure must be of datatype double"); }
            OptionsField=mxGetPr(TempField);
            Options.m=OptionsField[0];
        }  
        field_num = mxGetFieldNumber(prhs[7], "alpha");
        if(field_num>=0) {
            TempField=mxGetFieldByNumber(prhs[7], 0, field_num);
            if(!mxIsDouble(TempField)) { mexErrMsgTxt("Values in options structure must be of datatype double"); }
            OptionsField=mxGetPr(TempField);
            Options.alpha=OptionsField[0];
        }  
    }
    
    /* Check and get input image dimensions */
    ndimsu=mxGetNumberOfDimensions(prhs[0]);
    if(ndimsu!=3) { mexErrMsgTxt("Input Image must be 3D"); }
    dimsu_const = mxGetDimensions(prhs[0]);
    dimsu[0]=dimsu_const[0]; dimsu[1]=dimsu_const[1]; dimsu[2]=dimsu_const[2];
 
    /* Create output Tensor Volumes */
    plhs[0] = mxCreateNumericArray(3, dimsu, mxSINGLE_CLASS, mxREAL);
    plhs[1] = mxCreateNumericArray(3, dimsu, mxSINGLE_CLASS, mxREAL);
    plhs[2] = mxCreateNumericArray(3, dimsu, mxSINGLE_CLASS, mxREAL);
    plhs[3] = mxCreateNumericArray(3, dimsu, mxSINGLE_CLASS, mxREAL);
    plhs[4] = mxCreateNumericArray(3, dimsu, mxSINGLE_CLASS, mxREAL);
    plhs[5] = mxCreateNumericArray(3, dimsu, mxSINGLE_CLASS, mxREAL);

    /* Assign pointers to each input. */
    Jxx = (float *)mxGetPr(prhs[0]);
    Jxy = (float *)mxGetPr(prhs[1]);
    Jxz = (float *)mxGetPr(prhs[2]);
    Jyy = (float *)mxGetPr(prhs[3]);
    Jyz = (float *)mxGetPr(prhs[4]);
    Jzz = (float *)mxGetPr(prhs[5]);
    gradA = (float *)mxGetPr(prhs[6]);
   
    /* Assign pointers to each output. */
    Dxx = (float *)mxGetPr(plhs[0]); 
    Dxy = (float *)mxGetPr(plhs[1]); 
    Dxz = (float *)mxGetPr(plhs[2]);
    Dyy = (float *)mxGetPr(plhs[3]);
    Dyz = (float *)mxGetPr(plhs[4]);
    Dzz = (float *)mxGetPr(plhs[5]);
        
    Nthreads=2;
    Nthreads_f[0]=(float)Nthreads;
    for(i=0; i<3; i++) { dimsu_f[i]=(float)dimsu[i]; }
    constants_f[0]=(float)Options.eigenmode;
    constants_f[1]=(float)Options.C;
    constants_f[2]=(float)Options.m; 
    constants_f[3]=(float)Options.alpha;
    constants_f[4]=(float)Options.lambda_e;
    constants_f[5]=(float)Options.lambda_h;
    constants_f[6]=(float)Options.lambda_c;
    
    /* Reserve room for handles of threads in ThreadList  */
	#ifdef _WIN32
		ThreadList = (HANDLE*)malloc(Nthreads* sizeof( HANDLE ));
    #else
		ThreadList = (pthread_t*)malloc(Nthreads* sizeof( pthread_t ));
	#endif

    ThreadID = (float **)malloc( Nthreads* sizeof(float *) );
    ThreadArgs = (float ***)malloc( Nthreads* sizeof(float **) );
        
    for (i=0; i<Nthreads; i++) {
        /*  Make Thread ID  */
        ThreadID1= (float *)malloc( 1* sizeof(float) );
        ThreadID1[0]=(float)i;
        ThreadID[i]=ThreadID1;
        
        /*  Make Thread Structure  */
        ThreadArgs1 = (float **)malloc( 17* sizeof( float * ) );
        ThreadArgs1[0]=Jxx;
        ThreadArgs1[1]=Jxy;
        ThreadArgs1[2]=Jxz;
        ThreadArgs1[3]=Jyy;
        ThreadArgs1[4]=Jyz;
        ThreadArgs1[5]=Jzz;
        ThreadArgs1[6]=Dxx;
        ThreadArgs1[7]=Dxy;
        ThreadArgs1[8]=Dxz;
        ThreadArgs1[9]=Dyy;
        ThreadArgs1[10]=Dyz;
        ThreadArgs1[11]=Dzz;
        ThreadArgs1[12]=gradA;
        ThreadArgs1[13]=dimsu_f;
        ThreadArgs1[14]=constants_f;
        ThreadArgs1[15]=ThreadID[i];
        ThreadArgs1[16]=Nthreads_f;
       
        /* Start a Thread  */
        ThreadArgs[i]=ThreadArgs1;
		#ifdef _WIN32
			ThreadList[i] = (HANDLE)_beginthreadex( NULL, 0, &StructureTensor2DiffusionTensorThread, ThreadArgs[i] , 0, NULL );
		#else
			pthread_create ((pthread_t*)&ThreadList[i], NULL, (void *) &StructureTensor2DiffusionTensorThread, ThreadArgs[i]);
		#endif
    }
    
    #ifdef _WIN32
		for (i=0; i<Nthreads; i++) { WaitForSingleObject(ThreadList[i], INFINITE); }
		for (i=0; i<Nthreads; i++) { CloseHandle( ThreadList[i] ); }
	#else
		for (i=0; i<Nthreads; i++) { pthread_join(ThreadList[i],NULL); }
	#endif
    
    for (i=0; i<Nthreads; i++) {
        free(ThreadArgs[i]);
        free(ThreadID[i]);
    }
    
    free(ThreadArgs);
    free(ThreadID );
    free(ThreadList);
}






