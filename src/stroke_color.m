function [imout] = stroke_color(img,mask,imout,crange)
% inputs:
    % img: input image
    % mask: brush stroke mask
    % imout: output image to overwrite
    % crange: color perturbation
% outputs:
    % imout: output image

[h,w] = size(mask);

n = sum(mask(:));
r = sum(sum(img(:,:,1) .* mask)) / n + (randi(crange)/255);
r = min(max(r,0),255);
g = sum(sum(img(:,:,2) .* mask)) / n + (randi(crange)/255);
g = min(max(g,0),255);
b = sum(sum(img(:,:,3) .* mask)) / n + (randi(crange)/255);
b = min(max(b,0),255);
mask = reshape(mask,h*w,1);

outr = reshape(imout(:,:,1),h*w,1);
outg = reshape(imout(:,:,2),h*w,1);
outb = reshape(imout(:,:,3),h*w,1);
outr(mask ~= 0) = r;
outg(mask ~= 0) = g;
outb(mask ~= 0) = b;

imout(:,:,1) = reshape(outr,h,w);
imout(:,:,2) = reshape(outg,h,w);
imout(:,:,3) = reshape(outb,h,w);
