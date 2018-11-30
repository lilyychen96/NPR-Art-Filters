%% temporary script to run everything for impressionist rendering
clear all; close all;

% read in image(s)
% path = '../data/Amor-Psyche-Canova-wikipedia.jpg';
% img = im2double(imread('../data/DSCF2657.jpg'));
img = im2double(imread('../data/Amor-Psyche-Canova-wikipedia.jpg'));

% downsize image if too large
[h,w,~] = size(img);
if h > 1200
    scale = ceil(h/1200);
    img = imresize(img, 1/scale, 'bilinear');
elseif w > 1600
    scale = ceil(w/1600);
    img = imresize(img, 1/scale, 'bilinear');
end
[h,w,~] = size(img);

figure; subplot 211; imshow(img); title('original image');

sigma = 3;
[blurred, edges] = get_edges(img, sigma);
colors = discretize_colors(img);
imout = max(colors - edges, 0);

subplot 212; imshow(imout); title('output image');
