  function mfold_Main
%%  Mental folding experiment.
% Handed down from Chris Hilton, Leonie Raddatz, Benjamin Paulisch but the
% origianl creator is not exactly known 
%--------------------------------------------------------------------------
% Modified by seinjeung@gmail.com 2025                                    

                              
%% Preparation
addpath(genpath('P:\Sein_Jeung\Tools\liblsl-Matlab-1.14.0'))
sca;            %Screen('CloseAll') from PsychToolbox (PTB)
rng('default')  %reset random number generator
rng('shuffle')

% set default font size
fontsize = 30; 

global data     %create global data var (containing settings and timing parameters, input, and output)

try
    
    
    %% Input
    mfold_Input;    %get run parameters and participant demographics
  %  HideCursor;     %type 'ShowCursor' to restore
    
    
    %% PTB Preferences
    %  The following section contains various setting determining how the PTB initializes and runs. Due to their importance they have been placed at the very beginning instead of the experiment's preferences section.
    Screen('Preference', 'SkipSyncTests', 0);       %if sync tests are skipped, offscreen windows don't seem to work properly
    Screen('Preference', 'Verbosity', 0);
    [data.PTBdiag.SyncTestSettings.maxStddev, data.PTBdiag.SyncTestSettings.minSamples, data.PTBdiag.SyncTestSettings.maxDeviation, data.PTBdiag.SyncTestSettings.maxDuration] = ...
        Screen('Preference', 'SyncTestSettings', 0.0003, 120, 0.01, 5);     %settings for above-mentioned timing tests; will be executed on window opening
    Screen('Preference', 'DefaultFontSize', fontsize);    %default font size for any text drawn in PsychToolbox windows
      
    %% Variables
    mfold_Preferences;              %process the program's preferences
    
    
    %% Stimuli
    mfold_Stimuli;                  %prepare the stimuli
    
    
    %% Initialize Markers
    mfold_Markers(0);               %initialize the marker system with the parameter '0'
    
    
    %% Response Pad preparation
    % ATTENTION: Always use with a baud rate of 115200 for best performance!!
    % ATTENTION: Always make sure all 4 dip switches on the back side are down!!
    % 
    % Don't forget to RESET THE RT TIMER before any measurement!
    % Currently there is a bug in the pad introducing a time drift due to repeated response. Therefore it is not recommended using this pad for multiple consecutive time measurements as in tapping experiments.
    % 
    % And always CLEAR THE BUFFER as well, as the pad creates events for button presses as well as releases (the latter would remain in the cue!)
     if data.prefs.input.UseOfCedrusResponsePad
        mfold_CedrusResponsePadPreparation;
    end
    
    
    %% parts involving user interaction
    data.output.startMeasurement = GetSecs;
    %userAbort = mfold_Instructions;         %the participant's response to the final 'startstring' ("Press a button to start the experiment...") logs the start time and sets the 'experiment-start' marker
    
    %% Procedure
    sessionComplete = mfold_Core;

    %% Saving
    mfold_Save;                     % save all data including the 'data' struct variable to several files
    
    
    %% De-initialize Markers
    mfold_Markers(2);               % de-initialize the marker system with the parameter '2'
    
    
    %% End
    if data.input.experiment
        if sessionComplete      %if everything went smoothely...
            Screen('CopyWindow', data.stimuli.screen.endstring, data.prefs.screen.window1);                                         %show good-bye string
        else
            DrawFormattedText(data.prefs.screen.window1, 'User abort, data files incomplete!', 'center', 'center', [255 0 0]);      %else warn about potentially incomplete recording
        end
        Screen(data.prefs.screen.window1, 'Flip');      % show string
        KbWait;                                         % wait for a keypress
        Screen(data.prefs.screen.window1, 'Flip');      % remove string
        pause(1);                                       % wait a gracious second before...
    end
    sca;    %implies 'ShowCursor'                   % shutting the experiemnt down
    
catch e
    sca;
    fclose all;
    rethrow(e)
end