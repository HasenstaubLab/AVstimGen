
function [audCh audTrCh] = addAudioTriggers(yIn, stimOnset, SOA, trialLen, Fs)
%
% Old version:
% yOut = addAudioTriggers(yIn, trig1params, trig2params, trigFreq, pad1Len, pad2Len, Fs)
% pad1 = zeros(1,round(pad1Len/1000*Fs));
% pad2 = zeros(1,round(pad2Len/1000*Fs));
%
% yIn_pad = [pad1 yIn pad2];
% len_y = length(yIn_pad);
%
% trig1 = sin(linspace(1, trigFreq*2*pi, trig1params(2)));
% trig2 = sin(linspace(1, trigFreq*2*pi, trig2params(2)));
%
% trigChan = [pad1 trig1 zeros(1,[length(yIn_pad) - length(trig1) - length(trig2) - length(pad1) - length(pad2)]) trig2 pad2];
%
% yOut = [yIn_pad; trigChan];

if yIn == 0 | isempty(yIn)
    audCh = zeros(1,trialLen);
    audTrCh = zeros(1,trialLen);
else
    ms = round(Fs/1000);
    pad = zeros(1, ms*10); % pad 10ms
    trig = ones(1, ms*5)*0.3; % trigger ht = 0.3
    
    stimOnDelay = zeros(1,ms*stimOnset);
    
    if SOA> 0
        SOA_aud = zeros(1,ms*SOA);
    else
        SOA_aud = [];
    end
    
    endPad = trialLen - (length(pad) + length(stimOnDelay) + length(SOA_aud) + length(yIn));
    
    audTrCh = [pad stimOnDelay SOA_aud trig zeros(1,length(yIn)-length(trig)) trig*-1 zeros(1,endPad - length(trig))];
    audCh = [pad stimOnDelay SOA_aud yIn zeros(1,endPad)];
    
    if length(audTrCh) ~= trialLen
        error('addAudioTriggers: Length of audio trigger channel does not match trial length');
    end
    
    if length(audCh) ~= trialLen
        error('addAudioTriggers: Length of audio channel does not match trial length');
    end
    
        
end












