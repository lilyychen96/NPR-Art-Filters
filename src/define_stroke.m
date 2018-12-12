function [mask] = define_stroke(edge,cx,cy,theta,l,r)
% inputs:
    % edges: edge map from Canny detector, same size as image
    % (cx,cy): brush stroke center starting location
    % theta: orientation of brush stroke, in radians
    % l: brush stroke length in pixels
    % r: brush stroke radius in pixels
% outputs:
    % mask: brush stroke mask

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
    n_y = round(ey + dy);
    n_x = round(ex + dx);
    
    % check image bounds
    if (n_y < 1) || (n_x < 1)
        flag1 = true;
    elseif (n_y >= h-1) || (n_x >= w-1)
        flag2 = true;
    end
    
    % check edge map
    if ~flag1 && ~flag2
        if n_y == 1
            if n_x <= 1
                if edge(n_y, n_x) || edge(n_y+1, n_x) ...
                        || edge(n_y, n_x+1) || edge(n_y+1, n_x+1)
                    end_x = n_y;
                    end_y = n_x;
                end
            else % n_y > 1
                if edge(n_y, n_x-1) || edge(n_y+1, n_x-1) ...
                        || edge(n_y, n_x) || edge(n_y+1, n_x) ...
                        || edge(n_y, n_x+1) || edge(n_y+1, n_x+1)
                    end_x = n_y;
                    end_y = n_x;
                end
            end
        else % n_x > 1
            if n_x == 1
                if edge(n_y-1, n_x) || edge(n_y, n_x) ...
                        || edge(n_y+1, n_x) || edge(n_y-1, n_x+1) ...
                        || edge(n_y, n_x+1) || edge(n_y+1, n_x+1)
                    end_x = n_y;
                    end_y = n_x;
                end
            else % n_y > 1
                if edge(n_y-1, n_x-1) || edge(n_y, n_x-1) ...
                        || edge(n_y+1, n_x-1) || edge(n_y-1, n_x) ...
                        || edge(n_y, n_x) || edge(n_y+1, n_x) ...
                        || edge(n_y-1, n_x+1) || edge(n_y, n_x+1) ...
                        || edge(n_y+1, n_x+1)
                    end_x = n_y;
                    end_y = n_x;
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
end
