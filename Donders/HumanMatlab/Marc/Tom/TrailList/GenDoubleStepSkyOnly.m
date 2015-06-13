clear all
close all
%clc

%% -- Flags --%
LargeSky_Flag	=	0;	%-- 1: Use 16 rings -> Max: 90 deg						--%
Restrict_Flag	=	0;	%-- 1: Head-fixed monkey can't see lower targets		--%
ShowArray_Flag	=	0;	%-- 1: Show the trial sequence							--%
Write_Flag		=	0;	%-- 1: Write the .exp-file								--%
ShowExp_Flag	=	0;	%-- 1: Open .exp-file in texteditor						--%
WriteCSV_Flag	=	0;	%-- 1: Write .csv-file used for simulations				--%
WriteMat_Flag	=	1;	%-- 1: Write .mat file for monkey setup					--%
AddFigs_Flag	=	1;	%-- 1: Additional test figures							--%
AllowCenter_Flag=   0;  %-- 1: Allow center-led to be the first target          --%

%% -- Path --%
%Root			=	'/Users/peterbr/Work/Experiments/DMI/OptimalCalib/Boogfiles/SkyOnly/LimitNbrTrls/';

%% -- Variables --%
NSample		=	1500;
NFix		=	200;
Ntarget		=	600;
NbrReps		=	1;
Random		=	0;
OMrange		=	45;
MinStep		=	2;	%-- Minimal n o steps (1: single step)					--%
MaxStep		=	2;	%-- Maximal n o steps (1: single step)					--%

%% -- possible targets --%
Spoke		=	1:12;
if( LargeSky_Flag )
	Ring		=	1:10;
else
	Ring		=	1:7;
end
sr			=	nan( length(Spoke)*length(Ring)+1, 2 );
sr(1,:)		=	[0 2];
cnt			=	2;
for i=1:length(Spoke)
	for j=1:length(Ring)
		sr(cnt,:)		=	[Spoke(i) Ring(j)];
		cnt				=	cnt + 1;
	end
end

if( LargeSky_Flag )
	[azi,ele]	=	sky2azelPB(sr(:,2),sr(:,1));
else
	[azi,ele]	=	sky2azel(sr(:,2),sr(:,1));
end
Tarpool		=	[azi,ele,sr];

%% -- adjust target pool and plot
if( Restrict_Flag )
    Amp			=	sqrt( Tarpool(:,1).^2 + Tarpool(:,2).^2 );
    uAmp		=	unique(Amp);
    sel			=	Amp > 28 & Tarpool(:,2) < 0;
    AE			=	Tarpool(sel,:);
    Tarpool		=	Tarpool(~sel,:);
end
if AddFigs_Flag
    figure
%    plotfartlim
%    plotsky
    plot(Tarpool(:,1),Tarpool(:,2),'ko','MarkerFaceColor','k')
%    plot(AE(:,1),AE(:,2),'ko','MarkerFaceColor','w')
    xlim([-50 50])
    ylim([-50 50])
    set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
    xlabel('azimuth [deg]')
    ylabel('elevation [deg]')
    axis('square')
end

len			=	size(Tarpool,1);
start		=	ceil(len.*rand(1,1));

%% -- Calculate a circle centered at the target location --%
x	=	OMrange * cosd(0:360) + Tarpool(start,1);
y	=	OMrange * sind(0:360) + Tarpool(start,2);

Tar	=	nan(Ntarget,4);
for i=1:Ntarget
	Found_Flag	=	0;
	t			=	0;
	tic;
	while( ~Found_Flag )
		idx2	=	ceil(len.*rand(1,1));
		NewTar	=	Tarpool(idx2,:);
		sel		=	NewTar(1,1) <= max(x) & NewTar(1,1) >= min(x) & ...
					NewTar(1,2) <= max(y) & NewTar(1,2) >= min(y) & NewTar ~= Tarpool(start,:);
		t		=	toc;
		if( sum(sel) >= 1 || t >= 30 )
			Found_Flag = 1;
		end
	end
	
	Tar(i,:)	=	NewTar;
	
	%-- Assign new target location --%
	start	=	idx2;
	x		=	OMrange * cosd(0:360) + Tarpool(start,1);
	y		=	OMrange * sind(0:360) + Tarpool(start,2);	
