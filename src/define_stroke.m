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

[cols, rows] = meshgrid(1:w,1:h);
mask = zeros(h,w);
mask((rows - cy).^2 + (cols - cx).^2 <= r.^2) = 1;
temp = mask;

ex = cx;
ey = cy;
length = 1;
exit_loop = false;

% travel along stroke, clip if crosses an edge or beyond image size
while (length <= l) && ~exit_loop
    n_y = round(ey + dy);
    n_x = round(ex + dx);
    
    % check image bounds
    if (n_y < 1) || (n_x < 1) || (n_y >= h-1) || (n_x >= w-1)
        exit_loop = true;
    end
    
    % check if mask crosses an edge
    if ~exit_loop
        temp((rows - n_y).^2 + (cols - n_x).^2 <= r.^2) = 1;
        temp = temp .* edge;
        if sum(temp(:)) > r
            exit_loop = true;
        else
            ex = n_x;
            ey = n_y;
            mask((rows - ey).^2 + (cols - ex).^2 <= r.^2) = 1;
            length = length + 1;
        end
    end
end

end
