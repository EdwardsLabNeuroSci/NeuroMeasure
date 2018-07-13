function varargout = DataImportUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DataImportUI_OpeningFcn, ...
                   'gui_OutputFcn',  @DataImportUI_OutputFcn, ...
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


% --- Executes just before DataImportUI is made visible.
function DataImportUI_OpeningFcn(hObject, eventdata, handles, varargin)
%Parse input arguments if they exist
handles.ScanResolution = varargin{1,1};
handles.imdbSize = varargin{1,2};
handles.Position = varargin{1,3};
handles.Orientation = varargin{1,4};
handles.Sequence = varargin{1,5};
handles.TakenNames = varargin{1,6}; %Keep names of other tabs to make sure we don't get two tabs of the same name


%Search for a datafile
[FileName,FilePath] = uigetfile('*.xlsx','Select MEP xls file');
if isnumeric(FileName) && isnumeric(FilePath) %uigetfile returns 0 if the user cancels, instead of the correct string.
    delete(gcf)
else
    handles.EditName.String=FileName;
    handles.Data = xlsread(strcat(FilePath,'/',FileName));
    handles.Data(isnan(handles.Data) == 1) = 0; %convert any NaNs in Data to 0
    handles.Data = double(handles.Data);
    if size(handles.Data,2) ~= 4
        delete(gcf)
        errordlg({'Imported file must have exactly 4 columns with following format:',...
        '1st Column: X coordinate','2nd Column: Y Coodrinate',...
        '3rd Column: Z Coordinate','4th Coumn: MEP values'})
    else
        %Set up the gui by disabling certain ui elements
        handles.CoordinateSelect.Enable = 'off';
        handles.Done.Enable = 'off';
        handles.EditName.Enable = 'off';
        handles.HeadCoords.Visible = 'off';
        handles.HeadInfo.Visible = 'off';
        handles.Nexstim.Value = false;
        handles.BrainSight.Value = false;

        %Set defaults for the selections just in case
        handles.System = 'Nexstim';
        handles.Coordinates = 'Select Coordinate System';
        handles.Original = [NaN,NaN,NaN];
        handles.Name = FileName;

        %Set reference coordinate defaults
        handles.Reference = [NaN,NaN,NaN];
        handles.EnterX.Enable = 'off';
        handles.EnterY.Enable = 'off';
        handles.EnterZ.Enable = 'off';
        
        %Save the changes to handles and initiate uiwait
        guidata(hObject, handles);
        uiwait;
    end
end

% --- Outputs from this function are returned to the command line.
function varargout = DataImportUI_OutputFcn(hObject, eventdata, handles) 

if ~isempty(handles)
    varargout{1} = true;
    varargout{2} = handles.Data;
    varargout{3} = handles.Reference;
    varargout{4} = handles.Name;
    varargout{5} = {handles.Original,handles.System,handles.Coordinates};
    delete(gcf);
else %If the gui is closed or errors for whatever reason, the handles will be an empty array so this outputs a default
    varargout{1} = false;
    varargout{2} = [];
    varargout{3} = [];
    varargout{4} = [];
    varargout{5} = [];
end

% --- Executes on button press in BrainSight.
function BrainSight_Callback(hObject, eventdata, handles)

if get(hObject,'Value') == 1
    handles.CoordinateSelect.String = {'Select Coordinate System','BrainSight'};
    handles.System = 'BrainSight';
        
    handles.CoordinateSelect.Enable = 'on';
    handles.Done.Enable = 'on';
    handles.EnterX.Enable = 'on';
    handles.EnterY.Enable = 'on';
    handles.EnterZ.Enable = 'on';
    handles.EditName.Enable = 'on';
end
guidata(hObject, handles);

% --- Executes on button press in Nexstim.
function Nexstim_Callback(hObject, eventdata, handles)

