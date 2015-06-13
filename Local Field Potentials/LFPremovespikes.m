function [output_clean, output, input, h] = ...
    LFPremovespikes(rS, FS_SPIKE, rL, FS_LFP, fs_out, input_type, ...
                     verbose, unbiased)
%function [output_clean, output, input, h] = ...
%    infer_spikes_LFP(rS, FS_SPIKE, rL, FS_LFP, fs_out, input_type, ...
%                     verbose, unbiased)
%
% INPUTS:
% rS: vector of the raw spikes signal
% FS_SPIKE: sampling rate of spike signal
% rL: vector of the raw LFP signal
% FS_LFP: sampling rate of the LFP signal
% fs_out: resampling frequency for output. default = 300 Hz;
% input_type: string (default = 'sua2 4.0')
%   possible values:
%   - 'mua1' = MUA using the SQUARE/SQRT method (Stark et al. 2008)
%   - 'mua2' = MUA using the ABS method (Kayser et al. 2007)
%   - 'sua1 threshold' = SUA with the definition of spikes which uses peak
%   - 'sua2 threshold' = SUA with the def. of spikes which uses derivative
%     (threshold = how many standard deviations the peak/derivative
%     must be to count as an SUA event.)
% unbiased: if == 1 use the 20 *rotating cross-covariance. default 1.
%           (if 1, data must be at least 20*0.5 sec=10 sec duration).
% verbose: if == 1 plot results. default = 0
%
% OUPUTS:
% output_clean: LFP without spikes
% output: resampled raw LFP
% input: signal used as "spikes": SUA or MUA
% trials_start: used to create the position of the stimulus
%
% Authors:  Nicolas Malaval, Stephen David.  2009
% Supplementary material for "Decoupling action potential bias from
% cortical local field potentials"
%
MUA_FILT_ORDER = 500; %filter order for MUA
%FS_SPIKE = 25000;   %sampling rate of the spikes signal
%FS_LFP = 3125;      %sampling rate of the LFP signal

if nargin<5
    fs_out = 300;
end
if nargin<6
    input_type = 'sua2 4.0';
end
if nargin<7
    verbose = 0;
end
if nargin<8
    unbiased = 1;
end

FILTER_DURATION     = 0.5; %seconds
FILTER_LEN          = FILTER_DURATION.*fs_out;

% parse input_type
% return input_number which corresponds to the number mode of the input
% and threshold if SUA
switch input_type
    case 'mua1'
        input_number = 1;
    case 'mua2'
        input_number = 2;
    case 'sua1'
        input_number = 11;
    otherwise
        input_number = 12;
end
if input_number > 10
    threshold = 4;
end


% downsample raw LFP signal
output = resample(rL, fs_out, FS_LFP);

% extract the appropriate input (spike) signal
std_rS=std(rS);
switch input_number
     
   % MUA SQUARE/SQRT method
 case 1
  rSmua = rS;
  length_rSmua = length(rSmua);
  
  f_bp = firls(MUA_FILT_ORDER,[0 450/25000 500/25000 3000/25000 ...
                    3500/25000 1],[0 0 1 1 0 0]);
  rSmua = conv(rSmua, f_bp);
  rSmua = rSmua(round(MUA_FILT_ORDER/2)+1:round(MUA_FILT_ORDER/2)+length_rSmua);
  
  rSmua = rSmua.^2;
  rSmua = sqrt(abs(rSmua));
  
  input = resample(rSmua, fs_out, FS_SPIKE);
  
  
  % MUA ABS method
 case 2
  rSmua = rS;
  length_rSmua = length(rSmua);
  
  f_bp = firls(MUA_FILT_ORDER,[0 450/25000 500/25000 3000/25000 3500/25000 1],[0 0 1 1 0 0]);
  rSmua = conv(rSmua, f_bp);
  rSmua = rSmua(round(MUA_FILT_ORDER/2)+1:round(MUA_FILT_ORDER/2)+length_rSmua);
  
  rSmua = abs(rSmua);
  
  input = resample(rSmua, fs_out, FS_SPIKE);
  
  
  % SUA peak height method
 case 11
  rSshort = rS;
  spike_pos2 = (-rSshort>(threshold*std_rS)).*(-rSshort);
  spike_pos2 = [0;diff(spike_pos2)];
  spike_pos = zeros(length(rSshort),1);
  for i=1:length(spike_pos)-1
     if (spike_pos2(i+1)<0) && (spike_pos2(i)>0)
        spike_pos(i) = -rSshort(i);
     end
  end
  spike_pos = spike_pos / mean(spike_pos(spike_pos>0));
  input = zeros(round(length(spike_pos)*fs_out/FS_SPIKE),1);
  for i=1:length(spike_pos)
     if spike_pos(i) > 0
        input(max(1,floor(i*fs_out/FS_SPIKE))) = input(max(1,floor(i*fs_out/FS_SPIKE))) + spike_pos(i);
     end
  end
  
  
  % SUA derivative method
 case 12
  spike_pos = [0;diff(-rS>(threshold*std_rS))];
  spike_pos = spike_pos > 0;
  input = zeros(round(length(spike_pos)*fs_out/FS_SPIKE),1);
  for i=1:length(spike_pos)
     if spike_pos(i) > 0
        input(max(1,floor(i*fs_out/FS_SPIKE))) = input(max(1,floor(i*fs_out/FS_SPIKE))) + spike_pos(i);
     end
  end
  
 otherwise
  error('invalid input mode number');
  
