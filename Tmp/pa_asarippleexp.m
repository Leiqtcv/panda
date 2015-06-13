function pa_asarippleexp
% PA_ASARIPPLEEXP
%
% Experiment Ripples in Auditory Scene Analysis.
% In the first interval a constant signal ripple will be represented, while
% in the second any mixture of the signal ripple and a second random ripple
% is presented:
% - 0*signal + 1*mask
% - 1*signal + 1*mask
% - 1*signal + 0*mask
%
%
% See also PA_GENRIPPLE

% (c) 2012 Peter Bremen
%
% Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

%% Initialization
tic
close all hidden
clc

%% Flags

%% Variables
Pname	=	'E:\DATA\';
Subj	=	'MW-2012-10-24';

Vel1	=	10;			% Ripple velocity [Hz]
Dens1	=	0;			% Ripple density [cyc/oct]
Mod1	=	0.5;			% Modulation depth (0-1)
Dur1	=	1000;		% Duration [msec]

Vel2	=	0:5:20;		% Ripple velocity [Hz]
Dens2	=	-4:2:4;		% Ripple density [cyc/oct]
Mod2	=	0.5:0.5:1;			% Modulation depth (0-1)
Dur2	=	1000;		% Duration [msec]

Delay	=	0;			% Delay S2 re S1 [msec]
Amp		=	.4;			% AMplitude [0 1]
Nrep	=	5;			% Number of repetitions

% Fs		=	48828.125;	% Sampling frequency [Hz], for TDT
Fs		=	50000;	% Sampling frequency [Hz]

Ndelay	=	round(Delay * 10^-3 * Fs);
Dur2	=	Dur2 - Delay;

%% Setup the trial matrix
stmMtx	=	makemtx(Vel2,Dens2,Mod2,Vel1,Dens1,Mod1,Nrep);
nTrl	=	length(stmMtx);
S		= struct([]);

%% Paint the GUI and wait for button press before starting
hGui	=	makegui(nTrl);

if waitforbuttonpress == 0
    disp('%-------------------------------------------------%')
	disp('%--		Starting experiment		--%')
	str = ['This will take at least ' num2str((nTrl*((Dur1+Dur2)/1000)+1)/60) ' min'];
	disp(str);
	disp('%-------------------------------------------------%')
end

%% Work through the trial list
for ii = 1:nTrl
	set(gcf,'Name',[num2str(ii) '/' num2str(nTrl) ' trials'])

	snd1	=	pa_genripple(Vel1,Dens1,Mod1*100,Dur1,0,'Fs',Fs);
	snd2	=	pa_genripple(stmMtx(ii,1),stmMtx(ii,2),stmMtx(ii,3)*100,Dur2,0,'Fs',Fs);
	snd2	=	[zeros(1,Ndelay) snd2]; %#ok<AGROW>
	
	%% Normalization
	snd1	=	Amp * snd1 / max(abs(snd1));
	snd2	=	Amp * snd2 / max(abs(snd2));
	
	if( stmMtx(ii,4) == 1 )
		snd	=	snd2 + snd2;
	else
		snd	=	snd1 + snd2;
	end
	snd		=	Amp * snd / max(abs(snd));
	
	set(hGui(1),'Str','please listen to the sound...')
	
	if( isunix )
		sound(snd1,Fs);
		sound(snd,Fs);
	else
		p1 = audioplayer(snd1,Fs); %#ok<*TNMLP>
		p2 = audioplayer(snd,Fs);
		playblocking(p1);
		playblocking(p2);
		
	end
	set(hGui(1),'Str','please press a button...')
	
