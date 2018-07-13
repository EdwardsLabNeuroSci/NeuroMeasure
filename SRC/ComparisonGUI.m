function varargout = ComparisonGUI(varargin)
% COMPARISONGUI MATLAB code for ComparisonGUI.fig
%      COMPARISONGUI, by itself, creates a new COMPARISONGUI or raises the existing
%      singleton*.
%
%      H = COMPARISONGUI returns the handle to a new COMPARISONGUI or the handle to
%      the existing singleton*.
%
%      COMPARISONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COMPARISONGUI.M with the given input arguments.
%
%      COMPARISONGUI('Property','Value',...) creates a new COMPARISONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ComparisonGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ComparisonGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ComparisonGUI

% Last Modified by GUIDE v2.5 26-Apr-2018 15:49:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ComparisonGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ComparisonGUI_OutputFcn, ...
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


% --- Executes just before ComparisonGUI is made visible.
function ComparisonGUI_OpeningFcn(hObject, eventdata, handles, varargin)
handles.Back.Enable = 'off';

%Set dataset labels
handles.TrainingLabel.String = varargin{1,2};
handles.TestingLabel.String = varargin{1,3};

%Parse varargin
handles.parenthandles = varargin{1,1};
handles.TrainingSet = struct(handles.parenthandles.Alltabs(varargin{1,2}));
handles.TestingSet = struct(handles.parenthandles.Alltabs(varargin{1,3}));

%Center both training and testing sets to the image plane
[handles.TrainingSet.theta,handles.TrainingSet.xphi,handles.TrainingSet.yphi] = recenter(handles.TrainingSet.dataset,handles.parenthandles.Centroid);
[handles.TestingSet.theta,handles.TestingSet.xphi,handles.TestingSet.yphi] = recenter(handles.TestingSet.dataset,handles.parenthandles.Centroid);

%Cluster the two datasets with specified operation
if ~strcmp(handles.parenthandles.ClusterOp,'probability')
    TrainingData = clusterop(handles.TrainingSet.clusters,handles.parenthandles.ClusterOp,1);
    TestingData = clusterop(handles.TestingSet.clusters,handles.parenthandles.ClusterOp,1);
else
    TrainingData = clusterop(handles.TrainingSet.clusters,handles.parenthandles.ClusterOp,str2double(handles.parenthandles.BinThresh));
    TestingData = clusterop(handles.TestingSet.clusters,handles.parenthandles.ClusterOp,str2double(handles.parenthandles.BinThresh));
end

%Fit the datasets to their own elipsoids using their previously computed rotation parameters
[handles.TrainingSet.ImData,handles.TrainingSet.Elip,trU,trV] = createData(TrainingData,handles.parenthandles.Centroid,...
    handles.parenthandles.imlimits,handles.parenthandles.pixelspacing,...
    handles.TrainingSet.theta,handles.TrainingSet.xphi,handles.TrainingSet.yphi);
[handles.TestingSet.ImData,handles.TestingSet.Elip,teU,teV] = createData(TestingData,handles.parenthandles.Centroid,...
    handles.parenthandles.imlimits,handles.parenthandles.pixelspacing,...
    handles.TestingSet.theta,handles.TestingSet.xphi,handles.TestingSet.yphi);

%Reslice the imdb for both sets
[handles.TrainingSet.imdbSlice,handles.TrainingSet.Weights] = createSlice(handles.parenthandles.imdb,...
    handles.parenthandles.mesh,handles.parenthandles.pixelspacing,handles.parenthandles.imlimits,...
    handles.TrainingSet.xphi,handles.TrainingSet.yphi,handles.TrainingSet.theta,handles.parenthandles.k);
[handles.TestingSet.imdbSlice,handles.TestingSet.Weights] = createSlice(handles.parenthandles.imdb,...
    handles.parenthandles.mesh,handles.parenthandles.pixelspacing,handles.parenthandles.imlimits,...
    handles.TestingSet.xphi,handles.TestingSet.yphi,handles.TestingSet.theta,handles.parenthandles.k);

%Fit the 2D data to a surface using the specified algorithm
[handles.TrainingSet.Fit,handles.TrainingSet.Map,handles.TrainingSet.Mask] = surfaceop([trU,trV,TrainingData(:,4)],...
    handles.parenthandles.pixelspacing,handles.parenthandles.imlimits,...
    handles.parenthandles.SurfaceOp,handles.parenthandles.Threshold);
[handles.TestingSet.Fit,handles.TestingSet.Map,handles.TestingSet.Mask] = surfaceop([teU,teV,TestingData(:,4)],...
    handles.parenthandles.pixelspacing,handles.parenthandles.imlimits,...
    handles.parenthandles.SurfaceOp,handles.parenthandles.Threshold);

