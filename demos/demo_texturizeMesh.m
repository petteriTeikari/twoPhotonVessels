function demo_texturizeMesh()= demo_texturizeMesh(fileLoc, F, V) 

    % import test vector (SDF), from text file
    if nargin== 0
       fileLoc= '/home/highschoolintern/Desktop/twoPhotonVessels/SDFRetrival/build/SDFVals.txt';
    end
    fileID= fopen(fileLoc, 'r');
    diameterVals= fscanf(fileIdD, '%f');
       
    delimiterIn = ' '; % tab-delimited
    headerlinesIn = 1; % number of header rows
        %tmpImport = importdata(fullfile('..', 'testData', 'testVector.txt'), delimiterIn, headerlinesIn)
        tmpImport = importdata(fullfile('/home/highschoolintern/Desktop/SDFPropertyMap/build/SDFVals.txt'), delimiterIn, headerlinesIn)
            col1 = tmpImport.data(:,1);
            col2 = tmpImport.data(:,1);
            % only 10 values
            
            % for demo, reshape
            
    
    %% FROM THE DEMO (File Exchange), uses an image actually
    
        % texturePatch
        
        
        % Load Data;
        load testdata; % comes with texturePatch
        whos        
        %         FF                          572x3                 13728  double               
        %         I                           256x256x3            196608  uint8                
        %         TF                          572x3                 13728  double               
        %         VT                          428x2                  6848  double               
        %         VV                          594x3                 14256  double    
        
        % Show the textured patch
        figure, patcht(FF,VV,TF,VT,I); 
        
        % inputs,
        %   FF : Face list 3 x N with vertex indices
        %   VV : Vertices 3 x M
        %   TF : Texture list 3 x N with texture vertex indices
        %   VT : Texture Coordinates s 2 x K, range must be [0..1] or real pixel postions
        %   I : The texture-image RGB [O x P x 3] or Grayscale [O x P] 
        
        %   Options : Structure with options for the textured patch such as
        %           EdgeColor, EdgeAlpha see help "Surface Properties :: Functions"
        %
        %   Options.PSize : Special option, defines the image texturesize for each 
        %           individual  polygon, a low number gives a more block 
        %           like texture, defaults to 64;
        %}
        
    %% With SDF values
    
        % http://stackoverflow.com/questions/17023323/matlab-customize-surface-color-depending-on-a-parameter
        
        figure('Color','w')
        
        % creatu dummy values, import the SDF instead
       
        minValue = min(diameterVals);
        maxValue = max(diameterVals);
        noOfValues = length(FF);
        colorMap = (linspace(minValue,maxValue,noOfValues))';
        
        p = patch('Faces',     FF, ...
                  'Vertices',  VV, ...
                  'FaceColor', 'flat', ...
                  'CData',     colorMap, ...
                  'FaceAlpha', 0.3);
    
        view(3)
        camlight 
        lighting gouraud
        
        colorbar
        colormap('summer')
        title('Init plot')
        
        pause(2.0)
        % remove edges
        set(p, 'EdgeColor', 'none')
        title('Removed edges')
        
        % rotate
        for a = 0 : 10 : 90
            for e = 0 : 10 : 90
                view(a,e)
                pause(0.2)
                drawnow
            end
        end