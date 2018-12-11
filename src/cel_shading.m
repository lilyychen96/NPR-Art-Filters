%% temporary script to run everything for impressionist rendering
clear all; close all;

% read in image(s)
% path = '../data/Amor-Psyche-Canova-wikipedia.jpg';
img = im2double(imread('../data/DSCF2657.jpg'));
% img = im2double(imread('../data/Amor-Psyche-Canova-wikipedia.jpg'));
img_down = img;

% downsize image if too large
[h,w,~] = size(img);
if h > 1200
    scale = ceil(h/1200);
    img = imresize(img, 1/scale, 'bilinear');
    img_down = imresize(img, 1/(2*scale), 'bilinear');
elseif w > 1600
    scale = ceil(w/1600);
    img = imresize(img, 1/scale, 'bilinear');
    img_down = imresize(img, 1/(2*scale), 'bilinear');
end
[h,w,~] = size(img);

sigma = 2;
[blurred, blur_rgb, edges] = get_edges(img, sigma);
im_seg = color_segmentation(blur_rgb);
% figure; imshow(im_seg);
% colors = discretize_colors(img);
% % imout = max(colors - edges, 0);
imout = max(im_seg - edges, 0);

figure; subplot 211; imshow(img); title('original image');
subplot 212; imshow(imout); title('output image');