% 	if waitforbuttonpress == 0
% 		disp('waiting')
% 	end
	keydown = waitforbuttonpress;
	if (keydown == 0)
            disp('Mouse button was pressed');
        else
            disp('Key was pressed');
	end
	
	h	=	getguiobj(hGui,'Pause');
	pause(.5)	%-- This delay is needed otherwise the state is not updated --%
	
	if( get(h,'Value') == 0 )
		set(hGui(1),'Str','press start to resume')
		waitfor(h,'Value',1)
	else
		pause(.1)
		h	=	getguiobj(hGui,'No');
		Str	=	get(h,'Tag');
		if( strcmpi(Str,'pressed') )
			Resp	=	1;	%-- No --%
		else
			Resp	=	0;	%-- Yes --%
		end
		set(h,'Tag','xxxxxxx')
		
		S(ii).response			= Resp;
		S(ii).maskvelocity		= stmMtx(ii,1);
		S(ii).maskdensity		= stmMtx(ii,2);
		S(ii).maskmodulation	= stmMtx(ii,3);
		S(ii).zeros				= stmMtx(ii,4); %?
		S(ii).sgnvelocity		= Vel1;
		S(ii).sgndensity		= Dens1;
		S(ii).sgnmodulation		= Mod1;
		S(ii).delay				= Delay;
		S(ii).amplitude			= Amp;
		S(ii).sgnduration		= Dur1;
		S(ii).samplefreq		= Fs;
		S(ii).trial				= ii;
		
		%% Save after each trial
		str = [Pname Subj '-' date];
		save(str,'S')
	end
end
set(hGui(1),'Str','Congratulations! You did it!')
set(getguiobj(hGui,'Pause'),'Visible','off')
set(getguiobj(hGui,'Yes'),'Visible','off')
set(getguiobj(hGui,'No'),'Visible','off')

str = [Pname Subj '-' date '-Completed' ];
save(str,'S')

%-- Wrapping up --%
tend	=	(round(toc*100)/100 );
str		=	sprintf('\n%s\n',['Mission accomplished after ' num2str(tend) ' sec!']);
disp(str)


function Mtx = makemtx(Vel,Dens,Mod,cVel,cDens,cMod,Nrep)
% MTX = MAKEMTX(VEL,DENS,MD,CVEL,CDENS,CMD,NREP)
%
% Create stimulus matrix

%% Recombine Velocity, Density and Modulation Depth of mask
[X,Y,Z]	=	meshgrid(Vel,Dens,Mod);
X		=	X(:);
Y		=	Y(:);
Z		=	Z(:);
Mtx		=	[X,Y,Z];

%% Add catch trial
sel		=	cVel == Mtx(:,1) & cDens == Mtx(:,2) & cMod == Mtx(:,3);	%-- Make sure that you don't select Snd1 = Snd2 --%
M		=	Mtx(~sel,:);
C		=	[ M(randperm(sum(~sel),sum(sel)),:) ones(sum(sel),1)];
M		=	[Mtx zeros(size(Mtx,1),1)];
Mtx		=	[M; C];

%% Replicate by N number of repetitions
Mtx		=	repmat(Mtx,Nrep,1);

%% Randomize
len		=	length(Mtx);
idx		=	randperm(len);
Mtx		=	Mtx(idx,:);

function h = makegui(Ntrl)
f	=	figure(1);
% set(f,'Units','normalized','Position',[0 1 1 1])
clf
set(f,'MenuBar','none','Name',['1/' num2str(Ntrl) ' trials'],'NumberTitle','off')

h(1) = uicontrol( f,'Style','text',...
                'String','press start to begin', ...
				'Units','normalized','Position',[.45 .9 .1 .05], ...
				'FontName','Arial','FontWeight','bold','FontSize',14);

h(2) = uicontrol(	f,'Style','togglebutton','String','Start','BackgroundColor','g',...
				'Units','normalized','Position',[.2 .9 .1 .05], ...
				'FontName','Arial','FontWeight','bold','FontSize',14, ...
				'Callback',{@startbutton} );

h(3) = uicontrol(	f,'Style','pushbutton','String','Yes',...
				'Units','normalized','Position',[.45 .7 .1 .05], ...
				'FontName','Arial','FontWeight','bold','FontSize',14, ...
				'Callback',{@yesbutton} );
		
h(4) = uicontrol(	f,'Style','pushbutton','String','No',...
				'Units','normalized','Position',[.45 .6 .1 .05], ...
				'FontName','Arial','FontWeight','bold','FontSize',14, ...
				'Callback',{@nobutton} );

drawnow

function h = getguiobj(hGui,str)
len	=	length(hGui);
for ii=1:len
	if( strcmp( get(hGui(ii),'String'),str ) )
		h	=	hGui(ii);
	end
end

function startbutton(source,~)
if( get(source,'Val') == 0 )
	set(source,'String','Start')
elseif( get(source,'Val') == 1 )
	set(source,'String','Pause')
end

function yesbutton(source,~)

set(source,'Tag','pressed')
disp('reference present')

function nobutton(source,~)

set(source,'Tag','pressed')
disp('reference not present')


