InitializePsychSound(1); 

Fs = 44100;

f1 = 6e3; 
f2 = 8e3;  
f3 = 10e3;
f4 = 12e3; 


dur_s = 0.5; 

pad = zeros(1, round(0.25*Fs)); 

y1 = [pad sin(linspace(0, dur_s*f1*2*pi, round(dur_s*Fs))) pad]*0.3; 
y2 = [pad sin(linspace(0, dur_s*f2*2*pi, round(dur_s*Fs))) pad]*0.3; 
y3 = [pad sin(linspace(0, dur_s*f3*2*pi, round(dur_s*Fs))) pad]*0.3; 
y4 = [pad sin(linspace(0, dur_s*f4*2*pi, round(dur_s*Fs))) pad]*0.3; 

audio_data = [y1; y2; y3; y4]; 
% audio_data = [y1; y2]; 


devs = PsychPortAudio('GetDevices');
ASIOind = find(~cellfun(@isempty, regexp({devs.DeviceName}, 'ASIO')))-1; % -1 because 0-indexed

if isempty(ASIOind)
    errordlg('ASIO device may not have been found, may have latency issues', ...
        'ASIO device error');
end

numChans = 4;
% numChans = 2; 
pahandle = PsychPortAudio('Open', ASIOind, [], 2, Fs, numChans);

buffhandle = PsychPortAudio('CreateBuffer', pahandle, audio_data);
% PsychPortAudio('FillBuffer', pahandle, buffhandle);
PsychPortAudio('FillBuffer', pahandle, buffhandle);

PsychPortAudio('Start', pahandle, 20); 

% status = PsychPortAudio('GetStatus', pahandle); 
% while status.Active
%     WaitSecs(0.01);
%     status = PsychPortAudio('GetStatus', pahandle); 
% end 
% PsychPortAudio('Close'); 


