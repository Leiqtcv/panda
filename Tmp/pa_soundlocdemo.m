function varargout = pa_soundlocdemo(varargin)
% PA_SOUNDLOCDEMO MATLAB code for pa_soundlocdemo.fig
%      PA_SOUNDLOCDEMO, by itself, creates a new PA_SOUNDLOCDEMO or raises the existing
%      singleton*.
%
%      H = PA_SOUNDLOCDEMO returns the handle to a new PA_SOUNDLOCDEMO or the handle to
%      the existing singleton*.
%
%      PA_SOUNDLOCDEMO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PA_SOUNDLOCDEMO.M with the given input arguments.
%
%      PA_SOUNDLOCDEMO('Property','Value',...) creates a new PA_SOUNDLOCDEMO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pa_soundlocdemo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pa_soundlocdemo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pa_soundlocdemo

% Last Modified by GUIDE v2.5 23-Nov-2012 14:30:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pa_soundlocdemo_OpeningFcn, ...
                   'gui_OutputFcn',  @pa_soundlocdemo_OutputFcn, ...
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


% --- Executes just before pa_soundlocdemo is made visible.
function pa_soundlocdemo_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pa_soundlocdemo (see VARARGIN)

% Choose default command line output for pa_soundlocdemo
handles.output = hObject;

[I,map] = imread('phono.png');
% [a,map]=imread('vol.jpg');
whos I
[r,c,d] = size(I); 
x		= ceil(r/200); 
y		= ceil(c/200); 
g		= I(1:x:end,1:y:end,:);
% g(g==255)=5.5*255;
% g(g>200) = 230;
set(handles.pushbutton1,'CData',g);
set(handles.pushbutton2,'CData',flipdim(g,2));

% set(handles.pushbutton1,'cdata',I)
x = -100:1:100;
col = 1-gray;
colormap(col);
for ii = 1:.1:10;
	y = normpdf(x,0,2);
	z = normpdf(x,ii,ii);
	[y,z] = meshgrid(y,z);
	M		= y.*z;
% 	I		= ind2rgb(M,jet);
% [r,c,d] = size(I); 
% x		= ceil(r/200); 
% y		= ceil(c/200); 
% g		= I(1:x:end,1:y:end,:);
% 	set(handles.pushbutton1,'CData',g);

axes(handles.axes1);
contourf(M);
	shading flat;
	pause(.1);
	drawnow
end
	
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes pa_soundlocdemo wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = pa_soundlocdemo_OutputFcn(hObject, eventdata, handles) 
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


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
