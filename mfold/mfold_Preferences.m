function mfold_Preferences

global data;    %get global data var
screens = Screen('Screens'); 
stimpath    = 'P:\Sein_Jeung\Project_Fold_Rotation\Mental-folding-rotation-experiment\Images\'; 

%% get/set screen parameters and open window
% screen selection and proportions
if numel(Screen('Screens'))>1   %if more than one display exists (which should be avoided)...
    data.prefs.screen.whichScreen = max(screens);  %select display 1 (usually the main display on Windows; vs. 2; 0 might be the extended desktop leading to severe format and timing issues)
else
    data.prefs.screen.whichScreen = 0;  %display 0 is the only one existing
end
data.prefs.screen.scrsz = Screen('Rect', data.prefs.screen.whichScreen);
data.prefs.screen.center = data.prefs.screen.scrsz(3:4)/2;

%open the window
data.prefs.screen.window1 = Screen(data.prefs.screen.whichScreen, 'OpenWindow');    %no 'rect' specied means 'fullscreen'

%define some basic colors
data.prefs.screen.colors.white = WhiteIndex(data.prefs.screen.window1);     % pixel value for white (might differ from 255)
data.prefs.screen.colors.black = BlackIndex(data.prefs.screen.window1);     % pixel value for black (might differ from 0)
data.prefs.screen.colors.gray = (data.prefs.screen.colors.white + data.prefs.screen.colors.black)/2;    %medium display grey, often used as comfortable background color)
data.prefs.screen.colors.standbackcol = data.prefs.screen.colors.black;     %often 'data.prefs.screen.colors.gray'
data.prefs.screen.colors.standtextcol = data.prefs.screen.colors.white;

%populate the selected background color (has to be done only once, as the flip command by default clears the back buffer but maintains the background color)
Screen(data.prefs.screen.window1, 'FillRect', data.prefs.screen.colors.standbackcol);
Screen(data.prefs.screen.window1, 'Flip');


%% Design matrix
%--------------------------------------------------------------------------
% 5 blocks x 100 trials 

% column 1 : number of folds (0, 4, or 6 folds)
folds   = [repelem(0,20,1); repelem(4,40,1); repelem(6,40,1)];
% column 2 : folding angle (0, 40, or 90 degrees)
angles  = [repelem(0,20,1); repelem(40,20,1); repelem(90,20,1); repelem(40,20,1); repelem(90,20,1)];
% column 3 : parity (match Y or mismatch N)
parity  = [repelem(0,10,1); repelem(1,10,1); repelem(0,10,1); repelem(1,10,1); repelem(0,10,1); repelem(1,10,1); repelem(0,10,1); repelem(1,10,1); repelem(0,10,1); repelem(1,10,1);]; 
% column 4 : net identify (A to J)
netID   = repmat([1:10]', 10,1); 

% combine columns
design = [folds, angles, parity, netID];
data.prefs.present.design   = design;  
data.prefs.present.nconds   = 100; 
data.prefs.present.nblocks  = 5; 
data.prefs.present.ntrials  = data.prefs.present.nblocks*data.prefs.present.nconds; 

% strings corresponding to numerical codes
data.prefs.present.paritystrings   = {'Y', 'N'}; 
data.prefs.present.netIDstrings    = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'};

%% loading/preparation of stimuli
%---------------------------------------------------------------------------
% construct file paths of all stimuli
for Ii = 1:data.prefs.present.nconds
    data.prefs.present.stimpaths{Ii} = fullfile(stimpath, ['cube_' num2str(design(Ii,1)) '_', num2str(design(Ii,2)) '_' data.prefs.present.paritystrings{design(Ii,3)+1}, '_' data.prefs.present.netIDstrings{design(Ii,4)}, '.png']);  %assemble and collect their complete paths
end

%% graphical presentation parameters
data.prefs.present.hdisloc = 0;             %how many pixels to present a stimulus off-center (to the left/right)
data.prefs.present.cross_halfwidth = 50;    %dimensions of fixation cross (half the length of its lines)
data.prefs.present.cross_penwidth = 5;      %width of cross lines


%% experiment/trial timing and repetitions
if ~data.input.experiment
    data.prefs.present.instruct_wait = .5;
else
    data.prefs.present.instruct_wait = 2;   %could as well be 5 in experiment; prevents user from accidental skipping 
end
data.prefs.present.refstim_duration = 1;    %seconds for presenting the reference stimulus without the target

% inter trial interval (often pseudo-random waiting period between trials)
data.prefs.present.iti_minDur = 0.5;        %lower limit for variable inter trial interval (see linspace below)
data.prefs.present.iti_maxDur = 1.5;        %upper limit
data.prefs.present.iti_durations = linspace(data.prefs.present.iti_minDur, data.prefs.present.iti_maxDur, data.prefs.present.ntrials);  %create 'ntrials' different steps applied during one block

% block structure
data.prefs.present.nblocks = 1;             %how many blocks to administer
data.prefs.present.break_duration = 60;     %how long at least to pause after each block


%% response collection
data.prefs.input.response_waittime = -1;        %maximum allowed response time (RT); '-1': indefinite

% keyboard settings
data.prefs.input.kb_response_keys = [37; 39];

if ~data.input.experiment
    data.prefs.input.KbResponse_restrictKeys = 0;
elseif data.input.experiment
    data.prefs.input.KbResponse_restrictKeys = 1;
end

% specialized input hardware
data.prefs.input.UseOfCedrusResponsePad = 1;    %if not, keyboard is used for everything
data.prefs.input.COMX = 'COM4';                 %see 'mfold_CedrusResponsePadPreparation.m' for further notes on how to use the response pad

% result collection for output
data.output.results = [];                       %prepare output matrix


%% markers
data.output.LSL.numericalMarkers = 0;       %lsl markers are usually strings, numerical markers have to be treated differently


%% data output
data.prefs.present.datpath = 'data\';       %base data output path

% base file name contains all demographic data including participant code and a time stamp
%data.prefs.output.baseFilename = [data.prefs.present.datpath,num2str(data.input.vp),'_',num2str(data.input.hand),'_',num2str(data.input.age),'_',num2str(data.input.sex),'_',data.input.vpcode,'_',data.input.startTimeString];
data.prefs.output.baseFilename = [data.prefs.present.datpath,data.input.vpcode,'_',data.input.startTimeString];

% training/demo data gets a special name suffix
if ~data.input.experiment
    data.prefs.output.baseFilename = [data.prefs.output.baseFilename, '_Training'];
end

% 4 seperate files will be created
data.prefs.output.dataFilename = [data.prefs.output.baseFilename,'.dat'];   %contains trial data as one line per trial
data.prefs.output.headFilename = [data.prefs.output.baseFilename,'.hdr'];   %contains the column descriptors in one line; can be combined on demand
data.prefs.output.evntFilename = [data.prefs.output.baseFilename,'.evt'];   %contains all events in a continuous list (one event per call to marker funtion)
data.prefs.output.matfFilename = [data.prefs.output.baseFilename,'.mat'];   %contains the global 'data' struct variable