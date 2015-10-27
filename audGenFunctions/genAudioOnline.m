function buffhandle = genAudioOnline(pahandle, audio, visual, params, ind)

disp('********************************************************************')
disp(['TRIAL ' num2str(ind')]);
disp('********************************************************************')
t1 = GetSecs;

if visual.vis_only_BL(ind)
    audio_data = feval(@genNoAudio, ind, audio.dur(ind), audio.freq(ind), audio.Fs, audio.params_other);
elseif audio.aud_only_BL(ind)
    audio_data = feval(audio.genFunc_BL, ind, audio.dur_BL, audio.freq_BL, audio.Fs, audio.params_other_BL);
else
    audio_data = feval(audio.genFunc, ind, audio.dur(ind), audio.freq(ind), audio.Fs, audio.params_other);
end


%if ~strcmp(audio.genFunc, 'genNoAudio')
% do things to audio
if audio.AM_flag
    audio_data = addAmpMod(audio_data, audio.AM_freq, audio.Fs);
end

if ~strcmp(char(audio.genFunc), 'genNoAudio') & ~visual.vis_only_BL(ind)
    aud_trial = 1;
    % apply 4kHz highpass zero-phase filter
    Wn = 3.9e3/(0.5*audio.Fs); % pass above 3.9 kHz
    n = 1000; % 1000th order filter (before 100-order was too low)
    b = fir1(n, Wn, 'high');
    audio_data = filtfilt(b,1,audio_data);
    
    % apply speaker calibration filter
    if isfield(audio, 'spk_cal_filt')
        % audio_data2 = filtfilt(audio.spk_cal_filt, 1, audio_data); %
        % DON'T USE FILTFILT
        audio_data = filter(audio.spk_cal_filt, 1, audio_data);
        disp('Speaker calibration filter applied');
    end
    
    % apply attenuation
    %if audio.atten(ind) ~= 0
    atten = 10^-((audio.atten(ind) + audio.offset_atten)/20);
    audio_data = audio_data*atten;
else
    aud_trial = 0;
end

% add triggers
if strcmp(char(audio.genFunc), 'retWavAudio')
    trialLen_ms= round(length(audio_data)/(audio.Fs/1e3)+100);
else
    trialLen_ms = params.trialLen;
end

if params.allTriggersOneCh
    if ~isempty(params.lightTest)
        triggerCh = addLightTestTrigs(params.lightTest, trialLen_ms, audio.Fs);
        trialLen = length(triggerCh);
        audCh = zeros(1,trialLen);
    else
        
        %         triggerCh = addTriggersOneCh(audio.dur(ind), trialLen_ms, params.stimStart(ind), params.SOA(ind), aud_trial, params.lightStart(ind),...
        %             params.lightStop(ind), params.light_trial(ind), audio.Fs);
        
        % removed aud_trial flag - will start using sound trigger for all stimuli,
        % including visual only
        if visual.vis_only_BL(ind)
            triggerCh = addTriggersOneCh(visual.dur, trialLen_ms, params.stimStart(ind), params.SOA(ind), params.lightStart(ind),...
                params.lightStop(ind), params.light_trial(ind), audio.Fs);
        else
            triggerCh = addTriggersOneCh(audio.dur(ind), trialLen_ms, params.stimStart(ind), params.SOA(ind), params.lightStart(ind),...
                params.lightStop(ind), params.light_trial(ind), audio.Fs);
        end
        
        trialLen = length(triggerCh);
        audCh = padAudio(audio_data, params.stimStart(ind), params.SOA(ind), trialLen, audio.Fs);
    end
    
    audio_allChs = assignAudChs(audio.numChans, params.chSelect, audCh, [], triggerCh, []);
else
    trTrCh = addTrialTriggers(trialLen_ms, audio.Fs); % calculate trial triggers
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

fprintf('Call to genAudioOnline took %f s\n', t2-t1);
disp(['Trial length ' num2str(trialLen/audio.Fs, 10)]);


