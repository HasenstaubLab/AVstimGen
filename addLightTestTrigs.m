function triggerCh = addLightTestTrigs(test_type, trialLen, Fs) 

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

light_start_trig = [short_trig iti short_trig iti tall_trig]; 
light_stop_trig = light_start_trig *-1; 

if strcmp(test_type, 'Light Test Fast') % 5ms pulses with 10ms in between
    pulse = [light_start_trig zeros(1,round(ms*4.2)) light_stop_trig zeros(1,ms*10)];  
else %5ms pulses w/ 100ms in between 
    pulse = [light_start_trig zeros(1,round(ms*4.2)) light_stop_trig zeros(1,ms*100)]; 
end

numReps = floor((length(triggerCh) - length(pad*2))/length(pulse)); 

triggers = [pad repmat(pulse,1,numReps) pad]; 
triggerCh(1:length(triggers)) = triggers; 


%plot(triggerCh); 