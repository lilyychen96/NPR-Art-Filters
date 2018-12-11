function [im_seg] = color_segmentation(img)
% color-based segmentation using K-means clustering
tic
v = version('-release');

% convert image from RGB to LAB
im_lab = rgb2lab(img);
% classify colors using K-means clustering
im_ab = im_lab(:,:,2:3);
[h,w,~] = size(im_ab);
colors = 25; % can change this
im_seg = zeros(size(img));

if strcmp(v, '2017b')
    % https://www.mathworks.com/help/releases/R2017b/images/examples/color-based-segmentation-using-k-means-clustering.html
    im_ab = reshape(im_ab, h*w, 2);
    [ind, ~] = kmeans(im_ab,colors,'distance','sqEuclidean',...
        'Replicates',3);
    plabels = reshape(ind,h,w);
%     imshow(plabels, []); title('image labeled by cluster index');
    rgblabels = repmat(plabels,[1 1 3]);
    
    for k = 1:colors
        c = img;
        c(rgblabels ~= k) = NaN;
        
        r = c(:,:,1);
        g = c(:,:,2);
        b = c(:,:,3);
        
        % find average value for each color channel
        r(rgblabels(:,:,1) == k) = mean(r(rgblabels(:,:,1) == k));
        g(rgblabels(:,:,2) == k) = mean(g(rgblabels(:,:,2) == k));
        b(rgblabels(:,:,3) == k) = mean(b(rgblabels(:,:,3) == k));
        c(:,:,1) = r;
        c(:,:,2) = g;
        c(:,:,3) = b;
        
        c(rgblabels ~= k) = 0;
        im_seg = im_seg + c;
    end
else
    % https://www.mathworks.com/help/images/color-based-segmentation-using-k-means-clustering.html
    % https://www.mathworks.com/help/images/ref/imsegkmeans.html
    im_ab = im2single(im_ab);
    plabels = imsegkmeans(im_ab,colors,'NumAttempts',3);
%     imshow(plabels, []); title('image labeled by cluster index');
    
    for k = 1:colors
        c = img;
        c(plabels ~= k) = NaN;
        
        r = c(:,:,1);
        g = c(:,:,2);
        b = c(:,:,3);
        
        % find average value for each color channel
        r(plabels(:,:,1) == k) = mean(r(plabels(:,:,1) == k));
        g(plabels(:,:,2) == k) = mean(g(plabels(:,:,2) == k));
        b(plabels(:,:,3) == k) = mean(b(plabels(:,:,3) == k));
        c(:,:,1) = r;
        c(:,:,2) = g;
        c(:,:,3) = b;
        
        c(plabels ~= k) = 0;
        im_seg = im_seg + c;
    end
end

toc
