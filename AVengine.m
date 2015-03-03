function AVengine(audio, visual, params, status_handles, tcp_handle, pub_socket, session_save)
% AVengine(audio, visual, params)
% audio/visual engine for AVStimGen player
%

% persistent msg_hdr_date
%
% disp(['MSG hdr date is ' msg_hdr_date])

java.lang.Runtime.getRuntime.gc % java runtime garbage collection
% any other ways to clean up memory before running?
%set(status_handles, 'String', 'Loading initial parameters');

%%%% RJM 010915

% zeroMQwrapper('Send',tcp_handle ,'NewDesign Go_Left_Right');
% zeroMQwrapper('Send',tcp_handle ,'AddCondition Name GoRight TrialTypes 1 2 3');
% zeroMQwrapper('Send',tcp_handle ,'AddCondition Name GoLeft TrialTypes 4 5 6');

% tic; while toc < 2; end;
%%%%

Screen('Preference', 'VisualDebugLevel', 1); % should make initial screen black instead of white

ver = 'v_01_21_15';
audSubDir = 'audGenFunctions';
visSubDir = 'visGenFunctions';
addpath(audSubDir);
addpath(visSubDir);

AssertOpenGL;
InitializePsychSound(1);
Screen('Preference', 'SkipSyncTests', 0);
oldlevel = Screen('Preference', 'Verbosity', 4);

% For keyboard control during recordings
KbName('UnifyKeyNames');
escapeKey = KbName('ESCAPE');
GetSecs; % initialize to put into memory
WaitSecs(0.01);

disp('******************************************************************');
disp(['AVengine ' ver]);
% disp(['Will present ' num2str(numBlocks) ' blocks']);
% disp(['Presentation mode is ' num2str(stimMode)]);
disp('******************************************************************');

%%% SETUP AUDIO
% clear system
if PsychPortAudio('GetOpenDeviceCount')>0
    PsychPortAudio('Close')
end

% devs = PsychPortAudio('GetDevices');
% ASIOind = find(~cellfun(@isempty, regexp({devs.DeviceName}, 'ASIO')))-1; % -1 because 0-indexed
%pahandle = PsychPortAudio('Open' [, deviceid][, mode][, reqlatencyclass][, freq][, channels][, buffersize][, suggestedLatency][, selectchannels][, specialFlags=0]);
% Open audio device
try
    %pahandle = PsychPortAudio('Open', ASIOind, [], 2, audio.Fs, audio.numChans); % changed to 4, necessary?
    pahandle = PsychPortAudio('Open', audio.currdevind, [], 2, audio.Fs, audio.numChans);
catch me
    disp(me)
    errordlg('Error opening audio device. Check number of channels and sample rate.');
    return;
    % pahandle = PsychPortAudio('Open', 1, [], 2, audio.Fs, audio.numChans);
end

latbias = -0.001; % exp measured bias for Snake Pit Mac Mini, RJM 01/21/15
PsychPortAudio('LatencyBias', pahandle, latbias);

%if isempty(screenid)
Screen('CloseAll')
screenid = max(Screen('Screens'));

%%% SETUP VIDEO
% black/white values
black = BlackIndex(screenid);
white = WhiteIndex(screenid);
gray = (black+white)/2;

% set default screen color
switch visual.restScrCol
    case 'Black'
        restCol = black;
    case 'Gray'
        restCol = gray;
    case 'White'
        restCol = white;
end

% win = Screen('OpenWindow', screenid, restCol, [1 1 800 1200]); % for debug
% priority
%     topPriorityLevel = MaxPriority(win);
%     Priority(topPriorityLevel);

HideCursor();
WaitSecs(2); % Wait during change of display mode
win = Screen('OpenWindow', screenid, restCol);
AssertGLSL;

ifi = Screen('GetFlipInterval', win);
fR = Screen('NominalFrameRate', screenid);

[win_width win_height] = Screen('WindowSize', win);

% for incrementing phase if using gratings
phase = 0;
phase_inc = visual.cycles_perSec * 360 * ifi;

waitframes = 1; %% try to redraw on every monitor refresh
waitdur = waitframes * ifi;

% syncflash paramaters
syncFlashDur_fr = round(visual.syncFlashDur/ifi);
syncFlashDims = visual.syncFlashDims;

movieDurFrames=round(visual.dur/1000 * fR);

% calculate suggested latency for audio start based on ifi
% measured latency for RJM's audio system w E-MU 0204 is 18.86ms
% to measure this, use soundTimingTest (RJM)
% assuming an ifi of 16.7ms, this requires two screen flips
% i.e. schedule audio for 33.4ms after timestamp flip, adding one extra flip before
% video start flip
sugLat_flips = 1;
sugLat = ifi * 2;

padLen = 10; % pad before/after the trial: hard-coded for now, change later

