function demo_2d_maze()

    % Read Blood vessel image
    I=im2double(rgb2gray(imread('images/vessels2d.png')));

    % Convert double image to logical
    Ibin=I<0.5;

    % Use fastmarching to find the skeleton
    S=skeleton(Ibin);
    
    % Display the skeleton
    figure, imshow(Ibin); hold on;
    
    for i=1:length(S)
        L=S{i};
        plot(L(:,2),L(:,1),'-','Color',rand(1,3));
    end