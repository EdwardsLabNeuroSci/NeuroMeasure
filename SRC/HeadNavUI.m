function varargout = HeadNavUI(varargin)
% Parent script for HeadNavUI

% UI elements that have dependant functionalities or are part of the same
% panel are now organized in blocks. The order is:
% *Upload Buttons
% *Clustering Panel
% *Surface Fitting Panel
% *Display Panel
% *Hotspot Panel
% *Measurements Panel
% *ColorMap
% *WindowButton Functions
% *Clear/ExportData/3D Render/Compare
% *Tabs

% All CreateFcn's has been moved to the bottom of the script

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HeadNavUI_OpeningFcn, ...
                   'gui_OutputFcn',  @HeadNavUI_OutputFcn, ...
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

% --- Executes just before HeadNavUI is made visible.
function HeadNavUI_OpeningFcn(hObject, eventdata, handles, varargin)
% Initate figure window by disabling appropriate ui elements
handles.axes1.XTick=[]; handles.axes1.YTick=[]; % Disable ticks
handles.axes1.XColor='none'; handles.axes1.YColor='none'; %Hide the border lines forced by matlab
% Make all tabs except current invisible. Make current tab pressed.
handles.Tab1.Value = true;
handles.Tab2.Visible = 'off';
handles.Tab3.Visible = 'off';
handles.Tab4.Visible = 'off';
handles.Tab5.Visible = 'off';
handles.Tab6.Visible = 'off';
handles.Tab7.Visible = 'off';
handles.Tab8.Visible = 'off';
handles.DisplayReference.Enable = 'off';

% Disable all controls except UploadScanButton and Clear
handles.UploadData.Enable = 'off';
handles.Compare.Enable = 'off';
handles.Render3D.Enable = 'off';
handles.ExportData.Enable = 'off';
handles.ExportImage.Enable = 'off';

% Disable Measurements Panel
handles.MeasurementMode.Enable = 'off';
handles.MeasurementMode.Value = 0;
handles.RoamingMode.Enable = 'off';
handles.RoamingMode.Value = 1;
handles.DisplayCOG.Callback = @(hObject,eventdata)HeadNavUI('DisplayCOG_Callback',hObject,eventdata,guidata(hObject));
handles.DisplayPeak.Callback = @(hObject,eventdata)HeadNavUI('DisplayPeak_Callback',hObject,eventdata,guidata(hObject));
handles.DisplayRef.Callback = @(hObject,eventdata)HeadNavUI('DisplayRef_Callback',hObject,eventdata,guidata(hObject));
handles.DisplayCOG.Enable = 'off';
handles.DisplayPeak.Enable = 'off';
handles.DisplayRef.Enable = 'off';

%Disable Color Map Panel
handles.ColorMapMin.Enable = 'off';
handles.ColorMapMin.String = 'NaN';
handles.ColorMapMax.Enable = 'off';
handles.ColorMapMax.String = 'NaN';
handles.ColorMapSelect.Enable = 'off';
handles.ColorMapApply.Enable = 'off';
handles.TransparencySlider.Enable = 'off';

% Disable Display Panel
handles.DisplayRotate.Enable = 'off';
handles.DisplayRotate.Value = 0;
handles.DisplayPan.Enable = 'off';
handles.DisplayPan.Value = 0;
handles.DisplayZoom.Enable = 'off';
handles.DisplayZoom.Value = 0;
handles.Zoom.Enable = false;
handles.DisplayReference.Enable = 'off';
handles.DisplayReference.Value = 0;
handles.DepthSlider.Enable = 'off';
handles.DepthSlider.Max = 1;
handles.DepthSlider.SliderStep = [1,1];
handles.PixelSpacing.Enable = 'off';
handles.DisplayReset.Enable = 'off';

% Disable Hotspot Panel
handles.SensitivitySlider.Enable = 'off';
handles.SensitivitySlider.Max = 1;
handles.HotspotThreshold.Enable = 'off';
handles.HotspotTotal.Enable = 'off';
handles.HotspotTotal.Value = 1;
handles.HotspotTotal.Callback = @(hObject,eventdata)HeadNavUI('HotspotTotal_Callback',hObject,eventdata,guidata(hObject));
handles.HotspotSelect.Enable = 'off';
handles.HotspotSelect.Value = 0;
handles.HotspotSelect.Callback = @(hObject,eventdata)HeadNavUI('HotspotSelect_Callback',hObject,eventdata,guidata(hObject));
handles.HotspotApply.Enable = 'off';

% Disable Clustering Panel
handles.ClusterEdit.Enable = 'off';
handles.ClusterApply.Enable = 'off';
handles.ClusterConfirm.Enable = 'off';
handles.ClusterUndo.Enable = 'off';

% Disable Surface Fitting Panel
handles.ClusterOpPopup.Enable = 'off';
handles.ClusterOpEdit.Enable = 'off';
handles.SurfaceOpPopup.Enable = 'off';
handles.SurfaceApply.Enable = 'off';

% Pre-set some parameters for convenience
handles.theta = 0;
handles.xphi = 0;
handles.yphi = 0;
handles.k = 0;
handles.qt = '0.05';
handles.BinThresh = '40';
handles.COM = [NaN,NaN,NaN];
handles.PeakMEPPos = [NaN,NaN,NaN];
handles.RefK = NaN;
handles.Markers = [NaN,NaN,NaN,0;NaN,NaN,NaN,0;NaN,NaN,NaN,0];
handles.Threshold = 0;
handles.WindowProtocol = 'Null';
handles.WindowTracker = 'Scatterplot';
handles.ColorMin = NaN;
handles.ColorMax = NaN;
handles.Colormap = 'Heat';
handles.alpha = 0.5;
handles.hssensitivity = 0;
handles.Alltabs = containers.Map('KeyType','char','ValueType','any');
handles.Tabnames = {'','','','','','','',''};
handles.CurrentTab = uint8(1);
handles.PIXELSPACINGABSMIN = 0.0006;

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = HeadNavUI_OutputFcn(hObject, eventdata, handles) 
% This function is vestigal, but needs to be kept in.

% --- Executes on button press in UploadScan.
function UploadScan_Callback(hObject, eventdata, handles)

%Indicate that the app is busy and disable upload scan while processing
%handles.BusyString.String = 'Uploading Dicoms: 0%';
handles.UploadScan.Enable = 'off';
handles.Clear.Enable = 'off'; %prevent data from being cleared when upload is already in progress
drawnow;

%Search for dicom folder, load 3D image volume and store it in handles
DicomPath = uigetdir('','Select the data folder');
if DicomPath == 0
    handles.UploadScan.Enable = 'on';
    return
end

[tmpimdb,tmpScanResolution,handles.Position,handles.Orientation] = getimdb(DicomPath,handles,hObject);
if isnan(tmpimdb(1)) && isnan(tmpScanResolution(1))
   handles.BusyString.String='Idle';
   handles.UploadScan.Enable = 'on';
   drawnow;
   return
else
   handles.figure1.Visible = 'off';
   [handles.imdb,handles.ScanResolution,handles.Sequence,Mode] = ScanAlignmentUI(tmpimdb,tmpScanResolution);
   handles.figure1.Visible = 'on';
end

if ~strcmp(Mode,'Abort')
    handles.BusyString.String = 'Segmentation: 0%';
    drawnow;

    handles.mask = brainsegm(handles.imdb,Mode,handles,hObject);
    handles.BusyString.String = 'Post-Processing';
    drawnow;

    handles.mesh = maskmesh(handles.mask,25);
    handles.Centroid = mean(handles.mesh);
    handles.Reference = handles.Centroid;
    handles.RefString.String = sprintf('[%0.3f,%0.3f,%0.3f] (%s)',...
        handles.Reference(1),handles.Reference(2),handles.Reference(3),'HeadNav');

    %Create a default pixel spacing and image limits and store in handles
    handles.pixelspacing = pi/500;
    handles.imlimits = [-pi,pi,0,pi];

    %Create image slice of 3D image volume with given parameters
    [handles.imdbSlice,handles.Weights] = createSlice(handles.imdb,handles.mesh, ...
        handles.pixelspacing,handles.imlimits, ...
        handles.xphi,handles.yphi,handles.theta,handles.k);

    %Plot image slice
    createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice);

    %Enable all relevant uielements
    handles.DisplayRotate.Enable = 'on';
    handles.DisplayPan.Enable = 'on';
    handles.DisplayZoom.Enable = 'on';
    handles.DisplayCOG.Enable = 'on';
    handles.DisplayPeak.Enable = 'on';
    handles.DisplayRef.Enable = 'on';
    handles.DisplayReference.Enable = 'on';
    handles.DepthSlider.Enable = 'on';
    handles.PixelSpacing.Enable = 'on';
    handles.PixelSpacing.String = num2str(handles.pixelspacing);
    handles.DisplayReset.Enable = 'on';
    handles.UploadData.Enable = 'on';
    handles.ExportImage.Enable = 'on';
    handles.Render3D.Enable = 'on';

    %Indicate that the app is finished processing and save all changes to handles
    handles.BusyString.String = 'Idle';
    handles.Clear.Enable = 'on';
    guidata(hObject, handles);
else
    handles.BusyString.String = 'Idle';
    handles.UploadScan.Enable = 'on';
end

% --- Executes on button press in UploadData.
function UploadData_Callback(hObject, eventdata, handles)

%Indicate to the user that the app is busy
handles.BusyString.String = 'Busy';
handles.Clear.Enable = 'off';
drawnow;
    
if isfield(handles,'Data')
    handles.figure1.Visible = 'off';
    [Exit,handles.Data,Reference,Name,System] = DataImportUI(handles.ScanResolution,[size(handles.imdb,1),size(handles.imdb,2),size(handles.imdb,3)],handles.Position,handles.Orientation,handles.Sequence,handles.Tabnames);
    handles.figure1.Visible = 'on';
    
    if Exit == false
        handles.BusyString.String = 'Idle';
        return
    end
    
    if ~isnan(Reference(1)) || ~isnan(Reference(2)) || ~isnan(Reference(3))
        handles.Reference = Reference;
        handles.RefString.String = sprintf('[%0.3f,%0.3f,%0.3f] (%s)',...
            System{1,1}(1),System{1,1}(2),System{1,1}(3),strcat(System{1,2},';',System{1,3}));
        %if the user doesn't put in a reference, keep the original refpt from scan
    end
    handles.Tabnames{length(handles.Alltabs)+1}=Name; %Update the name in the struct with all tabnames
    handles.COM = centerofmass(handles.Data); % get the center of mass of the uploaded data
    handles.PeakMEPPos = handles.Data(find(handles.Data(:,4) == max(handles.Data(:,4))),1:3); % find the maximum mep value
    handles.Alltabs(Name)=UITab(handles.Data,Name,handles.COM,handles.PeakMEPPos); % Update the alltabs struct with a new UItab with relevant information
    handles=SwitchTab(hObject, handles, length(handles.Alltabs)); % Switch to the new tab
        
else
    handles.figure1.Visible = 'off';
    [Exit,handles.Data,Reference,Name,System] = DataImportUI(handles.ScanResolution,[size(handles.imdb,1),size(handles.imdb,2),size(handles.imdb,3)],handles.Position,handles.Orientation,handles.Sequence,handles.Tabnames);
    handles.figure1.Visible = 'on';
    
    if Exit == false
        handles.BusyString.String = 'Idle';
        return
    end
    
    if ~isnan(Reference(1)) || ~isnan(Reference(2)) || ~isnan(Reference(3))
        handles.Reference = Reference;
        handles.RefString.String = sprintf('[%0.3f,%0.3f,%0.3f] (%s)',...
            System{1,1}(1),System{1,1}(2),System{1,1}(3),strcat(System{1,2},';',System{1,3}));
        %if the user doesn't put in a reference, keep the original refpt from scan
    end
    handles.Tabnames{1}=Name; %Update the name in the struct with all tabnames
    handles.COM = centerofmass(handles.Data); % get the center of mass of the uploaded data
    handles.PeakMEPPos = handles.Data(find(handles.Data(:,4) == max(handles.Data(:,4))),1:3); % find the maximum mep value
    handles.Alltabs(Name)=UITab(handles.Data,Name,handles.COM,handles.PeakMEPPos); % Update the alltabs struct with a new UItab with relevant information
    handles=SwitchTab(hObject,handles, length(handles.Alltabs)); % Switch to the new tab
end

%Update color limits
if isnan(handles.ColorMin) || isnan(handles.ColorMax)
    handles.ColorMin = min(handles.Data(:,4));
    handles.ColorMapMin.String = num2str(handles.ColorMin);
    handles.ColorMax = max(handles.Data(:,4));
    handles.ColorMapMax.String = num2str(handles.ColorMax);
elseif min(handles.Data(:,4)) < handles.ColorMin
    handles.ColorMin = min(handles.Data(:,4));
elseif max(handles.Data(:,4)) > handles.ColorMax
    handles.ColorMax = max(handles.Data(:,4));
end

%Process data with current display parameters and fit to elipsoid
[handles.ImData,handles.MEPelip] = createData(handles.Data,handles.Centroid, ...
    handles.imlimits,handles.pixelspacing, ...
    handles.theta,handles.xphi,handles.yphi);

[Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
    handles.imlimits,handles.pixelspacing, ...
    handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);

%Display data
createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,handles.ImData,Markers);

%Update relevant ui elements
handles.ClusterEdit.Enable = 'on';
handles.ClusterApply.Enable = 'on';
handles.MeasurementMode.Enable = 'on';
handles.RoamingMode.Enable = 'on';
handles.SurfaceApply.Enable = 'off';
handles.SurfaceOpPopup.Enable = 'off';
handles.ClusterOpPopup.Enable = 'off';
handles.ColorMapMin.Enable = 'on';
handles.ColorMapMax.Enable = 'on';
handles.ColorMapSelect.Enable = 'on';
handles.ColorMapApply.Enable = 'on';
handles.TransparencySlider.Enable = 'on';

handles.ExportData.Enable = 'on';

handles.WindowTracker = 'Scatterplot';
handles.BusyString.String = 'Idle';
handles.Clear.Enable = 'on';
guidata(hObject, handles);


function ClusterEdit_Callback(hObject, eventdata, handles)

% Store entered value in handles
handles.qt = get(hObject,'String');
guidata(hObject, handles);

% --- Executes on button press in ClusterApply.
function ClusterApply_Callback(hObject, eventdata, handles)

%Indicate that the app is busy
handles.BusyString.String = 'Busy';
handles.ClusterApply.Enable = 'off';
drawnow;

%Check if a valid number is entered in the edit box
if ~(sum(isstrprop(handles.qt,'digit') | isstrprop(handles.qt,'punct')) == size(handles.qt,2))
    errordlg({'Invalid Entry','Enter a numeric value in the range of 0 - 1'})
    return
