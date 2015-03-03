% 10/3/14 - NOT USED IN AVSTIMGEN
% pause_status = pauseRoutine(pause_flag)
% if queried without input arg, returns pause_status, a persistent logical
% indicating value of the last input argument passed to pauseRoutine 

function pause_status = pauseRoutine(pause_flag)
persistent pause_pers

if nargin <1
    
    if isempty(pause_pers);
        pause_pers = 0; 
    end
else
    pause_pers = pause_flag; 
end
pause_status = pause_pers;