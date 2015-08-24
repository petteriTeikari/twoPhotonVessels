function demo_meshMeanCurvature() 

    %% SETUP

        close all;   
        fileName = mfilename; fullPath = mfilename('fullpath');
        pathCode = strrep(fullPath, fileName, '');
        if ~isempty(pathCode); cd(pathCode); end
        scrsz = get(0,'ScreenSize'); % get screen size for plotting

       
    %% DEFINE TEST MESH and PLOT
    
        % http://www.mathworks.com/help/matlab/ref/trimesh.html
        [x,y] = meshgrid(1:15,1:15);
        tri = delaunay(x,y);
        z = peaks(15);
        
        fig = figure('Color','w');    
        subplot(2,2,1); trisurf(tri,x,y,z); title('Input')        
        view(3);
        axis vis3d;
        lighting phong;
        shading interp;
        
        
    %% COMPUTE THE MEAN CURVATURE
    
        whos
        [gm samc] = mcurvature_vec(x,y,z);        
       
        subplot(2,2,2); trisurf(tri,x,y,gm); title('Mean Curvature')        
        colormap('jet')
        view(3);
        axis vis3d;
        lighting phong;
        shading interp;
        
        
    %% Do the same for Faces/Vertices
    
        load(fullfile('..', '3rdParty','testMeshCupdata.mat'))
        whos
        
        % PLOT Input    
        subplot(2,2,3); 
        
            p = patch('Faces', FF, ...
                  'Vertices',  VV, ...
                  'FaceColor', 'flat', 'EdgeColor', 'none', ...
                  'CData',     ones(length(VV),1), ...
                  'FaceAlpha', 0.3);
              
            az = 18; el = 68;
            view(az, el); axis tight
            camlight 
            lighting gouraud
            
    %% Compute mean curvature again
    
        % Need to reshape the data for the algorithm, 3 x 2D grids
        % http://www.mathworks.com/matlabcentral/newsreader/view_thread/323275
        n = length(VV);
        v = VV;
        [S,T] = ndgrid(linspace(0,1,n));
        G00 = (1-S).*(1-T); G10 = S.*(1-T); G01 = (1-S).*T; G11 = S.*T;
        xd = v(1,1)*G00+v(2,1)*G10+v(3,1)*G01+v(4,1)*G11;
        yd = v(1,2)*G00+v(2,2)*G10+v(3,2)*G01+v(4,2)*G11;
        zd = v(1,3)*G00+v(2,3)*G10+v(3,3)*G01+v(4,3)*G11;
        
        [gm samc] = mcurvature_vec(xd,yd,zd);
        gmVector = gm(:,1);
        
        % PLOT Results
        subplot(2,2,4); 
        
            p = patch('Faces', FF, ...
                  'Vertices',  VV, ...
                  'FaceColor', 'flat', 'EdgeColor', 'none', ...
                  'CData',     gmVector, ...
                  'FaceAlpha', 0.3);
              
            az = 18; el = 68;
            view(az, el); axis tight
            camlight 
            lighting gouraud

        % figure; plot(gm(:,1), gm(:,2)) % straight line