end
if ~(str2double(handles.qt) >= 0 && str2double(handles.qt) <= 1)
    errordlg({'Invalid Entry','Entered value must be in range of 0 - 1'})
    return
end

%Apply clustering with supplied threshold
handles.Clusters = qtcluster(handles.Data, str2double(handles.qt));

%Display results of clustering
col = jet(100);
imshow(handles.imdbSlice,[0,max(max(handles.imdbSlice))]);
hold on
for i = 1:size(handles.Clusters,2)
    n = randi(100,1);
    Data = handles.Clusters{i}; Data(:,4) = n*ones(size(Data,1),1);
    [ImData,~,~,~] = createData(Data,handles.Centroid,handles.imlimits,handles.pixelspacing,...
        handles.theta,handles.xphi,handles.yphi,'Skip');
    plot(ImData(:,1),ImData(:,2),'Color',col(n,:))
    hold on
    scatter(ImData(:,1),ImData(:,2),20,'MarkerFaceColor',col(n,:),'MarkerEdgeColor',col(n,:))
    hold on
end
hold off

handles.WindowProtocol = 'Null';
handles.DisplayRotate.Enable = 'off';
handles.DisplayPan.Enable = 'off';
handles.DisplayZoom.Enable = 'off';
handles.DisplayReference.Enable = 'off';

%Re-enable uicontrols and indicate the app is finished processing.
handles.ClusterConfirm.Enable = 'on';
handles.ClusterApply.Enable = 'on';
handles.ClusterEdit.Enable = 'on';
handles.BusyString.String = 'Idle';

%Save all to handles object
guidata(hObject, handles);

% --- Executes on button press in ClusterConfirm.
function ClusterConfirm_Callback(hObject, eventdata, handles)

%Save old data to cache in case of redo
handles.Cache = handles.Data;
curtab=handles.Tabnames{1,handles.CurrentTab};
curtabobj=handles.Alltabs(curtab);
curtabobj.cache = handles.Cache;
curtabobj.clusters = handles.Clusters;
curtabobj.status='clustered';

%Apply a dummy averaging on the clusters just for display purposes
handles.Data = clusterop(handles.Clusters,'average',1);
curtabobj.dataset = handles.Data;

%Update image data
handles.ImData = createData(handles.Data,handles.Centroid,handles.imlimits, ...
    handles.pixelspacing,handles.theta,handles.xphi,handles.yphi);

[Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
        handles.imlimits,handles.pixelspacing, ...
        handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
handles.Alltabs(curtab)=curtabobj;

%Update figure
createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,handles.ImData,Markers);

%Update relevant uielements
handles.ClusterApply.Enable = 'off';
handles.ClusterConfirm.Enable = 'off';
handles.ClusterEdit.Enable = 'off';
handles.ClusterUndo.Enable = 'on';

if handles.MeasurementMode.Value == 1
    handles.SurfaceOpPopup.Enable = 'on';
    handles.ClusterOpPopup.Enable = 'on';
    handles.SurfaceApply.Enable = 'on';
    handles.DisplayZoom.Enable = 'on';
    handles.DisplayZoom.Value = 0;
elseif handles.RoamingMode.Value == 1
    handles.WindowProtocol = 'Null';
    handles.DisplayRotate.Enable = 'on';
    handles.DisplayPan.Enable = 'on';
    handles.DisplayZoom.Enable = 'on';
    handles.DisplayReference.Enable = 'on';
end

%Save to handles structure
guidata(hObject, handles);

% --- Executes on button press in ClusterUndo.
function ClusterUndo_Callback(hObject, eventdata, handles)

%Retreive cached data and erase current clusters
handles.Data = handles.Cache;
curtab=handles.Tabnames{1,handles.CurrentTab};
curtabobj=handles.Alltabs(curtab);
curtabobj.dataset = handles.Data;
handles = rmfield(handles,'Cache');
curtabobj.cache=[];
handles = rmfield(handles,'Clusters');
curtabobj.clusters=[];
curtabobj.status='uploaded';

handles.ImData = createData(handles.Data,handles.Centroid,handles.imlimits, ...
    handles.pixelspacing,handles.theta,handles.xphi,handles.yphi);

[Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
        handles.imlimits,handles.pixelspacing, ...
        handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
curtabobj.imdata=handles.ImData; %update tab data
curtabobj.markers=Markers;
handles.Alltabs(curtab)=curtabobj;
createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,handles.ImData,Markers); %update figure

%update main window state and make sure permissions are correct
handles.ClusterApply.Enable = 'on';
handles.ClusterEdit.Enable = 'on';
handles.ClusterUndo.Enable = 'off';
handles.SurfaceOpPopup.Enable = 'off';
handles.ClusterOpPopup.Enable = 'off';
handles.SurfaceApply.Enable = 'off';
handles.HotspotTotal.Enable = 'off';
handles.HotspotSelect.Enable = 'off';
handles.HotspotThreshold.Enable = 'off';
handles.SensitivitySlider.Enable = 'off';
handles.HotspotApply.Enable = 'off';
handles.WindowTracker = 'Scatterplot';

%Save to handles structure
guidata(hObject, handles);


% --- Executes on button press in ClusterHelp.
function ClusterHelp_Callback(hObject, eventdata, handles)

 HelpMenu
 g1=guidata(HelpMenu);
 g1.visible = 'off';
 g1.text3.String='Learn more about point clustering below.';
 delete(g1.pushbutton2);
 delete(g1.pushbutton1);
 g1.text5.String='Point Clustering';
 g1.text4.String=strjust(sprintf('If your experiment did not sample the same location multiple times, point clustering should be set at 0, which will allow each point to be calculated independently. If your experiment used repeated measurements of the same location, point clustering is a method of Quality Threshold Clustering (QTC) which allows for the repeated measurements to be treated as a group, instead of as individual points. Without clustering, interpolation becomes jagged and discontinuous because each point is seen as a true value, rather than an additional measurement. The threshold value is a distance threshold which groups points together that have less than this chosen distance between them. In the Surface fitting panel, you can choose how you would like to handle the new clusters. If you try a value and the clusters are incorrect, simply input a new value and re-click the apply button until clusters are correct. Once you are satisfied, click confirm to gain access to the surface fitting panel.'),'left');
g1.visible = 'on';


% --- Executes on selection change in ClusterOpPopup.
function ClusterOpPopup_Callback(hObject, eventdata, handles)

% Select Clustering Operation
contents = cellstr(get(hObject,'String'));
handles.ClusterOp = contents{get(hObject,'Value')};
if strcmp(handles.ClusterOp,'probability') == true
    handles.ClusterOpEdit.Enable = 'on';
else
    handles.ClusterOpEdit.Enable = 'off';
end
guidata(hObject, handles);

% --- Executes on selection change in SurfaceOpPopup.
function SurfaceOpPopup_Callback(hObject, eventdata, handles)

contents = cellstr(get(hObject,'String'));
handles.SurfaceOp = contents{get(hObject,'Value')};
guidata(hObject, handles);

% --- Executes on button press in SurfaceApply.
function SurfaceApply_Callback(hObject, eventdata, handles)
%Check if clustering and surface fitting drop downs have been used
if strcmp(handles.ClusterOp,'Select Clustering Operation') == true
    errordlg('Select a valid clustering operation from the drop-down menu');
    return
end
if strcmp(handles.SurfaceOp,'Select Surface Fitting Algorithm') == true
    errordlg('Select a valid surface fitting algorithm from the drop-down menu');
    return
end

%Indicate that the app is busy and disable the relevant buttons to prevent multiple queues
handles.BusyString.String = 'Busy';
handles.SurfaceApply.Enable = 'off';
handles.HotspotTotal.Enable = 'off';
handles.HotspotSelect.Enable = 'off';
handles.MeasurementMode.Enable = 'off';
handles.RoamingMode.Enable = 'off';
drawnow

curtab=handles.Alltabs(handles.Tabnames{handles.CurrentTab}); %dereference the current tab object


if strcmp(handles.ClusterOp,'probability') == false
    %If anything except probability is selected, use a dummy value for threshold
    handles.Data = clusterop(handles.Clusters,handles.ClusterOp,1);
else
    %If probability is selected, check if the threshold is valid and use it for clustering
    if isfield(handles,'BinThresh') == false
        errordlg({'Enter a binarization threshold for this analysis'}) 
        return
    end
    if ~(sum(isstrprop(handles.BinThresh,'digit') | isstrprop(handles.BinThresh,'punct')) == size(handles.BinThresh,2))
        errordlg({'Invalid Entry','Enter a numeric value for binarization threshold'})
        return
    end
    %Store the new clustered values in data
    handles.Data = clusterop(handles.Clusters,handles.ClusterOp,str2double(handles.BinThresh));
    curtab.dataset=handles.Data; %updata the dataset in the tabdata
end

%Rotate data to center on 0,pi/2, fit surface and sample with given image window
[handles.ImData,handles.MEPelip,u,v] = createData(handles.Data,handles.Centroid, ...
    handles.imlimits,handles.pixelspacing,handles.theta,handles.xphi,handles.yphi);

[handles.MEPfit,handles.MEPmap,handles.MEPmask,gof] = ...
    surfaceop([u,v,handles.Data(:,4)],handles.pixelspacing,handles.imlimits,handles.SurfaceOp,handles.Threshold);
handles.MEPmask = handles.alpha*handles.MEPmask;

handles.gof.String = num2str(gof.rsquare);
curtab.surfmap=handles.MEPmap; %save the mepmap into the tabdata

%Update Measurement Values
handles.COM = centerofmass(handles.Data); 
curtab.com=handles.COM; %save the center of mass into the tabdata
COM = (handles.COM - handles.Reference).*handles.ScanResolution; COMdist = norm((handles.COM - handles.Reference).*handles.ScanResolution);
handles.PositionTable.Data{2,1} = COM(1); %update the table with center of mass values
handles.PositionTable.Data{2,2} = COM(2);
handles.PositionTable.Data{2,3} = COM(3);
handles.PositionTable.Data{2,4} = COMdist; %update the distance to center of mass
[~,~,u,v] = createData([handles.COM,0],handles.Centroid,handles.imlimits,handles.pixelspacing,...
    handles.theta,handles.xphi,handles.yphi,'Skip');
COMVal = handles.MEPfit(u,v);
handles.ValueTable.Data{2,1} = COMVal; %update the center of mass position value
PeakMEPVal = max(max(handles.MEPmap)); %find the peak mep value on the interpolated map
handles.ValueTable.Data{3,1} = PeakMEPVal;
%curtab.status='fitted';

if ~strcmp(handles.SurfaceOp,'Nearest Neighbor')  
    [PeakMEPPos(2),PeakMEPPos(1)] = find(handles.MEPmap == PeakMEPVal);
else
    for n=1:size(handles.Data,1) %since nearest neighbor has plateaus of maximas, return the node that spawned the neighborhood to begin with and use that as peak coord
        if handles.Data(n,4) == PeakMEPVal
            PeakMEPPos=createData(handles.Data(n,:),handles.Centroid,handles.imlimits,handles.pixelspacing,handles.theta,handles.xphi,handles.yphi);
        end
    end
end
PeakMEPPos(1) = (PeakMEPPos(1) * handles.pixelspacing) + handles.imlimits(1);
PeakMEPPos(2) = (PeakMEPPos(2) * handles.pixelspacing) + handles.imlimits(3);
PeakMEPPos = handles.MEPelip(PeakMEPPos(1),PeakMEPPos(2));
PeakMEPPos = transmatTHETA(PeakMEPPos,-handles.theta);
PeakMEPPos = transmatPHI(PeakMEPPos,-handles.xphi,-handles.yphi,'inverse');
handles.PeakMEPPos = PeakMEPPos + handles.Centroid;
curtab.peakpos = handles.PeakMEPPos; %save the peak mep position into the tabdata
PeakMEPdist = norm((handles.PeakMEPPos - handles.Reference).*handles.ScanResolution);
PeakMEPPos = (handles.PeakMEPPos - handles.Reference).*handles.ScanResolution;
handles.PositionTable.Data{3,1} = PeakMEPPos(1);
handles.PositionTable.Data{3,2} = PeakMEPPos(2);
handles.PositionTable.Data{3,3} = PeakMEPPos(3);
handles.PositionTable.Data{3,4} = PeakMEPdist;

[SA,VA] = surfacearea(cat(3,handles.MEPmap,handles.MEPmap > handles.Threshold),handles.MEPelip,handles.pixelspacing,handles.imlimits,handles.ScanResolution);
handles.ValueTable.Data{4,1} = SA;
handles.ValueTable.Data{5,1} = VA;

handles.PositionTable.Data{1,1} = NaN;
handles.PositionTable.Data{1,2} = NaN;
handles.PositionTable.Data{1,3} = NaN;
handles.PositionTable.Data{1,4} = NaN;
handles.ValueTable.Data{1,1} = NaN;

if handles.DisplayCOG.Value == true
    handles.Markers(1,1:3) = handles.COM;
end
if handles.DisplayPeak.Value == true
    handles.Markers(2,1:3) = handles.PeakMEPPos;
end
[Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
        handles.imlimits,handles.pixelspacing, ...
        handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
%Update figure
createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,cat(3,handles.MEPmap,handles.MEPmask),handles.ImData,Markers);

if handles.HotspotTotal.Value == 1
    handles.WindowProtocol = 'HSTotal';
else
    handles.hsimgs = HotspotQuantification(handles.MEPmap,handles.Threshold,handles.SensitivitySlider.Value);
    handles.WindowProtocol = 'HSSelect';
    curtab.hsimgs=handles.hsimgs;
    handles.SensitivitySlider.Enable = 'on';
    handles.HotspotApply.Enable = 'on';
end
%Update uielements
if checkSA(handles.MEPfit,handles.imlimits,handles.pixelspacing,handles.Threshold) == false
    warndlg({'WARNING','Your current display settings have cut off a portion of the interpolated map. Surface area and volume integral measurements will only measure the part of the map that is in view.'});
end
handles.SurfaceApply.Enable = 'on';
handles.HotspotTotal.Enable = 'on';
handles.HotspotSelect.Enable = 'on';
handles.HotspotThreshold.Enable = 'on';

handles.MeasurementMode.Enable = 'on';
handles.RoamingMode.Enable = 'on';

handles.WindowTracker = 'TruecolorMap';
handles.Compare.Enable = 'on';
handles.DisplayZoom.Value = 0;
handles.Alltabs(handles.Tabnames{handles.CurrentTab})=curtab; %update the tab in handles

handles.BusyString.String = 'Idle';
drawnow;
guidata(hObject, handles);

