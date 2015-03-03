function trTrCh = addTrialTriggers2(trLen_spec, Fs)
% adds positive/negative triggers indicadting start and stop of trial, with
% length indicated by trLen_spec  
% Fs = sample rate

%Fs = 44.1e3; 
ms = round(Fs/1000); 
pad = zeros(1, ms*10); % pad 10ms 
short_trig_ht = 0.2; 
tall_trig_ht = 0.6; 
trig_len = 0.2; 
iti_len = 0.2; 
pad_long = zeros(1,ms*2000); 

short_trig = ones(1,round(ms*trig_len))*short_trig_ht; 
tall_trig = ones(1,round(ms*trig_len))*tall_trig_ht; 
iti = zeros(1,round(ms*iti_len)); 

trial_start = [short_trig iti tall_trig]; 
light_start = [short_trig iti short_trig iti tall_trig]; 
audio_start = [short_trig iti short_trig iti short_trig iti tall_trig]; 

trial_stop = trial_start *-1; 
light_stop = light_start *-1; 
audio_stop = audio_start *-1;  

% start_trigs = [pad trial_start pad_long light_start pad_long ...
%     audio_start]; 
% stop_trigs = [audio_stop pad_long light_stop pad_long trial_stop pad]; 

%s_len = trLen_spec*ms - (length(start_trigs)+length(stop_trigs)); 
%trTrCh = [pad start_trigs zeros(1,s_len) stop_trigs pad]; 

%trTrCh = [pad trial_start pad_long trial_stop pad_long light_start pad_long light_stop pad_long audio_start pad_long...
%     audio_stop pad_long trial_start pad_long audio_stop pad_long light_start pad_long audio_stop pad_long ...
%     audio_start pad_long trial_stop pad_long audio_start pad_long light_stop pad]; 

trTrCh = [pad_long trial_start pad_long tall_trig pad_long light_start pad_long light_stop pad_long tall_trig*-1 pad_long trial_stop pad]; 




% figure; 
% plot(trTrCh); 

%trTrCh = [pad trig zeros(1,s_len) trig*-1 pad]; % RJM 123014

%trTrCh = [pad trig zeros(1,s_len) trig pad]; 
