% temporary script to run everything for impressionist rendering

% read in image(s)
path = '../data/Amor-Psyche-Canova-wikipedia.jpg';
img = im2double(imread('../data/Amor-Psyche-Canova-wikipedia.jpg'));

sigma = 15;
[blurred, edges] = get_edges(img, sigma);

% generate strokes