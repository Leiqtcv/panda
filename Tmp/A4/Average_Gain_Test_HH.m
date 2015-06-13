function Average_Gain_Test_HH
close all
clear all

[Gain10,K10] = get_gain('HH10'); %#ok<*NASGU>
[Gain30,K30] = get_gain('HH30');
[Gain50,K50] = get_gain('HH50');

whos Gain10
Gain = [Gain10;Gain30;Gain50];
K = [K10;K30;K50];


uK = unique(K);
muGain = NaN(length(uK),2);
for ii = 1:length(uK)
sel = K == uK(ii);
muGain(ii,1) = nanmean(Gain(sel,1));
muGain(ii,2) = nanmean(Gain(sel,2));

end

figure
subplot(121)
sel = K>1;
plot(K(sel),Gain(sel,1),'k.');
hold on
lsline
plot(K(~sel),Gain(~sel,1),'k.');
pa_horline(1);
plot(uK,muGain(:,1),'ko','MarkerFaceColor','w');
set(gca,'XTick',1:4,'XTickLabel',{'x';'10';'30';'50'});
xlabel('Previous condition');
ylabel('Gain');
xlim([0 5]);
ylim([0.5 1.5]);
axis square;

subplot(122)
sel = K>1;
plot(K(sel),Gain(sel,2),'k.');
hold on
lsline
plot(K(~sel),Gain(~sel,2),'k.');
pa_horline(1);
plot(uK,muGain(:,2),'ko','MarkerFaceColor','w');
set(gca,'XTick',1:4,'XTickLabel',{'x';'10';'30';'50'});
xlabel('Previous condition');
ylabel('Gain');
xlim([0 5]);
ylim([0.5 1.5]);
axis square;

function [Gain,K] = get_gain(subject)





switch subject
    
    
    case  'HH10'
        fnames = {
    'RG-HH-2011-11-24-0004';...
'RG-HH-2011-12-12-0001';...
'RG-HH-2012-01-09-0003';...
'RG-HH-2012-01-09-0007';...
'RG-HH-2012-01-13-0003';...
'RG-HH-2012-01-13-0006'};

        K= [4 1 4 4 4 4]';
        
    case 'HH30'
        fnames = {
    'RG-HH-2011-11-24-0002';...
'RG-HH-2011-12-12-0004';...
'RG-HH-2012-01-09-0001';...
'RG-HH-2012-01-09-0008';...
'RG-HH-2012-01-13-0001';...
'RG-HH-2012-01-13-0007'};

        K=  [4 4 1 2 1 2]';
        
        
    case 'HH50'
        fnames = {
    'RG-HH-2011-11-24-0001';'RG-HH-2011-11-24-0003';...
'RG-HH-2011-12-12-0002';'RG-HH-2011-12-12-0003';...
'RG-HH-2012-01-09-0002';'RG-HH-2012-01-09-0004';...
'RG-HH-2012-01-09-0005';'RG-HH-2012-01-09-0006';...
'RG-HH-2012-01-13-0002';'RG-HH-2012-01-13-0004';...
'RG-HH-2012-01-13-0005';'RG-HH-2012-01-13-0008';...
};


        
        K=  [1 3 2 4 3 2 4 4 3 2 4 3]';
end



nsets = length(fnames);
Gain = NaN(nsets,2);
SS = [];
for ii = 1:nsets
    fname = fnames{ii};
    pa_datadir(fname(1:end-5));
    load(fname); %load fnames(ii) = load('fnames(ii)');
    SupSac      = pa_supersac(Sac,Stim,2,1);
    
    
    Yel       = SupSac(:,9);
    Xel       = SupSac(:,24);
    Yaz       = SupSac(:,8);
    Xaz       = SupSac(:,23);
    
    statsaz = regstats(Yaz,Xaz,'linear',{'beta'});
    statsel = regstats(Yel,Xel,'linear',{'beta'});
    
    Gain(ii,1) = statsaz.beta(2);
    Gain(ii,2) = statsel.beta(2);

    Biasaz = statsaz.beta(1);
    Biasel = statsel.beta(1);
    
    SupSac(:,9) = SupSac(:,9)-Biasel;
    SupSac(:,8) = SupSac(:,8)-Biasaz;
    
    SS = [SS;SupSac]; %#ok<AGROW>
end
SupSac    = SS;
Yel       = SupSac(:,9);
Xel       = SupSac(:,24);
Yaz       = SupSac(:,8);
Xaz       = SupSac(:,23);

statsaz = regstats(Yaz,Xaz,'linear',{'beta'});
statsel = regstats(Yel,Xel,'linear',{'beta'});
Maz = statsaz.beta(2);
Mel = statsel.beta(2);

Gaz = Gain(:,1);
Gel = Gain(:,2);

Gel = Gel./Mel;
Gaz = Gaz./Maz;

Gain = [Gaz Gel];

