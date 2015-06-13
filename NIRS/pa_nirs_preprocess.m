function varargout = pa_nirs_preprocess(varargin)
% PA_NIRS_PREPROCESS M-file for pa_nirs_preprocess.fig
%      PA_NIRS_PREPROCESS, by itself, creates a new PA_NIRS_PREPROCESS or raises the existing
%      singleton*.
%
%      H = PA_NIRS_PREPROCESS returns the handle to a new PA_NIRS_PREPROCESS or the handle to
%      the existing singleton*.
%
%      PA_NIRS_PREPROCESS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PA_NIRS_PREPROCESS.M with the given input arguments.
%
%      PA_NIRS_PREPROCESS('Property','Value',...) creates a new PA_NIRS_PREPROCESS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pa_nirs_preprocess_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pa_nirs_preprocess_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pa_nirs_preprocess

% Last Modified by GUIDE v2.5 29-Oct-2013 10:21:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
	'gui_Singleton',  gui_Singleton, ...
	'gui_OpeningFcn', @pa_nirs_preprocess_OpeningFcn, ...
	'gui_OutputFcn',  @pa_nirs_preprocess_OutputFcn, ...
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

function pa_nirs_preprocess_OpeningFcn(hObject, eventdata, handles, varargin)
% --- Executes just before pa_nirs_preprocess is made visible.
home;
str = ['>>---- ' upper(mfilename) ' ----<<'];
disp(str);

% Get Data
handles                                = MAIN_Check_And_Load(handles, varargin{:});
handles                                = MAIN_process(handles, varargin{:});
% handles                                = MAIN_detect(handles);
handles                                = MAIN_plottrial(handles);
% Choose default command line output for pa_nirs_preprocess
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

function varargout = pa_nirs_preprocess_OutputFcn(hObject, eventdata, handles)
% --- Outputs from this function are returned to the command line.
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function handles	= MAIN_Check_And_Load(handles, varargin)

%% Initialization
lv                                          = length(varargin);
if lv<1
	handles.fname                               = [];
	handles.fname                               = pa_fcheckexist(handles.fname,'*.xls');
end
if length(varargin)==1
	handles.fname                               = varargin{1};
	handles.fname                               = pa_fcheckext(handles.fname,'.xlsx');
	handles.fname                               = pa_fcheckexist(handles.fname);
end
if length(varargin)==2
	handles.fname                               = varargin{1};
	handles.fname                               = pa_fcheckext(handles.fname,'.xls');
	handles.fname                               = pa_fcheckexist(handles.fname);
end
handles.fname
%% data
handles.data				= pa_nirs_read(handles.fname);

%% Default preprocessing values
handles.ctrial				= 1;
handles.zoom				= false;
handles.data.cfg.filter		= true;
if handles.data.cfg.filter
	set(handles.chck_filter,'Value',1);
end
handles.data.cfg.flow		= 0.008;
handles.data.cfg.fhigh		= 0.08;
% handles.data.cfg.flow		= [];
% handles.data.cfg.fhigh		= [];
set(handles.txt_lowfc,'String', num2str(handles.data.cfg.flow));
set(handles.txt_highfc,'String', num2str(handles.data.cfg.fhigh));

handles.data.cfg.pca		= 0;
if handles.data.cfg.pca
	set(handles.chck_pca,'Value',1);
else
	set(handles.chck_pca,'Value',0);
end

handles.data.cfg.neigen		= 0;
if handles.data.cfg.neigen
	set(handles.txt_ev,'String', num2str(handles.data.cfg.neigen));
end
handles.data.cfg.detrend	= 1;
if handles.data.cfg.detrend
	set(handles.chck_detrend,'Value',1);
else
	set(handles.chck_detrend,'Value',0);
end
handles.data.cfg.down	= 1;
if handles.data.cfg.down
	set(handles.chck_down,'Value',1);
	handles.data.fsdown = str2double(get(handles.txt_downfreq,'String'));
else
	set(handles.chck_down,'Value',0);
	handles.data.fsdown = [];
end


handles.data.cfg.exclude	= 200;
set(handles.txt_exclude,'String',num2str(handles.data.cfg.exclude));
handles.data.cfg.powerplot = 0;
if handles.data.cfg.powerplot
	set(handles.chck_freqplot,'Value',1);
