function testVisStim

AssertOpenGL;
AssertGLSL; 

screenid = max(Screen('Screens'));

win = Screen('OpenWindow', screenid, BlackIndex(screenid), [1 1 800 800]);
ifi = Screen('GetFlipInterval', win);

waitframes = 1; %% try to redraw on every monitor refresh
waitdur = waitframes * ifi;

rotateMode = kPsychUseTextureMatrixForRotation; 
%rotateMode = []; 

gratingtex = CreateProceduralSineGrating(win, 500, 500, [0.5 0.5 0.5 0]);
noisetex = CreateProceduralNoise(win, 500, 500, 'ClassicPerlin', [0.5 0.5 0.5 0], ); 

vbl = Screen('Flip', win);

cyc_per_sec = 5;
phase = 20;
phase_inc = cyc_per_sec * 360 * ifi;

freq = 1/50;

angle = 0; 

amplitude = 0.5;


while ~KbCheck
    % grating increment phase
    phase = phase + phase_inc;
    
    %where the magic happens
    %Screen('DrawTexture', win, gratingtex, [], [], angle, [], [], [], [], rotateMode, [[phase, freq, amplitude, 0]]);
    Screen('DrawTexture', win, gratingtex, [], [], angle, [], [], [], [], rotateMode, [[phase, freq, amplitude, 0]]);
    
    
    vbl = Screen('Flip', win, (vbl + 0.5* ifi));
    
    %angle = angle + 1;
end

Screen('CloseAll');



