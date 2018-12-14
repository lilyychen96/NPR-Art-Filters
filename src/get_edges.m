function [blurred, edges] = get_edges(img, sigma)
c = size(img,3);

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

end