end

%% Set buttons and texts
str			= handles.data.label(handles.data.hdr.oxyindx);
str			= str(handles.data.hdr.pos_indx);
for jj		= 1:length(str)
	str{jj}		= str{jj}(1:10);
end
set(handles.pop_channel,'String',str);
set(handles.txt_lowfc,'String',num2str(handles.data.cfg.flow));
set(handles.txt_highfc,'String',num2str(handles.data.cfg.fhigh));
set(handles.txt_filename,'String',handles.fname);

function handles	= MAIN_process(handles, varargin)
%% Preprocess data
dat = [handles.data.trial];
nchan = size(dat,1);
whos dat

if handles.data.cfg.down % downsample to gain time
	dat = pa_nirs_downsample(dat,handles.data.fsample,handles.data.fsdown);
	disp('Downsample');
	handles.data.timedown = (1:size(dat,2))/handles.data.fsdown;
else
	handles.data.fsdown = handles.data.fsample;
	handles.data.timedown = handles.data.time;
end

if isfield(handles.data.cfg,'flow') && isfield(handles.data.cfg,'fhigh') && handles.data.cfg.filter
	handles.data.fsdown
	for ii = 2:(nchan-1)
		dat(ii,:) = pa_nirs_bandpass(dat(ii,:),handles.data.fsdown,handles.data.cfg.flow,handles.data.cfg.fhigh);
	end
	% 	dat = pa_nirs_bandpass(dat,handles.data.fsample,handles.data.cfg.flow,handles.data.cfg.fhigh);
	% 	dat							= filternirs(dat,handles.data.fsample,handles.data.cfg.flow,handles.data.cfg.fhigh);
	disp('Filtering');
end


% 	str = ['axes(handles.axes' num2str(ii) ');'];
% axes(handles.axes9)
% keyboard
%% Remove start artifact and mean channel response
time		= handles.data.timedown; % time (s)
sel			= time<(2*60); % remove everything before 2 min, this is based on observing the data
dat(:,sel)	= NaN;

if handles.data.cfg.detrend % Detrend the data
	dat = pa_nirs_detrend(dat);
	disp('Detrending');
end

if handles.data.cfg.pca % Do PCA and remove first eigenvector
	dat				= nirspca(handles,dat);
	% 	handles.data.eigenvector = v;
	disp('PCA');
end
handles.data.processed	= dat;



%% Threshold
dat							= handles.data.processed;
oxy							= dat(:,handles.data.hdr.oxyindx);
deoxy						= dat(:,handles.data.hdr.deoxyindx);
oxy							= oxy(:,handles.data.hdr.pos_indx);
deoxy						= deoxy(:,handles.data.hdr.pos_indx);
lvl							= 5*std([oxy(:); deoxy(:)].^2);
handles.data.cfg.level		= lvl;

function handles	= MAIN_reprocess(handles)
handles                                = MAIN_process(handles);
handles                                = MAIN_detect(handles);
handles                                = MAIN_plottrial(handles);

function handles	= MAIN_detect(handles)
dat			= cat(2,handles.data.processed{:})';
for ii = 1:size(dat,2)
	V			= dat(:,ii).^2;
	sel1                                        = V>handles.data.cfg.level;  	% Trace Index in trial where saccade velocity exceeds minimum velocity
	sel2                                        = V>handles.data.cfg.level;  % Trace Index in trial where saccade velocity exceeds minimum velocity
	on											= find([0;diff(sel1)]==1); % onsets (+1)
	off                                         = NaN(size(on));
	tmpoff                                      = [find([0;diff(sel2)]==-1);numel(V)]; %  and offsets (-1)
	for jj = 1:numel(on)
		tmp		= tmpoff(find(tmpoff-on(jj)>0,1,'first'));
		off(jj) = tmp;
	end
	off = off(~isnan(off));
	% modify on and offset
	% exclude an extra number of samples
	% checking whether on and offset do not go outside data size
	on			= on-handles.data.cfg.exclude;
	off			= off+handles.data.cfg.exclude;
	sel			= on<1;
	on(sel)		= 1;
	sel			= off>length(V);
	off(sel)	= length(V);
	
	[on,indx]	= unique(on);
	off			= off(indx);
	[off,indx]	= unique(off);
	on			= on(indx);
	%% Combine
	for jj		= 2:length(on)
		if on(jj)<off(jj-1)
			on(jj)	= on(jj-1);
			off(jj) = max([off(jj) off(jj-1)]);
		end
	end
	[on,indx]	= unique(on);
	off			= off(indx);
	
	%% Save in handles
	handles.data.artefact(ii).onset		= on;
	handles.data.artefact(ii).offset	= off;
	if ~isempty(on)
		% 							for jj	= 1:length(on)
		% 								dat(on(jj):off(jj),ii) = NaN;
		% 							end
	end
