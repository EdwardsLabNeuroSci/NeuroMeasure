function varargout = HelpMenu(varargin)
% HELPMENU MATLAB code for HelpMenu.fig
%      HELPMENU, by itself, creates a new HELPMENU or raises the existing
%      singleton*.
%
%      H = HELPMENU returns the handle to a new HELPMENU or the handle to
%      the existing singleton*.
%
%      HELPMENU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HELPMENU.M with the given input arguments.
%
%      HELPMENU('Property','Value',...) creates a new HELPMENU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HelpMenu_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HelpMenu_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help HelpMenu

% Last Modified by GUIDE v2.5 25-Feb-2018 00:15:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HelpMenu_OpeningFcn, ...
                   'gui_OutputFcn',  @HelpMenu_OutputFcn, ...
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


% --- Executes just before HelpMenu is made visible.
function HelpMenu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to HelpMenu (see VARARGIN)

% Choose default command line output for HelpMenu
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes HelpMenu wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = HelpMenu_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.text5.ForegroundColor=[0.85,0.33,0.1];
handles.text5.FontSize=10.0;
handles.text5.String='Clustering Operations';
handles.text4.String=strjust(sprintf(['For help with clustering, see the help panel for Point Clustering.\n',...
'Average: Will take the unweighted average of each MEP value in the cluster, and yields that value as the MEP value on the map. Although averaging captures the underlying character of the measurements, it is also subject to misleading values if there are large deviations between measurements.\n',...
'Maximum: Will take the maximum experimental MEP value in the cluster, and yields that value as the MEP value on the map. Although not prone to the same error as averaging, can still lead to misleading values if, for example, the highest MEP value in the cluster was an accidental artifact due to patient movement, and other measurements at the site yielded low value or no MEP whatsoever.\n',...
'Minimum: Will take the minimum experimental MEP value in the cluster, and yields that value as the MEP value on the map. Possibly a somewhat safer option, but still prone to some error if, for example, an MEP was successfully evoked at the site three times, but failed once.\n',...
'Probability: For each point in the cluster, if the associated MEP value is above the given threshold, then the point becomes a binary ''1''. If not, the point becomes a binary ''0''. All points in the cluster are averaged, to give a percent of how many points in the node were above threshold. \n',...
'Variance: NOTE: NOT INTENDED AS A REPRESENTATION OF TRUE HEATMAP. The Variance option is intended to generate a heatmap to display where the greatest variance between measurements occured in the data. Thus, areas of potential error or exceptions can be identified.\n',...
'Note: All methods are for repeated measurements.\n',...
'MEP maps can still be plotted for single measurements. The option will have no effect for single measurements.',...
]),'left');

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.text5.ForegroundColor=[0.85,0.33,0.1];
handles.text5.FontSize=10.0;
handles.text5.String='Surface Fitting Algorithms';
handles.text4.String=strjust(sprintf(['The six supported surface methods are exlained below. \n'...
    'Piecewise Cubic: Uses a bi-cubic function to interpolate. \n \n'...
    'Piecewise Linear: Uses a bi-linear approach to interpolate between points. Similar to drawing a straight line between two points on a regular plot, but extended to three dimensions. \n \n'...
    'Biharmonic (V4): Interpolation yielded when Biharmonic operator (laplacian of the laplacian of dataset) is set to zero. Fourth order partial differential equation. \n'...
    'Lowess: Locally Weighted Scatterplot Smoothing looks at windows or subsets of the data, combining linear least squares regression with non-linear regression to create models which are pieced together into the full interpolation.']),'left');


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(gcf)
