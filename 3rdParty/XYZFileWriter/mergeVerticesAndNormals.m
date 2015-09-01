function mergeVerticesAndNormals(V,N, elementNum) 
%V = vertices (Y x 3)  
%N= normals (Z x 3) 

VN= zeros([elementNum 6]); 
for y= 1 : 3 
    for x = 1: elementNum
        VN(x, y)= V(x, y);
    end
    
end 
for z= 4:6
   a= z - 3;
    for x = 1: elementNum
        VN(x, z)= N(x, a);
    end
     
end 
dlmwrite('VerticesnNormals.mat', VN); 
end