% --- Executes on button press in SurfaceHelp.
function SurfaceHelp_Callback(hObject, eventdata, handles)
HelpMenu
 
% --- Executes on editing entry contents
function ClusterOpEdit_Callback(hObject, eventdata, handles)

% Enter binarization threshold for surface fitting
handles.BinThresh = get(hObject,'String');
guidata(hObject, handles);



% --- Executes on button press in DisplayRotate.
function DisplayRotate_Callback(hObject, eventdata, handles)

if ~handles.DisplayRotate.Value == 0
    handles.DisplayRotate.Value = 1;
    handles.DisplayPan.Value = 0;
    handles.DisplayZoom.Value = 0;
    handles.DisplayReference.Value = 0;
    handles.WindowProtocol = 'Rotate';
    handles.Rotate.Enable = false;
    handles.delxphi = 0;
    handles.delyphi = 0;
else
    handles.DisplayRotate.Value = 1;
end
guidata(hObject, handles);

% --- Executes on button press in DisplayPan.
function DisplayPan_Callback(hObject, eventdata, handles)

if ~handles.DisplayPan.Value == 0
    handles.DisplayRotate.Value = 0;
    handles.DisplayPan.Value = 1;
    handles.DisplayZoom.Value = 0;
    handles.DisplayReference.Value = 0;
    handles.WindowProtocol = 'Pan';
    handles.Pan.Enable = false;
    handles.deltheta = 0;
else
    handles.DisplayPan.Value = 1;
end
guidata(hObject, handles);

% --- Executes on button press in DisplayZoom.
function DisplayZoom_Callback(hObject, eventdata, handles)

if ~handles.DisplayZoom.Value == 0
    handles.DisplayRotate.Value = 0;
    handles.DisplayPan.Value = 0;
    handles.DisplayZoom.Value = 1;
    handles.DisplayReference.Value = 0;
    handles.WindowProtocol = 'Zoom';
    handles.Zoom.Enable = false;
else
    handles.DisplayZoom.Value = 1;
end
guidata(hObject, handles);

% --- Executes on button press in DisplayReference.
function DisplayReference_Callback(hObject, eventdata, handles)

if ~handles.DisplayReference.Value == 0
    handles.DisplayRotate.Value = 0;
    handles.DisplayPan.Value = 0;
    handles.DisplayZoom.Value = 0;
    handles.DisplayReference.Value = 1;
    handles.WindowProtocol = 'Reference';
else
    handles.DisplayReference.Value = 1;
end
guidata(hObject, handles);

function PixelSpacing_Callback(hObject, eventdata, handles)
handles.BusyString.String = 'Busy';
handles.PixelSpacing.Enable = 'off';
drawnow
tmp=str2double(get(hObject,'String'));
if tmp < handles.PIXELSPACINGABSMIN
    
    set(hObject,'String',num2str(handles.pixelspacing))
    handles.PixelSpacing.Enable='on';
    drawnow;
    guidata(hObject, handles);
    errordlg('You have selected a value for pixelspacing that would likely exceed available memory. Please choose a higher value.')
    return
end
handles.pixelspacing = str2double(get(hObject,'String'));
[handles.imdbSlice,handles.Weights] = createSlice(handles.imdb,handles.mesh, ...
    handles.pixelspacing,handles.imlimits, ...
    handles.xphi,handles.yphi,handles.theta,handles.k);
[Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
        handles.imlimits,handles.pixelspacing, ...
        handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
if isfield(handles,'Data')
    [handles.ImData,~] = createData(handles.Data,handles.Centroid, ...
        handles.imlimits,handles.pixelspacing, ...
        handles.theta,handles.xphi,handles.yphi);
    createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,handles.ImData,Markers);
else
    createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,Markers);
end

handles.HotspotTotal.Enable = 'off';
handles.HotspotSelect.Enable = 'off';
handles.HotspotThreshold.Enable = 'off';
handles.SensitivitySlider.Enable = 'off';
handles.HotspotApply.Enable = 'off';
handles.WindowTracker = 'Scatterplot';
handles.BusyString.String = 'Idle';
handles.PixelSpacing.Enable = 'on';
guidata(hObject, handles);

% --- Executes on slider movement.
function DepthSlider_Callback(hObject, eventdata, handles)
handles.BusyString.String = 'Busy';
handles.DepthSlider.Enable = 'off';
drawnow

handles.k = get(hObject,'Value');
if handles.DepthSlider.Max == handles.k
    handles.DepthSlider.Max = handles.DepthSlider.Max + 1;
end
if handles.DepthSlider.Min == handles.k
    handles.DepthSlider.Min = handles.DepthSlider.Min - 1;
end

[handles.imdbSlice,handles.Weights] = createSlice(handles.imdb,handles.mesh, ...
    handles.pixelspacing,handles.imlimits, ...
    handles.xphi,handles.yphi,handles.theta,handles.k);
if isfield(handles,'Data')
    [handles.ImData,~] = createData(handles.Data,handles.Centroid, ...
        handles.imlimits,handles.pixelspacing, ...
        handles.theta,handles.xphi,handles.yphi);
    [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
        handles.imlimits,handles.pixelspacing, ...
        handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
    if strcmp(handles.WindowTracker,'Scatterplot')
        createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,handles.ImData,Markers);
    else
        createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,cat(3,handles.MEPmap,handles.MEPmask),handles.ImData,Markers);
    end
else
    [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
        handles.imlimits,handles.pixelspacing, ...
        handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
    createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,Markers);
end

handles.BusyString.String = 'Idle';
handles.DepthSlider.Enable = 'on';
guidata(hObject, handles);

% --- Executes on button press in DisplayReset.
function DisplayReset_Callback(hObject, eventdata, handles)

handles.BusyString.String = 'Busy';
handles.DisplayReset.Enable = 'off';
drawnow

if handles.RoamingMode.Value == 1
    handles.xphi = 0;
    handles.yphi = 0;
    handles.theta = 0;
    handles.k = 0;
    handles.imlimits = [-pi,pi,0,pi];
    handles.pixelspacing = pi/500;
    
    [handles.imdbSlice,handles.Weights] = createSlice(handles.imdb,handles.mesh, ...
        handles.pixelspacing,handles.imlimits, ...
        handles.xphi,handles.yphi,handles.theta,handles.k);
    if isfield(handles,'Data') == true
        [handles.ImData,~,~,~] = createData(handles.Data,handles.Centroid, ...
            handles.imlimits,handles.pixelspacing, ...
            handles.theta,handles.xphi,handles.yphi);
        [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
            handles.imlimits,handles.pixelspacing, ...
            handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
        createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,handles.ImData,Markers);
    else
        [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
            handles.imlimits,handles.pixelspacing, ...
            handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
        createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,Markers);
    end
    
elseif handles.MeasurementMode.Value == 1
    handles.k = 0;
    handles.imlimits = [-pi,pi,0,pi];
    handles.pixelspacing = pi/500;
    
    [handles.imdbSlice,handles.Weights] = createSlice(handles.imdb,handles.mesh, ...
        handles.pixelspacing,handles.imlimits, ...
        handles.xphi,handles.yphi,handles.theta,handles.k);
    if isfield(handles,'Data') == true
        [handles.ImData,~,~,~] = createData(handles.Data,handles.Centroid, ...
            handles.imlimits,handles.pixelspacing, ...
            handles.theta,handles.xphi,handles.yphi);
        [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
            handles.imlimits,handles.pixelspacing, ...
            handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
        createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,handles.ImData,Markers);
    else
        [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
            handles.imlimits,handles.pixelspacing, ...
            handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
        createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,Markers);
    end
end

handles.WindowProtocol = 'Null';
handles.DisplayRotate.Value = 0;
handles.DisplayPan.Value = 0;
handles.DisplayZoom.Value = 0;
handles.DisplayReference.Value = 0;
handles.BusyString.String = 'Idle';
handles.DisplayReset.Enable = 'on';
handles.HotspotTotal.Enable = 'off';
handles.HotspotSelect.Enable = 'off';
handles.HotspotThreshold.Enable = 'off';
handles.SensitivitySlider.Enable = 'off';
handles.HotspotApply.Enable = 'off';
handles.WindowTracker = 'Scatterplot';
guidata(hObject, handles);

% --- Executes on button press in DisplayHelp.
function DisplayHelp_Callback(hObject, eventdata, handles)
 HelpMenu
 g1=guidata(HelpMenu);
 g1.visible = 'off';
 g1.text3.String='Learn more about display navigation below.';
 delete(g1.pushbutton2);
 delete(g1.pushbutton1);
 g1.text5.String='Display navigation';
 g1.text4.String=strjust(sprintf('To Rotate the image, click the ''rotate'' button and click and drag the image to rotate the ellipsoid. \n To Pan the image, click the ''pan'' button and click and drag left and right.  \n To zoom into the image, click the ''zoom'' button and click and drag a box over the area you would like to zoom into. A white box will display to indicate where you are zooming before you release the mouse button.  \nOnce done, press the ''reset'' button to return to the default zoom level. Note that when entering ''measurement mode'', the rotate and pan options will become disabled and the image will be centered on the MEPs.'),'left');
g1.visible = 'on';



