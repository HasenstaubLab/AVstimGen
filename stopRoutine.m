% 10/3/14 NOT USED IN AVSTIMGEN
% stop_status = stopRoutine(stop_flag)
% if queried without input arg, returns stop_status, a persistent logical
% indicating value of the last input argument passed to stopRoutine 

function stop_status = stopRoutine(stop_flag)
persistent stop_pers

if nargin <1
    
    if isempty(stop_pers);
        stop_pers = 0; 
    end
else
    stop_pers = stop_flag; 
end
stop_status = stop_pers;