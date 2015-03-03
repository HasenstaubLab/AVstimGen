% y = genWhiteNoise(dur, Fs)
% dur: duration in ms 

function y = genWhiteNoise(dur, ~, Fs, otherParams)

dur_s = dur/1000; 

y = rand(1, round(dur_s*Fs))*2-1; % scaled random numbers
% temp:
% y = [y; y]; 
