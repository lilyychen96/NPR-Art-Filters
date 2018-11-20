function [blurred, edges] = get_edges(img, sigma)
[h,w,c] = size(img);

% convert image to grayscale as necessary
if c == 3
    xyz = rgb2xyz(img, 'ColorSpace', 'linear-rgb');
    img = xyz(:,:,2);
end

% blur image with Gaussian kernel
hsize = 2 * ceil(3 * sigma) + 1;
g_filt = fspecial('gaussian', hsize, sigma);
blurred = conv2(img, g_filt, 'same');

% get edges with Canny filter
% Canny filter can find weak edges better than Sobel
edges = edge(blurred, 'Canny');

% check results
% figure; imshow(img); title('original image');
% figure; subplot 121; imshow(blurred); title('Gaussian blurred');
% subplot 122; imshow(edges); title('Edges from Canny filter');

end