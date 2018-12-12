%% temporary script to run everything for impressionist rendering
clear all; close all;

% read in image(s)
% path = '../data/Amor-Psyche-Canova-wikipedia.jpg';
img = im2double(imread('../data/Amor-Psyche-Canova-wikipedia.jpg'));
% img = ones(500,500,3);

% downsize image if too large
[h,w,~] = size(img);
if h > 600
    scale = ceil(h/600);
    img = imresize(img, 1/scale, 'bilinear');
elseif w > 800
    scale = ceil(w/800);
    img = imresize(img, 1/scale, 'bilinear');
end
[h,w,~] = size(img);

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
for i = 1:2000
    cx = randi(w);
    cy = randi(h);
    while ~isnan(imout(cx,cy))
        cx = randi(w);
        cy = randi(h);
    end
    
    theta = deg2rad(gdir(cy,cx));
    l = min(round(gmag(cy,cx)*100), h/15);
    
    % choose smaller brush stroke radius if near an edge
    if near_edge(cx,cy,edges)
        r = randi(3);
    else
        r = max(2, min(round(gmag(cy,cx)*20),h/100));
    end

    [imout] = define_stroke(img,edges,cx,cy,theta,l,r,imout);
end
toc

tic
while sum(isnan(imout(:))) > 0
    [row, col] = find(isnan(imout(:,:,1)));
    ind = randi(length(row));
    cx = col(ind);
    cy = row(ind);
    
    theta = deg2rad(gdir(cy,cx));
    l = min(round(gmag(cy,cx)*100), h/15);
    
    if near_edge(cx,cy,edges)
        r = randi(3);
    else
        r = max(2, min(round(gmag(cy,cx)*20),h/100));
    end

    [imout] = define_stroke(img,edges,cx,cy,theta,l,r,imout);
end
toc

figure(2); subplot 121; imshow(img); title('original');
subplot 122; imshow(imout); title('rendered');