% --- Executes on slider movement.
function SensitivitySlider_Callback(hObject, eventdata, handles)
    handles.hssensitivity = get(hObject,'Value');
    
    guidata(hObject, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% --- Executes on changing entered value.
function HotspotThreshold_Callback(hObject, eventdata, handles)

handles.BusyString.String = 'Busy';
drawnow;

if handles.HotspotTotal.Value == 1
    handles.Threshold = str2double(get(hObject,'String'));
    handles.MEPmask = handles.alpha*(handles.MEPmap > handles.Threshold);

    [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
                handles.imlimits,handles.pixelspacing, ...
                handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
    createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,cat(3,handles.MEPmap,handles.MEPmask),handles.ImData,Markers);

    [SA,VA] = surfacearea(cat(3,handles.MEPmap,handles.MEPmap > handles.Threshold),handles.MEPelip,handles.pixelspacing,handles.imlimits,handles.ScanResolution);
    handles.ValueTable.Data{4,1} = SA;
    handles.ValueTable.Data{5,1} = VA;
else
    handles.Threshold = str2double(get(hObject,'String'));
    handles.hsimgs = HotspotQuantification(handles.MEPmap,handles.Threshold,handles.SensitivitySlider.Value);
    handles.MEPmask = handles.alpha*(handles.MEPmap > handles.Threshold);
    
    [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
                handles.imlimits,handles.pixelspacing, ...
                handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
    createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,cat(3,handles.MEPmap,handles.MEPmask),handles.ImData,Markers);
end

handles.BusyString.String = 'Idle';
if checkSA(handles.MEPfit,handles.imlimits,handles.pixelspacing,handles.Threshold) == false
    warndlg({'WARNING','Your current display settings have cut off a portion of the interpolated map. Surface area and volume integral measurements will only measure the part of the map that is in view.'});
end
guidata(hObject, handles);

% --- Executes on button press in HotspotTotal.
function HotspotTotal_Callback(hObject, eventdata, handles)

handles.BusyString.String = 'Busy';
drawnow;

%Update Measurement Values
handles.COM = centerofmass(handles.Data);
COM = (handles.COM - handles.Reference).*handles.ScanResolution; COMdist = norm((handles.COM - handles.Reference).*handles.ScanResolution);
handles.PositionTable.Data{2,1} = COM(1);
handles.PositionTable.Data{2,2} = COM(2);
handles.PositionTable.Data{2,3} = COM(3);
handles.PositionTable.Data{2,4} = COMdist;

[~,~,u,v] = createData([handles.COM,0],handles.Centroid,handles.imlimits,handles.pixelspacing,...
    handles.theta,handles.xphi,handles.yphi,'Skip');
COMVal = handles.MEPfit(u,v);
handles.ValueTable.Data{2,1} = COMVal;

PeakMEPVal = max(max(handles.MEPmap));
handles.ValueTable.Data{3,1} = PeakMEPVal;

if ~strcmp(handles.SurfaceOp,'Nearest Neighbor')  
    [PeakMEPPos(2),PeakMEPPos(1)] = find(handles.MEPmap == PeakMEPVal);
else
    for n=1:size(handles.Data,1) %since nearest neighbor has plateaus of maximas, return the node that spawned the neighborhood to begin with and use that as peak coord
        if handles.Data(n,4) == PeakMEPVal
            PeakMEPPos=createData(handles.Data(n,:),handles.Centroid,handles.imlimits,handles.pixelspacing,handles.theta,handles.xphi,handles.yphi);
        end
    end
end

PeakMEPPos(1) = (PeakMEPPos(1) * handles.pixelspacing) + handles.imlimits(1);
PeakMEPPos(2) = (PeakMEPPos(2) * handles.pixelspacing) + handles.imlimits(3);
PeakMEPPos = handles.MEPelip(PeakMEPPos(1),PeakMEPPos(2));
PeakMEPPos = transmatTHETA(PeakMEPPos,-handles.theta);
PeakMEPPos = transmatPHI(PeakMEPPos,-handles.xphi,-handles.yphi,'inverse');
handles.PeakMEPPos = PeakMEPPos + handles.Centroid;

PeakMEPdist = norm((handles.PeakMEPPos - handles.Reference).*handles.ScanResolution);
PeakMEPPos = (handles.PeakMEPPos - handles.Reference).*handles.ScanResolution;
handles.PositionTable.Data{3,1} = PeakMEPPos(1);
handles.PositionTable.Data{3,2} = PeakMEPPos(2);
handles.PositionTable.Data{3,3} = PeakMEPPos(3);
handles.PositionTable.Data{3,4} = PeakMEPdist;

[SA,VA] = surfacearea(cat(3,handles.MEPmap,handles.MEPmap > handles.Threshold),handles.MEPelip,handles.pixelspacing,handles.imlimits,handles.ScanResolution);
handles.ValueTable.Data{4,1} = SA;
handles.ValueTable.Data{5,1} = VA;

handles.PositionTable.Data{1,1} = NaN;
handles.PositionTable.Data{1,2} = NaN;
handles.PositionTable.Data{1,3} = NaN;
handles.PositionTable.Data{1,4} = NaN;
handles.ValueTable.Data{1,1} = NaN;

if handles.DisplayCOG.Value == 1
    handles.Markers(1,1:3) = handles.COM;
else
    handles.Markers(1,1:3) = [NaN,NaN,NaN];
end
if handles.DisplayPeak.Value == 1
    handles.Markers(2,1:3) = handles.PeakMEPPos;
else
    handles.Markers(2,1:3) = [NaN,NaN,NaN];
end
if handles.DisplayRef.Value == 1
    handles.Markers(3,1:3) = handles.Reference;
else
    handles.Markers(3,1:3) = [NaN,NaN,NaN];
end

[Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
        handles.imlimits,handles.pixelspacing, ...
        handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,cat(3,handles.MEPmap,handles.MEPmask),handles.ImData,Markers);


%Update ui elements
handles.WindowProtocol = 'HSTotal';
handles.HotspotApply.Enable = 'off';
handles.SensitivitySlider.Enable = 'off';
handles.BusyString.String = 'Idle';
if checkSA(handles.MEPfit,handles.imlimits,handles.pixelspacing,handles.Threshold) == false
    warndlg({'WARNING','Your current display settings have cut off a portion of the interpolated map. Surface area and volume integral measurements will only measure the part of the map that is in view.'});
end

guidata(hObject, handles);

% --- Executes on button press in HotspotSelect.
function HotspotSelect_Callback(hObject, eventdata, handles)

handles.BusyString.String = 'Busy';
drawnow;

%Compute hotspots with floodfill algorithm
handles.hsimgs = HotspotQuantification(handles.MEPmap,handles.Threshold,handles.SensitivitySlider.Value);

%Upate measurement values
handles.PositionTable.Data{1,1} = NaN;
handles.PositionTable.Data{1,2} = NaN;
handles.PositionTable.Data{1,3} = NaN;
handles.PositionTable.Data{1,4} = NaN;
handles.PositionTable.Data{2,1} = NaN;
handles.PositionTable.Data{2,2} = NaN;
handles.PositionTable.Data{2,3} = NaN;
handles.PositionTable.Data{2,4} = NaN;
handles.PositionTable.Data{3,1} = NaN;
handles.PositionTable.Data{3,2} = NaN;
handles.PositionTable.Data{3,3} = NaN;
handles.PositionTable.Data{3,4} = NaN;
handles.ValueTable.Data{1,1} = NaN;
handles.ValueTable.Data{2,1} = NaN;
handles.ValueTable.Data{3,1} = NaN;
handles.ValueTable.Data{4,1} = NaN;
handles.ValueTable.Data{5,1} = NaN;

%Update uielements
handles.WindowProtocol = 'HSSelect';
handles.HotspotApply.Enable = 'on';
handles.SensitivitySlider.Enable = 'on';

handles.BusyString.String = 'Idle';

guidata(hObject, handles);

% --- Executes on button press in HotspotApply.
function HotspotApply_Callback(hObject, eventdata, handles)
    handles.BusyString.String='Busy';
    handles.hsimgs = HotspotQuantification(handles.MEPmap,handles.Threshold,handles.SensitivitySlider.Value);
    handles.WindowProtocol = 'HSSelect';
    curtab=handles.Alltabs(handles.Tabnames{handles.CurrentTab});
    curtab.hsimgs=handles.hsimgs;
    handles.Alltabs(handles.Tabnames{handles.CurrentTab})=curtab;

    handles.MEPmask = handles.alpha*(handles.MEPmap > handles.Threshold);
    
    [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
                handles.imlimits,handles.pixelspacing, ...
                handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
    createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,cat(3,handles.MEPmap,handles.MEPmask),handles.ImData,Markers);
    handles.BusyString.String='Idle';
    guidata(hObject, handles);
    

% --- Executes on button press in HotspotHelp.
function HotspotHelp_Callback(hObject, eventdata, handles)
HelpMenu
 g2=guidata(HelpMenu);
 g2.visible = 'off';
 delete(g2.pushbutton1); delete(g2.pushbutton2);
 g2.text3.String='Learn more about hotspot navigation below.';
 g2.text5.String='Hot Spot Navigation';
 g2.text4.String=strjust(sprintf(['When the ''select'' mode is turned on, a floodfill algorithm is used in order to assign points on the hotspot to all maxima in the interpolated image. However, if multiple maxima are very close together, this can cause incorrect representations of the hotspots. By using the slider, multiple maxima can be grouped together, allowing for more accurate representations of the hotspots. Click on the left arrow to decrease the threshold in order to de-group hotspots, and click on the right arrow to increase the threshold, which will group the hotspots. Click apply when you are satisfied.']),'left');
 g2.visible = 'on';


% --- Executes on button press in MeasurementMode.
function MeasurementMode_Callback(hObject, eventdata, handles)

handles.BusyString.String = 'Busy';
handles.MeasurementMode.Enable = 'off';
handles.RoamingMode.Enable = 'off';
drawnow;

if handles.MeasurementMode.Value
    handles.RoamingMode.Value = 0;
    
    handles.DisplayRotate.Enable = 'off';
    handles.DisplayPan.Enable = 'off';
    handles.DisplayReference.Enable = 'off';
    
    curtab=handles.Alltabs(handles.Tabnames{handles.CurrentTab});
    if ~isempty(curtab.clusters)
        handles.ClusterOpPopup.Enable = 'on';
        handles.SurfaceOpPopup.Enable = 'on';
        handles.SurfaceApply.Enable = 'on';
    end
    
    handles.WindowProtocol = 'Null';
    handles.Zoom.Enable = false;
    
    [handles.theta,handles.xphi,handles.yphi] = recenter(handles.Data,handles.Centroid);
    
    [handles.imdbSlice,handles.Weights] = createSlice(handles.imdb,handles.mesh, ...
        handles.pixelspacing,handles.imlimits, ...
        handles.xphi,handles.yphi,handles.theta,handles.k);
    [handles.ImData,~] = createData(handles.Data,handles.Centroid, ...
        handles.imlimits,handles.pixelspacing, ...
        handles.theta,handles.xphi,handles.yphi);
    [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
        handles.imlimits,handles.pixelspacing, ...
        handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
    createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,handles.ImData,Markers);
else
    handles.MeasurementMode.Value = 1;
end

handles.BusyString.String = 'Idle';
handles.MeasurementMode.Enable = 'on';
handles.RoamingMode.Enable = 'on';
guidata(hObject, handles);

% --- Executes on button press in RoamingMode.
function RoamingMode_Callback(hObject, eventdata, handles)

handles.BusyString.String = 'Busy';
handles.MeasurementMode.Enable = 'off';
handles.RoamingMode.Enable = 'off';
drawnow;

if handles.RoamingMode.Value
    handles.MeasurementMode.Value = 0;
    
    handles.DisplayRotate.Enable = 'on';
    handles.DisplayRotate.Value = 0;
    handles.DisplayPan.Enable = 'on';
    handles.DisplayPan.Value = 0;
    handles.DisplayZoom.Enable = 'on';
    handles.DisplayZoom.Value = 0;
    handles.DisplayReference.Enable = 'on';
    handles.DisplayReference.Value = 0;
    
    handles.WindowProtocol = 'Null';
    
    handles.ClusterOpPopup.Enable = 'off';
    handles.SurfaceOpPopup.Enable = 'off';
    handles.SurfaceApply.Enable = 'off';
    
    [handles.ImData,~,~,~] = createData(handles.Data,handles.Centroid, ...
        handles.imlimits,handles.pixelspacing, ...
        handles.theta,handles.xphi,handles.yphi);
    [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
        handles.imlimits,handles.pixelspacing, ...
        handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
    createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,handles.ImData,Markers);
    
    handles.PositionTable.Data{1,1} = NaN;
    handles.PositionTable.Data{1,2} = NaN;
    handles.PositionTable.Data{1,3} = NaN;
    handles.PositionTable.Data{1,4} = NaN;
    handles.PositionTable.Data{2,1} = NaN;
    handles.PositionTable.Data{2,2} = NaN;
    handles.PositionTable.Data{2,3} = NaN;
    handles.PositionTable.Data{2,4} = NaN;
    handles.PositionTable.Data{3,1} = NaN;
    handles.PositionTable.Data{3,2} = NaN;
    handles.PositionTable.Data{3,3} = NaN;
    handles.PositionTable.Data{3,4} = NaN;
    handles.ValueTable.Data{1,1} = NaN;
    handles.ValueTable.Data{2,1} = NaN;
    handles.ValueTable.Data{3,1} = NaN;
    handles.ValueTable.Data{4,1} = NaN;
    handles.ValueTable.Data{5,1} = NaN;
else
    handles.RoamingMode.Value = 1;
end

handles.BusyString.String = 'Idle';
handles.HotspotTotal.Enable = 'off';
handles.HotspotSelect.Enable = 'off';
handles.HotspotThreshold.Enable = 'off';
handles.SensitivitySlider.Enable = 'off';
handles.HotspotApply.Enable = 'off';
handles.WindowTracker = 'Scatterplot';
handles.MeasurementMode.Enable = 'on';
handles.RoamingMode.Enable = 'on';
handles.DisplayReference.Enable = 'on';
guidata(hObject, handles);

% --- Executes on button press in DisplayCOG.
function DisplayCOG_Callback(hObject, eventdata, handles)

if get(hObject,'Value') == 1
    handles.Markers(1,1:3) = handles.COM;
    if strcmp(handles.WindowTracker,'TruecolorMap')
        [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
                handles.imlimits,handles.pixelspacing, ...
                handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
        createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,cat(3,handles.MEPmap,handles.MEPmask),handles.ImData,Markers);
    else
        if isfield(handles,'Data') == true
            [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
                handles.imlimits,handles.pixelspacing, ...
                handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
            createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,handles.ImData,Markers);
        else
            [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
                handles.imlimits,handles.pixelspacing, ...
                handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
            createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,Markers);
        end
    end
else
    handles.Markers(1,1:3) = [NaN,NaN,NaN];
    if strcmp(handles.WindowTracker,'TruecolorMap')
        [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
                handles.imlimits,handles.pixelspacing, ...
                handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
        createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,cat(3,handles.MEPmap,handles.MEPmask),handles.ImData,Markers);
    else
        if isfield(handles,'Data') == true
            [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
                handles.imlimits,handles.pixelspacing, ...
                handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
            createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,handles.ImData,Markers);
        else
            [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
                handles.imlimits,handles.pixelspacing, ...
                handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
            createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,Markers);
        end
    end
end
guidata(hObject, handles);

% --- Executes on button press in DisplayPeak.
function DisplayPeak_Callback(hObject, eventdata, handles)

if get(hObject,'Value') == 1
    handles.Markers(2,1:3) = handles.PeakMEPPos;
    if strcmp(handles.WindowTracker,'TruecolorMap')
        [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
                handles.imlimits,handles.pixelspacing, ...
                handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
        createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,cat(3,handles.MEPmap,handles.MEPmask),handles.ImData,Markers);
    else
        if isfield(handles,'Data') == true
            [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
                handles.imlimits,handles.pixelspacing, ...
                handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
            createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,handles.ImData,Markers);
        else
            [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
                handles.imlimits,handles.pixelspacing, ...
                handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
            createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,Markers);
        end
    end
else
    handles.Markers(2,1:3) = [NaN,NaN,NaN];
    if strcmp(handles.WindowTracker,'TruecolorMap')
        [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
                handles.imlimits,handles.pixelspacing, ...
                handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
        createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,cat(3,handles.MEPmap,handles.MEPmask),handles.ImData,Markers);
    else
        if isfield(handles,'Data') == true
            [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
                handles.imlimits,handles.pixelspacing, ...
                handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
            createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,handles.ImData,Markers);
        else
            [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
                handles.imlimits,handles.pixelspacing, ...
                handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
            createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,Markers);
        end
    end
end
guidata(hObject, handles);

% --- Executes on button press in DisplayRef.
function DisplayRef_Callback(hObject, eventdata, handles)
if get(hObject,'Value') == 1
    handles.Markers(3,1:3) = handles.Reference;
    if strcmp(handles.WindowTracker,'TruecolorMap')
        [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
                handles.imlimits,handles.pixelspacing, ...
                handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
        createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,cat(3,handles.MEPmap,handles.MEPmask),handles.ImData,Markers);
    else
        if isfield(handles,'Data') == true
            [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
                handles.imlimits,handles.pixelspacing, ...
                handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
            createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,handles.ImData,Markers);
        else
            [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
                handles.imlimits,handles.pixelspacing, ...
                handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
            createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,Markers);
        end
    end
else
    handles.Markers(3,1:3) = [NaN,NaN,NaN];
    if strcmp(handles.WindowTracker,'TruecolorMap')
        [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
                handles.imlimits,handles.pixelspacing, ...
                handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
        createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,cat(3,handles.MEPmap,handles.MEPmask),handles.ImData,Markers);
    else
        if isfield(handles,'Data') == true
            [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
                handles.imlimits,handles.pixelspacing, ...
                handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
            createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,handles.ImData,Markers);
        else
            [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
                handles.imlimits,handles.pixelspacing, ...
                handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
            createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,Markers);
        end
    end
end
guidata(hObject, handles);

% --- Executes on button press in MeasurementHelp.
function MeasurementHelp_Callback(hObject, eventdata, handles)
 HelpMenu
 g2=guidata(HelpMenu);
 g2.visible = 'off';
 delete(g2.pushbutton1); delete(g2.pushbutton2);
 g2.text3.String='Learn more about quantification measures below.';
 g2.text5.String='Measurements';
 g2.text4.String=strjust(sprintf(['Center of gravity: Center of gravity is calculated for each axis by dividing the sum of the coordinates of each non-zero point on the heatmap multiplied by MEP amplitudes by the sum of the MEP amplitudes.\n', ...
'Cursor MEP: Displays the coordinates of an MEP amplitude when mouse hovers over map.\n', ...
'Peak MEP: Displays highest MEP amplitude of map\n', ...
'Surface Area: Surface area of map\n', ...
'MRI Coords: MRI coordinate position, updated in real time with mouse hover. Note that this IS dependent on your depth controlled through the display panel on the bottom left of the app.\n', ...
'Voltage per area: Displays the volumetric integration of the MEP map divided by the surface area, yielding a net average voltage per area.\n', ...
 ]),'left');
 g2.visible = 'on';

function ColorMapMin_Callback(hObject, eventdata, handles)
Entry = str2double(get(hObject,'String'));
if isnan(Entry)
    errordlg({'Invalid Entry','Please enter numeric characters only'})
else
    handles.ColorMin = Entry;
end
guidata(hObject, handles);

function ColorMapMax_Callback(hObject, eventdata, handles)
Entry = str2double(get(hObject,'String'));
if isnan(Entry)
    errordlg({'Invalid Entry','Please enter numeric characters only'})
else
    handles.ColorMax = Entry;
end
guidata(hObject, handles);

% --- Executes on selection change in ColorMapSelect.
function ColorMapSelect_Callback(hObject, eventdata, handles)
contents = cellstr(get(hObject,'String'));
handles.Colormap = contents{get(hObject,'Value')};
guidata(hObject, handles);

% --- Executes on slider movement.
function TransparencySlider_Callback(hObject, eventdata, handles)
handles.alpha = get(hObject,'Value');
if isfield(handles,'MEPmask')
    handles.MEPmask = handles.alpha*(handles.MEPmask ~= 0);
end
guidata(hObject, handles);

% --- Executes on button press in ColorMapApply.
function ColorMapApply_Callback(hObject, eventdata, handles)
if strcmp(handles.WindowTracker,'TruecolorMap')
    [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
            handles.imlimits,handles.pixelspacing, ...
            handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
    createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,cat(3,handles.MEPmap,handles.MEPmask),handles.ImData,Markers);
else
    if isfield(handles,'Data') == true
        [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
            handles.imlimits,handles.pixelspacing, ...
            handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
        createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,handles.ImData,Markers);
    else
        [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
            handles.imlimits,handles.pixelspacing, ...
            handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
        createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,Markers);
    end
end
guidata(hObject, handles);

% --- Executes on button press in ColorMapHelp.
function ColorMapHelp_Callback(hObject, eventdata, handles)
    HelpMenu
    g2=guidata(HelpMenu);
    g2.visible = 'off';
    delete(g2.pushbutton1); delete(g2.pushbutton2);
    g2.text3.String='Learn more about colormaps below.';
    g2.text5.String='Colormaps';
    g2.text4.String=strjust(sprintf(['Currently, the default colormap is ''hot'', which is a colormap which raises with linear brightness. Additionally, the rainbow (Jet), pink, copper, and bone colormaps are also available. For ease of comparison between images, it is possible to set the voltage maxima and minima for the colormap so that two maps can be compared with equivalent color levels. Further, a transparency slider is available for changing the overall opacity of the datapoints for easier resolution of either the underlying brain or the data. Click ''Apply'' when you are satisfied.']),'left');
    g2.visible = 'on';

% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)

