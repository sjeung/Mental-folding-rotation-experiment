function mfold_Instructions

global data

% show welcome string
Screen('CopyWindow', data.stimuli.screen.welcomestring, data.prefs.screen.window1);     %copy offscreen window with welcome message
Screen(data.prefs.screen.window1, 'Flip');                                              %show it (buffer swap)
if ~data.prefs.input.UseOfCedrusResponsePad                                             %if no special hardware used
    KbWait;                                                                             %wait for keyboard
else                                                                                    %otherwise
    mrot_waitForCedrusKey(data.prefs.input.s1,'center');                                %wait for special hardware
end
Screen(data.prefs.screen.window1, 'Flip');                                              %remove welcome message
pause(1)                                                                                %show >1 s blank screen

% show set of instructions
for i = 1:length(data.stimuli.screen.instruct)
    Screen('CopyWindow', data.stimuli.screen.instruct(i), data.prefs.screen.window1);
    Screen(data.prefs.screen.window1, 'Flip');
    pause(data.prefs.present.instruct_wait);        %ensure that instructions get read and not accidentally clicked away by a duplicate keypresses or impatient subjects
    if ~data.prefs.input.UseOfCedrusResponsePad
        KbWait;
    else
        mrot_waitForCedrusKey(data.prefs.input.s1,'center');
    end
    Screen(data.prefs.screen.window1, 'Flip');
    pause(1)
end

% show start instruction
Screen('CopyWindow', data.stimuli.screen.startstring, data.prefs.screen.window1);
Screen(data.prefs.screen.window1, 'Flip');
if ~data.prefs.input.UseOfCedrusResponsePad
    KbWait;
else
    mrot_waitForCedrusKey(data.prefs.input.s1,'center');
end
Screen(data.prefs.screen.window1, 'Flip');


%% setting the start-marker on button press
% logging the experiment start time (participent presses "Start"; rather than at initializing the Marker system)
data.output.startMeasurement = GetSecs;
marker_str = [];
marker_str = [marker_str,'measurement:start;'];
marker_code = data.markers.experiment + data.markers.start;
mfold_Markers(1,marker_code,marker_str);    %sending a corresponding marker (with eventlist entry and so on)

pause(1)