end
clear azi ele sr cnt

%% -- That's what you want to have... --%

% ==>
% trg0			1	2	0	    0			1
% Acq							1			Skyoff-200
% Sky	   0	  1		255		0     0		1	800(rnd)=Skyoff
% LED	 90     101	 	  7     0     0     1	1000
% Snd	-30		30	 200 70		1	800+200=Sndon	1	2000
% Snd	-30		-30	 200 70		1	800+200=Sndon

% ==>
% trg0			1	2	0	    0			1
% Acq							1				2000
% Sky	   0	  0		  1		0     0		1	800(rnd)=Skyoff
% Snd	-165	113	 200 70		1	800+200=Sndon

%% -- Arrays --%
Trg		=	([1,2,0,0,1]);
Acq		=	([1 0]);
Sky1	=	zeros(Ntarget,7);
Sky2	=	zeros(Ntarget,7);

Sky1(1,:)	=	[ 0, 2, 100, 0, 0, 1, NFix ];
for i=2:Ntarget
	Sky1(i,[1,2,3,4,5,6,7])	=	[ Tar(i-1,3), Tar(i-1,4), 100, 0, 0, 1, NFix ];
end
for i=1:Ntarget
	Sky2(i,[1,2,3,4,5,6,7])	=	[ Tar(i,3), Tar(i,4), 100, 1, NFix, 1, NSample ];
end

%% -- Plot the stimulus array --%
if( ShowArray_Flag )
	for i=1:Ntarget
		if( LargeSky_Flag )
			[Fix(1,1),Fix(1,2)]	=	sky2azelPB(Sky1(i,2),Sky1(i,1));
			[Sky(1,1),Sky(1,2)]	=	sky2azelPB(Sky2(i,2),Sky2(i,1));
		else
			[Fix(1,1),Fix(1,2)]	=	sky2azel(Sky1(i,2),Sky1(i,1));
			[Sky(1,1),Sky(1,2)]	=	sky2azel(Sky2(i,2),Sky2(i,1));
		end
		
		if( i ~= Ntarget )
			if( LargeSky_Flag )
				[Nxt(1,1),Nxt(1,2)]	=	sky2azelPB(Sky2(i+1,2),Sky2(i+1,1));
			else
				[Nxt(1,1),Nxt(1,2)]	=	sky2azel(Sky2(i+1,2),Sky2(i+1,1));
			end
		end
		x	=	OMrange * cosd(0:360) + Sky(1,1);
		y	=	OMrange * sind(0:360) + Sky(1,2);
		
		figure
		clf
		plot(Tarpool(:,1),Tarpool(:,2),'ko','MarkerFaceColor','k')
		xlabel('Azimuth [deg]')
		ylabel('Elevation [deg]')
		xlim([-75 75])
		ylim([-75 75])
		axis('square')
		title([ 'Trl ' num2str(i) '/' num2str(Ntarget) ])
		box on
		hold on
		h(1) = plot(Fix(1,1),Fix(1,2),'go','MarkerFaceColor','g');
		pause(NFix*5*10^-3)
		h(2) = plot(Fix(1,1),Fix(1,2),'ko','MarkerFaceColor','w');
		
		h(3) = plot(Sky(1,1),Sky(1,2),'ro','MarkerFaceColor','r');
		h(4) = plot(Nxt(1,1),Nxt(1,2),'bo','MarkerFaceColor','b');
		h(5) = plot(x,y,'r-');
		legend(h,'Fix_o_n','Fix_o_f_f','Tar','Nxt_t_a_r','Limit')
		
		pause(NSample*10^-3)
	end
end

