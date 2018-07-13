function varargout = ScanSelectUI(varargin)
% SCANSELECTUI MATLAB code for ScanSelectUI.fig
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ScanSelectUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ScanSelectUI_OutputFcn, ...
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


% --- Executes just before ScanSelectUI is made visible.
function ScanSelectUI_OpeningFcn(hObject, eventdata, handles, varargin)
% varargin command line arguments to ScanSelectUI (see VARARGIN)
handles.scantypes = varargin{1,1};
handles.scanprops = varargin{1,2};

handles.ScanSelect.String = fields(handles.scantypes);
handles.ScanSelect.Value = 1;
handles.NumberLabel.Visible = 'off'; 
handles.NumberString.Visible = 'off';
handles.SizeLabel.Visible = 'off'; 
handles.SizeString.Visible = 'off';
handles.SpacingLabel.Visible = 'off'; 
handles.SpacingString.Visible = 'off';
handles.ColorLabel.Visible = 'off'; 
handles.ColorString.Visible = 'off';
handles.ImageLabel.Visible = 'off'; 
handles.ImageString.Visible = 'off';
handles.Choice = handles.ScanSelect.String{1,1};

% Update handles structure
guidata(hObject, handles);

uiwait;

% --- Outputs from this function are returned to the command line.
function varargout = ScanSelectUI_OutputFcn(hObject, eventdata, handles) 
if isempty(handles)
    varargout{1} = [];
else
    varargout{1} = handles.Choice;
    delete(gcf);
end

% --- Executes on selection change in ScanSelect.
function ScanSelect_Callback(hObject, eventdata, handles)
contents = cellstr(get(hObject,'String'));
handles.Choice = contents{get(hObject,'Value')};

handles.NumberLabel.Visible = 'on'; handles.NumberString.Visible = 'on';
handles.NumberString.String = num2str(size(handles.scantypes.(handles.Choice).List,1));

handles.SizeLabel.Visible = 'on'; handles.SizeString.Visible = 'on';
handles.SizeString.String = sprintf('[%d,%d]',handles.scantypes.(handles.Choice).props{1,3}(1,1),handles.scantypes.(handles.Choice).props{1,3}(2,1));

handles.SpacingLabel.Visible = 'on'; handles.SpacingString.Visible = 'on';
handles.SpacingString.String = sprintf('[%0.3f,%0.3f,%0.3f]',handles.scantypes.(handles.Choice).props{1,2}(1,1),handles.scantypes.(handles.Choice).props{1,2}(2,1),handles.scantypes.(handles.Choice).props{1,2}(3,1));

info = handles.scanprops{handles.scantypes.(handles.Choice).List(1,1),1};
if isfield(info,'ColorType')
    if ischar(info.ColorType)
        handles.ColorLabel.Visible = 'on'; handles.ColorString.Visible = 'on';
        handles.ColorString.String = info.ColorType;
    end
else
    handles.ColorLabel.Visible = 'off'; handles.ColorString.Visible = 'off';
end

if isfield(info,'ImageType')
    if ischar(info.ImageType)
        handles.ImageLabel.Visible = 'on'; handles.ImageString.Visible = 'on';
        handles.ImageString.String = info.ImageType;
    end
else
    handles.ImageLabel.Visible = 'off'; handles.ImageString.Visible = 'off';
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ScanSelect_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in Confirm.
function Confirm_Callback(hObject, eventdata, handles)
uiresume;
