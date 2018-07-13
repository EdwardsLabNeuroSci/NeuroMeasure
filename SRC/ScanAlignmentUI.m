function varargout = ScanAlignmentUI(varargin)
% SCANALIGNMENTUI MATLAB code for ScanAlignmentUI.fig
%      SCANALIGNMENTUI, by itself, creates a new SCANALIGNMENTUI or raises the existing
%      singleton*.
%
%      H = SCANALIGNMENTUI returns the handle to a new SCANALIGNMENTUI or the handle to
%      the existing singleton*.
%
%      SCANALIGNMENTUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SCANALIGNMENTUI.M with the given input arguments.
%
%      SCANALIGNMENTUI('Property','Value',...) creates a new SCANALIGNMENTUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ScanAlignmentUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ScanAlignmentUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ScanAlignmentUI

% Last Modified by GUIDE v2.5 22-Apr-2018 22:48:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ScanAlignmentUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ScanAlignmentUI_OutputFcn, ...
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


% --- Executes just before ScanAlignmentUI is made visible.
function ScanAlignmentUI_OpeningFcn(hObject, eventdata, handles, varargin)

handles.imdbI = varargin{1,1};
handles.ScanResolution = varargin{1,2};
load('StandardScan.mat');
handles.imdbS = imdbS;

IsizeX = size(handles.imdbI,1);
IsizeY = size(handles.imdbI,2);
IsizeZ = size(handles.imdbI,3);

handles.InputSlice = round(IsizeZ/2);

axes(handles.InputZ)
imshow(handles.imdbI(:,:,round(IsizeZ/2)),[min(min(min(handles.imdbI))),max(max(max(handles.imdbI)))])
hold on
quiver(1,1,0,IsizeX,'Color','b','LineWidth',3,'Clipping','off');
text(1,IsizeX*(0.95),'X','Color','b','FontWeight','bold','FontSize',15)
quiver(1,1,IsizeY,0,'Color','r','LineWidth',3,'Clipping','off');
text(IsizeY*(0.95),1,'Y','Color','r','FontWeight','bold','FontSize',15)
hold off