switch handles.WindowProtocol
    case 'Null'
%         cursor = handles.figure1.CurrentAxes.CurrentPoint;
%         if 1 < cursor(1,1) && (handles.imlimits(2)-handles.imlimits(1))/handles.pixelspacing > cursor(1,1) ...
%             && 1 < cursor(1,2) && (handles.imlimits(4)-handles.imlimits(3))/handles.pixelspacing > cursor(1,2)
%         disp(cursor(1,1:2))
%         end
    case 'Rotate'      
        cursor = handles.figure1.CurrentAxes.CurrentPoint;
        if 1 < cursor(1,1) && (handles.imlimits(2)-handles.imlimits(1))/handles.pixelspacing > cursor(1,1) ...
            && 1 < cursor(1,2) && (handles.imlimits(4)-handles.imlimits(3))/handles.pixelspacing > cursor(1,2)
            if handles.Rotate.Enable == true
                y = handles.Rotate.Swivel(2) - cursor(1,2);
                x = handles.Rotate.Swivel(1) - cursor(1,1);
                handles.delxphi = (x/(handles.imlimits(2) - handles.imlimits(1)))*2*pi*0.005;
                handles.delyphi = (y/(handles.imlimits(4) - handles.imlimits(3)))*pi*0.005;
                
                handles.imdbSlice = createSlice(handles.imdb,handles.mesh, ...
                    handles.pixelspacing,handles.imlimits, ...
                    handles.xphi + handles.delxphi,handles.yphi + handles.delyphi,handles.theta,handles.k);
                if isfield(handles,'Data')
                    [handles.ImData,handles.MEPelip,~,~] = createData(handles.Data,handles.Centroid,...
                        handles.imlimits,handles.pixelspacing, ...
                        handles.theta,handles.xphi + handles.delxphi,handles.yphi + handles.delyphi);
                    [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
                        handles.imlimits,handles.pixelspacing, ...
                        handles.theta,handles.xphi + handles.delxphi,handles.yphi + handles.delyphi,'Skip'); Markers = Markers(:,1:2);
                    createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,handles.ImData,Markers);
                else
                    [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
                        handles.imlimits,handles.pixelspacing, ...
                        handles.theta,handles.xphi + handles.delxphi,handles.yphi + handles.delyphi,'Skip'); Markers = Markers(:,1:2);
                    createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,Markers);
                end
            end
        end

    case 'Pan'
        cursor = handles.figure1.CurrentAxes.CurrentPoint;
        if 1 < cursor(1,1) && (handles.imlimits(2)-handles.imlimits(1))/handles.pixelspacing > cursor(1,1) ...
            && 1 < cursor(1,2) && (handles.imlimits(4)-handles.imlimits(3))/handles.pixelspacing > cursor(1,2)
            if handles.Pan.Enable == true
                x = -(handles.Pan.Swivel(1) - cursor(1,1));
                handles.deltheta = (x/(handles.imlimits(2) - handles.imlimits(1)))*2*pi*0.005;
                
                handles.imdbSlice = createSlice(handles.imdb,handles.mesh, ...
                    handles.pixelspacing,handles.imlimits, ...
                    handles.xphi,handles.yphi,handles.theta + handles.deltheta,handles.k);
                if isfield(handles,'Data')
                    [handles.ImData,handles.MEPelip,~,~] = createData(handles.Data,handles.Centroid,...
                        handles.imlimits,handles.pixelspacing, ...
                        handles.theta + handles.deltheta,handles.xphi,handles.yphi);
                    [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
                        handles.imlimits,handles.pixelspacing, ...
                        handles.theta + handles.deltheta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
                    createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,handles.ImData,Markers);
                else
                    [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
                        handles.imlimits,handles.pixelspacing, ...
                        handles.theta + handles.deltheta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
                    createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,Markers);
                end
            end
        end
        
    case 'Zoom'
        cursor = handles.figure1.CurrentAxes.CurrentPoint;
        if 1 < cursor(1,1) && (handles.imlimits(2)-handles.imlimits(1))/handles.pixelspacing > cursor(1,1) ...
            && 1 < cursor(1,2) && (handles.imlimits(4)-handles.imlimits(3))/handles.pixelspacing > cursor(1,2)
            if handles.Zoom.Enable == true
                Box = zoombox(handles.Zoom.Point1,cursor(1,1:2),[size(handles.imdbSlice,1),size(handles.imdbSlice,2)]);
                [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
                        handles.imlimits,handles.pixelspacing, ...
                        handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
                if isfield(handles,'Data') == true
                    createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,handles.ImData,Markers);
                else
                    createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,Markers);
                end
                hold on
                h = imshow(double(cat(3,Box,Box,Box)));
                set(h, 'AlphaData', Box);
                hold off
            end
        end
        
    case 'Reference'
       cursor = handles.figure1.CurrentAxes.CurrentPoint;
        if 1 < cursor(1,1) && (handles.imlimits(2)-handles.imlimits(1))/handles.pixelspacing > cursor(1,1) ...
            && 1 < cursor(1,2) && (handles.imlimits(4)-handles.imlimits(3))/handles.pixelspacing > cursor(1,2)
        u = (cursor(1,1)*handles.pixelspacing)+handles.imlimits(1);
        v = (cursor(1,2)*handles.pixelspacing)+handles.imlimits(3);
        point = evalelip(u,v,handles.Weights,handles.k);
        point = transmatTHETA(point,-handles.theta);
        point = transmatPHI(point,-handles.xphi,-handles.yphi,'inverse');
        point = point + handles.Centroid; pointdist = norm((point - handles.Reference).*handles.ScanResolution);
        point = (point - handles.Reference).*handles.ScanResolution;
        handles.PositionTable.Data{1,1} = point(1);
        handles.PositionTable.Data{1,2} = point(2);
        handles.PositionTable.Data{1,3} = point(3);
        handles.PositionTable.Data{1,4} = pointdist;
        end
        
    case 'HSTotal'
        cursor = handles.figure1.CurrentAxes.CurrentPoint;
        if 1 < cursor(1,1) && (handles.imlimits(2)-handles.imlimits(1))/handles.pixelspacing > cursor(1,1) ...
            && 1 < cursor(1,2) && (handles.imlimits(4)-handles.imlimits(3))/handles.pixelspacing > cursor(1,2)
        MEP = handles.MEPmap(floor(cursor(1,2)),floor(cursor(1,1)));
        if strcmp(handles.ClusterOp,'probability')
            if MEP > 100
                MEP = 100;
            elseif MEP < 0
                MEP = 0;
            end
            handles.ValueTable.Data{1,1} = strcat(num2str(MEP),'%');
        else
            handles.ValueTable.Data{1,1} = MEP;
        end
        u = (cursor(1,1)*handles.pixelspacing)+handles.imlimits(1);
        v = (cursor(1,2)*handles.pixelspacing)+handles.imlimits(3);
        point = evalelip(u,v,handles.Weights,handles.k);
        point = transmatTHETA(point,-handles.theta);
        point = transmatPHI(point,-handles.xphi,-handles.yphi,'inverse');
        point = point + handles.Centroid; pointdist = norm((point - handles.Reference).*handles.ScanResolution);
        point = (point - handles.Reference).*handles.ScanResolution;
        handles.PositionTable.Data{1,1} = point(1);
        handles.PositionTable.Data{1,2} = point(2);
        handles.PositionTable.Data{1,3} = point(3);
        handles.PositionTable.Data{1,4} = pointdist;
        end
        
    case 'HSSelect'
        cursor = handles.figure1.CurrentAxes.CurrentPoint;
        if 1 < cursor(1,1) && (handles.imlimits(2)-handles.imlimits(1))/handles.pixelspacing > cursor(1,1) ...
            && 1 < cursor(1,2) && (handles.imlimits(4)-handles.imlimits(3))/handles.pixelspacing > cursor(1,2)
        MEP = handles.MEPmap(floor(cursor(1,2)),floor(cursor(1,1)));
        if strcmp(handles.ClusterOp,'probability')
            if MEP > 100
                MEP = 100;
            elseif MEP < 0
                MEP = 0;
            end
            handles.ValueTable.Data{1,1} = strcat(num2str(MEP),'%');
        else
            handles.ValueTable.Data{1,1} = MEP;
        end
        u = (cursor(1,1)*handles.pixelspacing)+handles.imlimits(1);
        v = (cursor(1,2)*handles.pixelspacing)+handles.imlimits(3);
        point = evalelip(u,v,handles.Weights,handles.k);
        point = transmatTHETA(point,-handles.theta);
        point = transmatPHI(point,-handles.xphi,-handles.yphi,'inverse');
        point = point + handles.Centroid; pointdist = norm((point - handles.Reference).*handles.ScanResolution);
        point = (point - handles.Reference).*handles.ScanResolution;
        handles.PositionTable.Data{1,1} = point(1);
        handles.PositionTable.Data{1,2} = point(2);
        handles.PositionTable.Data{1,3} = point(3);
        handles.PositionTable.Data{1,4} = pointdist;
        end
end
guidata(hObject, handles);

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)

