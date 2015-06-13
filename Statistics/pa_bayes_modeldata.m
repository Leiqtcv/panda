function pa_bayes_modeldata(model,Nnom,Nmet,xmet)
% function pa_bayes_modeldata
%
% For every nominal factor a parameter
% For every metric factor, N dependent parameters
%
% To do: multiple metrics
% PA_BAYES_MODELDATA
%
% Write Trial-line in an exp-file with file identifier FID.
% TRL - Trial Number
%
% See also GENEXPERIMENT, FOPEN, and the documentation of the Auditory
% Toolbox
pa_datadir

if nargin<1
	model = 'model.txt';
end
if nargin<2
	Nnom = 4;
end
if nargin<3
Nmet = 1;
end
if nargin<4
	xmet(1).Nom = [6];
end

[~,n] = size(xmet);
if n~=Nmet
	disp('error');
	return
end
%5
pa_datadir
fid = fopen(model,'w');

fprintf(fid,'%s \r\n','model {');
fprintf(fid,'\t\r\n');
fprintf(fid,'\t%s\r\n',		'for ( i in 1:Ntotal ) {'); % Loop through data
fprintf(fid,'\t\t%s\r\n',		'y[i] ~ dnorm( mu[i],tau)'); % Data is normally distributed

%%


% nominal factors: ANOVA
strNom = 'a0 ';
for ii = 1:Nnom
	tmp = ['+ a' num2str(ii) '[x' num2str(ii) '[i]]'];
	strNom = [strNom tmp]; %#ok<*AGROW>
end

% nominal 2-way interactions
x		= 1:Nnom;
[x,y]	= meshgrid(x,x);
x		= x(:);
y		= y(:);
sel		= x==y; % remove identical
x		= x(~sel);
y		= y(~sel);
M		= [x y];
M		= unique(sort(M,2),'rows'); % unique interactions, don't care about direction

% metric factors: linear regression
strMet = '+ (aMet0 ';

for ii = 1:Nmet
	str1 = ['+ aMet' num2str(ii) '['];
	for nomIdx = 1:length(xmet(ii).Nom)
		str2 =	[repmat(',',1,nomIdx-1) 'x' num2str(xmet(ii).Nom(nomIdx)) '[i]'];
		str1 = [str1 str2];
	end
	str2 = ['*xMet' num2str(ii) '[i]'];
	tmp = [str1 '])' str2];
	strMet = [strMet tmp];
end
% combine in ANCOVA
str		= ['mu[i] <- ' strNom strMet];
fprintf(fid,'\t\t%s\r\n',str); % Model

%% Missing values
fprintf(fid,'\t%s\r\n','# Missing values'); % Missing values
for ii = 1:Nnom
	str = ['x' num2str(ii) '[i] ~ dcat(pix' num2str(ii) '[])']; % normally distributed around mean of all levels in factor
	fprintf(fid,'\t\t%s\r\n',str);
end

for ii = 1:Nmet
	str = ['xMet' num2str(ii) '[i] ~ dnorm(muxMet' num2str(ii) ',tauxMet' num2str(ii) ')']; % normally distributed around mean of all conditions
	fprintf(fid,'\t\t%s\r\n',str); % Missing values
end


%% Close model
fprintf(fid,'\t%s\r\n','}'); % with end

%% Priors on missing predictors
fprintf(fid,'\t\r\n');
fprintf(fid,'%s\r\n','# Vague priors on missing predictors');
fprintf(fid,'%s\r\n','# Assuming predictor variances are equal');
for ii = 1:Nnom
	strfor			= ['for (j' num2str(ii) ' in 1:Nx' num2str(ii) 'Lvl){ '];
	str = ['pix' num2str(ii) '[j' num2str(ii) '] <- 1/Nx' num2str(ii) 'Lvl'];
	fprintf(fid,'\t%s\r\n',[strfor str ' }']);
end


for ii = 1:Nmet
	str = ['muxMet' num2str(ii) ' ~ dnorm(0,1.0E-12)'];
	fprintf(fid,'\t%s\r\n',str); % Missing values
end

