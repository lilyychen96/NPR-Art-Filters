img = im2double(imread('../data/obama.jpg'));
w = size(img, 2);
h = size(img, 1);

lambda = 0.5;

figure;imshow(img);
hold on;
theta = 0:pi/10:2*pi;
r = 150;
x = r*cos(theta);
y = r*sin(theta);
x_cent = 502;
y_cent = 215;
plot(x+x_cent, y+y_cent, 'bo', 'LineWidth', 2, 'MarkerSize', 10);

alpha = 0.01;

a = 0.2;
b = 1 - a;

in_circ = false(size(img,1), size(img,2));
[x, y] = meshgrid(1:size(img,2), 1:size(img,1));
ind = (x-x_cent).^2 + (y-y_cent).^2 <= r^2;
in_circ(ind) = true;

theta = atan2((y - y_cent), (x - x_cent));

d = zeros(size(img,1), size(img,2), 2);

%theta = 0:pi/10:2*pi;
denom = ((cos(theta)/a).^ (2/alpha) + (sin(theta)/b).^ (2/alpha)).^ (alpha/2);

x_circ = r * cos(theta);
y_circ = r * sin(theta);

beta_xp = 2 * r * cos(theta) ./ denom;
beta_yp = 2 * r * sin(theta) ./ denom;
%plot(beta_xp+x_cent, beta_yp+y_cent, 'bo', 'LineWidth', 2, 'MarkerSize', 10);

mags = transfer(sqrt(((x-x_cent).^2 + (y-y_cent).^2) ./ (x_circ.^2 + y_circ.^2)), lambda);

d(:,:,1) = (beta_xp - x_circ) .* mags;
d(:,:,2) = (beta_yp - y_circ) .* mags;

new_img = zeros(size(img,1), size(img,2), 3);
for i = 1:size(img, 2)
    for j = 1:size(img, 1)
        i_new = clip(round(i+d(j,i,1)), w);
        j_new = clip(round(j+d(j,i,2)), h);
        new_img(j_new, i_new, :) = img(j, i, :);
        new_img(clip(j_new - 1, h), i_new, :) = img(j, i, :);
        new_img(clip(j_new + 1, h), i_new, :) = img(j, i, :);
        new_img(j_new, clip(i_new - 1, w), :) = img(j, i, :);
        new_img(j_new, clip(i_new + 1, w), :) = img(j, i, :);
    end
end

figure;
imshow(new_img);