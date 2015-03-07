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
%     
%     p.tapers = [4 7];
%     p.Fs = 192000; 
%     [S,f] = mtspectrumc(audio_data, p); 
%     [S2,f2] = mtspectrumc(audio_data2, p); 
%     sca
%     
%     figure; 
%     plot(f, smooth(S,100), 'b'); 
%     hold on
%     plot(f2, smooth(S2,100), 'r'); 
%     legend({'WN before spkr filt', 'After spkr filt'})
%     xlabel('Freq');
%     ylabel('Power units'); 
%     set(gca, 'FontSize', 12); 
%     
%     figure; 
%     plot(audio_data(1:19200)); 
%     hold on
%     plot(audio_data2(1:19200), 'r');
%     keyboard
    
    
%     keyboard
%     
    % apply rms normalization 
    
    
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


