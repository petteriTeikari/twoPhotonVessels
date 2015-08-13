function visualize_meshWithSDFValues(F, V, SDF)
%creates mesh with texture map based on SDF Values 
figure('Color','w')
 minValue = min(SDF);
 maxValue = max(SDF);
 noOfValues = length(FF);
 colorMap = (linspace(minValue,maxValue,noOfValues))';
        
        p = patch('Faces',     F, ...
                  'Vertices',  V, ...
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
        
        
end

