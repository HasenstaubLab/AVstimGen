
function y = genSinTone(dur, freq, Fs, ~) 

dur_s = dur/1000;

y = sin(linspace(0, dur_s*freq*2*pi, round(dur_s*Fs)));
% TEMP
% y = [y; y]; 