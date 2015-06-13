function A7_prediction

close all
clear all
% cc

subjects	= {'RG';'JB';'DL';'RD';'PR';'SM';};

nsubjects	= length(subjects);
gain		= NaN(nsubjects,4);     % Elevation gain
gain2 = gain;                       % Azimuth gain
s = NaN(nsubjects,4);               % Residuen el
s2 = s;                             % Residuen az
% RT = NaN(nsubjects,4)
for ii = 1:nsubjects        
    subject = subjects{ii}; 
    % Determine Gain and offset, B = el; B2 = az
    [B,B2,B3,B4,sd]	= getgain(subject); 
    g		= [B.beta];         
    g2		= [B2.beta]; 
    g3      = [B3.beta];
    g4      = [B4.beta];
   
    % Determine Residuen
    for jj = 1:4                        
        s(ii,jj)		= std(B(jj).r);       
        s2(ii,jj)		= std(B2(jj).r);  
    end
 
    gain(ii,:) = g(2,:);   % EL: contains all 5_subjects gains/ subj in row; gain per cond in column
    gain2(ii,:) = g2(2,:); % AZ: contains all 5_subjects gains/ subj in row; gain per cond in column
    gain3(ii,:) = g3(2,:);  % EL, control cond
    gain4(ii,:) = g4(2,:);  % AZ, control cond
end

% figure
% subplot(221)
gain_i = gain';
gain3_i = gain3';
% plot(gain_i,'o-')
% hold on
% plot(gain3_i,'o-')
rng = [0 10 20 30];
figure(2)
grg1 = gain_i(:,1);     % gain_i ; exp
gjb1 = gain_i(:,2);     
grg3 = gain3_i(:,1);    % gain3_i ; control
gjb3 = gain3_i(:,2);

gdl1 = gain_i(:,3);
grd1 = gain_i(:,4);
gdl3 = gain3_i(:,3);
grd3 = gain3_i(:,4);


gpr1 = gain_i(:,5);
gsm1 = gain_i(:,6);
gpr3 = gain3_i(:,5);
gsm3 = gain3_i(:,6);


plot(rng,grg1,'ro-')
hold on
plot(rng,grg3,'bo-')
plot(rng,gjb1,'go-')
plot(rng,gjb3,'co-')


plot(rng,gdl1,'mo-')
plot(rng,gdl3,'ko-')
plot(rng,grd1,'yo-')
plot(rng,grd3,'o-','MarkerFaceColor',[.7 .7 .7])

plot(rng,gpr1,'ro-','MarkerFaceColor',[.7 .7 .7])
plot(rng,gpr3,'bo-','MarkerFaceColor',[.7 .7 .7])

plot(rng,gsm1,'go-','MarkerFaceColor',[.7 .7 .7])
plot(rng,gsm3,'co-','MarkerFaceColor',[.7 .7 .7])



% figure
% grgjb = [grg1,gjb1,grg3,gjb3]
% plot(grgjb,'o-')
legend('RG Exp','RG Control','JB Exp','JB Control','DL Exp', 'DL Cont','RD Exp', 'RD Cont','PR Exp','PR Control','SM Exp','SM Control')

%% for loop
figure(2)
for ii = 1:nsubjects
    g1 = gain_i(:,ii);
    g3 = gain3_i(:,ii);
    subplot(2,4,ii)

plot(rng,g1,'ro-')
hold on
plot(rng,g3,'ko-')
end
legend('data','control')

figure(3)

