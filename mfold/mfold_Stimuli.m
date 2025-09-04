function mfold_Stimuli

global data


%% PTB text preferences
% Possible PTB settings: 
% oldEnableFlag         = Screen('Preference', 'TextAlphaBlending',                 [enableFlag]);
% oldSize               = Screen('Preference', 'DefaultFontSize',                   [fontSize]);
% oldStyleFlag          = Screen('Preference', 'DefaultFontStyle',                  [styleFlag]);
% oldfontName           = Screen('Preference', 'DefaultFontName',                   [fontName]);
% oldEnableFlag         = Screen('Preference', 'DefaultTextYPositionIsBaseline',    [enableFlag]);
% oldEnableFlag         = Screen('Preference', 'TextAntiAliasing',                  [enableFlag=-1 (System setting), 0 = Disable, 1 = Enable, 2 = EnableHighQuality]);
% oldEnableFlag         = Screen('Preference', 'TextRenderer',                      [enableFlag=0 (Default OS-specific [fast]), 1 = HighQ OS-specific]);
% oldLocaleNameString   = Screen('Preference', 'TextEncodingLocale',                [newLocalenNameString]);


%% Repeated modules
% "Please wait..."
data.stimuli.screen.waitstring = Screen('OpenOffscreenWindow', data.prefs.screen.whichScreen, data.prefs.screen.colors.standbackcol);           %open an offscreen window
data.stimuli.text.waitstring = 'Bitte warten...';                                                                                               %define the text as a string
DrawFormattedText(data.stimuli.screen.waitstring, data.stimuli.text.waitstring, 'center', 'center', data.prefs.screen.colors.standtextcol);     %draw this text to the offscreen window
% immediately display the above text (during stimulus preparation, which might take a while if pre-loading images to RAM)
Screen('CopyWindow', data.stimuli.screen.waitstring, data.prefs.screen.window1);    %fast method of swapping out visual content in the back buffer
Screen(data.prefs.screen.window1, 'Flip');                                          %swapping back and front buffer (see 'Screen Flip?' for further info; strongly recommended!)

% "Press a key..."
data.stimuli.screen.welcomestring = Screen('OpenOffscreenWindow', data.prefs.screen.whichScreen, data.prefs.screen.colors.standbackcol);
if ~data.prefs.input.UseOfCedrusResponsePad
    data.stimuli.text.welcomestring = 'Bitte eine Taste drücken...';
else
    data.stimuli.text.welcomestring = 'Bitte den CENTER-Button drücken...';
end
DrawFormattedText(data.stimuli.screen.welcomestring, data.stimuli.text.welcomestring, 'center', 'center', data.prefs.screen.colors.standtextcol);

% "Press any key to start the experiment..."
data.stimuli.screen.startstring = Screen('OpenOffscreenWindow', data.prefs.screen.whichScreen, data.prefs.screen.colors.standbackcol);
if ~data.prefs.input.UseOfCedrusResponsePad
    data.stimuli.text.startstring = 'Zum Starten des Versuchs\nbitte eine Taste drücken...';
else
    data.stimuli.text.startstring = 'Zum Starten des Versuchs\nbitte den CENTER-Button drücken...';
end
DrawFormattedText(data.stimuli.screen.startstring, data.stimuli.text.startstring, 'center', 'center', data.prefs.screen.colors.standtextcol, [], [], [], 1.5);

% "Please take a break of at least [...] seconds."
data.stimuli.screen.pausestring = Screen('OpenOffscreenWindow', data.prefs.screen.whichScreen, data.prefs.screen.colors.standbackcol);
data.stimuli.text.pausestring = ['Bitte ',num2str(data.prefs.present.break_duration),' Sekunden Pause machen.'];
DrawFormattedText(data.stimuli.screen.pausestring, data.stimuli.text.pausestring, 'center', 'center', data.prefs.screen.colors.standtextcol);

% "Thank you!"
data.stimuli.screen.endstring = Screen('OpenOffscreenWindow', data.prefs.screen.whichScreen, data.prefs.screen.colors.standbackcol);
data.stimuli.text.endstring = 'Vielen Dank!';
DrawFormattedText(data.stimuli.screen.endstring, data.stimuli.text.endstring, 'center', 'center', data.prefs.screen.colors.standtextcol);


