function pa_audcenter_subject

clc;
close all hidden;
clear all

subject = 'MW';


%% determine thresholds
figure(1)

switch subject
	case 'BB'
subplot(221)
dname = 'E:\DATA\Test\Auditory Center\MW-BB-2012-10-23';
fname = 'MW-BB-2012-10-23-0001.dat';
aaleft = pa_audcenter_aa(fname,dname);

subplot(222)
dname = 'E:\DATA\Test\Auditory Center\MW-BB-2012-10-23';
fname = 'MW-BB-2012-10-23-0002.dat';
aaright = pa_audcenter_aa(fname,dname);

	case 'MW'
subplot(221)
dname = 'E:\DATA\Test\Auditory Center\RG-MW-2012-10-29';
fname = 'RG-MW-2012-10-29-0001.dat';
aaleft = pa_audcenter_aa(fname,dname);

subplot(222)
dname = 'E:\DATA\Test\Auditory Center\RG-MW-2012-10-29';
fname = 'RG-MW-2012-10-29-0002.dat';
aaright = pa_audcenter_aa(fname,dname);
aaright = 39;
end

%% Print
pa_datadir;
print('-depsc','-painter',[mfilename '1']);

%% determine X,Y
figure(2)
[x,y] = pa_audcenter2(aaleft,aaright);
% pa_audcenter2(-39,39);

%% Print
pa_datadir;
print('-depsc','-painter',[mfilename '2']);