function extractVein(filePath, newSize)
% add all sub-folders in current directory to the MATLAB path
addpath(genpath(pwd));

delimiter = '';
formatSpec = '%s%[^\n\r]';
fileID = fopen(filePath,'r');

dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);

fileList = dataArray{:, 1};
[m,~] = size(fileList);

if nargin == 1
    newSize = 240;
end
for i=1:m
    oriI = imread(fileList{i});
    if size(oriI,3) > 1
        I = rgb2gray(oriI);
    else
        I = oriI;
    end
    medI = medfilt2(I,[3 3]);
%     I = histeq(medI);
    I = im2double(medI);
    I = imcrop(I,[40 0 239 240]);
%     I = imsharpen(I);
    
    % Extract veins using maximum curvature method
    % use mean curvature later and compare
    [region, edges] = lee_region(I,4,40);    % Get finger region
    %     imshow(region)
    
    % Create a nice image for showing the edges
    edge_img = zeros(size(I));
    edge_img(edges(1,:) + size(I,1)*(0:size(I,2)-1)) = 1;
    edge_img(edges(2,:) + size(I,1)*(0:size(I,2)-1)) = 1;
    %     imshow(edge_img)% the edge of finger veins
    edgeVein =  edge_img + region.* I;
%     imshow(edgeVein);

    sigma = 3; % Parameter
    v_max_curvature = miura_max_curvature(I,region,sigma);
    
    % Binarise the vein image
    md = median(v_max_curvature(v_max_curvature>0));
    v_max_curvature_bin = v_max_curvature > md;

    IC = (I.*region + edge_img) .* v_max_curvature_bin ;
    imwrite(IC, strcat('data/FingerVeinDatabase/sharpenedvein_feature2/',fileList{i}));
end