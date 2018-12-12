% temporary script to run everything for impressionist rendering
% clear all; close all;

% read in image
% img = im2double(imread('../../Starry_Night_Over_the_Rhone.jpg'));
img = im2double(imread('../data/Amor-Psyche-Canova-wikipedia.jpg'));
% img = im2double(imread('../data/IMG_3094.jpg'));

% user prompts about max image size
disp('Change line 5 to desired image path, as needed.');
prompt = strcat('Please enter max height (hint: <= 600 is good)\n');
maxh = input(prompt);
if size(maxh,1) == 0
    disp('Setting max height to 1200 px');
    maxh = 600;
elseif maxh < 200 || maxh > 750
    disp('Bad dimension, setting max height to 750 px');
    maxh = 600;
end
prompt = strcat('Please enter max width (hint: <= 800 is good)\n');
maxw = input(prompt);
if size(maxw,1) == 0
    disp('Setting max height to 1000 px');
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
stop_pt = 0.05*h*w;

% user prompt about style
prompt = strcat(strcat('Enter number between 1 to 10 where \n', ...
    '    1=pointillist, 5=impressionist, 10=expressionist\n'), ...
    '    or 0 to exit\n');
style = input(prompt);
if style <= 0 || style >= 11
    disp('okay, bye bye!');
else
    [rmin,rmax,lmin,lmax,crange,thresh,img] = style_params(style,img);
end

% find edge image
sigma = 2;
[blurred, edges] = get_edges(img, sigma);

% calculate image gradient directions and magnitudes
[gmag, gdir] = imgradient(blurred,'prewitt');
gdir = gdir + 90;
gdir(gdir > 180) = gdir(gdir > 180) - 360;
gmagmax = max(gmag(:));
gmag = (gmagmax + 0.0001 - gmag);

% generate strokes
imout = NaN * ones(size(img));
disp('~*~ Painting your image ... please be patient! ~*~');

tic
while sum(isnan(imout(:))) > stop_pt
    [row, col] = find(isnan(imout(:,:,1)));
    ind = randi(length(row));
    cx = col(ind);
    cy = row(ind);
    
    theta = deg2rad(gdir(cy,cx));
    if theta == 0
        theta = (-1*round(rand)) * pi * rand;
    end
    
    l = max(lmin, min(round(gmag(cy,cx)*h/15), lmax));
    
    if near_edge(cx,cy,thresh,edges)
        r = min(rmin, randi(style));
    else
        r = max(rmin, min(round(gmag(cy,cx)*20), rmax));
    end

    [mask] = define_stroke(edges,cx,cy,theta,l,r);
    [imout] = stroke_color(img,mask,imout,crange);
end
% toc
% figure; imshow(imout)
[row, col] = find(isnan(imout(:,:,1)));
% tic
for i = 1:length(row)
    cx = col(i);
    cy = row(i);
    
    theta = deg2rad(gdir(cy,cx));
    if theta == 0
        theta = (-1*round(rand)) * pi * rand;
    end
    
    l = max(lmin, min(round(gmag(cy,cx)*h/15), lmax));
    
    if near_edge(cx,cy,thresh,edges)
        r = min(rmin, randi(style));
    else
        r = max(rmin, min(round(gmag(cy,cx)*20), rmax));
    end

    [mask] = define_stroke(edges,cx,cy,theta,l,r);
    [imout] = stroke_color(img,mask,imout,crange);
end
toc

disp('~*~ All done! ~*~');
figure; imshow(imout);
title(strcat('rendered with style #', num2str(style)));
