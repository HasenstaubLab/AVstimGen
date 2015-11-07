function checkImg = genCheckerboard(win_width, win_height, white)
% generates a checkerboard image 

%function checkImg = genCheckerboard(sidelength, win_width, win_height, white);
sidelength = 100; 

miniboard = eye(2,'uint8') .* white;

numCheckers =  ceil([win_height, win_width] ./ sidelength);
checkerboard_heads = repmat(miniboard, ceil(0.5 .* numCheckers));
checkImg = imresize(checkerboard_heads,sidelength,'box'); 
