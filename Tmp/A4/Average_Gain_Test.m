function Average_Gain_Test
close all
clear all

[Gain10LJ,K10LJ] = get_gain('LJ10'); %#ok<*NASGU>
[Gain30LJ,K30LJ] = get_gain('LJ30');
[Gain50LJ,K50LJ] = get_gain('LJ50');

[Gain10MW,K10MW] = get_gain('MW10'); %#ok<*NASGU>
[Gain30MW,K30MW] = get_gain('MW30');
[Gain50MW,K50MW] = get_gain('MW50');

[Gain10RG,K10RG] = get_gain('RG10'); %#ok<*NASGU>
[Gain30RG,K30RG] = get_gain('RG30');
[Gain50RG,K50RG] = get_gain('RG50');

[Gain10HH,K10HH] = get_gain('HH10'); %#ok<*NASGU>
[Gain30HH,K30HH] = get_gain('HH30');
[Gain50HH,K50HH] = get_gain('HH50');

[Gain10RO,K10RO] = get_gain('RO10'); %#ok<*NASGU>
[Gain30RO,K30RO] = get_gain('RO30');
[Gain50RO,K50RO] = get_gain('RO50');




whos Gain10
Gain = [Gain10LJ;Gain30LJ;Gain50LJ;Gain10MW;Gain30MW;Gain50MW;Gain10RG;Gain30RG;Gain50RG;Gain10HH;Gain30HH;Gain50HH;Gain10RO;Gain30RO;Gain50RO];
K = [K10LJ;K30LJ;K50LJ;K10MW;K30MW;K50MW;K10RG;K30RG;K50RG;K10HH;K30HH;K50HH;K10RO;K30RO;K50RO];


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



% subject = 'LJ50'   ;

switch subject
    
    
    case  'LJ10'
        fnames = {'RG-LJ-2011-12-14-0003';'RG-LJ-2011-12-14-0005';...
            'RG-LJ-2011-12-21-0002';'RG-LJ-2011-12-21-0007';...
            'RG-LJ-2012-01-10-0003';'RG-LJ-2012-01-10-0007';...
            'RG-LJ-2012-01-17-0004'};
        K= [4 4 4 3 4 4 4]';
        
    case 'LJ30'
        fnames = {'RG-LJ-2011-12-14-0001';'RG-LJ-2011-12-14-0006';...
            'RG-LJ-2011-12-21-0004';'RG-LJ-2011-12-21-0006';...
            'RG-LJ-2012-01-10-0001';'RG-LJ-2012-01-10-0008';...
            'RG-LJ-2012-01-17-0002'};
        K=  [1 2 4 4 1 2 4]';
        
        
    case 'LJ50'
        fnames = {'RG-LJ-2011-12-14-0002';'RG-LJ-2011-12-14-0004';...
            'RG-LJ-2011-12-14-0007';'RG-LJ-2011-12-14-0008';...
            'RG-LJ-2011-12-21-0001';'RG-LJ-2011-12-21-0003';...
            'RG-LJ-2011-12-21-0005';'RG-LJ-2011-12-21-0008';...
            'RG-LJ-2012-01-10-0002';'RG-LJ-2012-01-10-0004';...
            'RG-LJ-2012-01-10-0005';'RG-LJ-2012-01-10-0006';...
            'RG-LJ-2012-01-17-0001';'RG-LJ-2012-01-17-0003'
            };
        
        K=  [3 2 3 4 1 2 3 2 3 2 4 4 1 3]';
        
        
        case  'MW10'
        fnames = {'RG-MW-2011-12-02-0004';...
    'RG-MW-2011-12-02-0007';...
    'RG-MW-2011-12-08-0003';...
    'RG-MW-2012-01-11-0003';...
    'RG-MW-2012-01-12-0006';...
    'RG-MW-2012-01-19-0001'};

        K= [4 3 4 4 4 1]';
        
    case 'MW30'
        fnames = {'RG-MW-2011-12-02-0002';...
    'RG-MW-2011-12-02-0006';...
    'RG-MW-2011-12-08-0001';...
    'RG-MW-2012-01-11-0001';...
    'RG-MW-2012-01-12-0008';...
    'RG-MW-2012-01-19-0004'};
    
        K=  [4 4 1  1 4 4]';
        
        
    case 'MW50'
fnames = {'RG-MW-2011-12-02-0001';'RG-MW-2011-12-02-0003';...
    'RG-MW-2011-12-02-0005';'RG-MW-2011-12-02-0008';...
    'RG-MW-2011-12-08-0002';'RG-MW-2011-12-08-0004';...
    'RG-MW-2012-01-11-0002';'RG-MW-2012-01-11-0004';...
    'RG-MW-2012-01-12-0005';'RG-MW-2012-01-12-0007';...
    'RG-MW-2012-01-19-0002';'RG-MW-2012-01-19-0004'};

    
        K=  [1 3 2 2 3 2 3 2 4 2 2 4]';
        
        
            case  'RG10'
        fnames = {'MW-RG-2011-12-08-0004';...
'MW-RG-2011-12-08-0007';...
'MW-RG-2012-01-12-0004';...
'MW-RG-2012-01-12-0007'};


        K= [4 4 4 4]';
        
    case 'RG30'
fnames = {'MW-RG-2011-12-08-0001';'MW-RG-2011-12-08-0002';...
'MW-RG-2012-01-12-0002';...
'MW-RG-2012-01-12-0005'};

        K=  [1 3 4 2]';
        
        
    case 'RG50'

fnames = {
    'MW-RG-2011-12-08-0003';...
'MW-RG-2011-12-08-0005';'MW-RG-2011-12-08-0006';'MW-RG-2011-12-08-0008';...
'MW-RG-2012-01-12-0001';'MW-RG-2012-01-12-0003';...
'MW-RG-2012-01-12-0006';'MW-RG-2012-01-12-0008'};


        K =  [3 2 4 2 1 3 3 2]';
        
        
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
        
        
            case  'RO10'
       fnames = {
    'RG-RO-2011-12-12-0003';...
'RG-RO-2011-12-12-0005';...
'RG-RO-2012-01-11-0002';...
'RG-RO-2012-01-11-0007';...
'RG-RO-2012-01-18-0003';...
'RG-RO-2012-01-18-0006';...
};



        K= [3 4 4 3 4 4]';
        
    case 'RO30'
       fnames = {
    'RG-RO-2011-12-12-0002';...
'RG-RO-2011-12-12-0007';...
'RG-RO-2012-01-11-0004';...
'RG-RO-2012-01-11-0006';...
'RG-RO-2012-01-18-0001';'RG-RO-2012-01-18-0008';...
};


        K=  [4 4 4 4 1 4]';
        
        
    case 'RO50'
        fnames = {
    'RG-RO-2011-12-12-0001';'RG-RO-2011-12-12-0004';...
'RG-RO-2011-12-12-0006';'RG-RO-2011-12-12-0008';...
'RG-RO-2012-01-11-0001';'RG-RO-2012-01-11-0003';...
'RG-RO-2012-01-11-0005';'RG-RO-2012-01-11-0008';...
'RG-RO-2012-01-18-0002';'RG-RO-2012-01-18-0004';...
'RG-RO-2012-01-18-0005';'RG-RO-2012-01-18-0007'};

        
        K=  [1 2 2 3 1 2 3 2 3 2 4 2]';
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