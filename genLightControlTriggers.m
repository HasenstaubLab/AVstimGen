function buffhandle = genLightControlTriggers(pahandle, Fs, whichCall)

%genAudioOnline(pahandle, audio, params, ind)

padLen1 = 200;
padLen2 = 1000;

ms = round(Fs/1000);
pad1 = zeros(1, ms*padLen1);
pad2 = zeros(1, ms*padLen2);

short_trig_ht = 0.2;
tall_trig_ht = 0.6;
trig_len = 0.2;
iti_len = 0.2;
short_trig = ones(1,round(ms*trig_len))*short_trig_ht;
tall_trig = ones(1,round(ms*trig_len))*tall_trig_ht;
iti = zeros(1,round(ms*iti_len));
trig = [short_trig iti short_trig iti tall_trig]; % 2-1 trigger


if whichCall == 1
    controlTrigCh = [pad1 trig pad2];
elseif whichCall == 2
    controlTrigCh = [pad2 trig*-1 pad1];
end
emptyCh = zeros(1,length(controlTrigCh));

buffhandle = PsychPortAudio('CreateBuffer', pahandle, [emptyCh; controlTrigCh]);

% disp('********************************************************************')
% disp('RECORD CONTROL TRIGGER');
% %fprintf('Length is %d ', length(controlTrigCh));
% disp('********************************************************************')

