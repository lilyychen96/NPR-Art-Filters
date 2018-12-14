% script to run everything for cel-shading rendering
clear all; close all;

% read in image(s)
img = im2double(imread('../data/Amor-Psyche-Canova-wikipedia.jpg'));

% user prompts about max image size
disp('Change line 5 to desired image path, as needed.');
prompt = strcat('Please enter max height (hint: <= 600 is good)\n');
maxh = input(prompt);
if size(maxh,1) == 0
    disp('Setting max height to 600 px');
    maxh = 600;
elseif maxh < 200 || maxh > 750
    disp('Bad dimension, setting max height to 750 px');
    maxh = 600;
end
prompt = strcat('Please enter max width (hint: <= 800 is good)\n');
maxw = input(prompt);
if size(maxw,1) == 0
    disp('Setting max height to 800 px');
    maxw = 800;
elseif maxw < 200 || maxw > 1000
    disp('Bad dimension, setting max height to 1000 px');
    maxw = 800;
end

% downsize image if too large
[h,w,~] = size(img);
if h > maxh
    scale = h/maxh;
    img = imresize(img, 1/scale, 'bilinear');
elseif w > maxw
    scale = w/maxw;
    img = imresize(img, 1/scale, 'bilinear');
end
[h,w,~] = size(img);

sigma = 4;
[blurred, edges] = get_edges(img, sigma);

v = version('-release');
if strcmp(v, '2018a') || strcmp(v, '2018b')
    % extract L*a*b patch with no sharp edges
    im_lab = rgb2lab(img);
    disp('click on top left and bottom right of path with no sharp edges');
    figure(1); imshow(im_lab);
    [x,y] = ginput(2);
    dx = abs(x(2) - x(1));
    dy = abs(y(2) - y(1));
    patch = imcrop(im_lab, [x(1), y(1), dx, dy]);

    % compute variance in Euclidean distance and use bilateral filter
    patch = patch .^ 2;
    edist = sqrt(sum(patch, 3));
    DoS = 2 * (std2(edist) .^ 2);
    smooth_lab = imbilatfilt(im_lab, DoS);
    blur_rgb = lab2rgb(smooth_lab, 'Out', 'double');

else
    % use bfilter2, from
    % https://www.mathworks.com/matlabcentral/fileexchange/12191-bilateral-filtering
    % Set bilateral filter parameters.
    w     = 5;         % bilateral filter half-width
    sigma = [3 0.1];   % bilateral filter standard deviations
    % Set image abstraction paramters.
    max_gradient      = 0.2;    % maximum gradient (for edges)
    sharpness_levels  = [3 14]; % soft quantization sharpness
    quant_levels      = 8;      % number of quantization levels
    min_edge_strength = 0.3;    % minimum gradient (for edges)

    blur_rgb = bfilter2(img,w,sigma);
end

im_seg = color_segmentation(blur_rgb);
imout = max(im_seg - edges, 0);

figure; imshow(imout);
