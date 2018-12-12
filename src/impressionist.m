%% temporary script to run everything for impressionist rendering
% clear all; close all;

% read in image(s)
% path = '../data/Amor-Psyche-Canova-wikipedia.jpg';
% img = im2double(imread('../data/Amor-Psyche-Canova-wikipedia.jpg'));
img = im2double(imread('../data/IMG_3094.jpg'));
% img = ones(500,500,3);

% downsize image if too large
[h,w,~] = size(img);
if h > 900
    scale = h/900;
    img = imresize(img, 1/scale, 'bilinear');
elseif w > 1200
    scale = w/1200;
    img = imresize(img, 1/scale, 'bilinear');
end
[h,w,~] = size(img);

style = 0;
while style <= 0 || style >= 11
    prompt = strcat(strcat('Enter number between 1 to 10 where \n', ...
        '    1=pointillist, 5=impressionist, 10=expressionist\n'), ...
        '    or 0 to exit\n');
    style = input(prompt);
    if style == 0
        disp('okay, bye bye!');
    else
        [rmin,rmax,lmin,lmax,crange,thresh,img] = style_params(style,img);
    end
end

sigma = 2;
[blurred, edges] = get_edges(img, sigma);
[gmag, gdir] = imgradient(blurred,'prewitt');
gdir = (gdir + 90);
gdir(gdir > 180) = gdir(gdir > 180) - 360;
gmagmax = max(gmag(:));
gmag = (gmagmax + 0.0001 - gmag);

% generate strokes
imout = NaN * ones(size(img));

tic
while sum(isnan(imout(:))) > 0
    [row, col] = find(isnan(imout(:,:,1)));
    ind = randi(length(row));
    cx = col(ind);
    cy = row(ind);
    
    theta = deg2rad(gdir(cy,cx));
    l = max(lmin, min(round(gmag(cy,cx)*h/15), lmax));
    
    if near_edge(cx,cy,thresh,edges)
        r = randi(min(2*style,10));
    else
        r = max(rmin, min(round(gmag(cy,cx)*20), rmax));
    end

    [mask] = define_stroke(edges,cx,cy,theta,l,r);
    [imout] = stroke_color(img,mask,imout,crange);
end
toc

figure; imshow(imout);
title(strcat('rendered with style #', num2str(style)));
