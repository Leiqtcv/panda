function A42_Prediction
close all
clear all

% Analysis step by step

% Output:
% g     = offset and gain (el)
% g2    = offset and gain (az)
% gain  = elevation gain
% gain2 = azimuth gain
% s     = residuen (el)
% s2    = residuen (az)

% Figure 1
% Raw data (stimulus-response plots) without any correction


% Figure 3
% Individual gains per subject
% 1 az, 2 el not normalized
% 3 az, 4 el normalized

% Figure 4
% Averaged gains
% 1 az, 2 el not normalized
% 3 az, 4 el normalized

%cc

subjects	= {'RG';'JB';'DL';'RD';'PR';'SM';};
nsubjects	= length(subjects);
gain		= NaN(nsubjects,3);     % Elevation gain
gain2       = gain;                       % Azimuth gain
s           = NaN(nsubjects,3);               % Residuen el
s2          = s;                             % Residuen az
% RT = NaN(nsubjects,4)
for ii = 1:nsubjects
	subject = subjects{ii};
	% Determine Gain and offset, B = el; B2 = az
	[G(ii,:),B(ii,:),r(ii,:),az,el] = getgain(subject);
	
	
	
	
	%%
	ncond = 5;
	cond = [0 10 20 30 0];
	for jj = 1:ncond
		x	= az(jj).tar;
		y	= el(jj).tar;
		mux = median(x);
		muy = median(y);
			xi = -90:90;
		ks = ksdensity(x,xi);
		ks2 = ksdensity(y,xi);
		[KS,KS2] = meshgrid(ks,ks2);
		KS = KS.*KS2;
		KS = KS./max(KS(:));
		ks = 20*ks./max(ks)-90;
		
		
		uxy	= unique([x y],'rows');
		nx	= size(uxy,1);
		N	= NaN(nx,1);
		
		figure(ii)
		subplot(2,5,jj)
		hold on
		for kk = 1:nx
			sel = x==uxy(kk,1) & y == uxy(kk,2);
			N(kk) = sum(sel);
		end
		N = ceil(5*N./max(N));
		for kk =1:nx
			plot(uxy(kk,1),uxy(kk,2),'ko','MarkerFaceColor','k','MarkerSize',N(kk),'LineWidth',2);
		end
		axis([-90 90 -30 90]);
		axis square;
		xlabel('Target azimuth (deg)');
		ylabel('Target elevation (deg)');
		set(gca,'XTick',-60:30:60,'YTick',-60:30:60);
		pa_horline(cond(jj));
% 		stairs(xi,ks,'k-');
		contour(xi,xi,KS,4,'LineWidth',2);
		
		
		x = az(jj).res;
		y = el(jj).res;
		xi = -90:90;
		ks = ksdensity(x,xi);
		ks2 = ksdensity(y,xi);
		[KS,KS2] = meshgrid(ks,ks2);
		KS = KS.*KS2;
		KS = KS./max(KS(:));
		ks = 20*ks./max(ks)-90;
		
		mux = median(x);
		muy = median(y);
		x	= round(x/5)*5;
		y	= round(y/5)*5;
		uxy	= unique([x y],'rows');
		nx	= size(uxy,1);
		N	= NaN(nx,1);
		
		figure(ii)
		subplot(2,5,jj+5)
		hold on
		for kk = 1:nx
			sel = x==uxy(kk,1) & y == uxy(kk,2);
			N(kk) = sum(sel);
		end
		N = ceil(5*N./max(N));
		for kk =1:nx
			plot(uxy(kk,1),uxy(kk,2),'ko','MarkerFaceColor',[.7 .7 .7],'MarkerSize',N(kk),'LineWidth',1);
		end
		axis([-90 90 -30 90]);
		axis square;
		xlabel('Response azimuth (deg)');
		ylabel('Response elevation (deg)');
		set(gca,'XTick',-60:30:60,'YTick',-60:30:60);
		% 	title(cond{jj});
		pa_horline(cond(jj));
% 		pa_horline(muy,'r-');
% 		pa_verline(mux,'r-');
		plot(mux,muy,'ro','markerFaceColor','w','LineWidth',2,'markerSize',10);
% 		stairs(xi,ks,'k-');
		contour(xi,xi,KS,4,'LineWidth',2);
	end
	drawnow
% 	pause
end
pa_datadir;
print('-depsc','-painter',[mfilename '1']);

%%%%
% keyboard
return


function [G,B,r,az,el] = getgain(subject)


