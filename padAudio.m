function audCh = padAudio(yIn, stimOnset, SOA, trialLen, Fs) 
% pad audio data to meet requested trial timing 

if yIn == 0 | isempty(yIn)
    audCh = zeros(1,trialLen);
else
    ms = round(Fs/1000);
    pad = zeros(1, ms*10); % pad 10ms
    stimOnDelay = zeros(1,ms*stimOnset);
    
    if SOA> 0
        SOA_aud = zeros(1,ms*SOA);
    else
        SOA_aud = [];
    end
    
    endPad = trialLen - (length(pad) + length(stimOnDelay) + length(SOA_aud) + length(yIn));
    audCh = [pad stimOnDelay SOA_aud yIn zeros(1,endPad)];
        
end