if ~strcmp(handles.parenthandles.ClusterOp,'probability')
    %Compute measurements and display them at their corresponding labels
    handles.Reference.String = handles.parenthandles.RefString.String;
    handles.CursorPosition.String = 'NaN';
    handles.CursorValue.String = 'NaN';

    TrainingCOG = centerofmass(TrainingData); 
    TrainingCOGdist = norm((TrainingCOG - handles.parenthandles.Reference).*handles.parenthandles.ScanResolution);
    TrainingCOG2Ref = (TrainingCOG - handles.parenthandles.Reference).*handles.parenthandles.ScanResolution;
    handles.PositionTable.Data{1,1} = TrainingCOG2Ref(1);
    handles.PositionTable.Data{1,2} = TrainingCOG2Ref(2);
    handles.PositionTable.Data{1,3} = TrainingCOG2Ref(3);
    handles.PositionTable.Data{1,4} = TrainingCOGdist;

    TestingCOG = centerofmass(TestingData); 
    TestingCOGdist = norm((TestingCOG - handles.parenthandles.Reference).*handles.parenthandles.ScanResolution);
    TestingCOG2Ref = (TestingCOG - handles.parenthandles.Reference).*handles.parenthandles.ScanResolution;
    handles.PositionTable.Data{2,1} = TestingCOG2Ref(1);
    handles.PositionTable.Data{2,2} = TestingCOG2Ref(2);
    handles.PositionTable.Data{2,3} = TestingCOG2Ref(3);
    handles.PositionTable.Data{2,4} = TestingCOGdist;

    COGDif = (TrainingCOG - TestingCOG).*handles.parenthandles.ScanResolution;
    COGDist = norm(COGDif);
    handles.PositionTable.Data{3,1} = COGDif(1);
    handles.PositionTable.Data{3,2} = COGDif(2);
    handles.PositionTable.Data{3,3} = COGDif(3);
    handles.PositionTable.Data{3,4} = COGDist;

    TrainingPeakVal = max(max(handles.TrainingSet.Map));
    [TrainingPeakPos(2),TrainingPeakPos(1)] = find(handles.TrainingSet.Map == TrainingPeakVal);
    handles.TrainingSet.Peak = TrainingPeakPos;
    TrainingPeakPos(1) = (TrainingPeakPos(1) * handles.parenthandles.pixelspacing) + handles.parenthandles.imlimits(1);
    TrainingPeakPos(2) = (TrainingPeakPos(2) * handles.parenthandles.pixelspacing) + handles.parenthandles.imlimits(3);
    TrainingPeakPos = handles.TrainingSet.Elip(TrainingPeakPos(1),TrainingPeakPos(2));
    TrainingPeakPos = transmatTHETA(TrainingPeakPos,-handles.TrainingSet.theta);
    TrainingPeakPos = transmatPHI(TrainingPeakPos,-handles.TrainingSet.xphi,-handles.TrainingSet.yphi,'inverse');
    TrainingPeakPos = TrainingPeakPos + handles.parenthandles.Centroid;
    TrainingPeakDist = norm((TrainingPeakPos - handles.parenthandles.Reference).*handles.parenthandles.ScanResolution);
    TrainingPeakPos2Ref = (TrainingPeakPos - handles.parenthandles.Reference).*handles.parenthandles.ScanResolution;
    handles.PositionTable.Data{4,1} = TrainingPeakPos2Ref(1);
    handles.PositionTable.Data{4,2} = TrainingPeakPos2Ref(2);
    handles.PositionTable.Data{4,3} = TrainingPeakPos2Ref(3);
    handles.PositionTable.Data{4,4} = TrainingPeakDist;

    TestingPeakVal = max(max(handles.TestingSet.Map));
    [TestingPeakPos(2),TestingPeakPos(1)] = find(handles.TestingSet.Map == TestingPeakVal);
    handles.TestingSet.Peak = TestingPeakPos;
    TestingPeakPos(1) = (TestingPeakPos(1) * handles.parenthandles.pixelspacing) + handles.parenthandles.imlimits(1);
    TestingPeakPos(2) = (TestingPeakPos(2) * handles.parenthandles.pixelspacing) + handles.parenthandles.imlimits(3);
    TestingPeakPos = handles.TestingSet.Elip(TestingPeakPos(1),TestingPeakPos(2));
    TestingPeakPos = transmatTHETA(TestingPeakPos,-handles.TestingSet.theta);
    TestingPeakPos = transmatPHI(TestingPeakPos,-handles.TestingSet.xphi,-handles.TestingSet.yphi,'inverse');
    TestingPeakPos = TestingPeakPos + handles.parenthandles.Centroid;
    TestingPeakDist = norm((TestingPeakPos - handles.parenthandles.Reference).*handles.parenthandles.ScanResolution);
    TestingPeakPos2Ref = (TestingPeakPos - handles.parenthandles.Reference).*handles.parenthandles.ScanResolution;
    handles.PositionTable.Data{5,1} = TestingPeakPos2Ref(1);
    handles.PositionTable.Data{5,2} = TestingPeakPos2Ref(2);
    handles.PositionTable.Data{5,3} = TestingPeakPos2Ref(3);
    handles.PositionTable.Data{5,4} = TestingPeakDist;

    Peak2PeakDif = (TrainingPeakPos - TestingPeakPos).*handles.parenthandles.ScanResolution;
    Peak2PeakDist = norm(Peak2PeakDif);
    handles.PositionTable.Data{6,1} = Peak2PeakDif(1);
    handles.PositionTable.Data{6,2} = Peak2PeakDif(2);
    handles.PositionTable.Data{6,3} = Peak2PeakDif(3);
    handles.PositionTable.Data{6,4} = Peak2PeakDist;

    [~,~,u,v] = createData([TrainingCOG,0],handles.parenthandles.Centroid,...
        handles.parenthandles.imlimits,handles.parenthandles.pixelspacing,...
        handles.TrainingSet.theta,handles.TrainingSet.xphi,handles.TrainingSet.yphi,'Skip');
    TrainingCOMVal = handles.TrainingSet.Fit(u,v);
    handles.TrainingSet.COG(1) = (u - handles.parenthandles.imlimits(1))/handles.parenthandles.pixelspacing;
    handles.TrainingSet.COG(2) = (v - handles.parenthandles.imlimits(3))/handles.parenthandles.pixelspacing;
    handles.ValueTable.Data{1,1} = TrainingCOMVal;

    [~,~,u,v] = createData([TestingCOG,0],handles.parenthandles.Centroid,...
        handles.parenthandles.imlimits,handles.parenthandles.pixelspacing,...
        handles.TestingSet.theta,handles.TestingSet.xphi,handles.TestingSet.yphi,'Skip');
    TestingCOMVal = handles.TestingSet.Fit(u,v);
    handles.TestingSet.COG(1) = (u - handles.parenthandles.imlimits(1))/handles.parenthandles.pixelspacing;
    handles.TestingSet.COG(2) = (v - handles.parenthandles.imlimits(3))/handles.parenthandles.pixelspacing;
    handles.ValueTable.Data{1,2} = TestingCOMVal;

    handles.ValueTable.Data{1,3} = TrainingCOMVal - TestingCOMVal;

    handles.ValueTable.Data{2,1} = TrainingPeakVal;
    handles.ValueTable.Data{2,2} = TestingPeakVal;
    handles.ValueTable.Data{2,3} = abs(TrainingPeakVal - TestingPeakVal);

    [TrainingSA,TrainingVI] = surfacearea(cat(3,handles.TrainingSet.Map,handles.TrainingSet.Map > handles.parenthandles.Threshold),handles.TrainingSet.Elip,...
        handles.parenthandles.pixelspacing,handles.parenthandles.imlimits,handles.parenthandles.ScanResolution);
    handles.ValueTable.Data{3,1} = TrainingSA;
    handles.ValueTable.Data{4,1} = TrainingVI;

    [TestingSA,TestingVI] = surfacearea(cat(3,handles.TestingSet.Map,handles.TestingSet.Map > handles.parenthandles.Threshold),handles.TestingSet.Elip,...
        handles.parenthandles.pixelspacing,handles.parenthandles.imlimits,handles.parenthandles.ScanResolution);
    handles.ValueTable.Data{3,2} = TestingSA;
    handles.ValueTable.Data{4,2} = TestingVI;
    handles.ValueTable.Data{3,3} = abs(TrainingSA - TestingSA);
    handles.ValueTable.Data{4,3} = abs(TrainingVI - TestingVI);
    
    [~,~,teU,teV] = createData(handles.TestingSet.cache,handles.parenthandles.Centroid,...
        handles.parenthandles.imlimits,handles.parenthandles.pixelspacing,...
        handles.TrainingSet.theta,handles.TrainingSet.xphi,handles.TrainingSet.yphi);
    Observed = handles.TrainingSet.Fit(teU,teV);
    Observed(isnan(Observed)) = 0;
    GroundTruth = handles.TestingSet.cache(:,4);
    RMSE = sqrt(mean((Observed - GroundTruth).^2));
    handles.RMSE.String = sprintf('%0.3f',RMSE);
