LEDSKY_RING=[0,2,5,9,14,20,27,35];
LEDSKY_SPOKE=[60 30 0 330 300 : -30 : 90];

FLAG_less = 0;

Range = [0 40];

Sel = LEDSKY_RING <= max(Range) & LEDSKY_RING >= min(Range);
SelLEDSKY_RING = LEDSKY_RING(Sel);

Rings = repmat(SelLEDSKY_RING,numel(LEDSKY_SPOKE),1);
Spokes = repmat(LEDSKY_SPOKE',1,numel(SelLEDSKY_RING));

% remove ring 0
Rings = Rings(:,all([Rings ~= 0]));
Spokes= Spokes(:,all([Rings ~= 0]));

% make vector
Rings = Rings(:);
Spokes = Spokes(:);

% add central led
Rings = [Rings;0];
Spokes = [Spokes;0];

% remove lower (invisible) leds
sel = Rings > 20 & Spokes<360 & Spokes>180;
Rings = Rings(~sel);
Spokes = Spokes(~sel);

if FLAG_less == 1
% remove some rings
sel = ismember(Rings,[2,9,20,35]);
Rings = Rings(sel);
Spokes = Spokes(sel);
end

% plot
polar(deg2rad(Spokes),Rings,'.');

% convert to numbers
tIxRings = repmat(LEDSKY_RING,numel(Rings),1) == repmat(Rings,1,numel(LEDSKY_RING));
IxRings = nan(size(Rings,1),1);
for I_t = 1: size(tIxRings,1)
	IxRings(I_t) = find(tIxRings(I_t,:) == 1) - 1;
end
tIxSpokes = repmat(LEDSKY_SPOKE,numel(Spokes),1) == repmat(Spokes,1,numel(LEDSKY_SPOKE));
IxSpokes = nan(size(Spokes,1),1);
for I_t = 1: size(tIxSpokes,1)
	IxSpokes(I_t) = find(tIxSpokes(I_t,:) == 1);
end

% repair central led
sel = IxRings == 0;
IxSpokes(sel) = 2;
IxRings(sel) = 0;

% create Mtx
IJkRoosTars = [ones(numel(IxRings),1) IxRings , IxSpokes , zeros(numel(IxRings),21-3)];
% for offset
%IJkRoosTars = [ones(numel(IxRings),1) ones(numel(IxRings),1)*2 ones(numel(IxRings),1)*0 zeros(numel(IxRings),21-3)];

% save
if FLAG_less == 1
    fn = ['D:\HumanMatlab\Tom\TrailList\IJkroos_' datestr(now,'yyyy-mm-dd') '-lesstargets.mat'];
else
    fn = ['D:\HumanMatlab\Tom\TrailList\IJkroos_' datestr(now,'yyyy-mm-dd') '.mat'];
end
disp(fn)
save(fn,'IJkRoosTars','-mat')