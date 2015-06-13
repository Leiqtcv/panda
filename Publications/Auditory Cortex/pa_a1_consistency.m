function pa_a1_consistency
close all force
clear all


d = 'E:\DATA\Cortex\gain selected cells';
cd(d);
fname = 'thor08411';
% fname = 'thor07512';
fname = 'joe6707c01b00';

muR = getcorr(fname,true);
muR


function muR = getcorr(fname,disp)
load(fname);

strf = pa_spk_ripple2strf(spikep,'shift',1);
strf_ori = strf.strf;
if disp
	subplot(121)
contourf(strf.strf,100);
shading flat
colorbar;
axis square
end
vel		= [spikep.stimvalues];
vel		= vel(5,:);
dens	= [spikep.stimvalues];
dens	= dens(6,:);
VD		= [vel; dens]';
uVD		= unique(VD,'rows');
nVD		= length(uVD);

R = NaN(100,1);
for jj = 1:100;
	S		= struct([]);
	for ii = 1:nVD
		sel		= vel== uVD(ii,1) & dens == uVD(ii,2);
		s		= spikep(sel);
		nrep	= numel(s);
		indx	= randperm(nrep);
		indx	= indx(1:ceil(nrep/2));
		s		= s(indx);
		S		= [S s];
	end
	n = numel(S);
	for ii = 1:n
		S(ii).trial = repmat(ii,size(S(ii).trial));
	end
	strf = pa_spk_ripple2strf(S,'shift',1);
	strf_rnd = strf.strf;
	
	
	r = corrcoef(strf_rnd(:),strf_ori);
	R(jj) = r(2);
end
R

muR = mean(R);

if disp
	subplot(122)
hist(R.^2); axis square;box off;xlim([0 1]);

end


