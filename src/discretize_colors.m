function [quant] = discretize_colors(img)
% discretize colors of input image
% https://www.mathworks.com/help/images/ref/imquantize.html
tic
thresh = multithresh(img, 7);
val = [0 thresh(2:end) 255];
quant = imquantize(img, thresh, val);
toc