switch subject
    case 'RG'
        fnames = {'JB-RG-2013-05-22-0001';'JB-RG-2013-05-22-0002';...
                  'JB-RG-2013-05-22-0004';'JB-RG-2013-05-22-0005';...
                  'JB-RG-2013-05-22-0003';...
            };
        conditions = [3 1 ...
                      4 2 ...
                      5 ...
            ];

    case 'JB'
        fnames = {'RG-JB-2013-05-22-0001';'RG-JB-2013-05-22-0002';...
                  'RG-JB-2013-05-22-0004';'RG-JB-2013-05-22-0005';...
                  'RG-JB-2013-05-22-0003';...
            };
        conditions = [2 3 ...
                      1 4 ...
                      5 ...
            ];
        
    case 'DL'
        fnames = {'JB-DL-2013-05-24-0001';'JB-DL-2013-05-24-0003';...
                  'JB-DL-2013-05-24-0004';'JB-DL-2013-05-24-0005';...
                  'JB-DL-2013-05-24-0002';...
            };
        conditions = [4 2 ...
                      3 1 ...
                      5 ...
            ];
        
    case 'RD'
        fnames = {'JB-RD-2013-05-24-0001';'JB-RD-2013-05-24-0002';...
                  'JB-RD-2013-05-24-0003';'JB-RD-2013-05-24-0005';...
                  'JB-RD-2013-05-24-0004';...
            };
        conditions = [3 4 ...
                      2 1 ...
                      5 ...
            ];       
        
    case 'PR'
        fnames = {'JB-PR-2013-05-30-0001';'JB-PR-2013-05-30-0002';...
                  'JB-PR-2013-05-30-0005';...
				  'JB-PR-2013-05-30-0005';...
                  'JB-PR-2013-05-30-0004';...
            };
        conditions = [2 1 ...
                      4 3 ...
                      5 ...
            ];
         
        
    case 'SM'
        fnames = {'JB-SM-2013-05-30-0001';'JB-SM-2013-05-30-0003';...
                  'JB-SM-2013-05-30-0004';'JB-SM-2013-05-30-0005';...
                  'JB-SM-2013-05-30-0002';...
            };
        conditions = [1 3 ...
                      2 4 ...
                      5 ...
            ];

end
%% Pool data                    % Per subject 1:2
ncond = 5;
for ii = 1:ncond                % per condition 1:4
	sel         = conditions == ii;
	condfnames  = fnames(sel);
	nsets       = length(condfnames);
	SS			= [];
	for jj = 1:nsets
		fname		= condfnames{jj};
		dname = ['E:\DATA\Studenten\Jochem\' fname(1:end-5)];
		cd(dname);
		load(fname);
		SupSac  = pa_supersac(Sac,Stim,2,1);           %% pa_supersacr is supposed to add missing trials as 0/0 response trials automatically to SUPSAC
		SS		= [SS;SupSac]; %#ok<AGROW>          % Erstellte riesige SS pro condition, wo alle data-sets per condition und subject enthalten sind. zb MW, cond 20
	end
	
	x	= SS(:,23);
	y	= SS(:,8);
	sel = x>=10 & x<=30;
	%     x	= x(sel);
	%     y	= y(sel);
	b(ii) = regstats(y,x,'linear',{'beta','r'});
	
	az(ii).tar = SS(:,23);
	el(ii).tar = SS(:,24);
	az(ii).res = SS(:,8);
	el(ii).res = SS(:,9);
	
	%     plot(x,y,'k.');
	%     axis square
	%     axis([-90 90 -90 90])
	%     pa_unityline;
	%     ylabel('Response location (deg)');
	%     xlabel('Stimulus location (deg)');
	%     pa_regline(b(ii).beta,'r-');
	%     drawnow
	%     pause
	
	
	%
	%     % elevation
	%     sel				= abs(SS(:,24))<11 & (SS(:,23))>9 & SS(:,23)<31; % should hold for both! %Select only the 20 deg range in each condition
	%     Y1				= SS(sel,9);
	%     X1				= SS(sel,24);
	%     B(ii)			= regstats(Y1,X1,'linear',{'beta';'r'}); %#ok<AGROW>  B for elevation
	%     % azimuth
	%     Y2				= SS(sel,8)-20;
	%     X2				= SS(sel,23)-20;
	%     B2(ii)			= regstats(Y2,X2,'linear',{'beta';'r'}); %#ok<AGROW>  B2 for azimuth
	%
	% %     RT(ii) = SS(:,5)
	%
	
	
	
end
beta = [b.beta];
G = beta(2,:);
B = beta(1,:);
r = NaN(ncond,1);
for ii = 1:ncond
	r(ii) = std(b(ii).r);
end


