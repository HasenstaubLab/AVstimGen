function triggerCh = addTriggersOneCh(aud_dur, trialLen, stimOnset, SOA, aud_trial, light_start, light_stop, light_trial, Fs)

% add multiplexed audio, light triggers onto one channel

% audio will be one pulse 
% light will be two 

%t1 = GetSecs; 

% SOA = 0; 
% aud_dur = 500; 
% trialLen = 1000; 
% Fs = 192000; 
% stimOnset = 250; 
% light_start = 500; 
% light_stop = 750; 
% light_trial = 1; 
% yIn = [10 10]; 

ms = round(Fs/1000); 
pad = zeros(1,ms*10);

short_trig_ht = 0.2; 
tall_trig_ht = 0.6; 
trig_len = 0.2; 
iti_len = 0.2; 
%pad_long = zeros(1,ms*2000); 

short_trig = ones(1,round(ms*trig_len))*short_trig_ht; 
tall_trig = ones(1,round(ms*trig_len))*tall_trig_ht; 
iti = zeros(1,round(ms*iti_len)); 

triggerCh = zeros(1,trialLen*ms);

if aud_trial 
    if SOA>0
        SOA_aud = SOA;
    else
        SOA_aud = 0;
    end
    
    aud_start_trig = [short_trig iti tall_trig];
    aud_stop_trig = aud_start_trig *-1;
    aud_start = stimOnset + SOA_aud;
    aud_stop = aud_start + aud_dur;
    aud_start_idx = aud_start*ms;
    aud_stop_idx = aud_stop*ms;
    triggerCh(aud_start_idx-length(aud_start_trig)+1:aud_start_idx)= aud_start_trig;
    triggerCh(aud_stop_idx-length(aud_stop_trig)+1:aud_stop_idx)= aud_stop_trig;
end

if light_trial
    light_start_trig = [short_trig iti short_trig iti tall_trig]; 
    light_stop_trig = light_start_trig *-1; 
    light_start_idx = light_start*ms;
    light_stop_idx = light_stop*ms;
    triggerCh(light_start_idx-length(light_start_trig)+1:light_start_idx)= light_start_trig;
    triggerCh(light_stop_idx-length(light_stop_trig)+1:light_stop_idx)= light_stop_trig;
end

% overwrites what was previously written if audio and light start/stop
% coincide - has to be a better way to do this 
if aud_trial && light_trial 
    if aud_start == light_start
        both_start_trig = [short_trig iti short_trig iti short_trig iti tall_trig];
        triggerCh(light_start_idx-length(both_start_trig)+1:light_start_idx)= both_start_trig; 
    end
    if aud_stop == light_stop
        both_stop_trig = [short_trig iti short_trig iti short_trig iti tall_trig]*-1; 
        triggerCh(light_stop_idx-length(both_stop_trig)+1:light_stop_idx)= both_stop_trig; 
    end
end

triggerCh = [pad triggerCh pad]; 

% t2 = GetSecs; 
% fprintf('\nTime elapsed is %f\n', t2-t1)
%figure; plot([1:length(triggerCh)]/Fs, triggerCh)

    