else
    [~,~,teU,teV] = createData(handles.TestingSet.cache,handles.parenthandles.Centroid,...
        handles.parenthandles.imlimits,handles.parenthandles.pixelspacing,...
        handles.TrainingSet.theta,handles.TrainingSet.xphi,handles.TrainingSet.yphi);
    Observed = handles.TrainingSet.Fit(teU,teV);
    Observed(isnan(Observed)) = 0;
    Observed(Observed < 0) = 0;
    Observed(Observed > 100) = 100;
    GroundTruth = handles.TestingSet.cache(:,4);
    
    thresh = linspace(0,101,100);
    gr = GroundTruth > str2double(handles.parenthandles.BinThresh);
    handles.DetRate = zeros(1,size(thresh,2));
    handles.FalPosRate = zeros(1,size(thresh,2));
    for i = 1:100
        pr = Observed >= thresh(i);
        handles.DetRate(i) = size(intersect(find(pr == 1),find(gr == 1)),1)/size(find(gr == 1),1);
        handles.FalPosRate(i) = 1 - size(intersect(find(pr == 0),find(gr == 0)),1)/size(find(gr == 0),1);
    end
    AUC = -trapz(handles.FalPosRate,handles.DetRate);
    handles.CompLabel.String = 'AUC:';
    handles.RMSE.String = AUC;
    
    handles.DisplayCOG.Enable = 'off';
    handles.DisplayPeak.Enable = 'off';
    handles.DisplayRef.Enable = 'off';
    handles.ReferenceLabel.Visible = 'off';
    handles.Reference.Visible = 'off';
    handles.PositionsLabel.Visible = 'off';
    handles.PositionTable.Visible = 'off';
    handles.ValuesLabel.Visible = 'off';
    handles.ValueTable.Visible = 'off';
    handles.CursorPosition.String = 'NaN';
    handles.CursorValue.String = 'NaN';
    handles.axes4.Visible = 'on';
    axes(handles.axes4);
    plot(handles.FalPosRate,handles.DetRate); ylabel('Detection Rate'); xlabel('False Positive Rate'); title('ROC Curve'); xlim([0,1]); ylim([0,1]);
end

%Generate difference map by merging both datasets
handles.DifMap.dataset = cat(1,handles.TrainingSet.dataset,handles.TestingSet.dataset);
[handles.DifMap.theta,handles.DifMap.xphi,handles.DifMap.yphi] = recenter(handles.DifMap.dataset,handles.parenthandles.Centroid);
[~,~,u,v] = createData(handles.DifMap.dataset,handles.parenthandles.Centroid,...
    handles.parenthandles.imlimits,handles.parenthandles.pixelspacing,...
    handles.DifMap.theta,handles.DifMap.xphi,handles.DifMap.yphi);
handles.DifMap.imlimits = [min(u)-std(u),max(u)+std(u),min(v)-std(v),max(v)+std(v)];

