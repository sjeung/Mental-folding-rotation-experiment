function userAbort = mfold_Instructions

global data

%% preparation

userAbort = 0;

%text settings
hsize = 72;
bsize = 48;
fsize = 36;
vSpacing = 1;
winRect = [100 150 1820 980];
boffset = 100;
bhint_line = 1050;
%global ptb_drawformattedtext_disableClipping;
%ptb_drawformattedtext_disableClipping = 1;

%image settings
icenter = data.prefs.screen.center + [0 200];

%read instructions
fid = fopen([data.prefs.present.stimpath,'instructions.txt'],'r');
ins = textscan(fid,'%s%s%s','Delimiter',';');
fclose(fid);

%select slides
if ~data.input.experiment
    iset = 1:length(ins{1});
    repset = 12:23;
else
    iset = [2, 10, 26, 27, 28, 29];
    repset = 0;
end


%% display instructions
iter = 0;
done = false;
%for i = iset
while ~done
    
    iter = iter+1;                              %advance instruction idx
    if iter==length(iset), done = true; end     %check for exit criterion
    
    i = iset(iter);                             %get slide number
    
    %headline
    Screen('TextSize',  data.prefs.screen.window1, hsize);
    DrawFormattedText(data.prefs.screen.window1, ins{1}{i}, winRect(RectLeft), winRect(RectTop), data.prefs.screen.colors.standtextcol);
    
    %image
    imname = ins{3}{i};
    if ~isempty(imname)
        %disp([data.prefs.present.stimpath,'instructions\',imname])
        img = imread([data.prefs.present.stimpath,'instructions\',imname]);
        is_rev = size(img);
        ish = is_rev([2 1])*.5;
        tex = Screen('MakeTexture', data.prefs.screen.window1, double(img));
        Screen('DrawTexture',data.prefs.screen.window1,tex,[],[icenter(1)-ish(1) icenter(2)-ish(2) icenter(1)+ish(1) icenter(2)+ish(2)]);
    end
    
    %body
    Screen('TextSize',  data.prefs.screen.window1, bsize);
    DrawFormattedText(data.prefs.screen.window1, ins{2}{i}, winRect(RectLeft), winRect(RectTop)+boffset, data.prefs.screen.colors.standtextcol, [], [], [], vSpacing);
    
    %button hint
    if ~ismember(i,repset)
        Screen('TextSize',  data.prefs.screen.window1, fsize);
        if ~data.prefs.input.UseOfCedrusResponsePad
            DrawFormattedText(data.prefs.screen.window1, 'bitte eine Taste drücken', 1500, bhint_line, data.prefs.screen.colors.standtextcol);
        else
            DrawFormattedText(data.prefs.screen.window1, 'bitte den CENTER-Button drücken', 1350, bhint_line, data.prefs.screen.colors.standtextcol);
        end
    else
        if i==repset(end)
            Screen('TextSize',  data.prefs.screen.window1, fsize);
            if ~data.prefs.input.UseOfCedrusResponsePad
                DrawFormattedText(data.prefs.screen.window1, 'bitte eine Taste drücken ("R" zum Wiederholen)', 'center', bhint_line, data.prefs.screen.colors.standtextcol);
            else
                DrawFormattedText(data.prefs.screen.window1, 'bitte den CENTER-Button drücken (DOWN zum Wiederholen)', 'center', bhint_line, data.prefs.screen.colors.standtextcol);
            end
        end
    end
    
    
    %show
    Screen(data.prefs.screen.window1, 'Flip');                                              %show it (buffer swap)
    if ~ismember(i,repset(1:end-1))
        pause(data.prefs.present.instruct_wait)
        if ~data.prefs.input.UseOfCedrusResponsePad                                             %if no special hardware used
            [~, keyCode] = KbWait;                                                                             %wait for keyboard
            if any(find(keyCode)==27)
                userAbort = 1;
                Screen(data.prefs.screen.window1, 'Flip');
                return
            end
            if i==repset(end) && any(find(keyCode)==82)
                iter = iter-numel(repset);
            end
        else                                                                                    %otherwise
            if ~(i==repset(end))
                pressed_key = mfold_waitForCedrusKey(data.prefs.input.s1,'center');                                %wait for special hardware
            else
                pressed_key = mfold_waitForCedrusKey(data.prefs.input.s1,{'center','south'});
            end
            if strcmp(pressed_key,'south')
                iter = iter-numel(repset);
            elseif strcmp(pressed_key,'escape')
                userAbort = 1;
                Screen(data.prefs.screen.window1, 'Flip');
                return
            end
        end
    else
        pause(1)
    end
    %Screen(data.prefs.screen.window1, 'Flip');                                              %remove it
    %pause(1)                                                                                %wait a sec
    
end

% remove last instruction screen
Screen(data.prefs.screen.window1, 'Flip');



%% setting the start-marker on last button press and exit
% logging the experiment start time (participent presses "Start"; rather than at initializing the Marker system)
data.output.startMeasurement = GetSecs;
marker_str = [];
marker_str = [marker_str,'measurement:start;'];
marker_code = data.markers.experiment + data.markers.start;
mfold_Markers(1,marker_code,marker_str);    %sending a corresponding marker (with eventlist entry and so on)

pause(1)