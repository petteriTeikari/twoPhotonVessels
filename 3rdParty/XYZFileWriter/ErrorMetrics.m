function ErrorMetrics(file1, file2)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


input_unit = fopen (file1, 'r' );
a= -1;
pointNum=-7 ; 
coordinates= 0 ; 
while ( coordinates >a)
    coordinates = fgetl ( input_unit );
pointNum= pointNum +1 ; 
end
xyz_data_read(file1, pointNum) 
mesh1= ans; 
fclose(input_unit);



input_unit = fopen(file2, 'r' );
b= -1;
pointNum2= -7 ; 
coordinates= 0;
while ( coordinates >b)
    coordinates = fgetl ( input_unit );
pointNum2= pointNum2 +1 ; 
end
xyz_data_read(file2, pointNum2) ;
mesh2= ans; 
mdh= ModHausdorffDist(mesh1, mesh2); 
disp(mdh); 
end

