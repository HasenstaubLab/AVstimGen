%wait until we begin the polling loop; KbCheck is fast enough to catch
%the trailing end of the <RETURN> keypress which invokes this script.  
WaitSecs(0.5);
% poll the keyboad while waiting.
waitDurationSecs= 2;
disp(['Waiting ' num2str(waitDurationSecs) ' seconds while scanning for keypresses using KbCheck.']);

kDetected=0;
tStop=GetSecs + waitDurationSecs;
while GetSecs < tStop
    if ~kDetected
        [kDetected, kSecs, kCode]=KbCheck(-1);
    else 
        break 
    end 
end
%display the results
if kDetected
    disp(['You pressed the "' KbName(kCode) '" key.']);
else
    disp('You pressed no key');
end
 