switch handles.WindowProtocol
    case 'Null'
        disp('Null')
        
    case 'Rotate'
        cursor = handles.figure1.CurrentAxes.CurrentPoint;
        if 1 < cursor(1,1) && (handles.imlimits(2)-handles.imlimits(1))/handles.pixelspacing > cursor(1,1) ...
            && 1 < cursor(1,2) && (handles.imlimits(4)-handles.imlimits(3))/handles.pixelspacing > cursor(1,2)
            handles.Rotate.Enable = true;
            handles.Rotate.Swivel = cursor(1,1:2);
        end
        
    case 'Pan'
        cursor = handles.figure1.CurrentAxes.CurrentPoint;
        if 1 < cursor(1,1) && (handles.imlimits(2)-handles.imlimits(1))/handles.pixelspacing > cursor(1,1) ...
            && 1 < cursor(1,2) && (handles.imlimits(4)-handles.imlimits(3))/handles.pixelspacing > cursor(1,2)
            handles.Pan.Enable = true;
            handles.Pan.Swivel = cursor(1,1:2);
        end
        
    case 'Zoom'
        cursor = handles.figure1.CurrentAxes.CurrentPoint;
        if 1 < cursor(1,1) && (handles.imlimits(2)-handles.imlimits(1))/handles.pixelspacing > cursor(1,1) ...
            && 1 < cursor(1,2) && (handles.imlimits(4)-handles.imlimits(3))/handles.pixelspacing > cursor(1,2)
            handles.Zoom.Enable = true;
            handles.Zoom.Point1 = cursor(1,1:2);
        end
        
    case 'Reference'
        cursor = handles.figure1.CurrentAxes.CurrentPoint;
        if 1 < cursor(1,1) && (handles.imlimits(2)-handles.imlimits(1))/handles.pixelspacing > cursor(1,1) ...
            && 1 < cursor(1,2) && (handles.imlimits(4)-handles.imlimits(3))/handles.pixelspacing > cursor(1,2)
            u = (cursor(1,1)*handles.pixelspacing)+handles.imlimits(1);
            v = (cursor(1,2)*handles.pixelspacing)+handles.imlimits(3);
            point = evalelip(u,v,handles.Weights,handles.k);
            point = transmatTHETA(point,-handles.theta);
            point = transmatPHI(point,-handles.xphi,-handles.yphi,'inverse');
            point = point + handles.Centroid;
            handles.Reference = point;
            if handles.DisplayRef.Value == 1
                handles.Markers(3,1:3) = handles.Reference;
                [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
                        handles.imlimits,handles.pixelspacing, ...
                        handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
                if isfield(handles,'Data') == 1
                    createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,handles.ImData,Markers);
                else
                    createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,Markers);
                end
            end
            handles.RefString.String = sprintf('[%0.3f,%0.3f,%0.3f] (%s)',...
                handles.Reference(1),handles.Reference(2),handles.Reference(3),'HeadNav');

            curtab=handles.Alltabs(handles.Tabnames{handles.CurrentTab});
            handles.Alltabs(handles.Tabnames{handles.CurrentTab})=curtab;
        end
        
    case 'HSTotal'
        
    case 'HSSelect'
        cursor = handles.figure1.CurrentAxes.CurrentPoint;
        if 1 < cursor(1,1) && (handles.imlimits(2)-handles.imlimits(1))/handles.pixelspacing > cursor(1,1) ...
            && 1 < cursor(1,2) && (handles.imlimits(4)-handles.imlimits(3))/handles.pixelspacing > cursor(1,2)
           found = false;
            for i = 1:size(handles.hsimgs,3)
                query = handles.hsimgs(:,:,i);
                if query(floor(cursor(1,2)),floor(cursor(1,1))) == true
                    hs = handles.hsimgs(:,:,i);
                    found = true;
                end
            end
            if found == false
                hs = false(size(handles.hsimgs,1),size(handles.hsimgs,2));
            end
            
            if found == true
                MEPmap = handles.MEPmap;
                MEPmap(~hs) = 0;
                
                ImData = [];
                for i = 1:size(handles.ImData,1)
                    if hs(floor(handles.ImData(i,2)),floor(handles.ImData(i,1))) == 1
                        ImData(end+1,:) = handles.ImData(i,:);
                    end
                end
                
                if ~isempty(ImData)
                    ImData(:,1) = (ImData(:,1) *  handles.pixelspacing) + handles.imlimits(1);
                    ImData(:,2) = (ImData(:,2) *  handles.pixelspacing) + handles.imlimits(3);
                    for i = 1:size(ImData,1)
                        Data(i,:) = handles.MEPelip(ImData(i,1),ImData(i,2));
                    end
                    Data = transmatTHETA(Data,-handles.theta);
                    Data = transmatPHI(Data,-handles.xphi,-handles.yphi,'inverse');
                    Data = Data + handles.Centroid; Data(:,4) = ImData(:,3);
                    handles.COM = centerofmass(Data); COMdist = norm((handles.COM - handles.Reference).*handles.ScanResolution);
                    COM = (handles.COM - handles.Reference).*handles.ScanResolution;
                    handles.PositionTable.Data{2,1} = COM(1);
                    handles.PositionTable.Data{2,2} = COM(2);
                    handles.PositionTable.Data{2,3} = COM(3);
                    handles.PositionTable.Data{2,4} = COMdist;
                    [~,~,u,v] = createData([handles.COM,0],handles.Centroid,handles.imlimits,handles.pixelspacing,...
                        handles.theta,handles.xphi,handles.yphi,'Skip');
                    COMVal = handles.MEPfit(u,v);
                    handles.ValueTable.Data{2,1} = COMVal;
                else
                    handles.PositionTable.Data{2,:} = NaN;
                    handles.COM = [NaN,NaN,NaN];
                end
                
                PeakMEPVal = max(max(MEPmap));
                handles.ValueTable.Data{3,1} = PeakMEPVal;

                if ~strcmp(handles.SurfaceOp,'Nearest Neighbor')  
                    [PeakMEPPos(2),PeakMEPPos(1)] = find(MEPmap == PeakMEPVal);
                else
                    for n=1:size(handles.Data,1) %since nearest neighbor has plateaus of maximas, return the node that spawned the neighborhood to begin with and use that as peak coord
                        if handles.Data(n,4) == PeakMEPVal
                            PeakMEPPos=createData(handles.Data(n,:),handles.Centroid,handles.imlimits,handles.pixelspacing,handles.theta,handles.xphi,handles.yphi);
                        end
                    end
                end

                PeakMEPPos(1) = (PeakMEPPos(1) * handles.pixelspacing) + handles.imlimits(1);
                PeakMEPPos(2) = (PeakMEPPos(2) * handles.pixelspacing) + handles.imlimits(3);
                PeakMEPPos = handles.MEPelip(PeakMEPPos(1),PeakMEPPos(2));
                PeakMEPPos = transmatTHETA(PeakMEPPos,-handles.theta);
                PeakMEPPos = transmatPHI(PeakMEPPos,-handles.xphi,-handles.yphi,'inverse');
                handles.PeakMEPPos = PeakMEPPos + handles.Centroid;

                PeakMEPdist = norm((handles.PeakMEPPos - handles.Reference).*handles.ScanResolution);
                PeakMEPPos = (handles.PeakMEPPos - handles.Reference).*handles.ScanResolution;
                handles.PositionTable.Data{3,1} = PeakMEPPos(1);
                handles.PositionTable.Data{3,2} = PeakMEPPos(2);
                handles.PositionTable.Data{3,3} = PeakMEPPos(3);
                handles.PositionTable.Data{3,4} = PeakMEPdist;
                    
                [SA,VA] = surfacearea(cat(3,MEPmap,MEPmap > handles.Threshold),handles.MEPelip,handles.pixelspacing,handles.imlimits,handles.ScanResolution);
                handles.ValueTable.Data{4,1} = SA;
                handles.ValueTable.Data{5,1} = VA;
            end
            
            hs = edge(hs);
            hsc = cat(3,double(hs),double(hs),double(hs));
            
            if handles.DisplayCOG.Value == 1
                handles.Markers(1,1:3) = handles.COM;
            else
                handles.Markers(1,1:3) = [NaN,NaN,NaN];
            end
            if handles.DisplayPeak.Value == 1
                handles.Markers(2,1:3) = handles.PeakMEPPos;
            else
                handles.Markers(2,1:3) = [NaN,NaN,NaN];
            end
            if handles.DisplayRef.Value == 1
                handles.Markers(3,1:3) = handles.Reference;
            else
                handles.Markers(3,1:3) = [NaN,NaN,NaN];
            end
            
            [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
                        handles.imlimits,handles.pixelspacing, ...
                        handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
            createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,cat(3,handles.MEPmap,handles.MEPmask),handles.ImData,Markers);       
            hold on
            h = imshow(hsc);
            set(h, 'AlphaData', hs);
            hold off
            if checkSA(handles.MEPfit,handles.imlimits,handles.pixelspacing,handles.Threshold) == false
                warndlg({'WARNING','Your current display settings have cut off a portion of the interpolated map. Surface area and volume integral measurements will only measure the part of the map that is in view.'});
            end
        end
end
guidata(hObject, handles);

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)

switch handles.WindowProtocol
    case 'Null'
        
    case 'Rotate'
         handles.Rotate.Enable = false;
         handles.xphi = handles.xphi + handles.delxphi;
         handles.yphi = handles.yphi + handles.delyphi;
         
    case 'Pan'
         handles.Pan.Enable = false;
         handles.theta = handles.theta + handles.deltheta;
         
    case 'Zoom'
        cursor = handles.figure1.CurrentAxes.CurrentPoint;
        if 1 < cursor(1,1) && (handles.imlimits(2)-handles.imlimits(1))/handles.pixelspacing > cursor(1,1) ...
            && 1 < cursor(1,2) && (handles.imlimits(4)-handles.imlimits(3))/handles.pixelspacing > cursor(1,2)
            handles.Zoom.Enable = false;
            handles.Zoom.Point2 = cursor(1,1:2);
            
            x1 = (handles.Zoom.Point1(1) * handles.pixelspacing) + handles.imlimits(1);
            x2 = (handles.Zoom.Point2(1) * handles.pixelspacing) + handles.imlimits(1);
            y1 = (handles.Zoom.Point1(2) * handles.pixelspacing) + handles.imlimits(3);
            y2 = (handles.Zoom.Point2(2) * handles.pixelspacing) + handles.imlimits(3);
            if x2 > x1 && y2 > y1 
                handles.imlimits = [x1,x2,y1,y2];
            elseif x1 > x2 && y1 > y2
                handles.imlimits = [x2,x1,y2,y1];
            elseif x2 > x1 && y1 > y2 
                handles.imlimits = [x1,x2,y2,y1];
            elseif x1 > x2 && y2 > y1 
                handles.imlimits = [x2,x1,y1,y2];
            end

            [handles.imdbSlice,handles.Weights] = createSlice(handles.imdb,handles.mesh,...
                handles.pixelspacing,handles.imlimits,...
                handles.xphi,handles.yphi,handles.theta,handles.k);
            if isfield(handles,'Data')
                [handles.ImData,~,~,~] = createData(handles.Data,handles.Centroid,...
                    handles.imlimits,handles.pixelspacing,...
                    handles.theta,handles.xphi,handles.yphi);
                [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
                        handles.imlimits,handles.pixelspacing, ...
                        handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
                createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,handles.ImData,Markers);
            else
                [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
                        handles.imlimits,handles.pixelspacing, ...
                        handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
                createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,Markers);
            end
                handles.HotspotTotal.Enable = 'off';
                handles.HotspotSelect.Enable = 'off';
                handles.HotspotThreshold.Enable = 'off';
                handles.SensitivitySlider.Enable = 'off';
                handles.HotspotApply.Enable = 'off';
                handles.WindowTracker = 'Scatterplot';
        end
          
    case 'Reference'
        
    case 'HSTotal'
        
    case 'HSSelect'
end
guidata(hObject, handles);


% --- Executes on button press in Compare.
function Compare_Callback(hObject, eventdata, handles)

%Sets = setdiff(fields(handles.DataStore),CheckTab(handles));
curtabname=handles.Tabnames{1,handles.CurrentTab};
count=uint8(0);
for i = 1:length(handles.Alltabs)
    curtabobj=handles.Alltabs(handles.Tabnames{1,i});
    if ~isempty(curtabobj.clusters) && ~strcmp(curtabname, curtabobj.name)
        count=count+1;
    end
end

if count~=0
    count=uint8(0);
    ValidSets = cell(count,1);
    for i = 1:length(handles.Alltabs)
        curtabobj=handles.Alltabs(handles.Tabnames{1,i});
        if ~isempty(curtabobj.clusters) && ~strcmp(curtabname, curtabobj.name)
            count=count+1;
            ValidSets{count,1} = handles.Tabnames{1,i};
        end
    end
    [indx,tf] = listdlg('PromptString',{'Choose a dataset to compare:','Only clustered data is valid'},...
                   'SelectionMode','single','ListSize',[160,200], ...
                   'ListString',ValidSets); 
               
    if isempty(indx)
        return
    end
    TestingSet = ValidSets{indx,1};
    TrainingSet = handles.Tabnames{1,handles.CurrentTab};
               
    if tf == true
        handles.figure1.Visible = 'off';
        ComparisonGUI(handles,TrainingSet,TestingSet); uiwait;
        handles.figure1.Visible = 'on';
    end
else
    msgbox('There are no other valid datasets to compare. A valid dataset is one that has been clustered','No Valid Datasets')
end

guidata(hObject, handles);

% --- Executes on button press in Render3D.
function Render3D_Callback(hObject, eventdata, handles)
%Create meshgrid
[U,V] = meshgrid(-pi:(pi/500):pi-(pi/500), ...
    0:(pi/500):pi-(pi/500));

%Fit elipsoid onto head repositioned at origin
pointCloud = handles.mesh - handles.Centroid;
[u,v] = elipfit(pointCloud);
w = elipfitHEAD(u,v,pointCloud);

%Evaluate fitted elipsoid over meshgrid
vals = evalelip(U,V,w,handles.k);

%Reposition elipsoid in original location within MRI coordinates
c(1,1,1:3) = handles.Centroid;
vals = vals + c;

%Slice the 3D image volume
imdbSlice = sliceimdb(vals,handles.imdb);

%Plot the surface as a meshgrid
figure
mesh(vals(:,:,1),vals(:,:,2),vals(:,:,3),imdbSlice,'FaceAlpha',0.3,'EdgeAlpha',0.3); colormap gray; axis equal; hold on
if isfield(handles,'Data')
    scatter3(handles.Data(:,1),handles.Data(:,2),handles.Data(:,3),20,...
        squeeze(truecolor(handles.Data(:,4),handles.ColorMin,handles.ColorMax,handles.Colormap)),'filled');
end
scatter3(handles.Markers(1,1),handles.Markers(1,2),handles.Markers(1,3),'+','LineWidth',5,'MarkerEdgeColor','b')
if handles.DisplayCOG.Value == 1
    textscatter3(handles.Markers(1,1)+5,handles.Markers(1,2),handles.Markers(1,3)+5,{'COG'},'ColorData',[0,0,1])
end
scatter3(handles.Markers(2,1),handles.Markers(2,2),handles.Markers(2,3),'+','LineWidth',5,'MarkerEdgeColor','b')
if handles.DisplayPeak.Value == 1
    textscatter3(handles.Markers(2,1)+5,handles.Markers(2,2),handles.Markers(2,3)+5,{'Peak'},'ColorData',[0,0,1])
end
scatter3(handles.Markers(3,1),handles.Markers(3,2),handles.Markers(3,3),'+','LineWidth',5,'MarkerEdgeColor','b')
if handles.DisplayRef.Value == 1
    textscatter3(handles.Markers(3,1)+5,handles.Markers(3,2),handles.Markers(3,3)+5,{'Ref'},'ColorData',[0,0,1])
end

% --- Executes on button press in ExportData.
function ExportData_Callback(hObject, eventdata, handles)
[file,path] = uiputfile({'*.txt','Text File (*.txt)'});
if file == 0
    return
