function y = genClickTrain(dur, freq_dummy, Fs, click_params)
click_freq = click_params.click_freq; 
click_dur = click_params.click_dur;
ramp_on_dur = click_params.ramp_on_dur; 
ramp_off_dur = click_params.ramp_off_dur; 


one_ms = Fs/1000; 

triang_win_on = triang(round(one_ms*(ramp_on_dur)));
triang_win_off = triang(round(one_ms*(ramp_off_dur)));
click_noise = rand(1,round(one_ms*(click_dur+ramp_on_dur+ramp_off_dur)))*2-1; % scale from +1/-1 

ramp_on = triang_win_on(1:floor(length(triang_win_on)/2)); 
ramp_off = triang_win_off(ceil(length(triang_win_off)/2)+1:end); 

click_noise(1:length(ramp_on)) = click_noise(1:length(ramp_on)).*ramp_on';
click_noise(end-length(ramp_off)+1:end) = click_noise(end-length(ramp_off)+1:end).*ramp_off'; 

cycle_len = Fs/click_freq; 
a_cycle = [click_noise zeros(1, cycle_len-length(click_noise))];
y = repmat(a_cycle,1,floor(dur/1000*click_freq)); 
 

% remove when 2nd channel is actually trig ch
% y = [y; y]; 