if get(hObject,'Value') == 1
    handles.CoordinateSelect.String = {'Select Coordinate System','MRI','Head'};
    handles.System = 'Nexstim';
    
    handles.CoordinateSelect.Enable = 'on';
    handles.Done.Enable = 'on';
    handles.EnterX.Enable = 'on';
    handles.EnterY.Enable = 'on';
    handles.EnterZ.Enable = 'on';
    handles.EditName.Enable = 'on';
end
guidata(hObject, handles);

% --- Executes on selection change in CoordinateSelect.
function CoordinateSelect_Callback(hObject, eventdata, handles)

contents = cellstr(get(hObject,'String'));
handles.Coordinates = contents{get(hObject,'Value')};
if strcmp(handles.Coordinates,'Head')
    handles.HeadCoords.Visible = 'on';
    handles.HeadInfo.Visible = 'on';
    handles.Reference = [0,0,0];
    handles.Original = [0,0,0];
    handles.EnterX.String = '0';
    handles.EnterY.String = '0';
    handles.EnterZ.String = '0';
else
    handles.HeadCoords.Visible = 'off';
    handles.HeadInfo.Visible = 'off';
    handles.Reference = [NaN,NaN,NaN];
    handles.Original = [NaN,NaN,NaN];
    handles.EnterX.String = '';
    handles.EnterY.String = '';
    handles.EnterZ.String = '';
end
guidata(hObject, handles);

function EditName_Callback(hObject, eventdata, handles)
handles.Name = get(hObject,'String');
guidata(hObject, handles);

function EnterX_Callback(hObject, eventdata, handles)
X = str2double(get(hObject,'String'));
handles.Reference(1) = X;
handles.Original(1) = X;
guidata(hObject, handles);

function EnterY_Callback(hObject, eventdata, handles)
Y = str2double(get(hObject,'String'));
handles.Reference(2) = Y;
handles.Original(2) = Y;
guidata(hObject, handles);

function EnterZ_Callback(hObject, eventdata, handles)
Z = str2double(get(hObject,'String'));
handles.Reference(3) = Z;
handles.Original(3) = Z;
guidata(hObject, handles);

% --- Executes on button press in Done.
function Done_Callback(hObject, eventdata, handles)
for i=1:length(handles.TakenNames)
    if strcmp(handles.TakenNames{1,i}, handles.Name)
        errordlg('Name is already in use by another tab. Please use a different name.')
        return
    end
end
switch handles.System
    case 'Nexstim'
        switch handles.Coordinates
            case 'Select Coordinate System'
                errordlg('Please select a valid import coordinate system')
            case 'MRI'
                Data(:,1) = handles.Data(:,3)/handles.ScanResolution(1) + 1;
                Data(:,2) = handles.Data(:,1)/handles.ScanResolution(2) + 1;
                Data(:,3) = handles.Data(:,2)/handles.ScanResolution(3) + 1;
                Data(:,4) = handles.Data(:,4);
                handles.Data = Data;
                
                if (isnan(handles.Reference(1)) || isnan(handles.Reference(2)) || isnan(handles.Reference(3))) ...
                        && ~(isnan(handles.Reference(1)) && isnan(handles.Reference(2)) && isnan(handles.Reference(3)))
                    errordlg({'Please enter all three coordinates if setting a reference point','Otherwise leave all three entries blank'});
                    return
                else
                    Reference(1) = handles.Reference(3)/handles.ScanResolution(1) + 1;
                    Reference(2) = handles.Reference(1)/handles.ScanResolution(2) + 1;
                    Reference(3) = handles.Reference(2)/handles.ScanResolution(3) + 1;
                    handles.Reference = Reference;
                end
              
                guidata(hObject, handles);
                uiresume;
                
            case 'Scanner'
                errordlg('Please select a valid import coordinate system')
