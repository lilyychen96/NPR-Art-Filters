function [nearby] = near_edge(cx,cy,thresh,edges)
% inputs:
    % (cx,cy): brush stroke center starting location
    % thresh: number of edge pixels allowed
    % edges: edge map from Canny detector, same size as image
% outputs:
    % nearby: true or false
    
[h,w] = size(edges);
nearby = false;
d = round(thresh); % pixels

subimg = edges(max(1,cy-d):min(h,cy+d), max(1,cx-d):min(w,cx+d));

if sum(subimg(:)) > thresh
    nearby = true;
end
