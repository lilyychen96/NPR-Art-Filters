function [nearby] = near_edge(cx,cy,edges)
% inputs:
    % (cx,cy): brush stroke center starting location
    % edges: edge map from Canny detector, same size as image
% outputs:
    % nearby: true or false
    
[h,w] = size(edges);
thresh = h/100;
nearby = false;
d = round(thresh); % pixels, subject to change

subimg = edges(max(1,cy-d):min(h,cy+d), max(1,cx-d):min(w,cx+d));

if sum(subimg(:)) > thresh
    nearby = true;
end