switch visual.stimMode;
    case 'LM' % MOVIE
        movieFrameIndices=mod(0:(movieDurationFrames-1), numFrames) + 1;
    case 'DG' % DRIFTING GRATINGS
        texHandle = genGratings(win, visual.width, visual.height);
        PTparams = {phase visual.frequency_pixel visual.contrast 0};
    case 'NS' % NOISE
        %
        PTparams = {visual.contrast 1 0 0}; %% CHECK THIS
    case 'GB' % GABOR
        %
        PTparams = {};
    case 'RD' % RAINDROPPER
        %
    case 'FL' % FLASHES
        flashRect = [1 1 visual.width visual.height];
        flashRect = CenterRectOnPoint(flashRect, round(win_width/2), round(win_height/2));
        flashLums = ones(1, movieDurFrames)*white;
    case 'FP' % FLASH PULSES
        flashRect = [1 1 visual.width visual.height];
        flashRect = CenterRectOnPoint(flashRect, round(win_width/2), round(win_height/2));
        
        % precalculate frame luminances for flashes
        if visual.sin_varying
            flashLums = sin(linspace(0, visual.dur/1000*visual.cycles_perSec*2*pi, movieDurFrames)+1)*white;
        else
            %         flashHalf = round(1/(visual.cycles_perSec*2)*fR)
            %         flashCycle = [ones(1,flashHalf) zeros(1,flashHalf)]*white;
            %         flashLums = repmat(flashCycle, 1, floor(movieDurFrames/length(flashCycle)));
            flashLums = square(linspace(0, visual.dur/1000*visual.cycles_perSec*2*pi, movieDurFrames)+1)*white; %% same thing, quicker
        end
end

% Run PsychPortAudio very briefly to initialize: should take care of
% initialization-related delays
PsychPortAudio('FillBuffer', pahandle, zeros(audio.numChans,audio.Fs*0.2)); %200ms of zeros
PsychPortAudio('Start', pahandle, 1, 0, 1);
init_tic = GetSecs;
init_toc = GetSecs;
while init_toc-init_tic<0.1
    init_toc = GetSecs;