if handles.parenthandles.imlimits(1) < handles.DifMap.imlimits(1)
    handles.DifMap.imlimits(1) = handles.parenthandles.imlimits(1);
elseif handles.parenthandles.imlimits(2) > handles.DifMap.imlimits(2)
    handles.DifMap.imlimits(2) = handles.parenthandles.imlimits(2);
elseif handles.parenthandles.imlimits(3) < handles.DifMap.imlimits(3)
    handles.DifMap.imlimits(3) = handles.parenthandles.imlimits(3);
elseif handles.parenthandles.imlimits(4) > handles.DifMap.imlimits(4)
    handles.DifMap.imlimits(4) = handles.parenthandles.imlimits(4);
end

[handles.DifMap.imdbSlice,handles.DifMap.Weights] = createSlice(handles.parenthandles.imdb,handles.parenthandles.mesh,...
    handles.parenthandles.pixelspacing,handles.DifMap.imlimits,...
    handles.DifMap.xphi,handles.DifMap.yphi,handles.DifMap.theta,handles.parenthandles.k);
[~,~,trU,trV] = createData(TrainingData,handles.parenthandles.Centroid,...
    handles.DifMap.imlimits,handles.parenthandles.pixelspacing,...
    handles.DifMap.theta,handles.DifMap.xphi,handles.DifMap.yphi);
[~,~,teU,teV] = createData(TestingData,handles.parenthandles.Centroid,...
    handles.DifMap.imlimits,handles.parenthandles.pixelspacing,...
    handles.DifMap.theta,handles.DifMap.xphi,handles.DifMap.yphi);
[~,handles.DifMap.TrainingMap,~] = surfaceop([trU,trV,TrainingData(:,4)],...
    handles.parenthandles.pixelspacing,handles.DifMap.imlimits,...
    handles.parenthandles.SurfaceOp,handles.parenthandles.Threshold);
[~,handles.DifMap.TestingMap,~] = surfaceop([teU,teV,TestingData(:,4)],...
    handles.parenthandles.pixelspacing,handles.DifMap.imlimits,...
    handles.parenthandles.SurfaceOp,handles.parenthandles.Threshold);
handles.DifMap.Map = handles.DifMap.TestingMap - handles.DifMap.TrainingMap;
handles.DifMap.Mask = ones(size(handles.DifMap.Map,1),size(handles.DifMap.Map,2));

if ~strcmp(handles.parenthandles.ClusterOp,'probability')
    %Store marker locations for DifMap
    [handles.DifMap.TrainingCOG,~,~,~] = createData([TrainingCOG,0],handles.parenthandles.Centroid,...
        handles.DifMap.imlimits,handles.parenthandles.pixelspacing,...
        handles.DifMap.theta,handles.DifMap.xphi,handles.DifMap.yphi,'Skip');
    [handles.DifMap.TestingCOG,~,~,~] = createData([TestingCOG,0],handles.parenthandles.Centroid,...
        handles.DifMap.imlimits,handles.parenthandles.pixelspacing,...
        handles.DifMap.theta,handles.DifMap.xphi,handles.DifMap.yphi,'Skip');
    [handles.DifMap.TrainingPeak,~,~,~] = createData([TrainingPeakPos,0],handles.parenthandles.Centroid,...
        handles.DifMap.imlimits,handles.parenthandles.pixelspacing,...
        handles.DifMap.theta,handles.DifMap.xphi,handles.DifMap.yphi,'Skip');
    [handles.DifMap.TestingPeak,~,~,~] = createData([TestingPeakPos,0],handles.parenthandles.Centroid,...
        handles.DifMap.imlimits,handles.parenthandles.pixelspacing,...
        handles.DifMap.theta,handles.DifMap.xphi,handles.DifMap.yphi,'Skip');

    %Store Reference marker locations for all three maps
    [handles.DifMap.Reference,~,~,~] = createData([handles.parenthandles.Reference,0],handles.parenthandles.Centroid,...
        handles.DifMap.imlimits,handles.parenthandles.pixelspacing,...
        handles.DifMap.theta,handles.DifMap.xphi,handles.DifMap.yphi,'Skip');
    [handles.TrainingSet.Reference,~,~,~] = createData([handles.parenthandles.Reference,0],handles.parenthandles.Centroid,...
        handles.parenthandles.imlimits,handles.parenthandles.pixelspacing,...
        handles.TrainingSet.theta,handles.TrainingSet.xphi,handles.TrainingSet.yphi,'Skip');
    [handles.TestingSet.Reference,~,~,~] = createData([handles.parenthandles.Reference,0],handles.parenthandles.Centroid,...
        handles.parenthandles.imlimits,handles.parenthandles.pixelspacing,...
        handles.parenthandles.theta,handles.parenthandles.xphi,handles.parenthandles.yphi,'Skip');
end

%Set parameters for graphics
handles.TrainingMarkers = [NaN,NaN;NaN,NaN;NaN,NaN];
handles.TestingMarkers = [NaN,NaN;NaN,NaN;NaN,NaN];
handles.DifMarkers = [NaN,NaN;NaN,NaN;NaN,NaN;NaN,NaN;NaN,NaN];
handles.alpha = handles.parenthandles.alpha;
handles.TransparencySlider.Value = handles.alpha;
handles.ColorMin = min(min(min(handles.TrainingSet.Map)),min(min(handles.TestingSet.Map)));
handles.ColorMapMin.String = num2str(handles.ColorMin);
handles.ColorMax = max(max(max(handles.TrainingSet.Map)),max(max(handles.TestingSet.Map)));
handles.ColorMapMax.String = num2str(handles.ColorMax);
handles.Colormap = handles.parenthandles.Colormap;

