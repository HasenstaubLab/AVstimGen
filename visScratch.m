        
Screen('CloseAll')
screenid = max(Screen('Screens'));

restCol = 0; 

visual.width = 800; 
visual.height = 800; 

win = Screen('OpenWindow', screenid, restCol);
AssertGLSL;
[win_width win_height] = Screen('WindowSize', win);

stimRect = [1 1 visual.width visual.height];
stimRect = ones(visual.height, visual.width)*180; 
%stimRect = CenterRectOnPoint(stimRect, round(win_width/2), round(win_height/2));

texHandle = Screen('MakeTexture', win, stimRect); 
Screen('DrawTexture', win, texHandle); 
Screen('Flip', win); 

WaitSecs(1);

Screen('CloseAll'); 