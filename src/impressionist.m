%% temporary script to run everything for impressionist rendering
clear all; close all;

% read in image(s)
path = '../data/Amor-Psyche-Canova-wikipedia.jpg';
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

figure; imshow(img); title('original image');

sigma = 2;
[blurred, edges] = get_edges(img, sigma);

% generate strokes
figure; imshow(edges); hold on;
tic
for i = 1:25000
    cx = randi(w);
    cy = randi(h);
    theta = randi(360) * pi/180; % radians
    l = randi(25);
    r = randi(10);
    
    [sx,sy,length,rgb] = define_stroke(img, edges, cx, cy, theta, l);
    
    line(sy,sx,'Color',rgb,'LineWidth',r);
end
toc