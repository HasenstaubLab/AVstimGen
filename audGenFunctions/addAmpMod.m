function y_out = addAmpMod(y_in, AM_freq, Fs)

len_y_in = length(y_in); 

%y_env = sin(linspace(0, (len_y_in/Fs)*AM_freq*2*pi, len_y_in))+1;
y_env = (sin(linspace(1.5*pi, (len_y_in/Fs)*AM_freq*2*pi+(1.5*pi), len_y_in))+1)*0.5;

y_out = y_in(1,:).*y_env; 