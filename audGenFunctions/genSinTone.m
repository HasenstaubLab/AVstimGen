
function y = genSinTone(dur, freq, Fs, ~) 

rampSize = 6e-3; % ramp size of 3ms 

hanwin = hanning(rampSize*Fs); 
rampUp = hanwin(1:round(end/2)); 
rampDown = hanwin(round(end/2)+1:end); 

dur_s = dur/1000;

y = sin(linspace(0, dur_s*freq*2*pi, round(dur_s*Fs)));

y(1:length(rampUp)) = (y(1:length(rampUp)).*rampUp')'; 
y(end-length(rampDown)+1:end) = (y(end-length(rampDown)+1:end).*rampDown')'; 

% sca 
% figure; 
% plot(y); 

% keyboard
% TEMP
% y = [y; y]; 