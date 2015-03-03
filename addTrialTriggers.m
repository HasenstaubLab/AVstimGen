function trTrCh = addTrialTriggers(trLen_spec, Fs)
% adds positive/negative triggers indicadting start and stop of trial, with
% length indicated by trLen_spec  
% Fs = sample rate


ms = round(Fs/1000); 
pad = zeros(1, ms*10); % pad 10ms 
trig = ones(1, ms*5)*0.3; % trigger ht = 0.3 

s_len = trLen_spec*ms - length(trig)*2; 

trTrCh = [pad trig zeros(1,s_len) trig*-1 pad]; % RJM 123014

%trTrCh = [pad trig zeros(1,s_len) trig pad]; 


% %RJM 123014
% ms = round(Fs/1000); 
% pad = ones(1, ms*10)*-1; % pad 10ms 
% trig = ones(1, ms*5)*0.3; % trigger ht = 0.3 
% trig = ones(1, ms*5)*1; % trigger ht = 0.3 
% 
% s_len = trLen_spec*ms - length(trig)*2; 
% 
% trTrCh = [pad trig zeros(1,s_len) trig*-1 pad]; RJM 123014
% 
% trTrCh = [pad trig ones(1,s_len)*-1 trig pad]; 
