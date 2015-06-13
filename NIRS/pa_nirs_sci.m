function nirs = pa_nirs_sci(nirs,varargin)
% SCI = PA_NIRS_SCALPCOUPLINGINDEX(NIRS)
%
% Determine scalp coupling index
%
% See also Pollonini et al 2014:
% Pollonini, L., Olds, C., Abaya, H., Bortfeld, H., Beauchamp, M. S., & Oghalai, J. S. (2014).
% Auditory cortex activation to natural speech and simulated cochlear implant speech measured
% with functional near-infrared spectroscopy. Hearing Research, 309, 84?93. doi:10.1016/j.heares.2013.11.007

%% Initialization
dispFlag	= pa_keyval('disp',varargin);
if isempty(dispFlag)
	dispFlag = false;
end

methFlag	= pa_keyval('method',varargin);
if isempty(methFlag)
	methFlag = 'static';
end

OD1		= nirs.OD;
% yields 16 rows: Laser 1 to 8 for 2 detectors
Fs		= nirs.Fs;
nChan	= size(nirs.Rx_TxId,2);

%% Get cardiac component
for ii = 1:nChan
	OD(:,ii) = resample(OD1(:,ii),10,Fs); %#ok<*AGROW,*SAGROW> % we resample the data: this is better than downsample because it deals with anti-aliasing, but there is a discussion about this, see also auditory mailing list
	OD(:,ii) = pa_bandpass(OD(:,ii),[0.5 2.5],5); % we bandpass between 0.5 and 2.5 Hz to keep cardiac component only.
end

%% Coorelate cardiac component for two wavelengths of one optode
% The idea is that a well-placed optode should have a cardiac component
% at both wavelengths
kk		= 0;

SCI		= NaN(round(nChan/2),1);
for ii = 1:2:nChan % Optical density, so pairs of lasers
	
	kk		= kk+1; % counter
	
	% remove some outliers, which also include filtering artefacts
	t		= prctile(OD(:,ii),[2.5 97.5]);
	sel1	= OD(:,ii)<t(2) & OD(:,ii)>t(1);
	t		= prctile(OD(:,ii+1),[2.5 97.5]);
	sel2	= OD(:,ii+1)<t(2) & OD(:,ii+1)>t(1);
	sel		= sel1 & sel2;
	
	x1		= OD(sel,ii);
	x2		= OD(sel,ii+1);
	y1		= OD(:,ii);
	y2		= OD(:,ii+1);
	SCImov	= NaN(size(y1));		
	%
	x1		= zscore(x1); % zscore to remove amplitude differences
	x2		= zscore(x2); % zscore to remove amplitude differences
	
	if dispFlag
		figure(1)
		subplot(2,4,kk)
		plot(OD1(:,ii))
		box off;
		axis square;
		ylim([0 6.5]);
		xlim([0 length(OD1(:,ii))]);
		
		% X-Y plot
		figure(2)
		subplot(2,4,kk)
		hold on
		plot(x1,x2,'k.');
		box off
		axis square
		ylim([-3 3]);
		xlim([-3 3]);
		pa_unityline;
		xlabel('Amplitude Laser 1 (au)');
		ylabel('Amplitude Laser 2 (au)');
	end
	% cross-correlation with lag0
	r		= corrcoef(x1,x2);
	r		= r(2)^2;
	% Keep data
	SCI(kk) = r;
	switch methFlag
		case 'moving'
			nblock	= 50; % size (samples) of moving window
			nsamp	= numel(y1); % number of samples in signal
			R		= NaN(nsamp,1); % initialize moving correlation vector
			for jj	= (1+nblock):(nsamp-nblock) % loop
				idx				= (jj-nblock):(jj+nblock);
				r				= corrcoef(y1(idx),y2(idx));
				R(jj-nblock/2)	= r(2)^2;
			end
			%%
			figure(4)
			subplot(211)
			plot(y1)
			title(SCI(kk))
% 			SCImov(sel) = R;
			subplot(212)
			plot(R)
			ylim([0 1]);
			drawnow
			
% 			keyboard

			%%
	end
	% graphics
	% for setup left-right Rx1-Tx1-2, Rx2-Tx3-4
	if dispFlag; 		% time -X/Y
		figure(3);	subplot(2,4,kk)
		plot(x2,'k.-');
		hold on
		plot(x1,'r.-');
		xlim([200 300]); ylim([-2 2]);
		% 		title(['SCI = ' num2str(r,2)]); xlabel('Time (samples)'); ylabel('Amplitude (au)');
		axis square; box off;
		set(gca,'TickDir','out','TickLength',[0.005 0.025],...
			'XTick',200:50:300,'YTick',-2:2,...
			'FontSize',15,'FontAngle','Italic','FontName','Helvetica'); % publication-quality
	end
end
nirs.sci = SCI; % save in NIRS structure
