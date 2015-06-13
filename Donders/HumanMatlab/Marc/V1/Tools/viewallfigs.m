function viewallfigs

HFs = get(0,'children');
for I_f = 1:numel(HFs)
	figure(HFs(I_f))
end
