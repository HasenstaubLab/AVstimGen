function [texHandle, stimRect, moviedata, PTparams, flashLums] = retVisParams(win, visual, movieDurFrames, fR, white)

% [texHandle, stimRect, moviedata, PTparams, flashLums] = retVisParams(win, visual, movieDurFrames, fR, white)
% needs to return: 
% texHandle: a texture handle, made by Screen('MakeTexture, ...) or equivalent 
% moviedata: uint8 frames to a movie (do these really have to be uint8)? 
% PTparams: a set of parameters specificially for procedyral textures, for 
% other stimuli, this can be an empty cell
% stimRect: rectangle specifying the window in which a movie will be
% played (movies only - consider changing this var name) 
% flashLums: doesn't work atm 

% AVstimGen
% 10/27/2015

[win_width, win_height] = Screen('WindowSize', win);

phase = 0;

switch visual.stimMode;
    case 'LM' % MOVIE
        %movieFrameIndices=mod(0:(movieDurationFrames-1), numFrames) + 1;
    case 'DG' % DRIFTING GRATINGS
        texHandle = genGratings(win, visual.width, visual.height);
        PTparams = {phase visual.frequency_pixel visual.contrast 0}; %
%     case 'NS' % NOISE
%         %
%         PTparams = {visual.contrast 1 0 0}; %% CHECK THIS
%     case 'GB' % GABOR
%         %
%         PTparams = {};
    case 'CB' % checkerboard 
        % for a full screen checkerboard
        checkImg = genCheckerboard(win_width, win_height, white); 
        texHandle = Screen('MakeTexture', win, checkImg); 

    case 'RD' % RAINDROPPER
        moviedata = generateNoise_contrast(.05,10,0,0.5,visual.dur/1e3,visual.dur/1e3,fR);
        stimRect = [1 1 visual.width visual.height];
        stimRect = CenterRectOnPoint(stimRect, round(win_width/2), round(win_height/2));
        %
    case 'FL' % FLASHES
        flashRect = ones(visual.height, visual.width)*white; 
        texHandle = Screen('MakeTexture', win, flashRect); 

%         stimRect = [1 1 visual.width visual.height];
%         stimRect = CenterRectOnPoint(stimRect, round(win_width/2), round(win_height/2));
        flashLums = ones(1, movieDurFrames)*white;
        
    case 'FP' % FLASH PULSES
        flashRect = ones(visual.height, visual.width)*white;
        texHandle = Screen('MakeTexture', win, flashRect); 
%         stimRect = [1 1 visual.width visual.height];
%         stimRect = CenterRectOnPoint(stimRect, round(win_width/2), round(win_height/2));
        % precalculate frame luminances for flashes
        if visual.sin_varying
            flashLums = (sin(linspace(1.5*pi, visual.dur/1000*visual.cycles_perSec*2*pi+(pi*1.5), movieDurFrames))+1)*0.5*white;
        else
            flashLums = square(linspace(1.5*pi, visual.dur/1000*visual.cycles_perSec*2*pi+(1.5*pi), movieDurFrames)+1)*white; %% same thing, quicker
        end
end

% assign any unassigned vars
if ~exist('texHandle', 'var'); 
    texHandle = []; 
end
if ~exist('stimRect', 'var'); 
    stimRect = []; 
end
if ~exist('moviedata', 'var'); 
    moviedata = []; 
end
if ~exist('PTparams', 'var');
    PTparams = {}; 
end
if ~exist('flashLums', 'var'); 
    flashLums = []; 
end