end
TopRow = ['Positions',handles.PositionTable.ColumnName'];
EndRows = [handles.PositionTable.RowName,handles.PositionTable.Data];
PositionData = [TopRow;EndRows];

TopRow = ['Values',handles.ValueTable.ColumnName'];
EndRows = [handles.ValueTable.RowName,handles.ValueTable.Data];
ValueData = [TopRow;EndRows];

FileID = fopen(strcat(path,file),'w');
if ispc
    fprintf(FileID,'%s %6s\r\n','Reference:',handles.RefString.String);
    fprintf(FileID,'\r\n');
    fprintf(FileID,'%6s %12s %12s %12s %12s\r\n', PositionData{1,1},...
        PositionData{1,2},PositionData{1,3},PositionData{1,4},PositionData{1,5});
    fprintf(FileID,'%6s %12.2f %12.2f %12.2f %12.2f\r\n', PositionData{3,1},...
        PositionData{3,2},PositionData{3,3},PositionData{3,4},PositionData{3,5});
    fprintf(FileID,'%6s %12.2f %12.2f %12.2f %12.2f\r\n', PositionData{4,1},...
        PositionData{4,2},PositionData{4,3},PositionData{4,4},PositionData{4,5});
    fprintf(FileID,'\r\n');
    fprintf(FileID,'\r\n');
    fprintf(FileID,'\r\n');
    fprintf(FileID,'%6s %12s %12s\r\n', ValueData{1,1},...
        ValueData{1,2},ValueData{1,3});
    fprintf(FileID,'%6s %12.2f %12.2f\r\n', ValueData{3,1},...
        ValueData{3,2},ValueData{3,3});
    fprintf(FileID,'%6s %12.2f %12.2f\r\n', ValueData{4,1},...
        ValueData{4,2},ValueData{4,3});
    fprintf(FileID,'%6s %12.2f %12.2f\r\n', ValueData{5,1},...
        ValueData{5,2},ValueData{5,3});
    fprintf(FileID,'%6s %12.2f %12.2f\r\n', ValueData{6,1},...
        ValueData{6,2},ValueData{6,3});
else
    fprintf(FileID,'%s %6s\n','Reference:',handles.RefString.String);
    fprintf(FileID,'\n');
    fprintf(FileID,'%6s %12s %12s %12s %12s\n', PositionData{1,1},...
        PositionData{1,2},PositionData{1,3},PositionData{1,4},PositionData{1,5});
    fprintf(FileID,'%6s %12.2f %12.2f %12.2f %12.2f\n', PositionData{3,1},...
        PositionData{3,2},PositionData{3,3},PositionData{3,4},PositionData{3,5});
    fprintf(FileID,'%6s %12.2f %12.2f %12.2f %12.2f\n', PositionData{4,1},...
        PositionData{4,2},PositionData{4,3},PositionData{4,4},PositionData{4,5});
    fprintf(FileID,'\n');
    fprintf(FileID,'\n');
    fprintf(FileID,'\n');
    fprintf(FileID,'%6s %12s %12s\n', ValueData{1,1},...
        ValueData{1,2},ValueData{1,3});
    fprintf(FileID,'%6s %12.2f %12.2f\n', ValueData{3,1},...
        ValueData{3,2},ValueData{3,3});
    fprintf(FileID,'%6s %12.2f %12.2f\n', ValueData{4,1},...
        ValueData{4,2},ValueData{4,3});
    fprintf(FileID,'%6s %12.2f %12.2f\n', ValueData{5,1},...
        ValueData{5,2},ValueData{5,3});
    fprintf(FileID,'%6s %12.2f %12.2f\n', ValueData{6,1},...
        ValueData{6,2},ValueData{6,3});
end
fclose(FileID);


% --- Executes on button press in ExportImage.
function ExportImage_Callback(hObject, eventdata, handles)
[file,path] = uiputfile({'*.png','Portable Network Graphics (*.png)';...
    '*.bmp','Windows BitMap (*.bmp)';...
    '*.tif','Tagged Image File Format (*.tif)';...
    '*.jpg','JPEG 2000 (*.jpg)'});
if file == 0
    return
end

axes(handles.axes1)
I = getframe(gca);
imwrite(I.cdata,strcat(path,file));

% --- Executes on button press in Clear.
function Clear_Callback(hObject, eventdata, handles)

if length(handles.Alltabs) <2
    %Temporarily disable all buttons to prevent corruption
    handles.UploadData.Enable = 'off';
    handles.UploadScan.Enable = 'off';
    handles.SurfaceApply.Enable = 'off';
    handles.Render3D.Enable = 'off';
    handles.ClusterApply.Enable = 'off';
    handles.ClusterConfirm.Enable = 'off';
    handles.ClusterUndo.Enable = 'off';
    handles.HotspotApply.Enable = 'off';
    handles.DisplayReset.Enable = 'off';
    handles.DisplayRotate.Enable = 'off';
    handles.DisplayPan.Enable = 'off';
    handles.DisplayZoom.Enable = 'off';
    handles.SurfaceOpPopup.Enable = 'off';
    handles.ClusterOpPopup.Enable = 'off';
    handles.ClusterEdit.Enable = 'off';
    handles.HotspotTotal.Enable = 'off';
    handles.HotspotSelect.Enable = 'off';
    handles.HotspotThreshold.Enable = 'off';
    handles.PixelSpacing.Enable = 'off';
    handles.DepthSlider.Enable = 'off';

    %Get a list of all fields
    allfields = fieldnames(handles);

    %All UI elements remain on the page, so don't delete their fields
    normals = {'figure1';...

        %Top row
        'UploadScan';...
        'Clear'; ...
        'UploadData';...
        'Exit';...
        'Compare';...
        'Render3D';...
        'BusyString';...

        %Top tabs
        'Tab1';...
        'Tab2';...
        'Tab3';...
        'Tab4';...
        'Tab5';...
        'Tab6';...
        'Tab7';...
        'Tab8';...
        %main axes
        'axes1';...
        
        %Measurementmodes
        'MeasurementMode';'RoamingMode';...
        
        %Measurement Values and Labels
        'PositionTable';'ValueTable';...
        
        %ClusteringPanel
        'ClusteringPanel';...
        'ClusterEdit';...
        'ClusterApply';...
        'ClusterConfirm';...
        'ClusterUndo';...
        'ClusterHelp';...
        'ClusterOp';... %prevents the user from having to reselect the options in the clusterOp and surfaceOp dropdown already if they want to use the same settings as last workflow run

        
        %SurfaceFitPanel
        'SurfaceFitPanel';...
        'ClusterOpPopup';...
        'SurfaceOpPopup';...
        'ClusterOpEdit';...
        'SurfaceHelp';...
        'SurfaceApply';...
        'SurfaceOp';...  %prevents the user from having to reselect the options in the clusterOp and surfaceOp dropdown already if they want to use the same settings as last workflow run
        
        %HotspotNavigationPanel
        'HotspotNavPanel';...
        'SensitivitySlider';...
        'HotspotThreshold';...
        'HotspotModelPanel';...
        'HotspotTotal';...
        'HotspotSelect';...
        'HotspotHelp';...
        'HotspotApply';...
        'Threshold';...

        %DisplayPanel
        'DisplayPanel';...
        'DisplayRotate';...
        'DisplayPan';...
        'DisplayZoom';...
        'PixelSpacing';...
        'PixelSpacingLabel';...
        'DepthSlider';...
        'DepthLabel';...
        'DisplayReset';...
        'DisplayHelp';...
        'DisplayCOG';...
        'DisplayPeak';...
        'DisplayRef';...
        
        %ColorMapPanel
        'ColorMapMin';...
        'ColorMapMax';...
        'ColorMapSelect';...
        'TransparencySlider';...
        'ColorMapApply';...
        'ColorMapHelp';...


        };

    %Get a list of all fields that aren't UI elements which are defined in 'normals'
    clearfields = setdiff(allfields,normals);

    %And remove all non-UI fields
    handles = rmfield(handles,clearfields');

    %Next, reset all values just like we are starting up the program for the first time

  
    handles.DisplayReference.Enable = 'off';

    %Reset measurement values so that we aren't showing measurements from previous workflows
    handles.PositionTable.Data{1,1} = '';
    handles.PositionTable.Data{1,2} = '';
    handles.PositionTable.Data{1,3} = '';
    handles.PositionTable.Data{1,4} = '';
    handles.PositionTable.Data{2,1} = '';
    handles.PositionTable.Data{2,2} = '';
    handles.PositionTable.Data{2,3} = '';
    handles.PositionTable.Data{2,4} = '';
    handles.PositionTable.Data{3,1} = '';
    handles.PositionTable.Data{3,2} = '';
    handles.PositionTable.Data{3,3} = '';
    handles.PositionTable.Data{3,4} = '';
    handles.ValueTable.Data{1,1} = '';
    handles.ValueTable.Data{2,1} = '';
    handles.ValueTable.Data{3,1} = '';
    handles.ValueTable.Data{4,1} = '';
    handles.ValueTable.Data{5,1} = '';


    % Disable all controls except UploadScanButton Clear and ExportData
    handles.UploadScan.Enable = 'on';
    handles.Clear.Enable = 'on';
    handles.ExportData.Enable = 'on';
    handles.UploadData.Enable = 'off';
    handles.Compare.Enable = 'off';
    handles.Render3D.Enable = 'off';

    % Disable Measurements Panel
    handles.MeasurementMode.Enable = 'off';
    handles.MeasurementMode.Value = 0;
    handles.RoamingMode.Enable = 'off';
    handles.RoamingMode.Value = 1;

    % Disable Display Panel
    handles.DisplayRotate.Enable = 'off';
    handles.DisplayRotate.Value = 0;
    handles.DisplayPan.Enable = 'off';
    handles.DisplayPan.Value = 0;
    handles.DisplayZoom.Enable = 'off';
    handles.DisplayZoom.Value = 0;
    handles.Zoom.Enable = false;
    handles.DisplayReference.Enable = 'off';
    handles.DisplayReference.Value = 0;
    handles.DepthSlider.Enable = 'off';
    handles.DepthSlider.Max = 1;
    handles.DepthSlider.SliderStep = [1,1];
    handles.PixelSpacing.Enable = 'off';
    handles.DisplayReset.Enable = 'off';

    % Disable Hotspot Panel
    handles.SensitivitySlider.Enable = 'off';

    handles.SensitivitySlider.Max = 1;
    handles.HotspotThreshold.Enable = 'off';
    handles.HotspotTotal.Enable = 'off';
    handles.HotspotTotal.Value = 1;
    handles.HotspotSelect.Enable = 'off';
    handles.HotspotSelect.Value = 0;
    handles.HotspotApply.Enable = 'off';

    % Disable Clustering Panel
    handles.ClusterEdit.Enable = 'off';
    handles.ClusterApply.Enable = 'off';
    handles.ClusterConfirm.Enable = 'off';
    handles.ClusterUndo.Enable = 'off';

    % Disable Surface Fitting Panel
    handles.ClusterOpPopup.Enable = 'off';
    handles.ClusterOpEdit.Enable = 'off';
    handles.SurfaceOpPopup.Enable = 'off';
    handles.SurfaceApply.Enable = 'off';

    % Pre-set some parameters for convenience
    handles.theta = 0;
    handles.xphi = 0;
    handles.yphi = 0;
    handles.k = 0;
    handles.qt = '0.05';
    handles.BinThresh = '40';
    handles.COM = [NaN, NaN, NaN];
    handles.PeakMEPPos = [NaN, NaN, NaN];
    handles.RefK = NaN;
    handles.Markers = [NaN,NaN,NaN,0;NaN,NaN,NaN,0;NaN,NaN,NaN,0];
    handles.WindowProtocol = 'Null';
    handles.WindowTracker = 'Scatterplot';
    handles.ColorMin = NaN;
    handles.ColorMax = NaN;
    handles.Colormap = 'Heat';
    handles.alpha = 0.5;
    handles.hssensitivity = 0;
    handles.Alltabs=containers.Map('KeyType','char','ValueType','any');
    handles.Tabnames={'','','','','','','',''};
    handles.CurrentTab=uint8(1);
    handles.Tab1.String='Tab1';

    handles.PIXELSPACINGABSMIN=0.0006;

    %Make the axes blank again
    scatter([],[]);
    %reset the axes to prevent ticks and borders from reappearing
    handles.axes1.XTick=[]; handles.axes1.YTick=[]; % Disable ticks
    handles.axes1.XColor='none'; handles.axes1.YColor='none'; %Hide the border 
end
if length(handles.Alltabs) > 1
    remove(handles.Alltabs,handles.Tabnames{1,handles.CurrentTab});
    for i=handles.CurrentTab:length(handles.Alltabs)
        handles.Tabnames{1,i}=handles.Tabnames{1,i+1}; %shift all the tabnames to the left
    end
    handles.Tabnames{1,length(handles.Alltabs)+1}=''; %clear out the last tabname slot
    switch(length(handles.Alltabs)) %make the last tab invisible again
    case 1
        handles.Tab2.Visible = 'off';
    case 2
        handles.Tab3.Visible = 'off';
    case 3
        handles.Tab4.Visible = 'off';
    case 4
        handles.Tab5.Visible = 'off';
    case 5
        handles.Tab6.Visible = 'off';
    case 6
        handles.Tab7.Visible = 'off';
    case 7
        handles.Tab8.Visible = 'off';
    end
    handles.Tab1.String=handles.Tabnames{1,1}; %update all the tab name strings
    handles.Tab2.String=handles.Tabnames{1,2};
    handles.Tab3.String=handles.Tabnames{1,3};
    handles.Tab4.String=handles.Tabnames{1,4};
    handles.Tab5.String=handles.Tabnames{1,5};
    handles.Tab6.String=handles.Tabnames{1,6};
    handles.Tab7.String=handles.Tabnames{1,7};
    handles.Tab8.String=handles.Tabnames{1,8};
    if handles.CurrentTab == 1
        handles=SwitchTab(hObject,handles,1);
    else
        handles=SwitchTab(hObject,handles,handles.CurrentTab-1);
    end
end

%and finally reset the guidata to reflect changes
guidata(hObject, handles);

function handles = SwitchTab(hObject, handles, newtabnum)

handles.HotspotSelect.Value = 0; % switch back to total mode so that we don't have to worry about preserving hsimgs, ect
handles.HotspotTotal.Value = 1;
handles.CurrentTab = newtabnum; % update the tab number
curtab = handles.Alltabs(handles.Tabnames{1,handles.CurrentTab}); %derefrence the tab so we can modify it
handles.Data = curtab.dataset; %unpack the tab's values into handles
handles.Cache = curtab.cache;
handles.COM = curtab.com;
handles.PeakMEPPos = curtab.peakpos;
handles.Markers = curtab.markers;
if handles.DisplayCOG.Value == 1
    handles.Markers(1,1:3) = handles.COM;
end
if handles.DisplayPeak.Value == 1
    handles.Markers(2,1:3) = handles.PeakMEPPos;
end
if handles.DisplayRef.Value == 1
    handles.Markers(3,1:3) = handles.Reference;
end

if ~isempty(curtab.clusters)
    %If the data has been clustered, also replace the clusters and cache
    handles.Clusters = handles.Alltabs(handles.Tabnames{1,handles.CurrentTab}).clusters;
    handles.WindowTracker = 'Scatterplot';
    if strcmp(handles.WindowProtocol,'HSTotal') || strcmp(handles.WindowProtocol,'HSTotal')
        handles.WindowProtocol = 'Null';
    end
    if handles.MeasurementMode.Value == 1 %make sure we recenter if we're in measurement mode
        [handles.theta,handles.xphi,handles.yphi] = recenter(handles.Data,handles.Centroid);
        [handles.imdbSlice,handles.Weights] = createSlice(handles.imdb,handles.mesh, ...
            handles.pixelspacing,handles.imlimits, ...
            handles.xphi,handles.yphi,handles.theta,handles.k);
        [handles.ImData,~] = createData(handles.Data,handles.Centroid, ...
            handles.imlimits,handles.pixelspacing, ...
            handles.theta,handles.xphi,handles.yphi);
        [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
            handles.imlimits,handles.pixelspacing, ...
            handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
        createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,handles.ImData,Markers);
    else %if we're in roaming mode, just go ahead and plot the data without recentering
        [handles.ImData,handles.MEPelip,~,~] = createData(handles.Data,handles.Centroid, ...
        handles.imlimits,handles.pixelspacing, ...
        handles.theta,handles.xphi,handles.yphi);
        [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
        handles.imlimits,handles.pixelspacing, ...
        handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
        createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,handles.ImData,Markers);
    end
else %if we haven't clustered yet
    handles.WindowTracker = 'Scatterplot';
    if strcmp(handles.WindowProtocol,'HSTotal') || strcmp(handles.WindowProtocol,'HSTotal')
        handles.WindowProtocol = 'Null';
    end 
    if handles.MeasurementMode.Value == 1 %again, make sure we recenter before we let the user have access to measurements
        [handles.theta,handles.xphi,handles.yphi] = recenter(handles.Data,handles.Centroid);
        [handles.imdbSlice,handles.Weights] = createSlice(handles.imdb,handles.mesh, ...
            handles.pixelspacing,handles.imlimits, ...
            handles.xphi,handles.yphi,handles.theta,handles.k);
        [handles.ImData,~] = createData(handles.Data,handles.Centroid, ...
            handles.imlimits,handles.pixelspacing, ...
            handles.theta,handles.xphi,handles.yphi);
        [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
            handles.imlimits,handles.pixelspacing, ...
            handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
        createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,handles.ImData,Markers);
    else %otherwise go ahead and plot it without recentering
        [handles.ImData,handles.MEPelip,~,~] = createData(handles.Data,handles.Centroid, ...
            handles.imlimits,handles.pixelspacing, ...
            handles.theta,handles.xphi,handles.yphi);

        [Markers,~,~,~] = createData(handles.Markers,handles.Centroid, ...
        handles.imlimits,handles.pixelspacing, ...
        handles.theta,handles.xphi,handles.yphi,'Skip'); Markers = Markers(:,1:2);
    end
end

handles.Tab1.Value = false;
handles.Tab2.Value = false;
handles.Tab3.Value = false;
handles.Tab4.Value = false;
handles.Tab5.Value = false;
handles.Tab6.Value = false;
handles.Tab7.Value = false;
handles.Tab8.Value = false;

% 'Push in' the new tab
switch newtabnum
case 1
    handles.Tab1.Value = true;
    handles.Tab1.Visible = 'on';
    handles.Tab1.String=handles.Tabnames{1,1};
case 2
    handles.Tab2.Value = true;
    handles.Tab2.Visible = 'on';
    handles.Tab2.String=handles.Tabnames{1,2};
case 3
    handles.Tab3.Value = true;
    handles.Tab3.Visible = 'on';
    handles.Tab3.String=handles.Tabnames{1,3};
case 4
    handles.Tab4.Value = true;
    handles.Tab4.Visible = 'on';
    handles.Tab4.String=handles.Tabnames{1,4};
case 5 
    handles.Tab5.Value = true;
    handles.Tab5.Visible = 'on';
    handles.Tab5.String=handles.Tabnames{1,5};
case 6
    handles.Tab6.Value = true;
    handles.Tab6.Visible = 'on';
    handles.Tab6.String=handles.Tabnames{1,6};
case 7
    handles.Tab7.Value = true;
    handles.Tab7.Visible = 'on';
    handles.Tab7.String=handles.Tabnames{1,7};
case 8
    handles.Tab8.Value = true;
    handles.Tab8.Visible = 'on';
    handles.Tab8.String=handles.Tabnames{1,8};
end
drawnow;

%if handles.MeasurementMode.Value == 1
%    [handles.theta,handles.xphi,handles.yphi] = recenter(handles.Data,handles.Centroid); 
%end
%%Update the display

%if ~isempty(curtab.surfmap)
%    createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,cat(3,handles.MEPmap,handles.MEPmask),handles.ImData,Markers);
%else
createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.imdbSlice,handles.ImData,Markers);
%end


switch curtab.status %figure out the state we left the data points in, and make sure the window is in the corresponding state with buttons
    case 'uploaded'
        handles.ClusterUndo.Enable = 'off';
        handles.ClusterEdit.Enable = 'on';
        handles.ClusterConfirm.Enable = 'off';
        handles.ClusterApply.Enable = 'on';
        handles.SurfaceOpPopup.Enable = 'off';
        handles.ClusterOpPopup.Enable = 'off';
        handles.ClusterOpEdit.Enable = 'off';
        handles.SurfaceApply.Enable = 'off';
        handles.ColorMapMin.Enable = 'on';
        handles.ColorMapMax.Enable = 'on';
        handles.ColorMapSelect.Enable = 'on';
        handles.ColorMapApply.Enable = 'on';
        handles.HotspotTotal.Enable = 'off';
        handles.HotspotSelect.Enable = 'off';
        handles.HotspotThreshold.Enable = 'off';
        handles.SensitivitySlider.Enable = 'off';
        handles.HotspotApply.Enable = 'off';
        handles.Compare.Enable = 'off';
    case 'clustered'
        handles.ClusterUndo.Enable = 'on';
        handles.ClusterEdit.Enable = 'off';
        handles.ClusterConfirm.Enable = 'off';
        handles.ClusterApply.Enable = 'off';
        handles.SurfaceOpPopup.Enable = 'on';
        handles.ClusterOpPopup.Enable = 'on';
        handles.ClusterOpEdit.Enable = 'off'; %refine this to check if clusterop is binthresh
        handles.SurfaceApply.Enable = 'on';
        handles.ColorMapMin.Enable = 'on';
        handles.ColorMapMax.Enable = 'on';
        handles.ColorMapSelect.Enable = 'on';
        handles.ColorMapApply.Enable = 'on';
        handles.HotspotTotal.Enable = 'off';
        handles.HotspotSelect.Enable = 'off';
        handles.HotspotThreshold.Enable = 'off';
        handles.SensitivitySlider.Enable = 'off';
        handles.HotspotApply.Enable = 'off';
        handles.Compare.Enable = 'off';
%    case 'fitted'
%        handles.ClusterUndo.Enable = 'on';
%        handles.ClusterConfirm.Enable = 'off';
%        handles.ClusterApply.Enable = 'off';
%        handles.SurfaceOpPopup.Enable = 'on';
%        handles.ClusterOpPopup.Enable = 'on';
%        handles.ClusterOpEdit.Enable = 'off'; %refine this to check if clusterop is binthresh
%        handles.SurfaceApply.Enable = 'on';
%        handles.ColorMapMin.Enable = 'on';
%        handles.ColorMapMax.Enable = 'on';
%        handles.ColorMapSelect.Enable = 'on';
%        handles.ColorMapApply.Enable = 'on';
%        handles.HotspotTotal.Enable = 'on';
%        handles.HotspotSelect.Enable = 'on';
%        handles.HotspotThreshold.Enable = 'on';
%        handles.SensitivitySlider.Enable = 'off'; %fix this once added in. issue #14
%        handles.HotspotApply.Enable = 'on';
%        handles.Compare.Enable = 'on';
end

%if length(Alltabs) >= 0 
%    handles.Tab1.Enable='on';
%end
%if length(Alltabs) >= 2
%    handles.Tab2.Enable='on';
%end
%if length(Alltabs) >= 3
%    handles.Tab3.Enable='on';
%end
%if length(Alltabs) >= 4
%    handles.Tab4.Enable='on';
%end
%if length(Alltabs) >= 5
%    handles.Tab5.Enable='on';
%end
%if length(Alltabs) >= 6
%    handles.Tab6.Enable='on';
%end
%if length(Alltabs) >= 7
%    handles.Tab7.Enable='on';
%end
%if length(Alltabs) >= 8
%    handles.Tab8.Enable='on';
%if length(Alltabs) > 8
%    warning('More than 8 tabs. Something is wrong!')
%end
%if ~(length(Alltabs) >=8)
%    handles.UploadData.Enable = 'on';
%end
%handles.ExportData.Enable='on';

handles.PositionTable.Data{1,1} = NaN; %reset the table values 
handles.PositionTable.Data{1,2} = NaN;
handles.PositionTable.Data{1,3} = NaN;
handles.PositionTable.Data{1,4} = NaN;
handles.PositionTable.Data{2,1} = NaN;
handles.PositionTable.Data{2,2} = NaN;
handles.PositionTable.Data{2,3} = NaN;
handles.PositionTable.Data{2,4} = NaN;
handles.PositionTable.Data{3,1} = NaN;
handles.PositionTable.Data{3,2} = NaN;
handles.PositionTable.Data{3,3} = NaN;
handles.PositionTable.Data{3,4} = NaN;
handles.ValueTable.Data{1,1} = NaN;
handles.ValueTable.Data{2,1} = NaN;
handles.ValueTable.Data{3,1} = NaN;
handles.ValueTable.Data{4,1} = NaN;
handles.ValueTable.Data{5,1} = NaN;


function handles=DisableAll(handles) %not in use yet; will be for fool-proofing different fcns
    %disable tabs
    handles.Tab1.Enable = 'off';
    handles.Tab2.Enable = 'off';
    handles.Tab3.Enable = 'off';
    handles.Tab4.Enable = 'off';
    handles.Tab5.Enable = 'off';
    handles.Tab6.Enable = 'off';
    handles.Tab7.Enable = 'off';
    handles.Tab8.Enable = 'off';
    %disable all top row
    handles.UploadData.Enable = 'off';
    handles.UploadScan.Enable = 'off';
    handles.Compare.Enable = 'off';
    handles.Render3D.Enable = 'off';
    handles.ExportData.Enable = 'off';
    handles.ExportImage.Enable = 'off';
    handles.MeasurementMode.Enable = 'off';
    handles.RoamingMode.Enable = 'off';
    handles.DisplayCOG.Callback = @(hObject,eventdata)HeadNavUI('DisplayCOG_Callback',hObject,eventdata,guidata(hObject));
    handles.DisplayPeak.Callback = @(hObject,eventdata)HeadNavUI('DisplayPeak_Callback',hObject,eventdata,guidata(hObject));
    handles.DisplayRef.Callback = @(hObject,eventdata)HeadNavUI('DisplayRef_Callback',hObject,eventdata,guidata(hObject));
    handles.DisplayCOG.Enable = 'off';
    handles.DisplayPeak.Enable = 'off';
    handles.DisplayRef.Enable = 'off';
    %Disable Color Map Panel
    handles.ColorMapMin.Enable = 'off';
    handles.ColorMapMax.Enable = 'off';
    handles.ColorMapSelect.Enable = 'off';
    handles.ColorMapApply.Enable = 'off';
    handles.TransparencySlider.Enable = 'off';
    % Disable Display Panel
    handles.DisplayRotate.Enable = 'off';
    handles.DisplayPan.Enable = 'off';
    handles.DisplayZoom.Enable = 'off';
    handles.Zoom.Enable = 'off';
    handles.DisplayReference.Enable = 'off';
    % Disable Hotspot Panel
    handles.SensitivitySlider.Enable = 'off';
    handles.HotspotThreshold.Enable = 'off';
    handles.HotspotTotal.Enable = 'off';
    handles.HotspotTotal.Value = 1;
    handles.HotspotTotal.Callback = @(hObject,eventdata)HeadNavUI('HotspotTotal_Callback',hObject,eventdata,guidata(hObject));
    handles.HotspotSelect.Enable = 'off';
    handles.HotspotSelect.Value = 0;
    handles.HotspotSelect.Callback = @(hObject,eventdata)HeadNavUI('HotspotSelect_Callback',hObject,eventdata,guidata(hObject));
    handles.HotspotApply.Enable = 'off';
    % Disable Clustering Panel
    handles.ClusterEdit.Enable = 'off';
    handles.ClusterApply.Enable = 'off';
    handles.ClusterConfirm.Enable = 'off';
    handles.ClusterUndo.Enable = 'off';
    % Disable Surface Fitting Panel
    handles.ClusterOpPopup.Enable = 'off';
    handles.ClusterOpEdit.Enable = 'off';
    handles.SurfaceOpPopup.Enable = 'off';
    handles.SurfaceApply.Enable = 'off';




% --- Executes on button press in Tab1.
function Tab1_Callback(hObject, eventdata, handles)
if get(hObject,'Value') == 1
    handles=SwitchTab(hObject,handles,1);
else
    handles.Tab1.Value = true;
end

guidata(hObject, handles);

% --- Executes on button press in Tab2.
function Tab2_Callback(hObject, eventdata, handles)
    if get(hObject,'Value') == 1
        handles=SwitchTab(hObject,handles,2);
    else
        handles.Tab2.Value = true;
    end
    
    guidata(hObject, handles);

% --- Executes on button press in Tab3.
function Tab3_Callback(hObject, eventdata, handles)
if get(hObject,'Value') == 1
    handles=SwitchTab(hObject,handles,3);
else
    handles.Tab3.Value = true;
end

guidata(hObject, handles);
% --- Executes on button press in Tab4.
function Tab4_Callback(hObject, eventdata, handles)
if get(hObject,'Value') == 1
    handles=SwitchTab(hObject,handles,4);
else
    handles.Tab4.Value = true;
end

guidata(hObject, handles);
% --- Executes on button press in Tab5.
function Tab5_Callback(hObject, eventdata, handles)
if get(hObject,'Value') == 1
    handles=SwitchTab(hObject,handles,5);
else
    handles.Tab5.Value = true;
end

guidata(hObject, handles);
% --- Executes on button press in Tab6.
function Tab6_Callback(hObject, eventdata, handles)
if get(hObject,'Value') == 1
    handles=SwitchTab(hObject,handles,6);
else
    handles.Tab6.Value = true;
end

guidata(hObject, handles);
% --- Executes on button press in Tab7.
function Tab7_Callback(hObject, eventdata, handles)
if get(hObject,'Value') == 1
    handles=SwitchTab(hObject,handles,7);
else
    handles.Tab7.Value = true;
end

guidata(hObject, handles);
% --- Executes on button press in Tab8.
function Tab8_Callback(hObject, eventdata, handles)
if get(hObject,'Value') == 1
    handles=SwitchTab(hObject,handles,8);
else
    handles.Tab8.Value = true;
end

guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function HotspotThreshold_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function SensitivitySlider_CreateFcn(hObject, eventdata, handles)
    

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function PixelSpacing_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function DepthSlider_CreateFcn(hObject, eventdata, handles)

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function ClusterOpEdit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function SurfaceOpPopup_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function ClusterOpPopup_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function ClusterEdit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function ColorMapMin_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function ColorMapMax_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function ColorMapSelect_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function TransparencySlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function figure1_KeyReleaseFcn(hObject, eventdata, handles)

function figure1_KeyPressFcn(hObject, eventdata, handles)

function figure1_WindowKeyReleaseFcn(hObject, eventdata, handles)

function figure1_WindowKeyPressFcn(hObject, eventdata, handles)

% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% anwser = questdlg('All work will be lost. Confirm exit.', ...
%     'Exit Workspace','Yes','No','No');
% switch anwser
%     case 'Yes'
%     case 'No'
%         HeadNavUI(handles)
% end


% --- Executes during object creation, after setting all properties.
function PositionTable_CreateFcn(hObject, eventdata, handles)
set(hObject,'Data',cell(3,4));
set(hObject,'RowName',{'Ref->Cursor','Ref->COG','Ref->Peak'});
set(hObject,'ColumnName',{'Post->Ant','Right->Left','Inf->Sup','Distance'})
set(hObject,'ColumnWidth',{71,71,71,71})