handles.TrainingSet.Mask = (handles.TrainingSet.Mask ~= 0) * handles.alpha;
handles.TestingSet.Mask = (handles.TestingSet.Mask ~= 0) * handles.alpha;
handles.DifMap.Mask = handles.DifMap.Mask * handles.alpha;
handles.DifLimits = max(abs(min(min(handles.DifMap.Map))),abs(max(max(handles.DifMap.Map))));
drawnow;

%Show Graphics
axes(handles.axes1);
createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.TrainingSet.imdbSlice,...
    cat(3,handles.TrainingSet.Map,handles.TrainingSet.Mask),handles.TrainingSet.ImData);
axes(handles.axes2);
createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.TestingSet.imdbSlice,...
    cat(3,handles.TestingSet.Map,handles.TestingSet.Mask),handles.TestingSet.ImData);
axes(handles.axes3);
createFig(-handles.DifLimits,handles.DifLimits,'Rainbow',handles.DifMap.imdbSlice,...
    cat(3,handles.DifMap.Map,handles.DifMap.Mask));

%Check if SA measurements are not bieng eclipsed by figure windows
if checkSA(handles.TrainingSet.Fit,handles.parenthandles.imlimits,handles.parenthandles.pixelspacing,handles.parenthandles.Threshold) == false
    warndlg({'WARNING','Your current display settings have cut off a portion of the interpolated map in dataset 1. Surface area and volume integral measurements will only measure the part of the map that is in view. To correct this, go back to the previous window and increase the size of your view.'});
end
if checkSA(handles.TestingSet.Fit,handles.parenthandles.imlimits,handles.parenthandles.pixelspacing,handles.parenthandles.Threshold) == false
    warndlg({'WARNING','Your current display settings have cut off a portion of the interpolated map in dataset 2. Surface area and volume integral measurements will only measure the part of the map that is in view. To correct this, go back to the previous window and increase the size of your view.'});
end

%Reenable the back button
handles.Back.Enable = 'on';

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = ComparisonGUI_OutputFcn(hObject, eventdata, handles) 

% --- Executes on button press in Back.
function Back_Callback(hObject, eventdata, handles)

anwser = questdlg('Return to previous window?', ...
    'Back','Yes','No','No');
switch anwser
    case 'Yes'
        delete(gcf);
    case 'No'
end

% --- Executes on button press in MeasurementsHelp.
function MeasurementsHelp_Callback(hObject, eventdata, handles)

% --- Executes on button press in DisplayCOG.
function DisplayCOG_Callback(hObject, eventdata, handles)
if get(hObject,'Value') == 1
    handles.TrainingMarkers(1,:) = handles.TrainingSet.COG(1:2);
    handles.TestingMarkers(1,:) = handles.TestingSet.COG(1:2);
    handles.DifMarkers(1,:) = handles.DifMap.TrainingCOG(1:2);
    handles.DifMarkers(2,:) = handles.DifMap.TestingCOG(1:2);
else
    handles.TrainingMarkers(1,:) = [NaN,NaN];
    handles.TestingMarkers(1,:) = [NaN,NaN];
    handles.DifMarkers(1,:) = [NaN,NaN];
    handles.DifMarkers(2,:) = [NaN,NaN];
end
    
axes(handles.axes1);
createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.TrainingSet.imdbSlice,...
    cat(3,handles.TrainingSet.Map,handles.TrainingSet.Mask),handles.TrainingSet.ImData,handles.TrainingMarkers);
axes(handles.axes2);
createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.TestingSet.imdbSlice,...
    cat(3,handles.TestingSet.Map,handles.TestingSet.Mask),handles.TestingSet.ImData,handles.TestingMarkers);
axes(handles.axes3);
createFig(-handles.DifLimits,handles.DifLimits,'Rainbow',handles.DifMap.imdbSlice,...
    cat(3,handles.DifMap.Map,handles.DifMap.Mask),handles.DifMarkers);

guidata(hObject, handles);

% --- Executes on button press in DisplayPeak.
function DisplayPeak_Callback(hObject, eventdata, handles)
if get(hObject,'Value') == 1
    handles.TrainingMarkers(2,:) = handles.TrainingSet.Peak(1:2);
    handles.TestingMarkers(2,:) = handles.TestingSet.Peak(1:2);
    handles.DifMarkers(3,:) = handles.DifMap.TrainingPeak(1:2);
    handles.DifMarkers(4,:) = handles.DifMap.TestingPeak(1:2);
else
    handles.TrainingMarkers(2,:) = [NaN,NaN];
    handles.TestingMarkers(2,:) = [NaN,NaN];
    handles.DifMarkers(3,:) = [NaN,NaN];
    handles.DifMarkers(4,:) = [NaN,NaN];
end
    
axes(handles.axes1);
createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.TrainingSet.imdbSlice,...
    cat(3,handles.TrainingSet.Map,handles.TrainingSet.Mask),handles.TrainingSet.ImData,handles.TrainingMarkers);
axes(handles.axes2);
createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.TestingSet.imdbSlice,...
    cat(3,handles.TestingSet.Map,handles.TestingSet.Mask),handles.TestingSet.ImData,handles.TestingMarkers);
axes(handles.axes3);
createFig(-handles.DifLimits,handles.DifLimits,'Rainbow',handles.DifMap.imdbSlice,...
    cat(3,handles.DifMap.Map,handles.DifMap.Mask),handles.DifMarkers);

guidata(hObject, handles);

