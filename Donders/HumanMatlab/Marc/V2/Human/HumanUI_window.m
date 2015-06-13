% buttons and stim props
figure('name','User Interface','numbertitle','off','menubar','none','Tag','UserInterface');

HuiStop			= uicontrol('position',[0 0 60 30],'style','pushbutton','string','STOP','callback','set(HuiStop,''string'',''wait'');RUN=0;','tag','RUN=1');
HuiView			= uicontrol('position',[60 0 60 30],'style','pushbutton','string','ViewFigs','callback','viewallfigs');
HuiDispStuff	= uicontrol('position',[0 30 120 30],'style','togglebutton','string','Display stuff','value',1);

Y=2;
HuiFixDurMin	= uicontrol('position',[0 30*Y 60 30],'Style','edit','String','999');
HuiFixDurMax	= uicontrol('position',[60 30*Y 60 30],'Style','edit','String','999');
uicontrol('position',[120 30*Y 60 30],'Style','text','String','FixDur (min max)');Y=Y+1;

HuiGap1Dur      = uicontrol('position',[0 30*Y 60 30],'Style','edit','String','999');
HuiGap2Dur  	= uicontrol('position',[60 30*Y 60 30],'Style','edit','String','999');
uicontrol('position',[120 30*Y 60 30],'Style','text','String','GapDur (1 2)');Y=Y+1;

HuiTar1Dur		= uicontrol('position',[0 30*Y 60 30],'Style','edit','String','999');
HuiTar2Dur		= uicontrol('position',[60 30*Y 60 30],'Style','edit','String','999');
uicontrol('position',[120 30*Y 60 30],'Style','text','String','TarDur (1 2)');Y=Y+1;

HuiFixInt		= uicontrol('position',[0 30*Y 60 30],'Style','edit','String','999');
uicontrol('position',[120 30*Y 60 30],'Style','text','String','FixInt');Y=Y+1;

HuiTar1Int		= uicontrol('position',[0 30*Y 60 30],'Style','edit','String','999');
HuiTar2Int		= uicontrol('position',[60 30*Y 60 30],'Style','edit','String','999');
uicontrol('position',[120 30*Y 60 30],'Style','text','String','TarInt (1 2)');Y=Y+1;

HuiVelCrit		= uicontrol('position',[0 30*Y 60 30],'Style','edit','String','999');
uicontrol('position',[120 30*Y 60 30],'Style','text','String','Trigger Velocity');Y=Y+1;

HuiPredDel		= uicontrol('position',[0 30*Y 60 30],'Style','edit','String','999');
uicontrol('position',[120 30*Y 60 30],'Style','text','String','Prediction Delay');Y=Y+1;

HuiTrigDel		= uicontrol('position',[0 30*Y 60 30],'Style','edit','String','999');
uicontrol('position',[120 30*Y 60 30],'Style','text','String','Trigger Delay');Y=Y+1;

HuiTTLDur		= uicontrol('position',[0 30*Y 60 30],'Style','edit','String','999');
uicontrol('position',[120 30*Y 60 30],'Style','text','String','TTLDur');Y=Y+1;

HuiAcqDur		= uicontrol('position',[0 30*Y 60 30],'Style','edit','String','999');
uicontrol('position',[120 30*Y 60 30],'Style','text','String','AcqDur (smpls)');Y=Y+1;