for ii = 1:Nmet
	str = ['tauxMet' num2str(ii) ' ~ dgamma(0.001,0.001)'];
	fprintf(fid,'\t%s\r\n',str); % Missing values
end

%% Priors
fprintf(fid,'\t\r\n');
fprintf(fid,'%s\r\n','# Priors');

fprintf(fid,'\t%s\r\n','tau <- pow(sigma,-2)'); % conversion from sigma to precision
fprintf(fid,'\t%s\r\n','sigma ~ dgamma(1.01005,0.1005) # standardized y values'); % Missing values

priors(fid,Nnom,Nmet,xmet,[]);

%% Sampling from prior dist
fprintf(fid,'\t\r\n');
fprintf(fid,'%s\r\n','# Sampling from Prior distribution :');
priors(fid,Nnom,Nmet,xmet,'prior');


%% Close
fprintf(fid,'%s\r\n','}');

%% Close model-textfile
fclose(fid);
%
% if ispc
% 	dos(['"C:\Program Files\Windows NT\Accessories\wordpad.exe" ' model ' &']);
% end

function priors(fid,Nnom,Nmet,xmet,strprior)


%% Priors
fprintf(fid,'\t\r\n');
fprintf(fid,'%s\r\n','# Hyper Priors');

fprintf(fid,'\t\r\n');
fprintf(fid,'\t%s\r\n',['a0' strprior ' ~ dnorm(0,lambda0' strprior ')']); % offset
fprintf(fid,'\t%s\r\n',['aMet0' strprior ' ~ dnorm(0,lambdaMet0' strprior ')']); % offset

for ii = 1:Nnom
	str = ['for (j' num2str(ii) ' in 1:Nx' num2str(ii) 'Lvl){ a' num2str(ii) strprior '[j' num2str(ii) '] ~ dnorm(0.0,lambda' num2str(ii) strprior ') }'];
	fprintf(fid,'\t%s\r\n',str);
end
for ii = 1:Nmet
	for nomIdx = 1:length(xmet(ii).Nom)
		str = ['for (j' num2str(xmet(ii).Nom(nomIdx)) ' in 1:Nx' num2str(xmet(ii).Nom(nomIdx)) 'Lvl){ '];
		fprintf(fid,'\t%s',str);
	end
	fprintf(fid,'\t\r\n');
	str1 = ['aMet' num2str(ii) strprior '['];
	for nomIdx = 1:length(xmet(ii).Nom)
		str2 = [repmat(',',1,nomIdx-1) 'j'  num2str(xmet(ii).Nom(nomIdx)) ];
		str1 = [str1 str2];
	end
	str = [str1  ']~ dnorm(0.0,lambdaMet' num2str(ii) strprior ')'];
	fprintf(fid,'\t\t%s\r\n',str);
	for nomIdx = 1:length(xmet(ii).Nom)
		fprintf(fid,'\t%s','}');
	end
	fprintf(fid,'\t\r\n');
end


fprintf(fid,'\t%s\r\n',['lambda0' strprior ' ~ dchisqr(1)']); % chi sqr for nice statistical properties
for ii = 1:Nnom
	str = ['lambda' num2str(ii) strprior  ' ~ dchisqr(1)'];
	fprintf(fid,'\t%s\r\n',str);
end
fprintf(fid,'\t%s\r\n',['lambdaMet0' strprior ' ~ dchisqr(1)']); % chi sqr for nice statistical properties
for ii = 1:Nmet
	str = ['lambdaMet' num2str(ii) strprior ' ~ dchisqr(1)'];
	fprintf(fid,'\t%s\r\n',str);
end

%% Sum-to-zero for nominal factors
fprintf(fid,'\t\r\n');
fprintf(fid,'%s\r\n','# Convert nominal factors to sum-to-zero');

