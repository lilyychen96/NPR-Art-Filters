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
% just approximated and generalized

h = size(img, 1);
rmin = max(1, round(h/500));
rmax = max(round(h/150), 5);
lmin = round(style/2);
lmax = max(2*style, round(h/25));

if style <= 3
    % pointillist style tends to have short brush strokes and a greater
    % variation in color for adjacent areas
    rmax = max(1, ceil(h/125));
    lmax = min(2*style, 3);
    crange = [-5*(5-style), 5*(5-style)];
    thresh = 0;

elseif style > 3 && style <= 7
    % impressionist style tends to be vibrant with contrast between
    % opposing sides of the color wheel
    hsv = rgb2hsv(img);
    hsv(:,:,2) = hsv(:,:,2) * 1.2;
    hsv(hsv > 1) = 1;
    img = hsv2rgb(hsv);

    crange = [-(10-style), 3*(10-style)];
    thresh = 2;

else
    % expressionist style tends to be more intense but darker, agitated
    % make colors more vibrant/saturated to begin with
    hsv = rgb2hsv(img);
    hsv(:,:,2) = hsv(:,:,2)*1.4;
    hsv(:,:,3) = hsv(:,:,3) * 0.95;
    hsv(hsv > 1) = 1;
    img = hsv2rgb(hsv);

    crange = [-3*style, style];
    thresh = 5;
end

end