% gain_i
% gain3_i
meangainexp = mean(gain_i')
meangaincon = mean(gain3_i')

plot(rng,meangainexp','ko-','LineWidth',2,'MarkerFaceColor','w','Color',[.3 .3 .3]);
hold on
plot(rng,meangaincon','ko-','LineWidth',2,'MarkerFaceColor','w','Color',[.7 .7 .7]);
legend('Exp','Cont')



% Figure: Individual gains per subject    
figure(5)
% Raw EL
subplot(2,2,2)
gain_ind = gain';         
plot(gain_ind,'o-')
% Normalization
gain_ind_n = NaN(4,nsubjects);
for ii = 1:nsubjects
    gain_ind_n(:,ii) = gain_ind(:,ii)/max(gain_ind(:,ii));
end
% Normalized EL
subplot(2,2,4)
plot(gain_ind_n,'o-')        
ylim([0.4 1.2])

% Raw Az
subplot(2,2,1)
gain_ind2 =gain2';
plot(gain_ind2,'o-')
% Normalization
gain_ind2_n = NaN(4,nsubjects);
for ii = 1:nsubjects
    gain_ind2_n(:,ii) = gain_ind2(:,ii)/max(gain_ind2(:,ii));
end
% Normalized Az
subplot(2,2,3)
plot(gain_ind2_n,'o-')
ylim([0.4 1.2])

legend('RG','JB')




% Normalization 
gain_n = NaN(nsubjects,4);
gain2_n = NaN(nsubjects,4);
for ii= 1:nsubjects
gain_n(ii,:) = gain(ii,:)/max(gain(ii,:));
gain2_n(ii,:) = gain2(ii,:)/max(gain2(ii,:));
end


figure(4)
 sd = s'
subplot(2,2,1)
Gain_el = mean(gain);
plot(sd,gain','ko-','Markerfacecolor','w')

subplot(2,2,3)
musd=mean(s)
plot(musd,Gain_el,'ko-','Markerfacecolor','w')
col = hsv(4);
for ii = 1:4
h(ii) = plot(musd(ii),Gain_el(ii),'ko-','MarkerFaceColor',col(ii,:));
hold on
end





function [B,B2,B3,B4,sd] = getgain(subject)

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
                  'JB-PR-2013-05-30-0007';'JB-PR-2013-05-30-0005';...
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
for ii = 1:4                % per condition 1:4
    sel         = conditions == ii;
    condfnames  = fnames(sel);
    nsets       = length(condfnames);
    SS			= [];
    for jj = 1:nsets
        fname		= condfnames{jj};
        pa_datadir(['\A7_Shiftmean\' fname(1:end-5)]);
        load(fname);
        SupSac  = pa_supersac(Sac,Stim,2,1);           %% pa_supersacr is supposed to add missing trials as 0/0 response trials automatically to SUPSAC
%         x		= SupSac(:,24);
%         y		= SupSac(:,9);
%         b		= regstats(y,x,'linear','beta');
%         y		= y-b.beta(1);                      % remove bias from each dataset
%         SupSac(:,9) = y;
        SS		= [SS;SupSac]; %#ok<AGROW>          % Erstellte riesige SS pro condition, wo alle data-sets per condition und subject enthalten sind. zb MW, cond 20
    end
    
    % elevation
%     sel				= abs(SS(:,24))<11 & abs(SS(:,23))<11; % should hold for both! %Select only the 20 deg range in each condition
    Y1				= SS(:,9);
    X1				= SS(:,24);
    B(ii)			= regstats(Y1,X1,'linear',{'beta';'r'}); %#ok<AGROW>  B for elevation
    % azimuth
    Y2				= SS(:,8);
    X2				= SS(:,23);
    B2(ii)			= regstats(Y2,X2,'linear',{'beta';'r'}); %#ok<AGROW>  B2 for azimuth
    
    
 
      
subplot(1,4,ii)
plot(X2,X1,'o')
axis square
axis ([-20 20 -20 50])



    
end

for ii = 5
    sel         = conditions == ii;
    condfnames  = fnames(sel);
    nsets       = length(condfnames);
    SS			= [];
    for jj = 1:nsets
        fname		= condfnames{jj};
        pa_datadir(['\A7_Shift Mean\' fname(1:end-5)]);
        load(fname);
        SupSac  = pa_supersac(Sac,Stim,2,1);           %% pa_supersacr is supposed to add missing trials as 0/0 response trials automatically to SUPSAC
%         x		= SupSac(:,24);
%         y		= SupSac(:,9);
%         b		= regstats(y,x,'linear','beta');
%         y		= y-b.beta(1);                      % remove bias from each dataset
%         SupSac(:,9) = y;
        SS		= [SS;SupSac]; %#ok<AGROW>          % Erstellte riesige SS pro condition, wo alle data-sets per condition und subject enthalten sind. zb MW, cond 20
    end
    
    sel1 = abs(SS(:,23))<11 & abs(SS(:,24))<11;
    sel2 = abs(SS(:,23))<11 & SS(:,24)>=0 & SS(:,24)<21;
    sel3 = abs(SS(:,23))<11 & SS(:,24)>=10 & SS(:,24)<31;
    sel4 = abs(SS(:,23))<11 & SS(:,24)>=20 & SS(:,24)<41;
%     sel = {'sel1';'sel2';'sel3';'sel4'};
    SS1 = SS(sel1,:);
    SS2 = SS(sel2,:);
    SS3 = SS(sel3,:);
    SS4 = SS(sel4,:);
    
    SS = {SS1;SS2;SS3;SS4}
    for ii = 1:4
            SSt              = SS{ii};
            Y1				= SSt(:,9);
            X1				= SSt(:,24);
            B3(ii)			= regstats(Y1,X1,'linear',{'beta';'r'}); %#ok<AGROW>  B for elevation
            % azimuth
            Y2				= SSt(:,8);
            X2				= SSt(:,23);
            B4(ii)			= regstats(Y2,X2,'linear',{'beta';'r'}); %#ok<AGROW>  B2 for azimuth
            sd = std(SSt(:,9))
    end
    

end

