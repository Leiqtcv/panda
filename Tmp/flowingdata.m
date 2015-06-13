close all
clear all
clc
% function alpha3to2

cd('E:\DATA\FlowingData');
fname	= 'country-codes.txt';
fid		= fopen(fname,'r');
code	= textscan(fid,'%s\t%s');
fclose(fid);
alpha3to2 = cell2struct(code{1},code{2});% create library with key alpha3 and value alpha2

%%
cd('E:\DATA\FlowingData');
fname	= 'water-source1.txt';
fid		= fopen(fname,'r');
water	= textscan(fid,'%s %s%d %d %d %d %d','delimiter','\t','EmptyValue',NaN,'MultipleDelimsAsOne',0);
fclose(fid);

%%
fid = fopen('style.css','w');
n = numel(water{1});
for row = 2:n
	row
	if isfield(alpha3to2,water{2}{row})
		alpha2 = lower(alpha3to2.(water{2}{row}));
		pct = round(water{6}(row));
		if pct == 100;
			fill = '#08589E';
		elseif pct>90
			fill = '#08589E';
		elseif pct>80
			fill = '#4EB3D3';
		elseif pct>70
			fill = '#7BCCC4';
		elseif pct>60
			fill = '#A8DDB5';
		elseif pct>50
			fill = '#CCEBC5';
		else
			fill = '#EFF3FF';
		end
			str = ['.' alpha2 ' { fill: ' fill ' }'];
			fprintf(fid,'%s\n',str);
	end
end
fclose(fid)