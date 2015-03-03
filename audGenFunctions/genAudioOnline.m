function buffhandle = genAudioOnline(pahandle, audio, params, ind) 

disp('********************************************************************')
disp(['TRIAL ' num2str(ind')]); 
disp('********************************************************************')
t1 = GetSecs;

audio_data = feval(audio.genFunc, audio.dur(ind), audio.freq(ind), audio.Fs, audio.params_other);

%if ~strcmp(audio.genFunc, 'genNoAudio')
% do things to audio
if audio.AM_flag
    audio_data = addAmpMod(audio_data, audio.AM_freq, audio.Fs);
end

if ~strcmp(char(audio.genFunc), 'genNoAudio')
    aud_trial = 1; 
    % apply 4kHz highpass zero-phase filter
    Wn = 4e3/(0.5*audio.Fs);
    n = 100; % 100th order filter
    b = fir1(n, Wn, 'high');
    audio_data = filtfilt(b,1,audio_data);
    
%     % apply speaker calibration filter 
%     if isfield(audio, 'spk_cal_filt')
%         audio_data = filtfilt(audio.spk_cal_filt, 1, audio_data); 
%     end
    
    % apply attenuation
    if audio.atten(ind) ~= 0
        audio_data = audio_data*audio.atten(ind);
    end
else
    aud_trial = 0; 
end

% add triggers

if params.allTriggersOneCh 
    triggerCh = addTriggersOneCh(audio.dur(ind), params.trialLen, params.stimStart(ind), params.SOA(ind), aud_trial, params.lightStart(ind),...
        params.lightStop(ind), params.light_trial(ind), audio.Fs); 
    trialLen = length(triggerCh); 
   audCh = padAudio(audio_data, params.stimStart(ind), params.SOA(ind), trialLen, audio.Fs); 
   audio_allChs = assignAudChs(audio.numChans, params.chSelect, audCh, [], triggerCh, []);
else
    trTrCh = addTrialTriggers(params.trialLen, audio.Fs); % calculate trial triggers
    %trTrCh = addTrialTriggers2(params.trialLen, audio.Fs);
    trialLen = length(trTrCh);
    [audCh audTrCh] = addAudioTriggers(audio_data, params.stimStart(ind), params.SOA(ind), trialLen, audio.Fs); % calculate audio triggers
    liTrCh = addLightTriggers(params.lightStart(ind), params.lightStop(ind), trialLen, audio.Fs, params.light_trial(ind)); % calculate light triggers
    audio_allChs = assignAudChs(audio.numChans, params.chSelect, audCh, audTrCh, trTrCh, liTrCh);
end


% Defaults:
% ch 1: audio
% ch 2: audio triggers
% ch 3: trial triggers
% ch 4: light triggers

% audio_allChs = [audCh; audTrCh; trTrCh; liTrCh];


t2 = GetSecs; 

buffhandle = PsychPortAudio('CreateBuffer', pahandle, audio_allChs); % IS THIS THE BEST WAY?

disp(['Call to genAudioOnline took ' num2str(t2-t1)]); 
disp(['Trial length ' num2str(trialLen, 10)]); 


