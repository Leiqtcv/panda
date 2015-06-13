
function [mp_imp,mp_spec]=mag_spec2min_phase(mag_spec,output_length)
%Function mag_spec2min_phase takes an magnitude spectrum and convert it to
%an minimun phase spectrum and impulse response. It accomplishes this by
%usage of a Hilbert transform. 
%[mp_imp,mp_spec]=mag_spec2min_phase(mag_spec,output_length)

N           =output_length;
[trl NFFT chnl]  =size(mag_spec)  ;
if chnl==2
    mp_imp     = zeros(trl,N,2);
    mp_spec    = zeros(trl,N,2);
else
   mp_imp     = zeros(trl,N,1);
   mp_spec    = zeros(trl,N,1);
end
imp_lh  = zeros(trl,NFFT);
imp_rh  = zeros(trl,NFFT);
spec_lh = zeros(trl,NFFT);
spec_rh = zeros(trl,NFFT);


for i=1:trl
    spec_lh(i,:)=exp(conj(hilbert(log(abs(mag_spec(i,:,1))))));
    imp_lh(i,:) =real(ifft(spec_lh(i,:)));
    if chnl==2
    spec_rh(i,:)=exp(conj(hilbert(log(abs(mag_spec(i,:,2))))));
    imp_rh(i,:) =real(ifft(spec_rh(i,:)));
    end
    %Envelope
        points      =N;
        m           =N-24;          %start fall
        y           =zeros(1,points);
        y(1:m)      =ones(1,m);
        y(m:N)      =cos(0.5*pi*[0:(N-m)]/(N-m)).^2;
        mp_imp(i,:,1)  =imp_lh(i,1:N).*y;
        if chnl==2
            mp_imp(i,:,2)  =imp_rh(i,1:N).*y;%envelope

        end
     
    mp_spec(i,:,1) =fft(mp_imp(i,:,1));
    if chnl==2
        mp_spec(i,:,2) =fft(mp_imp(i,:,2));
    end
end
