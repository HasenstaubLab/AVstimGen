function liTrCh = addLightTriggers(lightStart, lightStop, trialLen, Fs, light_trial)

% adds positive/negative triggers indicadting start and stop of trial, with
% length indicated by trLen
% Fs = sample rate

if isempty(lightStart) || ~light_trial
    liTrCh = zeros(1,trialLen);
else
    ms = round(Fs/1000);
    pad = zeros(1, ms*10); % pad 10ms
    trig = ones(1, ms*5)*0.3; % trigger ht = 0.3
    preLight = zeros(1,ms*lightStart);
    lightOn = zeros(1,ms*(lightStop-lightStart)-length(trig));
    endPad = trialLen - (length(pad) + length(preLight) + length(trig)*2 + length(lightOn));
    liTrCh = [pad preLight trig lightOn trig*-1 zeros(1,endPad)];
end

