function exit_flag = CheckForEsc(escapeKey)
% check for esc key and return exit_flag = 1 if being pressed 
% AVstimGen 

[kDown, ~, kCode] = KbCheck;
if kDown
    disp('Keystroke recognized')
    if kCode(escapeKey)
        disp('ESC key recognized: aborting session...')
        %stop_it(pahandle, status_handles);
        exit_flag = 1;
    else
        exit_flag = 0; 
    end
else
    exit_flag = 0; 
end
