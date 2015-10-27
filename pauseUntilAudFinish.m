
function pauseUntilAudFinish(pahandle) 
% takes active psychportaudio handle 
% as implied, pauses until no longer playing
% AVstimGen 

pastatus = PsychPortAudio('GetStatus', pahandle);
while pastatus.Active
    pastatus = PsychPortAudio('GetStatus', pahandle);
end