% --- Executes on button press in DisplayRef.
function DisplayRef_Callback(hObject, eventdata, handles)
if get(hObject,'Value') == 1
    handles.TrainingMarkers(3,:) = handles.TrainingSet.Reference(1:2);
    handles.TestingMarkers(3,:) = handles.TestingSet.Reference(1:2);
    handles.DifMarkers(5,:) = handles.DifMap.Reference(1:2);
else
    handles.TrainingMarkers(3,:) = [NaN,NaN];
    handles.TestingMarkers(3,:) = [NaN,NaN];
    handles.DifMarkers(5,:) = [NaN,NaN];
end
    
axes(handles.axes1);
createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.TrainingSet.imdbSlice,...
    cat(3,handles.TrainingSet.Map,handles.TrainingSet.Mask),handles.TrainingSet.ImData,handles.TrainingMarkers);
axes(handles.axes2);
createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.TestingSet.imdbSlice,...
    cat(3,handles.TestingSet.Map,handles.TestingSet.Mask),handles.TestingSet.ImData,handles.TestingMarkers);
axes(handles.axes3);
createFig(-handles.DifLimits,handles.DifLimits,'Rainbow',handles.DifMap.imdbSlice,...
    cat(3,handles.DifMap.Map,handles.DifMap.Mask),handles.DifMarkers);

guidata(hObject, handles);

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
guidata(hObject, handles);

% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)

cursor = handles.axes1.CurrentPoint;
if 1 < cursor(1,1) && (handles.parenthandles.imlimits(2)-handles.parenthandles.imlimits(1))/handles.parenthandles.pixelspacing > cursor(1,1) ...
    && 1 < cursor(1,2) && (handles.parenthandles.imlimits(4)-handles.parenthandles.imlimits(3))/handles.parenthandles.pixelspacing > cursor(1,2)
    MEP = handles.TrainingSet.Map(floor(cursor(1,2)),floor(cursor(1,1)));
    if strcmp(handles.parenthandles.ClusterOp,'probability')
        if MEP > 100
            MEP = 100;
        elseif MEP < 0
            MEP = 0;
        end
        handles.CursorValue.String = strcat(sprintf('%0.3f',MEP),'%');
    else
        handles.CursorValue.String = sprintf('%0.3f',MEP);
    end
    u = (cursor(1,1)*handles.parenthandles.pixelspacing)+handles.parenthandles.imlimits(1);
    v = (cursor(1,2)*handles.parenthandles.pixelspacing)+handles.parenthandles.imlimits(3);
    point = evalelip(u,v,handles.TrainingSet.Weights,handles.parenthandles.k);
    point = transmatTHETA(point,-handles.TrainingSet.theta);
    point = transmatPHI(point,-handles.TrainingSet.xphi,-handles.TrainingSet.yphi,'inverse');
    point = point + handles.parenthandles.Centroid; pointdist = norm((point - handles.parenthandles.Reference).*handles.parenthandles.ScanResolution);
    point = (point - handles.parenthandles.Reference).*handles.parenthandles.ScanResolution;
    handles.CursorPosition.String = sprintf('[%0.3f,%0.3f,%0.3f]; %0.3f',point(1),point(2),point(3),pointdist);
end

cursor = handles.axes2.CurrentPoint;
if 1 < cursor(1,1) && (handles.parenthandles.imlimits(2)-handles.parenthandles.imlimits(1))/handles.parenthandles.pixelspacing > cursor(1,1) ...
    && 1 < cursor(1,2) && (handles.parenthandles.imlimits(4)-handles.parenthandles.imlimits(3))/handles.parenthandles.pixelspacing > cursor(1,2)
    MEP = handles.TestingSet.Map(floor(cursor(1,2)),floor(cursor(1,1)));
    if strcmp(handles.parenthandles.ClusterOp,'probability')
        if MEP > 100
            MEP = 100;
        elseif MEP < 0
            MEP = 0;
        end
        handles.CursorValue.String = strcat(sprintf('%0.3f',MEP),'%');
    else
        handles.CursorValue.String = sprintf('%0.3f',MEP);
    end
    u = (cursor(1,1)*handles.parenthandles.pixelspacing)+handles.parenthandles.imlimits(1);
    v = (cursor(1,2)*handles.parenthandles.pixelspacing)+handles.parenthandles.imlimits(3);
    point = evalelip(u,v,handles.TestingSet.Weights,handles.parenthandles.k);
    point = transmatTHETA(point,-handles.TestingSet.theta);
    point = transmatPHI(point,-handles.TestingSet.xphi,-handles.TestingSet.yphi,'inverse');
    point = point + handles.parenthandles.Centroid; pointdist = norm((point - handles.parenthandles.Reference).*handles.parenthandles.ScanResolution);
    point = (point - handles.parenthandles.Reference).*handles.parenthandles.ScanResolution;
    handles.CursorPosition.String = sprintf('[%0.3f,%0.3f,%0.3f]; %0.3f',point(1),point(2),point(3),pointdist);
end

