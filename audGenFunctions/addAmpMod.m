function y_out = addAmpMod(y_in, AM_freq, Fs)

len_y_in = length(y_in); 

y_env = sin(linspace(0, round((len_y_in/Fs)*AM_freq*2*pi), len_y_in))+1;

y_out = y_in(1,:).*y_env; 