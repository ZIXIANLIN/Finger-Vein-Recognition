function [huimMat] = createTrainSet_hu(filePath)%offest=1
    
    % add all sub-folders in current directory to the MATLAB path
    addpath(genpath(pwd));
    
    % initiate file import parameters
    delimiter = '';
    formatSpec = '%s%[^\n\r]';
    fileID = fopen(filePath,'r');
    
    % import file list of finger vein data into fileList
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
    fclose(fileID);
    fileList = dataArray{:, 1};
    [fileSize,~] = size(fileList);
    
    huimMat = [];
    
    % iterate through fileList and extract features 
    % from resized vein images
    for a=1:fileSize
        
        IC = imread(strcat('data/FingerVeinDatabase/sharpenedvein_feature/',fileList{a}));
        [m,n] = size(IC);
        [region, ~] = lee_region(IC,4,40);
        IG = double(zeros(m,n));
        IG(find(region==0))=NaN;
        IG(find(region==1))=double(IC(find(region==1)));

        
         % evaluate 9 Laws' texture energy measures 
%          lawMat = laws(IC, round(m/10));
%          lawMatSize = size(lawMat, 2);
% 
%          energyMat = zeros(m, n, lawMatSize);
%          for k=1:lawMatSize
%             energyMat(:,:, k) = lawMat{1,k};
%          end
% 
%          energyProps = zeros(1, lawMatSize);
%          for j=1:lawMatSize
%              energyProps(1,j) = mean(mean(energyMat(:,:,j)));
%          end
         
        % compute gray-level run-length matrix (GLRLM) with 
        % 256 gray levels and the default 4 angles
%         [GLRLMS,~]= grayrlmatrix(IC, 'G', [0 255], 'N', 256);
%         for i=1:4
%             GLRLangle = GLRLMS{i};
%             GLRLangle(1,:) = zeros(1,n);
%             GLRLMS{i} = GLRLangle;
%         end
        
        % extract 11 features from GLRLM for all 4 angles
%         stats = grayrlprops(GLRLMS);
%         glrlmsProps = mean(stats);

        % compute gray-level co-occurence matrix (GLCM)
        % 256 gray levels and 0, 45, 90 and 135 degrees
%         offsets = [0 offset; -offset offset; -offset 0; -offset -offset];
%         glcMat = graycomatrix( IG, 'Offset', offsets, 'GrayLimits', [0,255],'NumLevels', 256);
        
        % sum over all 4 GLCMs and extract 20 texture features
%         neighbors = size(glcMat,3);
%         glcm = zeros(size(glcMat,1),size(glcMat,2));
%         for k=1:neighbors
%             glcm = glcm + glcMat(:,:,k);
%         end
%         glcProps = getGLCProps(glcm);
         
        % extract 12 Fourier essence feature vector
        % 30 degree angle buckets and 2 pixel radius buckets
%         [essenceMat, ~] = fourierAnalysis(IC, 30, 1, 0.5);
        
        % extract 7 Hu's moment features 
        eta = SI_Moment(IC);
        inv_moments = Hu_Moments(eta);
        inv_moments = log(abs(inv_moments));
        
        % concatenate all extracted features
        % 11 GLRLM + 20 GLCM + 7 Hu's moments
        % 9 Law + 11 GLRLM + 20 GLCM + 12 Fourier + 7 Hu's moments
%         imRowMat = horzcat(energyProps, glrlmsProps, glcProps, essenceMat, inv_moments);
        
%         imRowMat = horzcat(inv_moments);
        huimMat(a,:) = inv_moments;
        
    end
end