end
PsychPortAudio('Stop', pahandle, 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% timestamp recording vectors, for ensuring SOA accuracy
vbl1 = zeros(1,params.cycles);
vbl2 = zeros(1,params.cycles);

lpind = 1; % for indexing function calls in big for loop
exit_flag = 0; % for breaking out of big for loop

[SOA_flips SOA_Tdel] = calcVdelay(params.SOA(lpind), params.stimStart(lpind), padLen, ifi);
preVflips = sugLat_flips + SOA_flips;

if params.trigger_control
    % First trial control trigger
    buffhandle = genTrControlTriggers(pahandle, audio, params, 1); % first call to genAudioOnline
    PsychPortAudio('FillBuffer', pahandle, buffhandle);
    startTime = PsychPortAudio('Start', pahandle,1,0,1);
end

% time stuff
trial_st_time = zeros(1,params.cycles);
ref_GetSecs_time = GetSecs;
now_time = now;
msg_hdr_date = datestr(now_time, 'yy-mm-dd-HHMM');

%msg_hdr_date_new = datestr(now_time, 'yy-mm-dd-HHMM');
%
% if strcmp(msg_hdr_date, msg_hdr_date_new)
%     append_nr = regexp(msg_hdr_date, '_\d', 'match');
%     if ~isempty(append_nr)
%         append_nr = str2double(append_nr{:}(2));
%         msg_hdr_date = [msg_hdr_date(1:end-1) num2str(append_nr+1)];
%     else
%         msg_hdr_date = [msg_hdr_date '_1'];
%     end
% else
%     msg_hdr_date = msg_hdr_date_new;
% end

msg_hdr = ['EXP ' msg_hdr_date ' '];

if params.loop_mode
    seq_msg = [msg_hdr params.trial_seq_msg];
else
    seq_msg = [msg_hdr 'TrialType No Loops'];
end

if params.send_messages
    %disp('Sending trial sequence message');
    zeroMQwrapper('Send',tcp_handle,seq_msg);
    disp('Sent trial info over ZMQ msg');
end

if params.pub_messages % send the first message
    publ_bytes = zeros(1,params.cycles);
    
    msg_len_tot = length(seq_msg);
    if msg_len_tot>255 %multi-part
        multipart_msg = 1;
        nr_msgs = ceil(msg_len_tot/255);
        str_ind = 1;
        bytes_sent = zeros(1,nr_msgs);
        msg_split = cell(nr_msgs, 1);
        for i = 1:nr_msgs
            if i == nr_msgs
                msg_split{i} = seq_msg(str_ind:end);
                bytes_sent(i) = zmq_send(pub_socket, uint8(msg_split{i}));
            else
                msg_split{i} = seq_msg(str_ind:str_ind+254);
                bytes_sent(i) = zmq_send(pub_socket, uint8(msg_split{i}), 'ZMQ_SNDMORE');
                str_ind = str_ind+255;
            end
        end
        publ_bytes(1) = sum(bytes_sent);
    else
        multipart_msg = 0;
        publ_bytes(1) = zmq_send(pub_socket, uint8(seq_msg));
    end
    
    if params.loop_mode
        tr_msgs_ct = length(params.var_list);
        for m = 1:tr_msgs_ct % number of trial messages to send
            zmq_send(pub_socket, uint8(sprintf('TRIAL %s %d', params.var_list{m}, params.stim_vals(1,m))));
        end
        zmq_send(pub_socket, uint8(sprintf('TRIAL ind %d', 1)));
    end
    
    disp('Sent trial info over ZMQ publish');
    fprintf('%d bytes sent\n', publ_bytes(1));
else
    publ_bytes = [];
end

if params.trigger_control
    % pause until playing finished
    pastatus = PsychPortAudio('GetStatus', pahandle);
    while pastatus.Active
        pastatus = PsychPortAudio('GetStatus', pahandle);
    end
    %fprintf('Trig 1 Time elapsed is %f', t9-startTime);
end

buffhandle = genAudioOnline(pahandle, audio, params, lpind); % first call to genAudioOnline
PsychPortAudio('FillBuffer', pahandle, buffhandle);


for j = 1:params.cycles
    %%%%% RJM 010915
    % zeroMQwrapper('Send',tcp_handle ,'TrialStart 2');
    %%%%
    
    % three types of movie production: use premade movie (visual.useMovie)
    % use procedural textures (visual.useProceduralTex)
    % use flashes (visual.useFlashMode)
    
    if visual.useMovie
        vbl = Screen('Flip', win);
        PsychPortAudio('Start', pahandle);
        % movie = Screen('OpenMovie', win, [%%%REPLACE W MOVIE FILE]);
        %end
        if visual.vis_stim(j)
            for i=1:movieDurFrames
                if i <= syncFlashDur_fr || i >= (movieDurFrames - syncFlashDur_fr)
                    Screen('FillRect', win, white, syncFlashDims);
                end
                
                % Draw image:
                Screen('DrawTexture', win, tex(movieFrameIndices(i)));
                vbl = Screen('Flip', win, (vbl+0.5*ifi));
            end
        end
        
    elseif visual.useProceduralTex
        PsychPortAudio('Start', pahandle);
        vbl = Screen('Flip', win);
        if visual.vis_stim(j)
            for i = 1:movieDurFrames
                
                if i <= syncFlashDur_fr || i >= (movieDurFrames - syncFlashDur_fr)
                    Screen('FillRect', win, white, syncFlashDims);
                end
                
                Screen('DrawTexture', win, texHandle, [], [], visual.angle, ...
                    [], [], [], [], visual.rotateMode, [PTparams{:}]);
                %vbl = Screen('Flip', win, (vbl+0.5*ifi));
                vbl = Screen('Flip', win);
                if visual.updatePhase
                    PTparams{1} = PTparams{1} + phase_inc;
                end
            end
        end
        
        
    elseif visual.useFlashMode % currently the only mode that works
        
        vbl1(j) = Screen('Flip', win);
        
        PsychPortAudio('Start', pahandle, 1, vbl1(j)+sugLat+SOA_Tdel);
        if visual.vis_stim(j)
            for k = 1:preVflips
                Screen('Flip', win); % better to have timing?
            end
            for i = 1:movieDurFrames
                [kDown, dummy, kCode] = KbCheck;
                if kDown
                    disp('Keystroke recognized')
                    if kCode(escapeKey)
                        disp('ESC key recognized: aborting session...')
                        %stop_it(pahandle, status_handles);
                        exit_flag = 1;
                        %return
                        break
                    end
                end
                
                if i <= syncFlashDur_fr || i >= (movieDurFrames - syncFlashDur_fr)
                    Screen('FillRect', win, white, syncFlashDims);
                end
                Screen('FillRect', win, flashLums(i), flashRect);
                if i == 1
                    vbl2(j) = Screen('Flip', win); % for debug only
                else
                    Screen('Flip', win);
                end
                
            end
        end
    elseif visual.noVisual
        PsychPortAudio('Start', pahandle);
    end
    
    
    
    Screen('FillRect', win, restCol);
    Screen('Flip', win);
    
    if exit_flag
        break
    end
    
    pastatus = PsychPortAudio('GetStatus', pahandle);
    req_st_time = pastatus.RequestedStartTime;
    act_st_time = pastatus.StartTime;
    % expect_end_time = pastatus.EstimatedStopTime;

    fprintf('\nPA status is %i\n', pastatus.Active)
    while pastatus.Active
        pastatus = PsychPortAudio('GetStatus', pahandle);
        [kDown, dummy, kCode] = KbCheck;
        if kDown
            disp('Keystroke recognized')
            if kCode(escapeKey)
                disp('ESC key recognized: aborting session...')
                %stop_it(pahandle, status_handles);
                exit_flag = 1;
                %return
                break
            end
        end
    end
    
    if exit_flag 
        break
    end

    ISI_tic = GetSecs;
    
    trial_st_time(j) = vbl1(j)+sugLat+SOA_Tdel; % this is the time the first sample hits the audio card
    
    if params.send_messages
        if strcmp(char(audio.genFunc), 'genSinTone')
            zeroMQwrapper('Send',tcp_handle ,sprintf('TrialEnd %.0f Hz', audio.freq(j)));
        else
            zeroMQwrapper('Send',tcp_handle ,'TrialEnd');
        end
    end
    
    disp(['Scheduled aud start was ' num2str(req_st_time)]);
    disp(['Actual start was ' num2str(act_st_time)]);
    % disp(['Expected length was ' num2str(expect_end_time-act_st_time)]);
    
    if lpind ~= params.cycles
        lpind = lpind +1; % update ind
        
        % replace stimulus
        buffhandle = genAudioOnline(pahandle, audio, params, lpind);
        PsychPortAudio('FillBuffer', pahandle, buffhandle);
        [SOA_flips SOA_Tdel] = calcVdelay(params.SOA(lpind), params.stimStart(lpind), padLen, ifi);
        preVflips = sugLat_flips + SOA_flips;
        
        % publish another message
        if params.pub_messages
            if multipart_msg
                bytes_sent = zeros(1,nr_msgs);
                for k = 1:nr_msgs % the number of split messages to send
                    if k == nr_msgs
                        bytes_sent(k) = zmq_send(pub_socket, uint8(msg_split{k}));
                    else
                        bytes_sent(k) = zmq_send(pub_socket, uint8(msg_split{k}), 'ZMQ_SNDMORE');
                    end
                end
                publ_bytes(lpind) = sum(bytes_sent);
                
            else
                publ_bytes(lpind) = zmq_send(pub_socket, uint8(seq_msg));
            end
            
            if params.loop_mode
                for m = 1:tr_msgs_ct % number of trial messages to send
                    zmq_send(pub_socket, uint8(sprintf('TRIAL %s %d', params.var_list{m}, params.stim_vals(lpind,m))));
                end
                zmq_send(pub_socket, uint8(sprintf('TRIAL ind %d', lpind)));
            end
            
            disp('Sent trial info over ZMQ publish');
            fprintf('%d bytes sent\n', publ_bytes(lpind));
        end
        % no ISI wait on the last trial
        currISI_s = params.ISI(j)/1e3;
        ISI_toc = GetSecs;
        while currISI_s > ISI_toc - ISI_tic
            ISI_toc = GetSecs;
        end
        t4 = GetSecs;
        disp(['ISI time elapsed = ' num2str(t4-ISI_tic, 10)]);
    end
    disp(['Trial length actual = ' num2str(ISI_tic-act_st_time)]);
    
end

if params.trigger_control
    % Second trial control trigger (end recording)
    buffhandle = genTrControlTriggers(pahandle, audio, params, 2);
    PsychPortAudio('FillBuffer', pahandle, buffhandle);
    startTime = PsychPortAudio('Start', pahandle,1,0,1)
    % pause until playing finished
    pastatus = PsychPortAudio('GetStatus', pahandle);
    while pastatus.Active
        pastatus = PsychPortAudio('GetStatus', pahandle);
    end
    %fprintf('Control Trigger 2 @ %i', startTime);
end

stop_it(pahandle, status_handles);

java.lang.Runtime.getRuntime.gc % java runtime garbage collection


% code to clean things up
Priority(0);
Screen('Preference', 'Verbosity', oldlevel);

% to make timestamps correspond to real time
trial_start.times = trial_st_time;
time_adj = now_time - ref_GetSecs_time/86400;
times_real_num = time_adj + trial_st_time/86400;
trial_start.times_real = str2num(datestr(times_real_num, 'HHMMSSFFF'))'; %format times

save_full = fullfile(session_save.dir, session_save.str);

if exist(save_full, 'file')
    delete(save_full)
end
save(save_full, 'params', 'audio', 'visual', 'trial_start', 'publ_bytes');

scheduledSOAs = vbl2-(vbl1+sugLat+SOA_Tdel);

clear AVengine;

%sprintf('\n cycle %d took  %g sec \n', [1:length(t2); t2-t1])


function stop_it(pahandle, status_handles)

% all done, clean up time
Screen('CloseAll');
PsychPortAudio('Stop', pahandle);
PsychPortAudio('Close', pahandle);
set(status_handles, 'String', 'Stopped');
Priority(0);