axes(handles.InputX)
I = flipud(squeeze(handles.imdbI(round(IsizeX/2),:,:))');
imshow(I,[min(min(min(handles.imdbI))),max(max(max(handles.imdbI)))])
hold on
quiver(1,IsizeZ,0,-IsizeZ,'Color','g','LineWidth',3,'Clipping','off');
text(1,IsizeY*(0.05),'Z','Color','g','FontWeight','bold','FontSize',15)
quiver(1,IsizeZ,IsizeY,0,'Color','r','LineWidth',3,'Clipping','off');
text(IsizeY*(0.95),IsizeZ*(0.95),'Y','Color','r','FontWeight','bold','FontSize',15)
hold off

axes(handles.InputY)
I = flipud(squeeze(handles.imdbI(:,round(IsizeY/2),:))');
imshow(I,[min(min(min(handles.imdbI))),max(max(max(handles.imdbI)))])
hold on
quiver(1,IsizeZ,0,-IsizeZ,'Color','g','LineWidth',3,'Clipping','off');
text(1,IsizeX*(0.05),'Z','Color','g','FontWeight','bold','FontSize',15)
quiver(1,IsizeZ,IsizeX,0,'Color','b','LineWidth',3,'Clipping','off');
text(IsizeX*(0.95),IsizeZ*(0.95),'X','Color','b','FontWeight','bold','FontSize',15)
hold off

SsizeX = size(handles.imdbS,1);
SsizeY = size(handles.imdbS,2);
SsizeZ = size(handles.imdbS,3);

handles.StandardSlice = round(SsizeZ/2);

axes(handles.StandardZ)
imshow(handles.imdbS(:,:,round(SsizeZ/2)),[min(min(min(handles.imdbS))),max(max(max(handles.imdbS)))])
hold on
quiver(1,1,0,SsizeX,'Color','b','LineWidth',3,'Clipping','off');
text(1,SsizeX*(0.95),'X','Color','b','FontWeight','bold','FontSize',15)
quiver(1,1,SsizeY,0,'Color','r','LineWidth',3,'Clipping','off');
text(SsizeY*(0.95),1,'Y','Color','r','FontWeight','bold','FontSize',15)
hold off

axes(handles.StandardX)
I = flipud(squeeze(handles.imdbS(round(SsizeX/2),:,:))');
imshow(I,[min(min(min(handles.imdbS))),max(max(max(handles.imdbS)))])
hold on
quiver(1,SsizeZ,0,-SsizeY,'Color','g','LineWidth',3,'Clipping','off');
text(1,SsizeY*(0.05),'Z','Color','g','FontWeight','bold','FontSize',15)
quiver(1,SsizeZ,SsizeY,0,'Color','r','LineWidth',3,'Clipping','off');
text(SsizeZ*(0.95),SsizeY*(0.95),'Y','Color','r','FontWeight','bold','FontSize',15)
hold off

axes(handles.StandardY)
I = flipud(squeeze(handles.imdbS(:,round(SsizeY/2),:))');
imshow(I,[min(min(min(handles.imdbS))),max(max(max(handles.imdbS)))])
hold on
quiver(1,SsizeZ,0,-SsizeX,'Color','g','LineWidth',3,'Clipping','off');
text(1,SsizeX*(0.05),'Z','Color','g','FontWeight','bold','FontSize',15)
quiver(1,SsizeZ,SsizeX,0,'Color','b','LineWidth',3,'Clipping','off');
text(SsizeZ*(0.95),SsizeX*(0.95),'X','Color','b','FontWeight','bold','FontSize',15)
hold off

handles.InputSlider.Min = 1;
handles.InputSlider.Max = IsizeZ;
handles.InputSlider.Value = round(IsizeZ/2);

handles.StandardSlider.Min = 1;
handles.StandardSlider.Max = SsizeZ;
handles.StandardSlider.Value = round(SsizeZ/2);

handles.Output = 'Quick';
handles.Quality.Value = 0;
handles.Quick.Value = 1;
handles.Sequence = cell(0,0); %This entry will track what operations are done to the imdb and will be used in DataImportUI for data point alignment.

% Update handles structure
guidata(hObject, handles);

uiwait;

% --- Outputs from this function are returned to the command line.
function varargout = ScanAlignmentUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(handles)
    varargout{1} = handles.imdbI;
    varargout{2} = handles.ScanResolution;
    varargout{3} = handles.Sequence;
    varargout{4} = handles.Output;

    delete(gcf);
else
    varargout{1} = [];
    varargout{2} = [];
    varargout{3} = [];
    varargout{4} = 'Abort';
end


% --- Executes on slider movement.
function InputSlider_Callback(hObject, eventdata, handles)

handles.InputSlice = round(get(hObject,'Value'));
I = handles.imdbI(:,:,round(get(hObject,'Value')));
IsizeX = size(handles.imdbI,1);
IsizeY = size(handles.imdbI,2);

axes(handles.InputZ)
imshow(I,[min(min(min(handles.imdbI))),max(max(max(handles.imdbI)))])
hold on
quiver(1,1,0,IsizeX,'Color','b','LineWidth',3,'Clipping','off');
text(1,IsizeX*(0.95),'X','Color','b','FontWeight','bold','FontSize',15)
quiver(1,1,IsizeY,0,'Color','r','LineWidth',3,'Clipping','off');
text(IsizeY*(0.95),1,'Y','Color','r','FontWeight','bold','FontSize',15)
hold off

guidata(hObject, handles);

% --- Executes on slider movement.
function StandardSlider_Callback(hObject, eventdata, handles)

handles.StandardSlice = round(get(hObject,'Value'));
I = handles.imdbS(:,:,round(get(hObject,'Value')));
SsizeX = size(handles.imdbS,1);
SsizeY = size(handles.imdbS,2);

axes(handles.StandardZ)
imshow(I,[min(min(min(handles.imdbS))),max(max(max(handles.imdbS)))])
hold on
quiver(1,1,0,SsizeX,'Color','b','LineWidth',3,'Clipping','off');
text(1,SsizeX*(0.95),'X','Color','b','FontWeight','bold','FontSize',15)
quiver(1,1,SsizeY,0,'Color','r','LineWidth',3,'Clipping','off');
text(SsizeY*(0.95),1,'Y','Color','r','FontWeight','bold','FontSize',15)
hold off

guidata(hObject, handles);


% --- Executes on button press in Done.
function Done_Callback(hObject, eventdata, handles)

anwser = questdlg('Confirm scan alignment', ...
    'Confirm','Yes','No','No');
switch anwser
    case 'Yes'
        guidata(hObject, handles);
        uiresume;
    case 'No'
end

% --- Executes on button press in Abort.
function Abort_Callback(hObject, eventdata, handles)
handles.Output = 'Abort';

anwser = questdlg('Abort Alignment?', ...
    'Abort','Yes','No','No');
switch anwser
    case 'Yes'
        guidata(hObject, handles);
        uiresume;
    case 'No'
end



% --- Executes on button press in XRotate.
function XRotate_Callback(hObject, eventdata, handles)
handles.Sequence{1,end+1} = 'XRotate';
IsizeX = size(handles.imdbI,1);
IsizeY = size(handles.imdbI,2);
IsizeZ = size(handles.imdbI,3);

handles.ScanResolution = [handles.ScanResolution(1),handles.ScanResolution(3),handles.ScanResolution(2)];
% handles.Position = [handles.Position(1),-handles.Position(3),handles.Position(2)];
% Orientation(1,:) = handles.Orientation(1,:);
% Orientation(2,:) = -handles.Orientation(3,:);
% Orientation(3,:) = handles.Orientation(2,:);
% handles.Orientation = Orientation;

tempimdbI = zeros(IsizeX,IsizeZ,IsizeY);
for i = 1:IsizeZ
    tempimdbI(:,(end+1)-i,:) = handles.imdbI(:,:,i);
end
handles.imdbI = tempimdbI;
IsizeX = size(handles.imdbI,1);
IsizeY = size(handles.imdbI,2);
IsizeZ = size(handles.imdbI,3);

axes(handles.InputZ)
imshow(handles.imdbI(:,:,handles.InputSlice),[min(min(min(handles.imdbI))),max(max(max(handles.imdbI)))])
hold on
quiver(1,1,0,IsizeX,'Color','b','LineWidth',3,'Clipping','off');
text(1,IsizeX*(0.95),'X','Color','b','FontWeight','bold','FontSize',15)
quiver(1,1,IsizeY,0,'Color','r','LineWidth',3,'Clipping','off');
text(IsizeY*(0.95),1,'Y','Color','r','FontWeight','bold','FontSize',15)
hold off

axes(handles.InputX)
I = flipud(squeeze(handles.imdbI(round(IsizeX/2),:,:))');
imshow(I,[min(min(min(handles.imdbI))),max(max(max(handles.imdbI)))])
hold on
quiver(1,IsizeZ,0,-IsizeZ,'Color','g','LineWidth',3,'Clipping','off');
text(1,IsizeY*(0.05),'Z','Color','g','FontWeight','bold','FontSize',15)
quiver(1,IsizeZ,IsizeY,0,'Color','r','LineWidth',3,'Clipping','off');
text(IsizeY*(0.95),IsizeZ*(0.95),'Y','Color','r','FontWeight','bold','FontSize',15)
hold off

axes(handles.InputY)
I = flipud(squeeze(handles.imdbI(:,round(IsizeY/2),:))');
imshow(I,[min(min(min(handles.imdbI))),max(max(max(handles.imdbI)))])
hold on
quiver(1,IsizeZ,0,-IsizeZ,'Color','g','LineWidth',3,'Clipping','off');
text(1,IsizeX*(0.05),'Z','Color','g','FontWeight','bold','FontSize',15)
quiver(1,IsizeZ,IsizeX,0,'Color','b','LineWidth',3,'Clipping','off');
text(IsizeX*(0.95),IsizeZ*(0.95),'X','Color','b','FontWeight','bold','FontSize',15)
hold off

guidata(hObject, handles);

% --- Executes on button press in YRotate.
function YRotate_Callback(hObject, eventdata, handles)
handles.Sequence{1,end+1} = 'YRotate';
IsizeX = size(handles.imdbI,1);
IsizeY = size(handles.imdbI,2);
IsizeZ = size(handles.imdbI,3);

handles.ScanResolution = [handles.ScanResolution(3),handles.ScanResolution(2),handles.ScanResolution(1)];
% handles.Position = [-handles.Position(3),handles.Position(2),handles.Position(1)];
% Orientation(1,:) = -handles.Orientation(3,:);
% Orientation(2,:) = handles.Orientation(2,:);
% Orientation(3,:) = handles.Orientation(1,:);
% handles.Orientation = Orientation;

tempimdbI = zeros(IsizeZ,IsizeY,IsizeX);
for i = 1:IsizeZ
    tempimdbI((end+1)-i,:,:) = handles.imdbI(:,:,i)';
end
handles.imdbI = tempimdbI;
IsizeX = size(handles.imdbI,1);
IsizeY = size(handles.imdbI,2);
IsizeZ = size(handles.imdbI,3);

axes(handles.InputZ)
imshow(handles.imdbI(:,:,handles.InputSlice),[min(min(min(handles.imdbI))),max(max(max(handles.imdbI)))])
hold on
quiver(1,1,0,IsizeX,'Color','b','LineWidth',3,'Clipping','off');
text(1,IsizeX*(0.95),'X','Color','b','FontWeight','bold','FontSize',15)
quiver(1,1,IsizeY,0,'Color','r','LineWidth',3,'Clipping','off');
text(IsizeY*(0.95),1,'Y','Color','r','FontWeight','bold','FontSize',15)
hold off

axes(handles.InputX)
I = flipud(squeeze(handles.imdbI(round(IsizeX/2),:,:))');
imshow(I,[min(min(min(handles.imdbI))),max(max(max(handles.imdbI)))])
hold on
quiver(1,IsizeZ,0,-IsizeZ,'Color','g','LineWidth',3,'Clipping','off');
text(1,IsizeY*(0.05),'Z','Color','g','FontWeight','bold','FontSize',15)
quiver(1,IsizeZ,IsizeY,0,'Color','r','LineWidth',3,'Clipping','off');
text(IsizeY*(0.95),IsizeZ*(0.95),'Y','Color','r','FontWeight','bold','FontSize',15)
hold off

axes(handles.InputY)
I = flipud(squeeze(handles.imdbI(:,round(IsizeY/2),:))');
imshow(I,[min(min(min(handles.imdbI))),max(max(max(handles.imdbI)))])
hold on
quiver(1,IsizeZ,0,-IsizeZ,'Color','g','LineWidth',3,'Clipping','off');
text(1,IsizeX*(0.05),'Z','Color','g','FontWeight','bold','FontSize',15)
quiver(1,IsizeZ,IsizeX,0,'Color','b','LineWidth',3,'Clipping','off');
text(IsizeX*(0.95),IsizeZ*(0.95),'X','Color','b','FontWeight','bold','FontSize',15)
hold off

guidata(hObject, handles);

% --- Executes on button press in ZRotate.
function ZRotate_Callback(hObject, eventdata, handles)
handles.Sequence{1,end+1} = 'ZRotate';
IsizeX = size(handles.imdbI,1);
IsizeY = size(handles.imdbI,2);
IsizeZ = size(handles.imdbI,3);

handles.ScanResolution = [handles.ScanResolution(2),handles.ScanResolution(1),handles.ScanResolution(3)];
% handles.Position = [handles.Position(2),-handles.Position(1),handles.Position(3)];
% Orientation(1,:) = handles.Orientation(2,:);
% Orientation(2,:) = -handles.Orientation(1,:);
% Orientation(3,:) = handles.Orientation(3,:);
% handles.Orientation = Orientation;

tempimdbI = zeros(IsizeY,IsizeX,IsizeZ);
for i = 1:IsizeX
    tempimdbI(:,(end+1)-i,:) = handles.imdbI(i,:,:);
end
handles.imdbI = tempimdbI;
IsizeX = size(handles.imdbI,1);
IsizeY = size(handles.imdbI,2);
IsizeZ = size(handles.imdbI,3);

axes(handles.InputZ)
imshow(handles.imdbI(:,:,handles.InputSlice),[min(min(min(handles.imdbI))),max(max(max(handles.imdbI)))])
hold on
quiver(1,1,0,IsizeX,'Color','b','LineWidth',3,'Clipping','off');
text(1,IsizeX*(0.95),'X','Color','b','FontWeight','bold','FontSize',15)
quiver(1,1,IsizeY,0,'Color','r','LineWidth',3,'Clipping','off');
text(IsizeY*(0.95),1,'Y','Color','r','FontWeight','bold','FontSize',15)
hold off

axes(handles.InputX)
I = flipud(squeeze(handles.imdbI(round(IsizeX/2),:,:))');
imshow(I,[min(min(min(handles.imdbI))),max(max(max(handles.imdbI)))])
hold on
quiver(1,IsizeZ,0,-IsizeZ,'Color','g','LineWidth',3,'Clipping','off');
text(1,IsizeY*(0.05),'Z','Color','g','FontWeight','bold','FontSize',15)
quiver(1,IsizeZ,IsizeY,0,'Color','r','LineWidth',3,'Clipping','off');
text(IsizeY*(0.95),IsizeZ*(0.95),'Y','Color','r','FontWeight','bold','FontSize',15)
hold off

axes(handles.InputY)
I = flipud(squeeze(handles.imdbI(:,round(IsizeY/2),:))');
imshow(I,[min(min(min(handles.imdbI))),max(max(max(handles.imdbI)))])
hold on
quiver(1,IsizeZ,0,-IsizeZ,'Color','g','LineWidth',3,'Clipping','off');
text(1,IsizeX*(0.05),'Z','Color','g','FontWeight','bold','FontSize',15)
quiver(1,IsizeZ,IsizeX,0,'Color','b','LineWidth',3,'Clipping','off');
text(IsizeX*(0.95),IsizeZ*(0.95),'X','Color','b','FontWeight','bold','FontSize',15)
hold off

guidata(hObject, handles);

% --- Executes on button press in XFlip.
function XFlip_Callback(hObject, eventdata, handles)
handles.Sequence{1,end+1} = 'XFlip';

tmpimdbI = zeros(size(handles.imdbI,1),size(handles.imdbI,2),size(handles.imdbI,3));
for i = 1:size(handles.imdbI,1)
    tmpimdbI((end+1)-i,:,:) = handles.imdbI(i,:,:);
end
handles.imdbI = tmpimdbI;
IsizeX = size(handles.imdbI,1);
IsizeY = size(handles.imdbI,2);
IsizeZ = size(handles.imdbI,3);

axes(handles.InputZ)
imshow(handles.imdbI(:,:,handles.InputSlice),[min(min(min(handles.imdbI))),max(max(max(handles.imdbI)))])
hold on
quiver(1,1,0,IsizeX,'Color','b','LineWidth',3,'Clipping','off');
text(1,IsizeX*(0.95),'X','Color','b','FontWeight','bold','FontSize',15)
quiver(1,1,IsizeY,0,'Color','r','LineWidth',3,'Clipping','off');
text(IsizeY*(0.95),1,'Y','Color','r','FontWeight','bold','FontSize',15)
hold off

axes(handles.InputX)
I = flipud(squeeze(handles.imdbI(round(IsizeX/2),:,:))');
imshow(I,[min(min(min(handles.imdbI))),max(max(max(handles.imdbI)))])
hold on
quiver(1,IsizeZ,0,-IsizeZ,'Color','g','LineWidth',3,'Clipping','off');
text(1,IsizeY*(0.05),'Z','Color','g','FontWeight','bold','FontSize',15)
quiver(1,IsizeZ,IsizeY,0,'Color','r','LineWidth',3,'Clipping','off');
text(IsizeY*(0.95),IsizeZ*(0.95),'Y','Color','r','FontWeight','bold','FontSize',15)
hold off

axes(handles.InputY)
I = flipud(squeeze(handles.imdbI(:,round(IsizeY/2),:))');
imshow(I,[min(min(min(handles.imdbI))),max(max(max(handles.imdbI)))])
hold on
quiver(1,IsizeZ,0,-IsizeZ,'Color','g','LineWidth',3,'Clipping','off');
text(1,IsizeX*(0.05),'Z','Color','g','FontWeight','bold','FontSize',15)
quiver(1,IsizeZ,IsizeX,0,'Color','b','LineWidth',3,'Clipping','off');
text(IsizeX*(0.95),IsizeZ*(0.95),'X','Color','b','FontWeight','bold','FontSize',15)
hold off

guidata(hObject, handles);

% --- Executes on button press in YFlip.
function YFlip_Callback(hObject, eventdata, handles)
handles.Sequence{1,end+1} = 'YFlip';

tmpimdbI = zeros(size(handles.imdbI,1),size(handles.imdbI,2),size(handles.imdbI,3));
for i = 1:size(handles.imdbI,2)
    tmpimdbI(:,(end+1)-i,:) = handles.imdbI(:,i,:);
end
handles.imdbI = tmpimdbI;
IsizeX = size(handles.imdbI,1);
IsizeY = size(handles.imdbI,2);
IsizeZ = size(handles.imdbI,3);

axes(handles.InputZ)
imshow(handles.imdbI(:,:,handles.InputSlice),[min(min(min(handles.imdbI))),max(max(max(handles.imdbI)))])
hold on
quiver(1,1,0,IsizeX,'Color','b','LineWidth',3,'Clipping','off');
text(1,IsizeX*(0.95),'X','Color','b','FontWeight','bold','FontSize',15)
quiver(1,1,IsizeY,0,'Color','r','LineWidth',3,'Clipping','off');
text(IsizeY*(0.95),1,'Y','Color','r','FontWeight','bold','FontSize',15)
hold off

axes(handles.InputX)
I = flipud(squeeze(handles.imdbI(round(IsizeX/2),:,:))');
imshow(I,[min(min(min(handles.imdbI))),max(max(max(handles.imdbI)))])
hold on
quiver(1,IsizeZ,0,-IsizeZ,'Color','g','LineWidth',3,'Clipping','off');
text(1,IsizeY*(0.05),'Z','Color','g','FontWeight','bold','FontSize',15)
quiver(1,IsizeZ,IsizeY,0,'Color','r','LineWidth',3,'Clipping','off');
text(IsizeY*(0.95),IsizeZ*(0.95),'Y','Color','r','FontWeight','bold','FontSize',15)
hold off

axes(handles.InputY)
I = flipud(squeeze(handles.imdbI(:,round(IsizeY/2),:))');
imshow(I,[min(min(min(handles.imdbI))),max(max(max(handles.imdbI)))])
hold on
quiver(1,IsizeZ,0,-IsizeZ,'Color','g','LineWidth',3,'Clipping','off');
text(1,IsizeX*(0.05),'Z','Color','g','FontWeight','bold','FontSize',15)
quiver(1,IsizeZ,IsizeX,0,'Color','b','LineWidth',3,'Clipping','off');
text(IsizeX*(0.95),IsizeZ*(0.95),'X','Color','b','FontWeight','bold','FontSize',15)
hold off

guidata(hObject, handles);

% --- Executes on button press in ZFlip.
function ZFlip_Callback(hObject, eventdata, handles)
handles.Sequence{1,end+1} = 'ZFlip';

tmpimdbI = zeros(size(handles.imdbI,1),size(handles.imdbI,2),size(handles.imdbI,3));
for i = 1:size(handles.imdbI,3)
    tmpimdbI(:,:,(end+1)-i) = handles.imdbI(:,:,i);
end
handles.imdbI = tmpimdbI;
IsizeX = size(handles.imdbI,1);
IsizeY = size(handles.imdbI,2);
IsizeZ = size(handles.imdbI,3);

axes(handles.InputZ)
imshow(handles.imdbI(:,:,handles.InputSlice),[min(min(min(handles.imdbI))),max(max(max(handles.imdbI)))])
hold on
quiver(1,1,0,IsizeX,'Color','b','LineWidth',3,'Clipping','off');
text(1,IsizeX*(0.95),'X','Color','b','FontWeight','bold','FontSize',15)
quiver(1,1,IsizeY,0,'Color','r','LineWidth',3,'Clipping','off');
text(IsizeY*(0.95),1,'Y','Color','r','FontWeight','bold','FontSize',15)
hold off

axes(handles.InputX)
I = flipud(squeeze(handles.imdbI(round(IsizeX/2),:,:))');
imshow(I,[min(min(min(handles.imdbI))),max(max(max(handles.imdbI)))])
hold on
quiver(1,IsizeZ,0,-IsizeZ,'Color','g','LineWidth',3,'Clipping','off');
text(1,IsizeY*(0.05),'Z','Color','g','FontWeight','bold','FontSize',15)
quiver(1,IsizeZ,IsizeY,0,'Color','r','LineWidth',3,'Clipping','off');
text(IsizeY*(0.95),IsizeZ*(0.95),'Y','Color','r','FontWeight','bold','FontSize',15)
hold off

axes(handles.InputY)
I = flipud(squeeze(handles.imdbI(:,round(IsizeY/2),:))');
imshow(I,[min(min(min(handles.imdbI))),max(max(max(handles.imdbI)))])
hold on
quiver(1,IsizeZ,0,-IsizeZ,'Color','g','LineWidth',3,'Clipping','off');
text(1,IsizeX*(0.05),'Z','Color','g','FontWeight','bold','FontSize',15)
quiver(1,IsizeZ,IsizeX,0,'Color','b','LineWidth',3,'Clipping','off');
text(IsizeX*(0.95),IsizeZ*(0.95),'X','Color','b','FontWeight','bold','FontSize',15)
hold off

guidata(hObject, handles);

% --- Executes on button press in Quick.
function Quick_Callback(hObject, eventdata, handles)
if get(hObject,'Value') == 1
    handles.Output = 'Quick';
else
end
guidata(hObject, handles);

% --- Executes on button press in Quality.
function Quality_Callback(hObject, eventdata, handles)
if get(hObject,'Value') == 1
    handles.Output = 'Quality';
else
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function InputSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function StandardSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
uiresume;
