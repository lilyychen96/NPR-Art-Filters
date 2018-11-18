function [blurred, edges] = get_edges(img, sigma)
[h,w,c] = size(img);

% TODO: downsize image if too large
% if h > # || w > #
%   scale = 
%   img = imresize(img, scale);
% end

% convert image to grayscale as necessary
if c == 3
    img = rgb2xyz(img, 'ColorSpace', 'linear-rgb');
end

% blur image with Gaussian kernel
blurred = imgaussfilt(img, sigma);

% get edges with Sobel filter
edges = edge(blurred, 'Sobel');

% check results
figure; imshow(img); title('original image');
figure; subplot 121; imshow(blurred); title('Gaussian blurred');
subplot 122; imshow(edges); title('Edges from Sobel filter');

end