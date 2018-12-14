function new_img = cubist(img_in)

img = im2double(imread(img_in));
w = size(img, 2);
h = size(img, 1);

alpha = 0.01;
lambda = 0.95;
[x, y] = meshgrid(1:w, 1:h);

parts = zeros(36, 6); % x_cent, y_cent, a, b, r, rot_theta
for i = 1:6
    for j = 1:6
        parts(j + (i-1)*6, 1) = round((i - 0.5) * w / 6);
        parts(j + (i-1)*6, 2) = round((j - 0.5) * h / 6);
        parts(j + (i-1)*6, 3) = 0.2 + rand(1) * 0.6;
        parts(j + (i-1)*6, 4) = 1 - parts(j + (i-1)*6, 3);
        parts(j + (i-1)*6, 5) = min(w/6, h/6) + rand(1) * 50;
        parts(j + (i-1)*6, 6) = -pi/2 + rand(1) * pi;
    end
end

new_img = NaN * ones(size(img));
shapes = 1:36;
shapes = shapes(randperm(length(shapes)));

for p = 1:36
    q = shapes(p);
    theta = atan2((y - parts(q, 2)), (x - parts(q, 1)));
    d = zeros(h, w, 2);
    
    x_circ = parts(q, 5) * cos(theta);
    y_circ = parts(q, 5) * sin(theta);
    
    in_circ = false(size(img,1), size(img,2));
    ind = (x-parts(q,1)).^2 + (y-parts(q,2)).^2 <= parts(q,5)^2;
    in_circ(ind) = true;
    
    near_edge = zeros(size(img,1), size(img,2));
    % ind = (x-parts(q,1)).^2 + (y-parts(q,2)).^2 <= parts(q,5)^2 & ...
    %      (x-parts(q,1)).^2 + (y-parts(q,2)).^2 >= (parts(q,5)-30)^2;
    % near_edge(ind) = true;
    near_edge = exp(-((x-parts(q,1)).^2 + (y-parts(q,2)).^2) / parts(q,5)^2);
    
    denom = ((cos(theta)/parts(q,3)).^ (2/alpha) + (sin(theta)/parts(q,4)).^(2/alpha)).^(alpha/2);
    
    x_dist = 2 * parts(q,5) * cos(theta) ./ denom;
    y_dist = 2 * parts(q,5) * sin(theta) ./ denom;
    
    mags = transfer(sqrt(((x-parts(q, 1)).^2 + (y-parts(q,2)).^2) ./ (x_circ.^2 + y_circ.^2)), lambda);
    
    d(:,:,1) = (x_dist - x_circ) .* mags;
    d(:,:,2) = (y_dist - y_circ) .* mags;
    
    new_d = d;
    new_d(:,:,1) = cos(parts(q,6)) * d(:,:,1) - sin(parts(q,6)) * d(:,:,2);
    new_d(:,:,2) = sin(parts(q,6)) * d(:,:,1) + cos(parts(q,6)) * d(:,:,2);
    
    colors = zeros(3, 3);
    
    blur_img = img;
    levels = 15;
    
    reds = blur_img(:,:,1);
    reds = reds(in_circ);
    colors(1, 1) = min(reds);
    colors(1, 2) = max(reds);
    colors(1, 3) = levels;
    
    blur_img(:,:,1) = round((blur_img(:,:,1) - colors(1,1)) * colors(1,3)) / colors(1,3) + colors(1,1);
    % blur_img(:,:,1) = blur_img(:,:,1) .* near_edge;
    
    greens = blur_img(:,:,2);
    greens = greens(in_circ);
    colors(2, 1) = min(greens);
    colors(2, 2) = max(greens);
    colors(2, 3) = levels;
    
    blur_img(:,:,2) = round((blur_img(:,:,2) - colors(2,1)) * colors(2,3)) / colors(2,3) + colors(2,1);
    % blur_img(:,:,2) = blur_img(:,:,2) .* near_edge;
    
    blues = blur_img(:,:,3);
    blues = blues(in_circ);
    colors(3, 1) = min(blues);
    colors(3, 2) = max(blues);
    colors(3, 3) = levels;
    
    blur_img(:,:,3) = round((blur_img(:,:,3) - colors(3,1)) * colors(3,3)) / colors(3,3) + colors(3,1);
    % blur_img(:,:,3) = blur_img(:,:,3) .* near_edge;
    
    blur_img = imgaussfilt(blur_img,3);
    
    for i = 1:w
        for j = 1:h
            if (in_circ(j,i))
            % if (((i - parts(q,1)) / parts(q,3))^(2/alpha) + ((j - parts(q,2)) / parts(q,4))^(2/alpha) < (2*parts(q,5))^(2/alpha))
                i_new = clip(round(i+new_d(j,i,1)), w);
                j_new = clip(round(j+new_d(j,i,2)), h);
                new_img(j_new, i_new, :) = img(j, i, :);
                new_img(clip(j_new - 1, h), i_new, :) = blur_img(j, i, :);
                new_img(clip(j_new + 1, h), i_new, :) = blur_img(j, i, :);
                new_img(j_new, clip(i_new - 1, w), :) = blur_img(j, i, :);
                new_img(j_new, clip(i_new + 1, w), :) = blur_img(j, i, :);
            end
        end
    end
end

filler = imgaussfilt(img, 3);
new_img(isnan(new_img)) = filler(isnan(new_img));
new_img = imgaussfilt(new_img, 4);

end