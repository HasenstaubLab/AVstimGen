% passes zeros to AVengine
function y = genNoAudio(ind_dummy, dur, ~, Fs, ~) 
%y = [0; 0];
dur_s = dur/1000;
y = zeros(1,round(dur_s*Fs)); 