end
handles.data.processed{1} = dat';

function handles	= MAIN_plottrial(handles, varargin)
ctrial		= handles.ctrial;
dat			= handles.data.processed;


%%
handles.data.hdr.oxyindx
handles.data.hdr.deoxyindx
oxy			= dat(handles.data.hdr.oxyindx,:);
deoxy		= dat(handles.data.hdr.deoxyindx,:);
% artefact = struct([]);
% for ii = 1:8
% 	indx = (ii-1)*3+1;
% 	artefact(ii).onset = handles.data.artefact(indx).onset;
% 	artefact(ii).offset = handles.data.artefact(indx).offset;
% end

oxy			= oxy(handles.data.hdr.pos_indx,:);
deoxy		= deoxy(handles.data.hdr.pos_indx,:);

oxylabel	= handles.data.label(handles.data.hdr.oxyindx);
oxylabel	= oxylabel(handles.data.hdr.pos_indx);

time		= handles.data.timedown;
xax			= [min(time) max(time)];
mx			= max(abs([oxy(:); deoxy(:)]));

yax			= [-mx mx];

nOxyChan = size(oxy,1);
for ii = 1:nOxyChan
	str = ['set(handles.axes' num2str(ii) ',''Visible'',''on'')'];
	eval(str);
	
	str = ['axes(handles.axes' num2str(ii) ');'];
	eval(str);
	cla;
	yo = oxy(ii,:);
	yd = -deoxy(ii,:);
	plot(time,yo,'r-','LineWidth',2);
	hold on
	plot(time,yd,'b-','LineWidth',2);
	
	% 	plot(time,yo,'r-','LineWidth',2);
	% 	hold on
	% 	plot(time,yd,'b-','LineWidth',2);
	xlim(xax);
	% 	ylim(yax);
	axis square;
	% 	set(gca,'XTick',[],'YTick',[]);
	title(oxylabel{ii}(1:10));
	% 	box off
	% 	set(gca,'TickDir','out');
	% 	if ii==ctrial
	% 		handles                          = REFRESH_plottrial(handles, varargin);
	% 	end
end

%%
function handles	= REFRESH_plottrial(handles, varargin)
%% Current trial
ctrial		= handles.ctrial;
set(handles.pop_channel,'Value',ctrial);

%% Refresh
lvl			= handles.data.cfg.level;
data		= handles.data;
dat			= cat(2,data.processed{:})';

oxy			= dat(:,handles.data.hdr.oxyindx);
deoxy		= dat(:,handles.data.hdr.deoxyindx);
oxy			= oxy(:,handles.data.hdr.pos_indx);
deoxy		= deoxy(:,handles.data.hdr.pos_indx);
oxylabel	= data.label(handles.data.hdr.oxyindx);
oxylabel	= oxylabel(handles.data.hdr.pos_indx);

time		= data.time;
xax			= [min(time) max(time)];
mx			= max(abs([oxy(:); deoxy(:)]));
yax			= [-mx mx];

value	= [data.event.value];
sample	= [data.event.sample];
sel		= value == 1;
on		= sample(sel)/data.fsample;
sel		= value == 0;
off		= sample(sel)/data.fsample;
if length(on)>length(off)
	on = on(1:length(off));
end

yo = oxy(:,ctrial);
yd = -deoxy(:,ctrial); % Take reverse, if neural activity OHb and HHb should correlate negatively
dyo = yo.^2;
dyd = yd.^2;

