%% denoise images - median filter
close all;
orig = im2double(imread('C:\Users\linzi\Documents\MATLAB\ECEpatternRecognition\termProject\data\FingerVeinDatabase\003_L_middle_1.bmp'));  
I = rgb2gray(orig);
J = medfilt2(I,[3 3]);
imshowpair(I, J, 'montage')
%% image crop
orig = im2double(imread('data\FingerVeinDatabase\001_L_middle_3.bmp'));  
I = rgb2gray(orig);
cropI = imcrop(I);
[m,n] = size(cropI);
new = zeros(240,320);
new((240-m)/2:(240-m)/2+m-1,:) = cropI; 
% new((240-m)/2:(240-m)/2+m-1,(320-n)/2:(320-n)/2+n-1) = cropI;
imshow(new);
imwrite(new,'C:\Users\linzi\Documents\MATLAB\ECEpatternRecognition\termProject\data\FingerVeinDatabase\001_L_middle_3.bmp');
        
%% 
close all;
% Segmentation
orig = im2double(imread('C:\Users\linzi\Documents\MATLAB\ECEpatternRecognition\termProject\data\FingerVeinDatabase\002_L_index_1.bmp'));  
if size(orig,3) > 1
    I = rgb2gray(orig);
else
    I = orig;
end
I = imresize(I, 0.5); 
[m,n] = size(I);
mask_h = 4;
mask_w = 20;
upMask = zeros(mask_h,mask_w);
downMask = zeros(mask_h,mask_w);
upMask(1:2,:) = -1;
upMask(3:4,:) = 1;
downMask(1:2,:) = 1;
downMask(3:4,:) = -1;
imgUpFilt = imfilter(I,upMask,'replicate'); 
upFilt = imgUpFilt(1:floor(m/2),:);
[~,upEdge] = max(upFilt);
imgDownFilt = imfilter(I,downMask,'replicate');
downFilt = imgDownFilt(ceil(m/2):end,:);
[~,downEdge] = max(downFilt);
region = zeros(size(I));
for i=1:n
    region(upEdge(i):downEdge(i)+size(downFilt,1), i) = 1;
end
imshowpair(I,region,'montage')
edges = zeros(2,n);
edges(1,:) = upEdge;
edges(2,:) = round(downEdge + size(downFilt,1));imshow(edges)
edge_img = zeros(size(I));
edge_img(edges(1,:) + size(I,1)*(0:size(I,2)-1)) = 1;
edge_img(edges(2,:) + size(I,1)*(0:size(I,2)-1)) = 1;imshow(edge_img)
SI = I.*region + edge_img;
imshowpair(I,SI,'montage');

% Feature Extraction
[~,H2] = curvature(SI);
md = median(H2(H2>0));
v_mean_curvature_bin = H2 > md; imshow(v_mean_curvature_bin)
IC = SI.*v_mean_curvature_bin;imshow(IC)
% IC = zeros([size(I) 3]);
% IC(:,:,1) = SI;
% IC(:,:,2) = SI + 0.4*v_mean_curvature_bin;
% IC(:,:,3) = SI;
imshowpair(SI,IC,'montage')

%% Extract veins using repeated line tracking method
max_iterations = 3000; r=1; W=17; % Parameters
v_repeated_line = miura_repeated_line_tracking(I,region,max_iterations,r,W);

% Binarise the vein image
md = median(v_repeated_line(v_repeated_line>0));
v_repeated_line_bin = v_repeated_line > md; 
imshow(v_repeated_line_bin)

% Matching
[h, w] = size(v_repeated_line_bin); % Get height and width of registered data

% Determine value of match, just cross-correlation, see also xcorr2
% Nm = conv2(double(v_mean_curvature_bin), rot90(double(v_repeated_line_bin(W+1:h-W, r+1:w-r),2)), 'valid');
Nm = xcorr2(double(v_mean_curvature_bin), double(v_repeated_line_bin));


% Maximum value of match
[Nmm,mi] = max(Nm(:)); % (what about multiple maximum values ?)
[t0,s0] = ind2sub(size(Nm),mi);
v_repeated_line_bin = im2double(v_repeated_line_bin);
% Normalize
score = Nmm/(sum(sum(v_repeated_line_bin(W+1:h-W, r+1:w-r))) + sum(sum(I(t0:t0+h-2*W-1, s0:s0+w-2*r-1))));
fprintf('Match score: %6.4f %%\n', score);

%% extract features using maximum curvature
oriI = imread('C:\Users\linzi\Documents\MATLAB\ECEpatternRecognition\termProject\data\FingerVeinDatabase\001_L_index_5.bmp');
if size(oriI,3) > 1
    I = rgb2gray(oriI);
else
    I = oriI;
end
medI = medfilt2(I,[3 3]);
I = im2double(medI);
I = imcrop(I,[40 0 239 240]);
% Extract veins using maximum curvature method
% use mean curvature later and compare
[region, edges] = lee_region(I,4,40);    % Get finger region
imshow(region)
% Create a nice image for showing the edges
edge_img = zeros(size(I));
edge_img(edges(1,:) + size(I,1)*(0:size(I,2)-1)) = 1;
edge_img(edges(2,:) + size(I,1)*(0:size(I,2)-1)) = 1;
imshow(edge_img);
edgeVein =  edge_img + region.* I;
imshow(edgeVein);
sigma = 3; % Parameter
v_max_curvature = miura_max_curvature(I,region,sigma);
% Binarise the vein image
md = median(v_max_curvature(v_max_curvature>0));
v_max_curvature_bin = v_max_curvature > md;
imshowpair(edgeVein,v_max_curvature_bin,'montage')
IC = (I.*region + edge_img) .* v_max_curvature_bin ;
imshow(IC);
[mag, phase] = imgaborfilt(IC,2,0)









