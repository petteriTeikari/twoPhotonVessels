function err=fitgaussian(I,a,t)
hd=(size(I,1)-1)/2;
if(size(I,3)>1)
    [x,y,z]=meshgrid(-hd:hd,-hd:hd,-hd:hd);
    r2=(x.^2+y.^2+z.^2);
else
    [x,y]=meshgrid(-hd:hd,-hd:hd);
    r2=(x.^2+y.^2);
end
J=(1/(sqrt(pi)*sqrt(a*t)))*exp(-(r2)/(a*t)); J=J./sum(J(:));
err=sum((I(:)-J(:)).^2);
if(isnan(err)), err=1; end
