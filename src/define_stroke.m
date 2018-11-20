function [sx,sy,length,rgb] = define_stroke(img, edge, cx, cy, theta, l)
% inputs:
    % img: input image
    % edges: edge map from Canny detector, same size as image
    % (cx,cy): brush stroke center starting location
    % theta: orientation of brush stroke, in radians
    % l: brush stroke length in pixels
% outputs:
    % sx: range of stroke x-component, [cx end_x]
    % sy: range of stroke y-component, [cy end_y]
    % length: resulting stroke length
    % rgb: rgb color components, [r,g,b]

[h,w] = size(edge);

% compute brush stroke center end
dx = cos(theta);
dy = sin(theta);
end_x = min(cx + round(l * dx), w);
end_y = min(cy + round(l * dy), h);

x = cx;
y = cy;
length = 1;
rgb = [0 0 0];
flag1 = false;
flag2 = false;

% travel along stroke, clip if crosses an edge
while ~flag1 && ~flag2 && (x ~= end_x) && (y ~= end_y) ...
        && (x > 0) && (x < w) && (y > 0) && (y < h)
    n_x = round(x + dx);
    n_y = round(y + dy);
    
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
                if edge(n_x-1, n_y) || edge(n_x, n_y) || edge(n_x+1, n_y) ...
                        || edge(n_x-1, n_y+1) || edge(n_x, n_y+1) ...
                        || edge(n_x+1, n_y+1)
                    end_x = n_x;
                    end_y = n_y;
                end
            else % n_y > 1
                if edge(n_x-1, n_y-1) || edge(n_x, n_y-1) || edge(n_x+1, n_y-1) ...
                        || edge(n_x-1, n_y) || edge(n_x, n_y) || edge(n_x+1, n_y) ...
                        || edge(n_x-1, n_y+1) || edge(n_x, n_y+1) || edge(n_x+1, n_y+1)
                    end_x = n_x;
                    end_y = n_y;
                end
            end
        end
    end
    
    if flag1 && ~flag2
        x = 1;
        y = 1;
    elseif ~flag1 && flag2
        x = w-1;
        y = h-1;
    else
        x = n_x;
        y = n_y;
    end
    
    length = length + 1;
    
    % find RGB value at each point
    r = img(x,y,1);
    g = img(x,y,2);
    b = img(x,y,3);
    rgb = rgb + [r,g,b];
end

% find average RGB value
% length = round(sqrt((x-cx)^2 + (y-cy)^2));
sx = [cx x]; sy = [cy y];
rgb = rgb / length;