%% test instructions
% general plot
data.stimuli.screen.instruct(1) = Screen('OpenOffscreenWindow', data.prefs.screen.whichScreen, data.prefs.screen.colors.standbackcol);      %creating a list of instruction windows makes it very easy to display all of them via a simple loop (-> mfold_Instructions)
if ~data.prefs.input.UseOfCedrusResponsePad     %particular key-press instructions for different hardware
    hardware_string = 'Bitte beurteile jeweils, ob es sich bei dem Zielobjekt (im Vergleich mit dem Referenzobjekt)\num das gleiche <LINKS> oder um ein anderes <RECHTS> Objekt handelt.\nBitte benutze hierfür die entsprechenden Tasten auf der Tastatur.\n';
else
    hardware_string = 'Bitte beurteile jeweils, ob es sich bei dem Zielobjekt (im Vergleich mit dem Referenzobjekt)\num das gleiche <CENTER> oder um ein anderes <DOWN> Objekt handelt.\nBitte benutze hierfür die entsprechenden Tasten auf dem Response Pad.\n';
end
data.stimuli.text.instruct1 = ['Hier erscheinen gleich Paare [...].\nZunächst erscheint immer ein Referenzobjekt und anschließend das Zielobjekt.\nDas Zielobjekt kann unterschiedlche [...] (es wird ...).\n',hardware_string,'\n\n\n\n\nBitte eine Taste drücken...'];
DrawFormattedText(data.stimuli.screen.instruct(1), data.stimuli.text.instruct1, 'center', 'center', data.prefs.screen.colors.standtextcol, 150, [], [], 1.5, []);
%%%%% [nx, ny, textbounds] = DrawFormattedText(win, tstring [, sx][, sy][, color][, wrapat][, flipHorizontal][, flipVertical][, vSpacing][, righttoleft])

% additional instructions
%data.stimuli.screen.instruct(2) = Screen('OpenOffscreenWindow', data.prefs.screen.whichScreen, data.prefs.screen.colors.standbackcol);
%data.stimuli.text.instruct2 = '[...]\n\n\n\n\n\nBitte eine Taste drücken...';
%DrawFormattedText(data.stimuli.screen.instruct(2), data.stimuli.text.instruct2, 'center', 'center', data.prefs.screen.colors.standtextcol, 50, [], [], 1.5, []);

% even more instructions
%data.stimuli.screen.instruct(3) = ...


% %% Fixation Cross
% data.stimuli.screen.fixation = Screen('OpenOffscreenWindow', data.prefs.screen.whichScreen, data.prefs.screen.colors.standbackcol);
% cw = data.prefs.present.cross_halfwidth;
% Screen('DrawLine', data.stimuli.screen.fixation, data.prefs.screen.colors.standtextcol, data.prefs.screen.center(1)-cw, data.prefs.screen.center(2),    data.prefs.screen.center(1)+cw, data.prefs.screen.center(2));
% Screen('DrawLine', data.stimuli.screen.fixation, data.prefs.screen.colors.standtextcol, data.prefs.screen.center(1),    data.prefs.screen.center(2)-cw, data.prefs.screen.center(1),    data.prefs.screen.center(2)+cw);


%% Pictures
% determine image dimensions
imname = data.prefs.present.stimpaths{1};   %get the name of an arbitrary image
img = imread(imname);                       %read image data (bmp, jpg, png...)
is_rev = size(img);                         %get pixel dimensions ('rev': Matlab uses [rows,columns] for window positioning, image sizes come the other way around)
data.prefs.present.ish = is_rev([2 1])*.5;  %half the image size, we need this for later (-> mfold_Core)

% pre-loading images; not advised if too many, and not necessary if enough time between stimuli
%for j = 1:length(data.prefs.present.stimpaths)
%    imname = data.prefs.present.stimpaths{j};
%    img = imread(imname);
%    data.stimuli.pics{j} = Screen('MakeTexture', data.prefs.screen.window1, double(img));
%    % drawing images to pre-created offscreen windows (pseudo frame buffers) can speed up image presentation dramatically; works only in full-screen
%    %data.stimuli.picscreens{j} = Screen('OpenOffscreenWindow', data.prefs.screen.whichScreen, data.prefs.screen.colors.standbackcol);
%    %Screen('DrawTexture', data.stimuli.picscreens{j}, data.stimuli.pics{j}, [], [data.prefs.screen.center(1)-ish(1) data.prefs.screen.center(2)-ish(2) data.prefs.screen.center(1)+ish(1) data.prefs.screen.center(2)+ish(2)]);
%end


%% remove waitstring
Screen(data.prefs.screen.window1, 'Flip');