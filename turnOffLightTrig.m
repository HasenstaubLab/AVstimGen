function turnOffLightTrig()
% turnOffRecordTrig()
% a quick function to turn off the record trigger, takes no input args 

Fs = 192e3; 
pahandle = PsychPortAudio('Open', [], [], [], Fs);

buffhandle = genLightControlTriggers(pahandle, Fs, 2); 
PsychPortAudio('FillBuffer', pahandle, buffhandle); 
PsychPortAudio('Start', pahandle, [], [], 1); 
stat = PsychPortAudio('GetStatus', pahandle); 
while stat.Active 
    stat = PsychPortAudio('GetStatus', pahandle); 
end

PsychPortAudio('Close', pahandle); 
