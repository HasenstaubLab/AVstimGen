% y = genWhiteNoise(dur, Fs)
% dur: duration in ms 

function y = genWhiteNoise(dur, ~, Fs, otherParams)

dur_s = dur/1000; 

y = rand(1, round(dur_s*Fs))*2-1; % scaled random numbers

% add ramp up/down RJM 3/4/15 untested  

rampSize = 6e-3; % ramp size of 3ms 
hanwin = hanning(round(rampSize*Fs)); 
rampUp = hanwin(1:round(end/2)); 
rampDown = hanwin(round(end/2)+1:end); 
y(1:length(rampUp)) = (y(1:length(rampUp)).*rampUp')'; 
y(end-length(rampDown)+1:end) = (y(end-length(rampDown)+1:end).*rampDown')'; 

% temp:
% y = [y; y]; 