end

if length(input)>length(output),
%    fprintf('truncating input at %d bins to match output length\n',...
%            length(output));
   input=input(1:length(output));
elseif length(output)>length(input),
%    fprintf('truncating output at %d bins to match input length\n',...
%            length(input));
   input=input(1:length(output));
end

if sum(input) == 0
    error('sum of input signal == 0. bad channel');
end

%
% measure the spike-LFP filter and apply it to the LFP signal
%
if unbiased

   % 20 cross-covariance
   for i=0:19
      
      stop1 = floor(length(input)/20)*i;
      start2 = floor(length(input)/20)*(i+1)+1;
      
      switch i
       case 0
        input_filter = input(start2:end);
        output_filter = output(start2:end);
       case 19
        input_filter = input(1:stop1);
        output_filter = output(1:stop1);
       otherwise
        input_filter = [input(1:stop1);input(start2:end)];
        output_filter = [output(1:stop1);output(start2:end)];
      end
      
      xc = xcov(output_filter,input_filter,FILTER_LEN,'unbiased');
      ac = xcov(input_filter,input_filter,FILTER_LEN,'unbiased');
      
      fft_xc = fft(xc);
      fft_ac = fft(ac);
      
      h_fft = fft_xc./fft_ac;
      h = real(ifft(h_fft));
      h = fftshift(h) .* hann(FILTER_LEN*2+1);
      h = h - mean(h);
      
      switch i
       case 0
        out_spikes = conv(input(stop1+1:start2-1+length(h)), h);
        out_spikes = out_spikes(round(length(h)/2):length(out_spikes)-round(3*length(h)/2)+1);
        output_short = output(stop1+1:start2-1);
       case 19
        out_spikes = conv(input(stop1+1-length(h):end), h);
        out_spikes = out_spikes(round(3*length(h)/2):length(out_spikes)-round(length(h)/2)+1);
        output_short = output(stop1+1:end);
       otherwise
        out_spikes = conv(input(stop1+1-length(h):start2-1+length(h)), h);
        out_spikes = out_spikes(round(3*length(h)/2):length(out_spikes)-round(3*length(h)/2)+1);
        output_short = output(stop1+1:start2-1);
      end
      
      output_clean = cat(1, output_clean, output_short - out_spikes);
   end
   
else
   % biased
   
   xc = xcov(output,input,FILTER_LEN,'unbiased');
   ac = xcov(input,input,FILTER_LEN,'unbiased');
   
   fft_xc = fft(xc);
   fft_ac = fft(ac);
   
   h_fft = fft_xc./fft_ac;
   h = real(ifft(h_fft));
   h = fftshift(h) .* hann(FILTER_LEN*2+1);
   h = h - mean(h);
   
   out_spikes = conv(input, h);
   output_clean = output - ...
       out_spikes(round(length(h)/2):...
                  length(out_spikes)-round(length(h)/2)+1);
end

% only for debugging purposes
if ((exist('verbose','var') ~= 0) && (verbose == 1))

   figure(1)
   plot(h);
   title('spike-LFP filter');
   
   figure(2);
   clf
   plot(xcov(output,input,fs_out*2,'unbiased'));
   hold on;
   plot(xcov(input,output_clean,fs_out*2,'unbiased'),'g');
   hold off
   title('spike-LFP cross correlations');
   legend('lfp raw-spike','lfp clean-spike');

end

