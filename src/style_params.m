function [rmin,rmax,lmin,lmax,crange,thresh,img] = style_params(style,img)
% inputs:
    % style: integer between 1 and 10, inclusive
    % img: input image
% outputs:
    % rmin: minimum brush stroke radius
    % rmax: maximum brush stroke radius
    % lmin: minimum brush stroke length
    % lmax: maximum brush stroke length
    % crange: color perturbance
    % thresh: number of edge pixels allowed
    % img: input image (may or may not be altered)
    
% NOTE: style params are not totally true to each art movement,
% just approximate and generalized

h = size(img,1);
rmin = round(h/500);

if style <= 3
    % pointillist style tends to have short brush strokes and a greater
    % variation in color for adjacent areas
    rmax = min(round(h/250),5);
    lmin = 1;
    lmax = round(1.5*style);
    crange = [-5*(5-style),5*(5-style)];
    thresh = 0;
    
elseif style > 3 && style <= 7
    % impressionist style tends to be vibrant with contrast between
    % opposing sides of the color wheel
    hsv = rgb2hsv(img);
    hsv(:,:,2) = hsv(:,:,2) * 1.2;
    hsv(hsv > 1) = 1;
    img = hsv2rgb(hsv);
    
    rmax = min(floor(h/150),7);
    lmin = round(h/100);
    lmax = lmin*2*style;
    crange = [-(10-style),3*(10-style)];
    thresh = h/25;
    
else
    % expressionist style tends to be more intense but darker, agitated
    % make colors more vibrant/saturated to begin with
    hsv = rgb2hsv(img);
    hsv(:,:,2) = hsv(:,:,2)*1.4;
    hsv(:,:,3) = hsv(:,:,3) * 0.95;
    hsv(hsv > 1) = 1;
    img = hsv2rgb(hsv);
    
    rmax = min(floor(h/150),7);
    lmin = style*2;
    lmax = style*style;
    crange = [-3*style,style];
    thresh = h/50;
end
    