whos time yo
axes(handles.axes9) %#ok<*MAXES>
cla;
plot(time,yo,'r-','LineWidth',2);
hold on
plot(time,yd,'b-','LineWidth',2);
xlim(xax);
ylim(yax);
for jj = 1:length(on);
	x = [on(jj) on(jj) off(jj) off(jj)];
	y = [-mx mx mx -mx];
	h = patch(x,y,'k');
	alpha(h,0.3);
	set(h,'EdgeColor','none');
end
% set(gca,'XTickLabel',[]);
ylabel('Amplitude');
legend('OHb','-DHb');
title(oxylabel{ctrial}(1:10));

axes(handles.axes11)
cla;
plot(time,dyo,'r-','LineWidth',2);
hold on
plot(time,dyd,'b-','LineWidth',2);
xlim(xax);
xlabel('Time (s)');
ylabel('Velocity');
horline(lvl);

axes(handles.axes10)
cla;
plot(yo,-yd,'k.-');
hold on
xlabel('OHb');
ylabel('DHb');
xlim(yax);
ylim(yax);
plot(yax,-yax,'k--');
box on

axes(handles.axes12)
cla;
if ~handles.data.cfg.powerplot
	showaxes('hide');
else
	[f,mxo] = getpower(yo,data.fsample); %#ok<ASGLU>
	[f,mxd] = getpower(-yd,data.fsample);
	cla;
	h2 = semilogx(f,mxo);
	set(h2,'Color','r');
	hold on
	h2 = semilogx(f,mxd);
	set(h2,'Color','b');
	set(gca,'XTick',[0.01 0.05 1 2 3 4 6 8 10]);
	set(gca,'XTickLabel',[0.01 0.05 1 2 3 4 6 8 10]);
	xlabel('Frequency (Hz)');
	ylabel('Power');
	xlim([min(f) max(f)]);
end

axes(handles.axes14)
cla;

data		= handles.data;
dat			= cat(2,data.processed{:})';
oxy			= dat(:,handles.data.hdr.oxyindx);
oxy			= oxy(:,handles.data.hdr.pos_indx);
oxy			= oxy(:,ctrial);

value	= [data.event.value];
sample	= [data.event.sample];
sel		= value == 1;
on		= sample(sel);
sel		= value == 0;
off		= sample(sel);
if length(on)>length(off)
	on = on(1:length(off));
end
m = max(diff(on));
n = length(on);
mndur = min(off-on);
block = NaN(m,n);
for ii = 1:n-1;
	indx = (on(ii)-100):(on(ii)+mndur+100);
	sel = indx>0;
	indx = indx(sel);
	blckindx = 1:length(indx);
	block(blckindx,ii) = oxy(indx);
end
mublock = nanmean(block,2);
mublock = mublock-mublock(100);
sdblock = 1.96*nanstd(block,[],2)/n;
x		= 1:length(mublock);
sel = ~isnan(mublock);
errorpatch(x(sel),mublock(sel),sdblock(sel),'r');
hold on
xlabel('Time (samples)');
ylabel('OHb');
xlim([1 mndur+200])
% ylim(yax);
axis square
verline(100);
verline(mndur+100);

data		= handles.data;
dat			= cat(2,data.processed{:})';
oxy			= dat(:,handles.data.hdr.deoxyindx);
oxy			= oxy(:,handles.data.hdr.pos_indx);
oxy			= oxy(:,ctrial);
value	= [data.event.value];
sample	= [data.event.sample];
sel		= value == 1;
on		= sample(sel);
sel		= value == 0;
off		= sample(sel);
if length(on)>length(off)
	on = on(1:length(off));
end
m = max(diff(on));
n = length(on);
mndur = min(off-on);
block = NaN(m,n);
for ii = 1:n-1;
	indx = (on(ii)-100):(on(ii)+mndur+100);
	sel = indx>0;
	indx = indx(sel);
	blckindx = 1:length(indx);
	block(blckindx,ii) = oxy(indx);
end
mublock = nanmean(block,2);
mublock = mublock-mublock(100);
sdblock = 1.96*nanstd(block,[],2)/n;
x		= 1:length(mublock);
sel = ~isnan(mublock);
errorpatch(x(sel),mublock(sel),sdblock(sel),'b');
xlabel('Time (samples)');
ylabel('OHb/DHb');
xlim([1 mndur+200])
% ylim(yax);
axis square
verline(100);
verline(mndur+100);