cursor = handles.axes3.CurrentPoint;
if 1 < cursor(1,1) && (handles.DifMap.imlimits(2)-handles.DifMap.imlimits(1))/handles.parenthandles.pixelspacing > cursor(1,1) ...
    && 1 < cursor(1,2) && (handles.DifMap.imlimits(4)-handles.DifMap.imlimits(3))/handles.parenthandles.pixelspacing > cursor(1,2)
    MEP = handles.DifMap.Map(floor(cursor(1,2)),floor(cursor(1,1)));
    if strcmp(handles.parenthandles.ClusterOp,'probability')
        if MEP > 0
            handles.CursorValue.String = strcat(sprintf('+%0.3f',MEP),'%');
        else
            handles.CursorValue.String = strcat(sprintf('%0.3f',MEP),'%');
        end
    else
        if MEP > 0
            handles.CursorValue.String = sprintf('+%0.3f',MEP);
        else
            handles.CursorValue.String = sprintf('%0.3f',MEP);
        end
    end
    u = (cursor(1,1)*handles.parenthandles.pixelspacing)+handles.DifMap.imlimits(1);
    v = (cursor(1,2)*handles.parenthandles.pixelspacing)+handles.DifMap.imlimits(3);
    point = evalelip(u,v,handles.DifMap.Weights,handles.parenthandles.k);
    point = transmatTHETA(point,-handles.DifMap.theta);
    point = transmatPHI(point,-handles.DifMap.xphi,-handles.DifMap.yphi,'inverse');
    point = point + handles.parenthandles.Centroid; pointdist = norm((point - handles.parenthandles.Reference).*handles.parenthandles.ScanResolution);
    point = (point - handles.parenthandles.Reference).*handles.parenthandles.ScanResolution;
    handles.CursorPosition.String = sprintf('[%0.3f,%0.3f,%0.3f]; %0.3f',point(1),point(2),point(3),pointdist);
end
guidata(hObject, handles);
        
% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
guidata(hObject, handles);

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

% --- Executes on slider movement.
function TransparencySlider_Callback(hObject, eventdata, handles)
handles.alpha = get(hObject,'Value');
handles.TrainingSet.Mask = handles.alpha*(handles.TrainingSet.Mask ~= 0);
handles.TestingSet.Mask = handles.alpha*(handles.TestingSet.Mask ~= 0);
handles.DifMap.Mask = handles.alpha*(handles.DifMap.Mask ~= 0);
guidata(hObject, handles);

% --- Executes on selection change in ColorMapSelect.
function ColorMapSelect_Callback(hObject, eventdata, handles)
contents = cellstr(get(hObject,'String'));
handles.Colormap = contents{get(hObject,'Value')};
guidata(hObject, handles);

% --- Executes on button press in ColorMapApply.
function ColorMapApply_Callback(hObject, eventdata, handles)
axes(handles.axes1);
createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.TrainingSet.imdbSlice,...
    cat(3,handles.TrainingSet.Map,handles.TrainingSet.Mask),handles.TrainingSet.ImData,handles.TrainingMarkers);
axes(handles.axes2);
createFig(handles.ColorMin,handles.ColorMax,handles.Colormap,handles.TestingSet.imdbSlice,...
    cat(3,handles.TestingSet.Map,handles.TestingSet.Mask),handles.TestingSet.ImData,handles.TestingMarkers);
axes(handles.axes3);
createFig(-handles.DifLimits,handles.DifLimits,'Rainbow',handles.DifMap.imdbSlice,...
    cat(3,handles.DifMap.Map,handles.DifMap.Mask),handles.DifMarkers);
guidata(hObject, handles);

% --- Executes on button press in ExportData.
function ExportData_Callback(hObject, eventdata, handles)
[file,path] = uiputfile({'*.txt','Text File (*.txt)'});
if file == 0
    return
