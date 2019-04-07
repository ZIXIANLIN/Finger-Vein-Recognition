function varargout = fingerveinReco(varargin)
% FINGERVEINRECO MATLAB code for fingerveinReco.fig
%      FINGERVEINRECO, by itself, creates a new FINGERVEINRECO or raises the existing
%      singleton*.
%
%      H = FINGERVEINRECO returns the handle to a new FINGERVEINRECO or the handle to
%      the existing singleton*.
%
%      FINGERVEINRECO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FINGERVEINRECO.M with the given input arguments.
%
%      FINGERVEINRECO('Property','Value',...) creates a new FINGERVEINRECO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fingerveinReco_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fingerveinReco_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fingerveinReco

% Last Modified by GUIDE v2.5 14-Nov-2018 08:09:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fingerveinReco_OpeningFcn, ...
                   'gui_OutputFcn',  @fingerveinReco_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before fingerveinReco is made visible.
function fingerveinReco_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fingerveinReco (see VARARGIN)

% Choose default command line output for fingerveinReco
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fingerveinReco wait for user response (see UIRESUME)
% uiwait(handles.fingerveinReco);
setappdata(handles.fingerveinReco,'img_src',0);
setappdata(handles.fingerveinReco,'region',0);
setappdata(handles.fingerveinReco,'edge_img',0);
setappdata(handles.fingerveinReco,'I',0);

% --- Outputs from this function are returned to the command line.
function varargout = fingerveinReco_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when fingerveinReco is resized.
function fingerveinReco_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to fingerveinReco (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function m_file_open_Callback(hObject, eventdata, handles)
% hObject    handle to m_file_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile(...
    {'*.bmp;*jpg;*.png;*.jpeg','Image Files(*.bmp,*.jpg,*.png,*.jpeg)';...
    '*.*','All Files (*.*)'},...
    'Pick an image');
if isequal(filename,0)||isequal(pathname,0)
    return;
end
axes(handles.ori_axes);
fpath = [pathname filename];
img_src = imread(fpath);
imshow(img_src);
setappdata(handles.fingerveinReco,'img_src',img_src);
set(handles.import_img,'String', fpath);


% --- Executes on button press in resize_button.
function resize_button_Callback(hObject, eventdata, handles)
% hObject    handle to resize_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
img_src = getappdata(handles.fingerveinReco,'img_src');
if (length(size(img_src)) == 3)
    img_gray = rgb2gray(img_src);
else
    img_gray = img_src;
end

medI = medfilt2(img_gray,[3 3]);
I = im2double(medI);
cropI = imcrop(I,[40 0 239 240]);
img_crop = imsharpen(cropI);
axes(handles.resize_axes);
imshow(img_crop);
setappdata(handles.fingerveinReco, 'img_gray', img_gray);
setappdata(handles.fingerveinReco, 'img_crop', img_crop);

% --- Executes on button press in region_button.
function region_button_Callback(hObject, eventdata, handles)
% hObject    handle to region_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
img_crop = getappdata(handles.fingerveinReco, 'img_crop');
[region, ~] = lee_region(img_crop,4,40);
axes(handles.region_axes)
imshow(region);
setappdata(handles.fingerveinReco, 'region', region);

% --- Executes on button press in seg_button.
function seg_button_Callback(hObject, eventdata, handles)
% hObject    handle to seg_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
region = getappdata(handles.fingerveinReco, 'region');
img_crop = getappdata(handles.fingerveinReco, 'img_crop');
[~, edges] = lee_region(img_crop,4,40);
edge_img = zeros(size(img_crop));
edge_img(edges(1,:) + size(img_crop,1)*(0:size(img_crop,2)-1)) = 1;
edge_img(edges(2,:) + size(img_crop,1)*(0:size(img_crop,2)-1)) = 1;
edgeVein =  edge_img + region.* img_crop;
axes(handles.seg_axes)
imshow(edgeVein);

% --- Executes on button press in extract_button.
function extract_button_Callback(hObject, eventdata, handles)
% hObject    handle to extract_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
img_crop = getappdata(handles.fingerveinReco,'img_crop');
region = getappdata(handles.fingerveinReco, 'region');
edge_img = getappdata(handles.fingerveinReco, 'edge_img');
sigma = 3; % Parameter
v_max_curvature = miura_max_curvature(img_crop,region,sigma);
% Binarise the vein image
md = median(v_max_curvature(v_max_curvature>0));
v_max_curvature_bin = v_max_curvature > md;
IC = (img_crop.*region + edge_img) .* v_max_curvature_bin ;
axes(handles.extract_axes);
imshow(IC);
setappdata(handles.fingerveinReco,'IC', IC);


% --- Executes on button press in match_button.
function match_button_Callback(hObject, eventdata, handles)
% hObject    handle to match_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% region = getappdata(handles.fingerveinReco, 'region');
IC = getappdata(handles.fingerveinReco, 'IC');
[m,n] = size(IC);
[region, ~] = lee_region(IC,4,40);
IG = double(zeros(m,n));
IG(find(region==0))=NaN;
IG(find(region==1))=double(IC(find(region==1)));
[GLRLMS,~]= grayrlmatrix(IC, 'G', [0 255], 'N', 256);
for i=1:4
    GLRLangle = GLRLMS{i};
    GLRLangle(1,:) = zeros(1,n);
    GLRLMS{i} = GLRLangle;
end
stats = grayrlprops(GLRLMS);
glrlmsProps = mean(stats);
offset=1;
offsets = [0 offset; -offset offset; -offset 0; -offset -offset];
glcMat = graycomatrix( IG, 'Offset', offsets, 'GrayLimits', [0,255],'NumLevels', 256);
neighbors = size(glcMat,3);
glcm = zeros(size(glcMat,1),size(glcMat,2));
for k=1:neighbors
    glcm = glcm + glcMat(:,:,k);
end
glcProps = getGLCProps(glcm);
eta = SI_Moment(IC);
inv_moments = Hu_Moments(eta);
imMat=[glrlmsProps, glcProps, inv_moments];
imMat
xlswrite('testinput.xlsx','''','A2:AL2');
xlswrite('testinput.xlsx',imMat,'A2:AL2');
testinput = readtable('testinput.xlsx');
load trainedModel.mat;
yfit = trainedModel.predictFcn(testinput);
setappdata(handles.fingerveinReco, 'testinput', testinput);
setappdata(handles.fingerveinReco, 'yfit', yfit);

% --- Executes on button press in predict_button.
function predict_button_Callback(hObject, eventdata, handles)
% hObject    handle to predict_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on button press in err_button.
% testinput = getappdata(handles.fingveinReco,'testinput');
yfit = getappdata(handles.fingerveinReco, 'yfit');
set(handles.predict_text,'String', yfit);


% --------------------------------------------------------------------
function m_file_Callback(hObject, eventdata, handles)
% hObject    handle to m_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