%% -- Write the expfile --%
if( Write_Flag )
	FileName	=	['rand' num2str(Ntarget) 'TarsSkyRestrict'];
	ExpName		=	[Root FileName '.exp'];
	ExpName		=	fcheckext(ExpName,'.exp');

	fid			=	fopen(ExpName,'w');

	%-- Header of exp-file --%
	fprintf(fid,'%s\n','%');
	fprintf(fid,'%s\n','%% Experiment: C:\Human\');
	fprintf(fid,'%s\n','%');
	fprintf(fid,'%s\t\t%d\t%d\n','ITI',0,0);
	fprintf(fid,'%s\t%d\n','Trials',Ntarget);
	fprintf(fid,'%s\t%d\n','Repeats',NbrReps);
	fprintf(fid,'%s\t%d\t%s\n','Random',Random,'% 0=no, 1=per set, 2=all trials');
	fprintf(fid,'%s\t\t%s\n','Motor','y');
	fprintf(fid,'\n');
	%-- Information Line of body --%
	fprintf(fid,'%s %s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','%','MOD','X','Y','ID','INT','On','On','Off','Off','Event');
	fprintf(fid,'%s\t\t\t%s\t%s\t%s\t%s\t%s\t%s\n','%','edg','bit','Event','Time','Event','Time');

	%-- Body of exp-file	--%
	%-- Create a trial for	--%
	%-- each location		--%

	for i=1:Ntarget

		fprintf(fid,'\n');
		fprintf(fid,'%s\t%d\n','%Trl: ', i);
		fprintf(fid,'%s\n','==>');

		fprintf(fid,'%s\t\t\t%d\t%d\t%d\t%d\t\t\t%d\n','Trg0',...
			Trg(1,1),Trg(1,2),Trg(1,3),Trg(1,4),Trg(1,5) );
		fprintf(fid,'%s\t\t\t\t\t%d\t%d\n','Acq',...
			Acq(1,1),Acq(1,2) );
		
		fprintf(fid,'%s\t%d\t%d\t \t%d\t%d\t%d\t%d\t%d\n','Sky',...
			Sky1(i,1),Sky1(i,2),Sky1(i,3),Sky1(i,4),Sky1(i,5),Sky1(i,6),Sky1(i,7));
		fprintf(fid,'%s\t%d\t%d\t \t%d\t%d\t%d\t%d\t%d\n','Sky',...
			Sky2(i,1),Sky2(i,2),Sky2(i,3),Sky2(i,4),Sky2(i,5),Sky2(i,6),Sky2(i,7));

		fprintf(fid,'\n');

	end

	fclose(fid);

	%-- Show the .exp file in editor --%
	if( ShowExp_Flag )

		if( isunix  )
			unix(['open ' ExpName]);
		else
			dos(['"C:\Program Files\Windows NT\Accessories\wordpad.exe" ' ExpName ' &']);
		end

	end
end

%% -- Write the csvfile --%
if( WriteCSV_Flag )
	FileName	=	['rand' num2str(Ntarget) 'TarsSkyRestrict'];
	ExpName		=	[Root FileName '.csv'];
	ExpName		=	fcheckext(ExpName,'.csv');

	writecsvsky(ExpName,Ntarget,NSample,Sky1,Sky2);
end

%% -- Write the matfile --%
if( WriteMat_Flag )
	k			=	0;
	while k ~= 1
		NTar	=	round( MinStep + (MaxStep-MinStep) * rand(Ntarget,1) );

		crit	=	0;
		cnt		=	1;
		while crit < Ntarget
			crit	=	crit + NTar(cnt);
			cnt		=	cnt + 1;
		end
		if( crit ~= Ntarget )
			k = 0;
		else
			k = 1;
		end
	end
	NTar	=	NTar(1:cnt-1);

	RPhi	=	nan(Ntarget,1);
	cnt		=	1;
	for k=1:Ntarget
		RPhi(cnt:cnt+1,1)	=	[Sky1(k,2); Sky1(k,1)];
		cnt					=	cnt + 2;
	end
	
	inc		=	21;
	len		=	length(NTar);
	Mtx		=	zeros(len*inc,1);
	c1		=	1;
	c2		=	1;
	for k=1:len
		Mtx(c1,1)		=	NTar(k);
		idx1			=	c1+1:c1+NTar(k)*2;
		idx2			=	c2:c2-1+NTar(k)*2;
		Mtx(idx1,1)		=	RPhi(idx2,1);
		c1				=	c1 + inc;
		c2				=	idx2(end) + 1;
	end
	
	Mtx			=	Mtx';

	save_flag=1;			% 0 to simulate and debug
	if (save_flag==1) 		% Matlab
		FileName	=	['DoubleStep' num2str(Ntarget) '_' datestr(now,'yyyy-mm-dd')];
		disp(FileName)
		cd 'D:\HumanMatlab\Tom\TrailList';
		save([FileName '.mat'],'Mtx')
	elseif (save_flag==2)	% robs programm
		fid=fopen([FileName '.bin'], 'w');
		fwrite(fid, Mtx, 'float32');
		fclose(fid);
    end
    if AllowCenter_Flag ~= 1
        tMtx = reshape(Mtx,21,[])';
        sel = tMtx(:,3)==0;
        % replace by target on ring 1
        NewTars = [fix(rand(sum(sel),1)*12+1) ones(sum(sel),1)];
        tMtx(sel,[2 3]) = NewTars;
        Mtx = reshape(tMtx',1,[]);
    end
        
end

%% -- plot --%
if( AddFigs_Flag )
	figure
	clf
	
	subplot(2,2,1)
	plot([-90 0],[0 90],'-','Color',[.7 .7 .7])
	hold on
	plot([0 90],[90 0],'-','Color',[.7 .7 .7])
	plot([90 0],[0 -90],'-','Color',[.7 .7 .7])
	plot([0 -90],[-90 0],'-','Color',[.7 .7 .7])
	plot(Tarpool(:,1),Tarpool(:,2),'ko')
	plot(Tar(:,1),Tar(:,2),'ko','MarkerFaceColor','k')
	xlim([-max([Tar(:,1);Tar(:,2)])-5 max([Tar(:,1);Tar(:,2)])+5])
	ylim([-max([Tar(:,1);Tar(:,2)])-5 max([Tar(:,1);Tar(:,2)])+5])
	xlabel('azimuth [deg]')
	ylabel('elevation [deg]')
	title([ 'max: ' num2str( max(abs([Tar(:,1);Tar(:,2)])) ) ' deg' ])
	axis('square')
	
	if( LargeSky_Flag )
		[Fixaz,Fixel]	=	sky2azelPB(Sky1(:,2),Sky1(:,1));
		[Taraz,Tarel]	=	sky2azelPB(Sky2(:,2),Sky2(:,1));
	else
		[Fixaz,Fixel]	=	sky2azel(Sky1(:,2),Sky1(:,1));
		[Taraz,Tarel]	=	sky2azel(Sky2(:,2),Sky2(:,1));
	end
	
	r				=	sqrt( (Fixaz-Taraz).^2 + (Fixel-Tarel).^2 );
	ucombi			=	size( unique([Fixaz Fixel Taraz Tarel],'rows'),1 );
	
%	RPhi			=	azelrphi(Fixaz-Taraz,Fixel-Tarel);
%	d				=	RPhi(:,2);
	
	subplot(2,2,2)
	hist(r)
	xlabel('amplitude r [deg]')
	ylabel('# occurences')
	title(['Unique combinations: ' num2str(ucombi) '/' num2str(Ntarget) ' = ' num2str(ucombi/Ntarget*100) '%'])
	
	subplot(2,2,4)
%	hist(d)
	xlabel('direction phi [deg]')
	ylabel('# occurences')
end

%% -- Cleaning up --%
%clear all

disp('Mission accomplished!')
