function varargout = HelpMenu_HN(varargin)
% HELPMENU_HN MATLAB code for HelpMenu_HN.fig
%      HELPMENU_HN, by itself, creates a new HELPMENU_HN or raises the existing
%      singleton*.
%
%      H = HELPMENU_HN returns the handle to a new HELPMENU_HN or the handle to
%      the existing singleton*.
%
%      HELPMENU_HN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HELPMENU_HN.M with the given input arguments.
%
%      HELPMENU_HN('Property','Value',...) creates a new HELPMENU_HN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HelpMenu_HN_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HelpMenu_HN_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help HelpMenu_HN

% Last Modified by GUIDE v2.5 11-Mar-2018 21:19:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HelpMenu_HN_OpeningFcn, ...
                   'gui_OutputFcn',  @HelpMenu_HN_OutputFcn, ...
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


% --- Executes just before HelpMenu_HN is made visible.
function HelpMenu_HN_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to HelpMenu_HN (see VARARGIN)

% Choose default command line output for HelpMenu_HN
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes HelpMenu_HN wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = HelpMenu_HN_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in CloseMenu.
function CloseMenu_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(gcf)
