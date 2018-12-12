function [imout] = define_stroke(img,edge,cx,cy,theta,l,r,imout)
% inputs:
    % img: input image
    % edges: edge map from Canny detector, same size as image
    % (cx,cy): brush stroke center starting location
    % theta: orientation of brush stroke, in radians
    % l: brush stroke length in pixels
    % r: brush stroke radius in pixels
    % imout: output image to overwrite
% outputs:
    % imout: output image

[h,w] = size(edge); % rows, cols

% compute brush stroke center end
dx = cos(theta);
dy = sin(theta);
end_x = min(cx + round(l * dx), w);
end_y = min(cy + round(l * dy), h);

[cols, rows] = meshgrid(1:w,1:h);
mask = zeros(h,w);
mask((rows - cy).^2 + (cols - cx).^2 <= r.^2) = 1;

ex = cx;
ey = cy;
length = 1;
flag1 = false;
flag2 = false;

% figure; image(mask); colormap([0 0 0; 1 1 1]);

% travel along stroke, clip if crosses an edge or beyond image size
while (length <= l) && ~flag1 && ~flag2 && (ex ~= end_x) ...
        && (ey ~= end_y) && (ex > 0) && (ex < w) && (ey > 0) && (ey < h)
    n_x = round(ex + dx);
    n_y = round(ey + dy);
    
    % check image bounds
    if (n_x < 1) || (n_y < 1)
        flag1 = true;
    elseif (n_x >= w-1) || (n_y >= h-1)
        flag2 = true;
    end
    
    % check edge map
    if ~flag1 && ~flag2
        if n_x == 1
            if n_y <= 1
                if edge(n_x, n_y) || edge(n_x+1, n_y) ...
                        || edge(n_x, n_y+1) || edge(n_x+1, n_y+1)
                    end_x = n_x;
                    end_y = n_y;
                end
            else % n_y > 1
                if edge(n_x, n_y-1) || edge(n_x+1, n_y-1) ...
                        || edge(n_x, n_y) || edge(n_x+1, n_y) ...
                        || edge(n_x, n_y+1) || edge(n_x+1, n_y+1)
                    end_x = n_x;
                    end_y = n_y;
                end
            end
        else % n_x > 1
            if n_y == 1
                if edge(n_x-1, n_y) || edge(n_x, n_y) ...
                        || edge(n_x+1, n_y) || edge(n_x-1, n_y+1) ...
                        || edge(n_x, n_y+1) || edge(n_x+1, n_y+1)
                    end_x = n_x;
                    end_y = n_y;
                end
            else % n_y > 1
                if edge(n_x-1, n_y-1) || edge(n_x, n_y-1) ...
                        || edge(n_x+1, n_y-1) || edge(n_x-1, n_y) ...
                        || edge(n_x, n_y) || edge(n_x+1, n_y) ...
                        || edge(n_x-1, n_y+1) || edge(n_x, n_y+1) ...
                        || edge(n_x+1, n_y+1)
                    end_x = n_x;
                    end_y = n_y;
                end
            end
        end
    end
    
    if flag1 && ~flag2
        ex = 1;
        ey = 1;
    elseif ~flag1 && flag2
        ex = w-1;
        ey = h-1;
    else
        ex = n_x;
        ey = n_y;
    end
    
    mask((rows - ey).^2 + (cols - ex).^2 <= r.^2) = 1;
    length = length + 1;
%     figure(1); imshow(mask);
%     pause
end

% figure; image(mask); colormap([0 0 0; 1 1 1]); pause
n = sum(mask(:));
crange = [-10,10];
r = sum(sum(img(:,:,1) .* mask)) / n + (randi(crange)/255);
g = sum(sum(img(:,:,2) .* mask)) / n + (randi(crange)/255);
b = sum(sum(img(:,:,3) .* mask)) / n + (randi(crange)/255);
mask = reshape(mask,h*w,1);

outr = reshape(imout(:,:,1),h*w,1);
outg = reshape(imout(:,:,2),h*w,1);
outb = reshape(imout(:,:,3),h*w,1);
outr(mask ~= 0) = r;
outg(mask ~= 0) = g;
outb(mask ~= 0) = b;

% figure; imshow(imout);
imout(:,:,1) = reshape(outr,h,w);
imout(:,:,2) = reshape(outg,h,w);
imout(:,:,3) = reshape(outb,h,w);
