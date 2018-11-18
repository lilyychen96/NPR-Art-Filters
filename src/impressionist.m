% temporary script to run everything for impressionist rendering

% read in image(s)
img = im2double(imread(path));

sigma = 5;
[blurred, edges] = get_edges(img, sigma)

% generate strokes