strmuj		= [];
strNom		= [];
strClose	= [];
for ii = 1:Nnom
	strfor			= ['for (j' num2str(ii) ' in 1:Nx' num2str(ii) 'Lvl){ '];
	fprintf(fid,'\t%s\r\n',strfor);
	if ii<Nnom
		tmp		= ['j' num2str(ii) ','];
	else
		tmp		= ['j' num2str(ii)];
	end
	strmuj		= [strmuj tmp];
	
	tmp			= ['+ a' num2str(ii) strprior '[j' num2str(ii) '] '];
	strNom		= [strNom tmp]; %#ok<*AGROW>
	
	strClose	= [strClose '} '];
end
str = ['m' strprior '[' strmuj '] <- a0' strprior ' ' strNom ];
fprintf(fid,'\t\t%s\r\n',str);
fprintf(fid,'\t%s\r\n',strClose);

fprintf(fid,'\t%s\r\n',['b0' strprior '<-mean(m' strprior '[' repmat(',',1,Nnom-1) '])']);
for ii = 1:Nnom
	str1	= repmat(',',1,ii-1);
	str2	= repmat(',',1,Nnom-ii);
	str		= ['for ( j' num2str(ii) ' in 1:Nx' num2str(ii) 'Lvl ) { '];
	fprintf(fid,'\t%s\r\n',str);
	str = 	['b' num2str(ii) strprior '[j' num2str(ii) '] <- mean( m' strprior '[' str1  'j' num2str(ii) str2 '] ) - b0' strprior ' }'];
	fprintf(fid,'\t\t%s\r\n',str);
end

%% Sum-to-zero for metric factors
fprintf(fid,'\t\r\n');
fprintf(fid,'%s\r\n','# Convert metric factors to sum-to-zero');

strmuj		= [];
strMet		= [];
for ii = 1:Nmet
	strfor = [];
	for nomIdx = 1:length(xmet(ii).Nom)
		str		= ['for (j' num2str(xmet(ii).Nom(nomIdx)) ' in 1:Nx' num2str(xmet(ii).Nom(nomIdx)) 'Lvl){ '];
		strfor = [strfor str];
	end
	fprintf(fid,'\t%s\r\n',strfor);
	
	for nomIdx = 1:length(xmet(ii).Nom)
	str		= [repmat(',',1,nomIdx-1) 'j' num2str(xmet(ii).Nom(nomIdx))];
	strmuj = [strmuj str];
	end
	
	tmp			= ['+ aMet' num2str(ii) strprior '[' strmuj '] '];
	strMet		= [strMet tmp]; %#ok<*AGROW>
	
	strClose	= [];
	for nomIdx = 1:length(xmet(ii).Nom)
	strClose	= [strClose '} '];
	end
end
str = ['mMet' strprior '[' strmuj '] <- aMet0' strprior ' ' strMet ];
fprintf(fid,'\t\t%s\r\n',str);
fprintf(fid,'\t%s\r\n',strClose);


fprintf(fid,'\t%s\r\n',['bMet0' strprior '<-mean(mMet' strprior '[' repmat(',',1,length(xmet(ii).Nom)-1) '])']);

strmuj		= [];
strMet		= [];
for ii = 1:Nmet
	strfor = [];
	for nomIdx = 1:length(xmet(ii).Nom)
		str		= ['for (j' num2str(xmet(ii).Nom(nomIdx)) ' in 1:Nx' num2str(xmet(ii).Nom(nomIdx)) 'Lvl){ '];
		strfor = [strfor str];
	end
	fprintf(fid,'\t%s\r\n',strfor);
	
	for nomIdx = 1:length(xmet(ii).Nom)
	str		= [repmat(',',1,nomIdx-1) 'j' num2str(xmet(ii).Nom(nomIdx))];
	strmuj = [strmuj str];
	end
	
	tmp			= ['aMet' num2str(ii) strprior '[' strmuj '] '];
	strMet		= [strMet tmp]; %#ok<*AGROW>
	
	str = ['bMet' num2str(ii) strprior '[' strmuj '] <- ' strMet ' - bMet0' strprior ];

fprintf(fid,'\t\t%s\r\n',str);
	
	strClose	= [];
	for nomIdx = 1:length(xmet(ii).Nom)
	strClose	= [strClose '} '];
	end
end

fprintf(fid,'\t%s\r\n',strClose);

