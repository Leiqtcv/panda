function pa_tdt2wav(fltdt)

%	function tdt2wav(fltdt);

fs          = 50000;
[pa,na]     = fileparts(fltdt);
flwav=[na,'.wav'];

fid = fopen(fltdt);
z	= fread(fid,'short');
fclose(fid);

mx	= max(abs(z));
z	= z/mx;
plot(z);
sound(z,fs);
wavwrite(z,fs,flwav);