end
if ~strcmp(handles.parenthandles.ClusterOp,'probability')
TopRow = ['Positions',handles.PositionTable.ColumnName'];
EndRows = [handles.PositionTable.RowName,handles.PositionTable.Data];
PositionData = [TopRow;EndRows];

TopRow = ['Values',handles.ValueTable.ColumnName'];
EndRows = [handles.ValueTable.RowName,handles.ValueTable.Data];
ValueData = [TopRow;EndRows];

FileID = fopen(strcat(path,file),'w');
if ispc
    fprintf(FileID,'%s %6s\r\n','Reference:',handles.Reference.String);
    fprintf(FileID,'\r\n');
    fprintf(FileID,'%6s %12s %12s %12s %12s\r\n',PositionData{1,1},...
        PositionData{1,2},PositionData{1,3},PositionData{1,4},PositionData{1,5});
    fprintf(FileID,'%6s %12.2f %12.2f %12.2f %12.2f\r\n', PositionData{2,1},...
        PositionData{2,2},PositionData{2,3},PositionData{2,4},PositionData{2,5});
    fprintf(FileID,'%6s %12.2f %12.2f %12.2f %12.2f\r\n', PositionData{3,1},...
        PositionData{3,2},PositionData{3,3},PositionData{3,4},PositionData{3,5});
    fprintf(FileID,'%6s %12.2f %12.2f %12.2f %12.2f\r\n', PositionData{4,1},...
        PositionData{4,2},PositionData{4,3},PositionData{4,4},PositionData{4,5});
    fprintf(FileID,'%6s %12.2f %12.2f %12.2f %12.2f\r\n', PositionData{5,1},...
        PositionData{5,2},PositionData{5,3},PositionData{5,4},PositionData{5,5});
    fprintf(FileID,'%6s %12.2f %12.2f %12.2f %12.2f\r\n', PositionData{6,1},...
        PositionData{6,2},PositionData{6,3},PositionData{6,4},PositionData{6,5});
    fprintf(FileID,'\r\n');
    fprintf(FileID,'\r\n');
    fprintf(FileID,'\r\n');
    fprintf(FileID,'%6s %12s %12s %12s\r\n', ValueData{1,1},...
        handles.TrainingLabel.String,handles.TestingLabel.String,ValueData{1,4});
    fprintf(FileID,'%6s %12.2f %12.2f %12.2f\r\n', ValueData{2,1},...
        ValueData{2,2},ValueData{2,3},ValueData{2,4});
    fprintf(FileID,'%6s %12.2f %12.2f %12.2f\r\n', ValueData{3,1},...
        ValueData{3,2},ValueData{3,3},ValueData{3,4});
    fprintf(FileID,'%6s %12.2f %12.2f %12.2f\r\n', ValueData{4,1},...
        ValueData{4,2},ValueData{4,3},ValueData{4,4});
    fprintf(FileID,'%6s %12.2f %12.2f %12.2f\r\n', ValueData{5,1},...
        ValueData{5,2},ValueData{5,3},ValueData{5,4});
    fprintf(FileID,'\r\n');
    fprintf(FileID,'\r\n');
    fprintf(FileID,'\r\n');
    fprintf(FileID,'%6s %12.2f\r\n', handles.CompLabel.String, str2double(handles.RMSE.String));
else
    fprintf(FileID,'%s %6s\n','Reference:',handles.Reference.String);
    fprintf(FileID,'\n');
    fprintf(FileID,'%6s %12s %12s %12s %12s\n',PositionData{1,1},...
        PositionData{1,2},PositionData{1,3},PositionData{1,4},PositionData{1,5});
    fprintf(FileID,'%6s %12.2f %12.2f %12.2f %12.2f\n', PositionData{2,1},...
        PositionData{2,2},PositionData{2,3},PositionData{2,4},PositionData{2,5});
    fprintf(FileID,'%6s %12.2f %12.2f %12.2f %12.2f\n', PositionData{3,1},...
        PositionData{3,2},PositionData{3,3},PositionData{3,4},PositionData{3,5});
    fprintf(FileID,'%6s %12.2f %12.2f %12.2f %12.2f\n', PositionData{4,1},...
        PositionData{4,2},PositionData{4,3},PositionData{4,4},PositionData{4,5});
    fprintf(FileID,'%6s %12.2f %12.2f %12.2f %12.2f\n', PositionData{5,1},...
        PositionData{5,2},PositionData{5,3},PositionData{5,4},PositionData{5,5});
    fprintf(FileID,'%6s %12.2f %12.2f %12.2f %12.2f\n', PositionData{6,1},...
        PositionData{6,2},PositionData{6,3},PositionData{6,4},PositionData{6,5});
    fprintf(FileID,'\n');
    fprintf(FileID,'\n');
    fprintf(FileID,'\n');
    fprintf(FileID,'%6s %12s %12s %12s\n', ValueData{1,1},...
        handles.TrainingLabel.String,handles.TestingLabel.String,ValueData{1,4});
    fprintf(FileID,'%6s %12.2f %12.2f %12.2f\n', ValueData{2,1},...
        ValueData{2,2},ValueData{2,3},ValueData{2,4});
    fprintf(FileID,'%6s %12.2f %12.2f %12.2f\n', ValueData{3,1},...
        ValueData{3,2},ValueData{3,3},ValueData{3,4});
    fprintf(FileID,'%6s %12.2f %12.2f %12.2f\n', ValueData{4,1},...
        ValueData{4,2},ValueData{4,3},ValueData{4,4});
    fprintf(FileID,'%6s %12.2f %12.2f %12.2f\n', ValueData{5,1},...
        ValueData{5,2},ValueData{5,3},ValueData{5,4});
    fprintf(FileID,'\n');
    fprintf(FileID,'\n');
    fprintf(FileID,'\n');
    fprintf(FileID,'%6s %12.2f\n', handles.CompLabel.String, str2double(handles.RMSE.String));
end
fclose(FileID);

else
    thresh = linspace(0,101,100);
    FileID = fopen(strcat(path,file),'w');
    fprintf(FileID,'%6s %12s %12s\n','Threshold','False Positive Rate','Detection Rate');
    for i = 1:size(thresh,2)
        fprintf(FileID,'%6.2f %12.2f %12.2f\n',thresh(i),handles.FalPosRate(i),handles.DetRate(i));
    end
    fclose(FileID);
end

% --- Executes on button press in ExportDifImage.
function ExportDifImage_Callback(hObject, eventdata, handles)
axes(handles.axes3)
I = getframe(gca);

[file,path] = uiputfile({'*.png','Portable Network Graphics (*.png)';...
    '*.bmp','Windows BitMap (*.bmp)';...
    '*.tif','Tagged Image File Format (*.tif)';...
    '*.jpg','JPEG 2000 (*.jpg)'});
if file == 0
    return
end
imwrite(I.cdata,strcat(path,file));

% --- Executes on button press in ExportImage2.
function ExportImage2_Callback(hObject, eventdata, handles)
axes(handles.axes2)
I = getframe(gca);

[file,path] = uiputfile({'*.png','Portable Network Graphics (*.png)';...
    '*.bmp','Windows BitMap (*.bmp)';...
    '*.tif','Tagged Image File Format (*.tif)';...
    '*.jpg','JPEG 2000 (*.jpg)'});
if file == 0
    return
end
imwrite(I.cdata,strcat(path,file));

% --- Executes on button press in ExportImage1.
function ExportImage1_Callback(hObject, eventdata, handles)
axes(handles.axes1)
I = getframe(gca);

[file,path] = uiputfile({'*.png','Portable Network Graphics (*.png)';...
    '*.bmp','Windows BitMap (*.bmp)';...
    '*.tif','Tagged Image File Format (*.tif)';...
    '*.jpg','JPEG 2000 (*.jpg)'});
if file == 0
    return
end
imwrite(I.cdata,strcat(path,file));

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
function TransparencySlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function ColorMapSelect_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