%                 dX = [1;1;1]*handles.ScanResolution(1);
%                 dY = [1;1;1]*handles.ScanResolution(2);
%                 dZ = [1;1;1]*handles.ScanResolution(3);
%                 T1 = handles.Position(:,1);
%                 TN = handles.Position(:,2);
%                 
%                 cosx = handles.Orientation(1:3,1);
%                 cosy = handles.Orientation(4:6,1);
%                 cosz = T1 - TN;
%                 cosz = cosz/sqrt(cosz(1)^2+cosz(2)^2+cosz(3)^2);
%                 
%                 M = [cosy,cosx,cosz].*[dX,dY,dZ];
%                 M = [M,TN];
%                 M = [M;[0,0,0,1]];
%                 
%                 for i = 1:size(handles.Data,1)
%                     N = [handles.Data(i,1);handles.Data(i,2);handles.Data(i,3);1];
%                     I = M\N;
%                     Data(i,1) = I(1,1); Data(i,2) = I(2,1); Data(i,3) = I(3,1);
%                 end
%                 Data(:,4) = handles.Data(:,4);
%                 handles.Data = Data;
%                 
%                 if (isnan(handles.Reference(1)) || isnan(handles.Reference(2)) || isnan(handles.Reference(3))) ...
%                         && ~(isnan(handles.Reference(1)) && isnan(handles.Reference(2)) && isnan(handles.Reference(3)))
%                     errordlg({'Please enter all three coordinates if setting a reference point','Otherwise leave all three entries blank'});
%                     return
%                 else
%                     Reference = [handles.Reference(1);handles.Reference(2);handles.Reference(3);1];
%                     Reference = M\Reference;
%                 end
%                 
%                 for i = 1:size(handles.Sequence,2)
%                     switch handles.Sequence{1,i}
%                         case 'XRotate'
%                             Data = [handles.Data(:,1),handles.imdbSize(2) - handles.Data(:,3),handles.Data(:,2)];
%                             Data(:,4) = handles.Data(:,4);
%                             handles.Data = Data;
%                         case 'YRotate'
%                             Data = [handles.imdbSize(1) - handles.Data(:,3),handles.Data(:,2),handles.Data(:,1)];
%                             Data(:,4) = handles.Data(:,4);
%                             handles.Data = Data;
%                         case 'ZRotate'
%                             Data = [handles.Data(:,2),handles.imdbSize(2) - handles.Data(:,1),handles.Data(:,3)];
%                             Data(:,4) = handles.Data(:,4);
%                             handles.Data = Data;
%                         case 'XFlip'
%                             Data = [handles.imdbSize(1) - handles.Data(:,1),handles.Data(:,2),handles.Data(:,3)];
%                             Data(:,4) = handles.Data(:,4);
%                             handles.Data = Data;
%                         case 'YFlip'
%                             Data = [handles.Data(:,1),handles.imdbSize(2) - handles.Data(:,2),handles.Data(:,3)];
%                             Data(:,4) = handles.Data(:,4);
%                             handles.Data = Data;
%                         case 'ZFlip'
%                             Data = [handles.Data(:,1),handles.Data(:,2),handles.imdbSize(3) - handles.Data(:,3)];
%                             Data(:,4) = handles.Data(:,4);
%                             handles.Data = Data;
%                     end
%                 end
%                 
%                 guidata(hObject, handles);
%                 uiresume;
            case 'Head'
                RegPoints = str2double(handles.HeadCoords.Data);
                if sum(sum(isnan(RegPoints))) == 0
                    EarL = RegPoints(1,:);
                    EarR = RegPoints(2,:);
                    Nose = RegPoints(3,:);
                    Origin = mean([EarL;EarR],1);
                    x = (EarR - EarL)/norm(EarR - EarL);
                    y = (Nose - Origin)/norm(Nose - Origin);
                    z = cross(x,y);
                    M = [x',y',z',Origin'];
                    M = [M;[0,0,0,1]];
                    for i = 1:size(handles.Data,1)
                        N = [handles.Data(i,1);handles.Data(i,2);handles.Data(i,3);1];
                        I = M*N;
                        Data(i,1) = I(1,1); Data(i,2) = I(2,1); Data(i,3) = I(3,1);
                    end
                    Data(:,4) = handles.Data(:,4);
                    handles.Data = Data;
                    
                    if (isnan(handles.Reference(1)) || isnan(handles.Reference(2)) || isnan(handles.Reference(3))) ...
                            && ~(isnan(handles.Reference(1)) && isnan(handles.Reference(2)) && isnan(handles.Reference(3)))
                        errordlg({'Please enter all three coordinates if setting a reference point','Otherwise leave all three entries blank'});
                        return
                    else
                        Reference = M*[handles.Reference';1];
                        handles.Reference = Reference(1:3,1)';
                    end
                    
                    handles.Data(:,1) = Data(:,3)/handles.ScanResolution(1) + 1;
                    handles.Data(:,2) = Data(:,1)/handles.ScanResolution(2) + 1;
                    handles.Data(:,3) = Data(:,2)/handles.ScanResolution(3) + 1;
                    handles.Data(:,4) = Data(:,4);

                    if (isnan(handles.Reference(1)) || isnan(handles.Reference(2)) || isnan(handles.Reference(3))) ...
                            && ~(isnan(handles.Reference(1)) && isnan(handles.Reference(2)) && isnan(handles.Reference(3)))
                        errordlg({'Please enter all three coordinates if setting a reference point','Otherwise leave all three entries blank'});
                        return
                    else
                        Reference = [];
                        Reference(1) = handles.Reference(3)/handles.ScanResolution(1) + 1;
                        Reference(2) = handles.Reference(1)/handles.ScanResolution(2) + 1;
                        Reference(3) = handles.Reference(2)/handles.ScanResolution(3) + 1;
                        handles.Reference = Reference;
                    end

                    guidata(hObject, handles);
                    uiresume;

                    else
                        errordlg('Please enter valid numeric entries for the head coordinate registration points in the specified table');
                end
        end
        
    case 'BrainSight'
        switch handles.Coordinates
            case 'Select Coordinate System'
                errordlg('Please select a valid import coordinate system')
            case 'BrainSight'
                Data(:,1) = handles.imdbSize(1) - handles.Data(:,2)/handles.ScanResolution(1);
                Data(:,2) = handles.Data(:,1)/handles.ScanResolution(2);
                Data(:,3) = handles.Data(:,3)/handles.ScanResolution(3);
                Data(:,4) = handles.Data(:,4);
                handles.Data = Data;
                
                if (isnan(handles.Reference(1)) || isnan(handles.Reference(2)) || isnan(handles.Reference(3))) ...
                        && ~(isnan(handles.Reference(1)) && isnan(handles.Reference(2)) && isnan(handles.Reference(3)))
                    errordlg({'Please enter all three coordinates if setting a reference point','Otherwise leave all three entries blank'});
                    return
                else
                    Reference(1) = handles.imdbSize(1) - handles.Reference(2)/handles.ScanResolution(1);
                    Reference(2) = handles.Reference(1)/handles.ScanResolution(2);
                    Reference(3) = handles.Reference(3)/handles.ScanResolution(3);
                    handles.Reference = Reference;
                end
                
%                if ~(sum(isstrprop(handles.Name,'alphanum')) == size(handles.Name,2))
%                    errordlg({'Please enter a valid set name','A valid name consists of only letters and numbers and no spaces'});
%                    return
%                elseif isstrprop(handles.Name(1),'digit')
%                    errordlg({'Dataset names cannot begin with a number'});
%                    return
%                end
                
                guidata(hObject, handles);
                uiresume;
            
            case 'Global'
                errordlg('Please select a valid import coordinate system')
        end       
end


% --- Executes during object creation, after setting all properties.
function CoordinateSelect_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function EnterX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function EnterY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function EnterZ_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function EditName_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function HeadCoords_CreateFcn(hObject, eventdata, handles)
set(hObject,'Data',cell(3,3));
set(hObject,'RowName',{'Left Ear','Right Ear','Nose'});
set(hObject,'ColumnName',{'X','Y','Z'});
set(hObject,'ColumnEditable',[true,true,true]);
set(hObject,'ColumnWidth',{90,90,90});
