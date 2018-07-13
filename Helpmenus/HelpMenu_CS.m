function varargout = HelpMenu_CS(varargin)
% HELPMENU_CS MATLAB code for HelpMenu_CS.fig
%      HELPMENU_CS, by itself, creates a new HELPMENU_CS or raises the existing
%      singleton*.
%
%      H = HELPMENU_CS returns the handle to a new HELPMENU_CS or the handle to
%      the existing singleton*.
%
%      HELPMENU_CS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HELPMENU_CS.M with the given input arguments.
%
%      HELPMENU_CS('Property','Value',...) creates a new HELPMENU_CS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HelpMenu_CS_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HelpMenu_CS_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help HelpMenu_CS

% Last Modified by GUIDE v2.5 11-Mar-2018 21:35:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HelpMenu_CS_OpeningFcn, ...
                   'gui_OutputFcn',  @HelpMenu_CS_OutputFcn, ...
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


% --- Executes just before HelpMenu_CS is made visible.
function HelpMenu_CS_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to HelpMenu_CS (see VARARGIN)

% Choose default command line output for HelpMenu_CS
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes HelpMenu_CS wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = HelpMenu_CS_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in ClusteringOperationsSelect.
function ClusteringOperationsSelect_Callback(hObject, eventdata, handles)
% hObject    handle to ClusteringOperationsSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.DescriptionTitle.ForegroundColor=[0.85,0.33,0.1];
handles.DescriptionTitle.FontSize=10.0;
handles.DescriptionTitle.String='Clustering Operations';
handles.DescriptionBody.String=strjust(sprintf(['For help with clustering, see the help panel for Point Clustering.\n',...
'Average: Will take the unweighted average of each MEP value in the cluster, and yields that value as the MEP value on the map. Although averaging captures the underlying character of the measurements, it is also subject to misleading values if there are large deviations between measurements.\n',...
'Maximum: Will take the maximum experimental MEP value in the cluster, and yields that value as the MEP value on the map. Although not prone to the same error as averaging, can still lead to misleading values if, for example, the highest MEP value in the cluster was an accidental artifact due to patient movement, and other measurements at the site yielded low value or no MEP whatsoever.\n',...
'Minimum: Will take the minimum experimental MEP value in the cluster, and yields that value as the MEP value on the map. Possibly a somewhat safer option, but still prone to some error if, for example, an MEP was successfully evoked at the site three times, but failed once.\n',...
'Binary Average: For each point in the cluster, if the associated MEP value is above the given threshold, then the point becomes a binary ''1''. If not, the point becomes a binary ''0''. All points in the cluster are averaged, to give a percent of how many points in the node were above threshold. \n',...
'Variance: NOTE: NOT INTENDED AS A REPRESENTATION OF TRUE HEATMAP. The Variance option is intended to generate a heatmap to display where the greatest variance between measurements occured in the data. Thus, areas of potential error or exceptions can be identified.\n',...
'Note: All methods are for repeated measurements.\n',...
'MEP maps can still be plotted for single measurements. The option will have no effect for single measurements.',...
]),'left');

% --- Executes on button press in SurfaceFittingAlgorithmsSelect.
function SurfaceFittingAlgorithmsSelect_Callback(hObject, eventdata, handles)
% hObject    handle to SurfaceFittingAlgorithmsSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes during object deletion, before destroying properties.
figure1_DeleteFcn
HelpMenu_SF
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(gcf)

% --- Executes on button press in CloseMenu.
function CloseMenu_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(gcf)


