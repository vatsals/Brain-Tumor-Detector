
function varargout = BrainMRI_GUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BrainMRI_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @BrainMRI_GUI_OutputFcn, ...
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




function BrainMRI_GUI_OpeningFcn(hObject, eventdata, handles, varargin)


handles.output = hObject;
ss = ones(200,200);
axes(handles.axes1);
imshow(ss);
axes(handles.axes2);
imshow(ss);
guidata(hObject, handles);



function varargout = BrainMRI_GUI_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;

function pushbutton1_Callback(hObject, eventdata, handles)

[FileName,PathName] = uigetfile('*.jpg;*.png;*.bmp','Pick an MRI Image');
if isequal(FileName,0)||isequal(PathName,0)
    warndlg('User Press Cancel');
else
    P = imread([PathName,FileName]);
    P = imresize(P,[200,200]);
  
  
  axes(handles.axes1)
  imshow(P);title('Brain MRI Image');
 
  handles.ImgData = P;

  guidata(hObject,handles);
end
function pushbutton2_Callback(hObject, eventdata, handles)

if isfield(handles,'ImgData')
    
    I = handles.ImgData;

gray = rgb2gray(I);
level = graythresh(I);
img = im2bw(I,.6);
img = bwareaopen(img,80); 
img2 = im2bw(I);


axes(handles.axes2)
imshow(img);title('Segmented Image');
%imshow(tumor);title('Segmented Image');

handles.ImgData2 = img2;
guidata(hObject,handles);

signal1 = img2(:,:);
%Feat = getmswpfeat(signal,winsize,wininc,J,'matlab');
%Features = getmswpfeat(signal,winsize,wininc,J,'matlab');

[cA1,cH1,cV1,cD1] = dwt2(signal1,'db4');
[cA2,cH2,cV2,cD2] = dwt2(cA1,'db4');
[cA3,cH3,cV3,cD3] = dwt2(cA2,'db4');

DWT_feat = [cA3,cH3,cV3,cD3];
G = pca(DWT_feat);
whos DWT_feat
whos G
g = graycomatrix(G);
stats = graycoprops(g,'Contrast Correlation Energy Homogeneity');
Contrast = stats.Contrast;
Correlation = stats.Correlation;
Energy = stats.Energy;
Homogeneity = stats.Homogeneity;
Mean = mean2(G);
Standard_Deviation = std2(G);
Entropy = entropy(G);
RMS = mean2(rms(G));
Skewness = skewness(img);
Variance = mean2(var(double(G)));
a = sum(double(G(:)));
Smoothness = 1-(1/(1+a));
Kurtosis = kurtosis(double(G(:)));
Skewness = skewness(double(G(:)));
% Inverse Difference Movement
m = size(G,1);
n = size(G,2);
in_diff = 0;
for i = 1:m
    for j = 1:n
        temp = G(i,j)./(1+(i-j).^2);
        in_diff = in_diff+temp;
    end
end
IDM = double(in_diff);
    
feat = [Contrast,Correlation,Energy,Homogeneity, Mean, Standard_Deviation, Entropy, RMS, Variance, Smoothness, Kurtosis, Skewness, IDM];

load Trainset.mat
 xdata = meas;
 group = label;
 svmStruct1 = svmtrain(xdata,group,'kernel_function', 'linear');
 species = svmclassify(svmStruct1,feat,'showplot',false);
 
 if strcmpi(species,'MALIGNANT')
     helpdlg(' Malignant Tumor ');
     disp(' Malignant Tumor ');
 else
     helpdlg(' Benign Tumor ');
     disp(' Benign Tumor ');
 end
 set(handles.edit4,'string',species);
 % Put the features in GUI
%set(handles.edit5,'string',Mean);
%set(handles.edit6,'string',Standard_Deviation);
%set(handles.edit7,'string',Entropy);
%set(handles.edit8,'string',RMS);
%set(handles.edit9,'string',Variance);
%set(handles.edit10,'string',Smoothness);
%set(handles.edit11,'string',Kurtosis);
%set(handles.edit12,'string',Skewness);
%set(handles.edit13,'string',IDM);
%set(handles.edit14,'string',Contrast);
%set(handles.edit15,'string',Correlation);
%set(handles.edit16,'string',Energy);
%set(handles.edit17,'string',Homogeneity);
end


