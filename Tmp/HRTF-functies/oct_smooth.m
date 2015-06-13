%Octave smoother. Smoothing windows increases with frequency.
%User can input a symmetric complex or absolute spectrum (positive and
%negative frequencies). Fucntion outputs absolute spectrum.
%Noct determines amout of smoothing. E.g. Noct=3 give 1/3 octave smoothing.

function y = oct_smooth(H,Noct,result_plot)
if nargin<3
    result_plot=0;
end
if nargin<2
    fprintf('Choose N_oct; amount of smoothing is 1/N_oct');
    return;
end

Fs          =48828.125;
spec        =abs(H);
[trl,Nfft]  =size(spec);
freq        =(0:Fs/(Nfft):Fs/2)';
if Noct > 0
    Noct=2*Noct;
    % octave center frequencies
    f1=1;
    i=0;
    while f1 < Fs/2
        f1=f1*10^(3/(10*Noct));
        i=i+1;
        fc(i,:)=f1;
    end

    % octave edge frequencies
    fe=zeros(length(fc),1);
    for i=0:length(fc)-1
        i=i+1;
        f1=10^(3/(20*Noct))*fc(i);
        fe(i,:)=f1;
    end

    % find nearest frequency edges
    for i=1:length(fe)
        fe_p=find(freq>fe(i),1,'first');
        fe_m=find(freq<fe(i),1,'last');
        fe_0=find(freq==fe(i));
        if isempty(fe_0)==0
            fe(i)=fe_0;
        else
            p=fe_p-fe(i);
            m=fe(i)-fe_m;
            if p<m
                fe(i)=fe_p;
            else
               fe(i)=fe_m;
            end
        end
    end
    spec_oct=zeros(trl,length(fe)-1);
    spec_oct_int=zeros(trl,length(freq));

    assignin('base','a',fe);
    for i=1:length(fe)-1
        spec_i=spec(:,fe(i):fe(i+1));
        spec_oct(:,i)=mean(spec_i,2);
    end
    fc=fc(2:end);
    for i=1:trl
        spec_oct_int(i,:)=interp1(fc,spec_oct(i,:),freq,'spline');
        spec_oct_int(i,1)=spec(i,1);
    end
%     plot(spec_oct_int(1,:))
%     hold on; plot(spec(1,1:1024),'g'); hold off   
end
spec_oct_tot                                =zeros(size(H));
if mod(Nfft,2)==0
    sel                                     =length(spec_oct_int)-1:-1:2;
else
    sel                                     =length(spec_oct_int):-1:2;
end
spec_oct_tot(:,length(spec_oct_int)+1:Nfft) =spec_oct_int(:,sel);
spec_oct_tot(:,1:length(spec_oct_int))      =spec_oct_int;

y=spec_oct_tot;
if (result_plot)
    hf_y=round(length(y(1,:))/2);
    hf_s=round(length(spec(1,:))/2);
    for i=1:trl
    dBlog_plot_duo(y(i,1:hf_y),spec(i,1:hf_s))
    tilefig;
    pause
    close all
    end
end
