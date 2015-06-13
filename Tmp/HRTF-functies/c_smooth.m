function y = c_smooth(H,coeff,result_plot)
if nargin<3
    result_plot=0;
end
if nargin<2
    fprintf('Choose number of coefficients M, with M<frequencys/2');
    return;
end


%%recreate impulse responses
[trl N]=size(H);
y      =zeros(size(H));
for i=1:trl

    if coeff > N
        fprintf('Choose number of coefficients M, with M<frequencys/2');
        return;
    end

    M                   =coeff;
    C                   =zeros(1,floor(N/2)+1);
    ft_H                =ifft(log(abs(H(i,:))));
    C([1:M+1])          =ft_H([1:M+1]);

    
    %M bepaalt tot aan welke hoogfrequente sinussen het signaal opgebouwd
    %wordt.

    C_s                 =zeros(1,N);
    C_s(1)              =(C(1));
    C_s([2:floor(N/2)]) =(C([2:floor(N/2)]))*2;
    C_s(floor(N/2)+1)   =(C(floor(N/2)+1));
    H_mag_s             =exp((fft(C_s)));
    y(i,:)              =abs(H_mag_s);
end
if (result_plot)
    for i=1:trl
        dBlog_plot_duo(abs(H(i,[1:N/2])),y(i,[1:N/2]));
        reply = input(['\n' 'Press enter to continue.' ...
            '\n' 'Input s to break!' ...
            '\n' '\\'], 's');
            if reply == 's' 
                close all
                break
            end
            close all
    end
end



