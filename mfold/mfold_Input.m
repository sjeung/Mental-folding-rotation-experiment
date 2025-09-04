function mfold_Input

global data     %get global data var


%% Logging
t = clock;      %get current system time for output file naming
data.input.startTimeString = [num2str(t(1)),'-',num2str(t(2)),'-',num2str(t(3)),'-',num2str(t(4)),'-',num2str(t(5))];   %create a concise date/time string


%% VL-Input
answer = inputdlg('Bitte Versuchsmodus (Training:0/Experiment:1) angeben:','Modus',1);
data.input.experiment = str2double(answer{1});      %whether demo or actual test run

% answer = inputdlg('Bitte laufende VP-Nummer angeben:','Vp-Nummer',1);
% data.input.vp = str2double(answer{1});              %arbitrary numbering (meant to be running)


%% VP-Input
% answer = inputdlg('Bitte Händigkeit (l:0/r:1) angeben:','Händigkeit',1);
% data.input.hand = str2double(answer{1});            %participant handedness
% 
% answer = inputdlg('Bitte Geschlecht (w:0/m:1) angeben:','Geschlecht',1);
% data.input.sex = str2double(answer{1});             %participant sex (this is probably too simplified for 2018)
% 
% answer = inputdlg('Bitte Alter angeben:','Alter',1);
% data.input.age = str2double(answer{1});             %participant age

answer = inputdlg('Bitte Vp-Code (feste Länge) eingeben:','Vp-Code',1);
data.input.vpcode = answer{1};                      %identification tag commenly known as "subject code" or "Vp code"