function edit1_Callback(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_next_channel.
function btn_next_channel_Callback(hObject, eventdata, handles) %#ok<*INUSL>
% hObject    handle to btn_next_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ctrial	= handles.ctrial;
if ctrial<8
	ctrial	= ctrial+1;
end
handles.ctrial = ctrial;
handles = REFRESH_plottrial(handles);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in btn_prev_channel.
function btn_prev_channel_Callback(hObject, eventdata, handles)
% hObject    handle to btn_prev_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ctrial	= handles.ctrial;
if ctrial>1
	ctrial	= ctrial-1;
end
handles.ctrial = ctrial;
handles = REFRESH_plottrial(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in btn_zoom.
function btn_zoom_Callback(hObject, eventdata, handles)
% hObject    handle to btn_zoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~handles.zoom
	set(handles.btn_zoom,'String','Zoom off');
	zoom on;
	handles.zoom = true;
elseif handles.zoom
	set(handles.btn_zoom,'String','Zoom on');
	zoom off;
	handles.zoom = false;
end

% Update handles structure
guidata(hObject, handles);

% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
h                                      = get(hObject);
CC                                     = upper(h.CurrentCharacter);
switch CC
	case 'P'
		btn_prev_channel_Callback(hObject, eventdata, handles);
	case 'N'
		btn_next_channel_Callback(hObject, eventdata, handles);
end

function txt_lowfc_Callback(hObject, eventdata, handles)
flow			= get(hObject,'String');
handles.data.cfg.flow	= str2double(flow);
handles			= MAIN_reprocess(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function txt_lowfc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_lowfc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end

function txt_highfc_Callback(hObject, eventdata, handles)
fhigh			= get(hObject,'String');
handles.data.cfg.fhigh	= str2double(fhigh);
handles			= MAIN_reprocess(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function txt_highfc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_highfc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end


function txt_ev_Callback(hObject, eventdata, handles)
neigen			= get(hObject,'String');
handles.data.cfg.neigen	= str2double(neigen);
handles			= MAIN_reprocess(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function txt_ev_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_ev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pop_channel.
function pop_channel_Callback(hObject, eventdata, handles)
% hObject    handle to pop_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pop_channel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_channel

ctrial			= get(hObject,'Value');
handles.ctrial	= ctrial;
handles = REFRESH_plottrial(handles);

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function pop_channel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end


function txt_exclude_Callback(hObject, eventdata, handles)
% hObject    handle to txt_exclude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_exclude as text
%        str2double(get(hObject,'String')) returns contents of txt_exclude as a double

% --- Executes during object creation, after setting all properties.
function txt_exclude_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_exclude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end

function [f,mx]		= getpower(x,Fs)
% Sampling frequency
if nargin<2
	Fs = 1024;
end

% Time vector of 1 second
% Use next highest power of 2 greater than or equal to length(x) to calculate FFT.
nfft= 2^(nextpow2(length(x)));
% Take fft, padding with zeros so that length(fftx) is equal to nfft
fftx = fft(x,nfft);
% Calculate the numberof unique points
NumUniquePts = ceil((nfft+1)/2);
% FFT is symmetric, throw away second half
fftx = fftx(1:NumUniquePts);
% Take the magnitude of fft of x and scale the fft so that it is not a function of
% the length of x
mx = abs(fftx)/length(x);
% Take the square of the magnitude of fft of x.
mx = mx.^2;

% Since we dropped half the FFT, we multiply mx by 2 to keep the same energy.
% The DC component and Nyquist component, if it exists, are unique and should not
% be mulitplied by 2.
if rem(nfft, 2) % odd nfft excludes Nyquist point
	mx(2:end) = mx(2:end)*2;
else
	mx(2:end -1) = mx(2:end -1)*2;
end
% This is an evenly spaced frequency vector with NumUniquePts points.
f = (0:NumUniquePts-1)*Fs/nfft;
% Generate the plot, title and labels.
mx = 20*log10(mx);
sel = isinf(mx);
mx(sel) = min(mx(~sel));

function data = nirspca(handles,data)
% PDATA = NIRSPCA(DATA,FS,NEIG,METH,GRPH)
%
% Remove first NEIG (default: 1) eigenvectors from the NIRS-data DATA,
% which was sampled at FS Hz. You can choose to remove principal components
% across the 3 measures (HbO, HbR, HbT; default METH = 1) or separate
% (METH = 2).

%% Initialization
neig = handles.data.cfg.neigen;
if neig>0
	
	% 	optod = [handles.data.hdr.oxyindx handles.data.hdr.deoxyindx];
	% 	data(:,handles.data.hdr.deoxyindx) = -data(:,handles.data.hdr.deoxyindx);
	% 	[u,s,v]		= svd(data(:,optod)');
	% 	ev1			= v(:,1);
	%
	% 	s0		= zeros(size(s));
	% 	for kk	= 1:neig
	% 		s0(kk,kk) = s(kk,kk);
	% 	end
	% 	m		= u*s0*v';
	% 	m		= m';
	% 	data(:,optod)	= data(:,optod)-m;
	% 	data(:,handles.data.hdr.deoxyindx) = -data(:,handles.data.hdr.deoxyindx);
	% Fastest method, why?
	dat = data(:,handles.data.hdr.oxyindx);
	m	= mean(dat);
	M	= repmat(m,size(dat,1),1);
	coeff = princomp(dat);
	coeff	= coeff(:,1+neig:end);
	score	= (coeff'*(dat-M)')';
	dat		= (coeff * score')' + M;
	data(:,handles.data.hdr.oxyindx)= dat;
	
	dat = data(:,handles.data.hdr.deoxyindx);
	m	= mean(dat);
	M	= repmat(m,size(dat,1),1);
	coeff = princomp(dat);
	coeff	= coeff(:,1+neig:end);
	score	= (coeff'*(dat-M)')';
	dat		= (coeff * score')' + M;
	data(:,handles.data.hdr.deoxyindx)= dat;
	
	dat = data(:,[handles.data.hdr.oxyindx handles.data.hdr.deoxyindx]);
	m	= mean(dat);
	M	= repmat(m,size(dat,1),1);
	coeff = princomp(dat);
	coeff	= coeff(:,1+neig:end);
	score	= (coeff'*(dat-M)')';
	dat		= (coeff * score')' + M;
	data(:,[handles.data.hdr.oxyindx handles.data.hdr.deoxyindx]) = dat;
	
	% 	[u,s,v]		= svd(data(:,handles.data.hdr.oxyindx)'); %#ok<ASGLU>
	
end

function fdata		= filternirs(data,Fs,Fl,Fh)
% FDATA = FILTERNIRS(DATA,FS,FL,FH,GRPH)
%
% Bandpassfilter (at low FL and high FH cutoffs) nirs-DATA with
% samplingrate FS
%
% This is to remove components originating from slow fluctuations of
% cerebral blood flow and heartbeat noise
%
% See also READNIRS

n		= 3;
Fn		= Fs/2;
Wn		= [Fl Fh]/Fn;
ftype	= 'bandpass';
[b a]	= butter(n,Wn,ftype);
fdata	= data; % initialize!
for ii = 1:size(data,2);
	fdata(:,ii)	= filtfilt(b,a,data(:,ii));
	meandata	= mean(fdata(:,ii));
	fdata(:,ii)	= fdata(:,ii)-meandata;
end

function chck_filter_Callback(hObject, eventdata, handles)
user_entry                             = get(hObject,'Value');
handles.data.cfg.filter                = user_entry;
handles			= MAIN_reprocess(handles);
% Update handles structure
guidata(hObject, handles);

function chck_pca_Callback(hObject, eventdata, handles)
user_entry                             = get(hObject,'Value');
handles.data.cfg.pca                   = user_entry;
handles			= MAIN_reprocess(handles);
% Update handles structure
guidata(hObject, handles);

function chck_detrend_Callback(hObject, eventdata, handles)
user_entry                             = get(hObject,'Value');
handles.data.cfg.detrend                = user_entry;
handles                                = MAIN_reprocess(handles);

% Update handles structure
guidata(hObject, handles);

function h = errorpatch(X,Y,E,markcol)
%  H = ERRORPATCH(X,Y,E)
%
% plot an errors E around X,Y as a smoothlooking patch
%
% Author: Smooth Criminal

if size(X,1)>1
	X=X(:)';
	if size(X,1)>1
		error('X should be a vector');
	end
end
if size(Y,1)>1
	Y   = Y(:)';
	if size(Y,1)>1
		error('Y should be a vector');
	end
end
if size(E,1)>1
	E   = E(:)';
	if size(E,1)>1
		error('E should be a vector');
	end
end
if length(Y)~=length(X)
	error('Y and X should be the same size');
end

x           = [X fliplr(X)];
y           = [Y+E fliplr(Y-E)];
h           = patch(x,y,markcol);
alpha(h,0.4);
set(h,'EdgeColor','none');
hold on;
p = plot(X,Y,'k-');
% if strcmpi(markcol,'r')
% 	markcol = [1 0 0];
% elseif strcmpi(markcol,'b')
% 		markcol = [0 0 1];
% else
% 			markcol = [0 1 0];
% end
set(p,'LineWidth',2,'Color',markcol);
box on;


% --- Executes on button press in btn_save.
function btn_save_Callback(hObject, eventdata, handles)
% hObject    handle to btn_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fname        = pa_fcheckext(handles.fname,'.mat');
data = handles.data; %#ok<NASGU>
save(fname,'data');
disp(['Saved data in ' fname]);

function fname = fcheckexist(fname,fspec)
% Check existence of file
%
% FNAME = FCHECKEXIST(FNAME,FSPECI)
%
% See also FCHECKEXT
if nargin<2
	fspec               = '*.*';
end
if nargin<1
	fname               = '';
end

if isempty(fname)
	str                 = 'Choose a file';
else
	[pathstr,name,ext]  = fileparts(fname); %#ok<ASGLU>
	str                 = ['[' name ext '] not found, Choose a file'];
end

if ~exist(fname,'file')
	[fname,pname]       = uigetfile(fspec,str);
	fname               = [pname fname];
	if ~ischar(fname) % cancel has been pressed
		fname           = '';
		return
	end
end

function fname = fcheckext(fname,fext)
% Check extenstion of file
%
% FNAME = FCHECKEXT(FNAME,FEXT)
%
% Check whether the file FNAME has extension FEXT. If not, the
% extension will be replaced or added.
%
% See also FCHECKEXIST
%
if ~strcmp(fext(1),'.')
	fext = ['.' fext];
end;

[pathstr,name,ext,versn] = fileparts(fname);
if ~strcmp(ext,fext)
	ext     = fext;
end
fname       = fullfile(pathstr,[name ext versn]);


% --- Executes on button press in chck_freqplot.
function chck_freqplot_Callback(hObject, eventdata, handles)
user_entry                             = get(hObject,'Value');
handles.data.cfg.powerplot               = user_entry;
handles                                = REFRESH_plottrial(handles);

% Update handles structure
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_file_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_load_new_Callback(hObject, eventdata, handles)
% hObject    handle to menu_load_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% [filename, pathname] = uigetfile( ...
% 	{'*.xls', 'All xls-Files (*.xls)'; ...
% 	'*.*','All Files (*.*)'}, ...
% 	'Select Trace File');
% % If "Cancel" is selected then return
% if isequal([filename,pathname],[0,0])
% 	return
% 	% Otherwise construct the fullfilename and Check and load the file
% else
% 	cd(pathname);
handles                                = MAIN_Check_And_Load(handles);
handles                                = MAIN_process(handles);
handles                                = MAIN_detect(handles);
handles                                = MAIN_plottrial(handles);
% Choose default command line output for nirs_artefact_detection
handles.output = hObject;
% end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in btn_saveas.
function btn_saveas_Callback(hObject, eventdata, handles)
% hObject    handle to btn_saveas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fname,pname]       = uiputfile('*.mat','Choose a file');
fname               = [pname fname];
data		= handles.data; %#ok<NASGU>
save(fname,'data');
disp(['Saved data in ' fname]);


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in chck_down.
function chck_down_Callback(hObject, eventdata, handles)
% hObject    handle to chck_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chck_down



function txt_downfreq_Callback(hObject, eventdata, handles)
% hObject    handle to txt_downfreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_downfreq as text
%        str2double(get(hObject,'String')) returns contents of txt_downfreq as a double


% --- Executes during object creation, after setting all properties.
function txt_downfreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_downfreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end
