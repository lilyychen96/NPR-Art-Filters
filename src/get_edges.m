function [blurred, blur_rgb, edges] = get_edges(img, sigma)
[h,w,c] = size(img);

xyz = img;
blur_rgb = zeros(size(img));
% convert image to grayscale as necessary
if c == 3
    xyz = rgb2xyz(xyz, 'ColorSpace', 'linear-rgb');
    xyz = xyz(:,:,2);
end

% blur image with Gaussian kernel
hsize = 2 * ceil(3 * sigma) + 1;
g_filt = fspecial('gaussian', hsize, sigma);
blurred = conv2(xyz, g_filt, 'same');

hsize = 2 * ceil(9 * sigma) + 1;
g_filt = fspecial('gaussian', hsize, 3*sigma);
blur_rgb(:,:,1) = conv2(img(:,:,1), g_filt, 'same');
blur_rgb(:,:,2) = conv2(img(:,:,2), g_filt, 'same');
blur_rgb(:,:,3) = conv2(img(:,:,3), g_filt, 'same');

% get edges with Canny filter
% Canny filter can find weak edges better than Sobel
edges = edge(blurred, 'Canny');

% check results
% figure; imshow(img); title('original image');
% figure; subplot 121; imshow(blurred); title('Gaussian blurred');
% subplot 122; imshow(edges); title('Edges from Canny filter');

end