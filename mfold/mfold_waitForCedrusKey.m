function pressed_key = mfold_waitForCedrusKey(serialObjectHandle, keys)
%
% works for Cedrus Response Pad RB-530
%
% string    press  release  button	dezimalwert des gesamten byte (press)
%
% north    110000   100000	1        48
% east   10110000 10100000	5       176
% south  11010000 11000000	6       208
% west    1110000  1100000	3       112
% center 10010000 10000000	4       144
%
% bits 0-3 (right to left) code for the port, that is 0 for the buttons (and 1 for the accessory port)
% bit for is an "action" bit, that is 1 for a press and 0 for a release
% bits 5-7 code for the buttons

%make sure, output exists
pressed_key = '';

%define all possible keys and key codes
allKeys = {'north','east','south','west','center'};
allKeyNums = [48; 176; 208; 112; 144];

%enable empty key list, allows all keys to be pressed
if isempty(keys), keys=allkeys; end

%get handle to serial interface
s1 = serialObjectHandle;

%if single key string, make cell
if ischar(keys)
    keys = {keys};
end

% % get valid key codes
% keyNums = [];
%
% for i = 1:length(keys)
%
%     switch keys{i}
%
%         case allKeys{1}, keyNums = [keyNums; allKeyNums(1)];
%         case allKeys{2}, keyNums = [keyNums; allKeyNums(2)];
%         case allKeys{3}, keyNums = [keyNums; allKeyNums(3)];
%         case allKeys{4}, keyNums = [keyNums; allKeyNums(4)];
%         case allKeys{5}, keyNums = [keyNums; allKeyNums(5)];
%
%             %         case 'north', keyNums = [keyNums; 48];
%             %         case 'east', keyNums = [keyNums; 176];
%             %         case 'south', keyNums = [keyNums; 208];
%             %         case 'west', keyNums = [keyNums; 112];
%             %         case 'center', keyNums = [keyNums; 144];
%     end
% end

% get valid key codes (prevent false input)
keyNums = [];
for i = 1:length(keys)
    keyNums = [keyNums, allKeyNums(strcmp(keys{i},allKeys))];
end

% empty buffer
if s1.bytesAvailable
    fread(s1,s1.bytesAvailable);
end

keyPressed = 0;

% wait for keypress
RestrictKeysForKbCheck(27);
while ~keyPressed
    % check serial interface
    if s1.bytesAvailable
        response = fread(s1,6);
        keyPressed = any(response(2)==keyNums);
        if keyPressed
            pressed_key = allKeys{response(2)==allKeyNums};
        end
        if s1.bytesAvailable
            fread(s1,s1.bytesAvailable);
        end
    end
    % check keyboard
    if ~keyPressed
        [keyPressed,~,keyCode] = KbCheck;
        if any(find(keyCode)==27)
            pressed_key = 'escape';
        end
    end
    WaitSecs(.001);
end
RestrictKeysForKbCheck([]);