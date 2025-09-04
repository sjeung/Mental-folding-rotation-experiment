function userAbort = mfold_CedrusResponsePadPreparation

global data

% ATTENTION: Always use with a baud rate of 115200 for best performance!!
% ATTENTION: Always make sure all 4 dip switches on the back side are down!!
% 
% Don't forget to RESET THE RT TIMER before any measurement!
% Currently there is a bug in the pad introducing a time drift due to repeated response. Therefore it is not recommended using this pad for multiple consecutive time measurements as in tapping experiments.
% 
% And always CLEAR THE BUFFER as well, as the pad creates events for button presses as well as releases (the latter would remain in the cue!)



delete(instrfind('Type','serial'));    % would be a helpful precaution, is done however in "Markers" section (as there takes place the handling of serial markers)
data.prefs.input.s1 = serial(data.prefs.input.COMX, 'BaudRate', 115200, 'DataBits', 8, 'StopBits', 1, 'FlowControl', 'none', 'Parity', 'none', 'Terminator', 'CR', 'Timeout', 400, 'InputBufferSize', 16000); % initialize the serial device with the appropriate settings
s1 = data.prefs.input.s1;

fopen(s1);                          % open it for reading and writing
%s1                                 % check the results, can be commented out
pause(.1)
if s1.bytesAvailable
    fread(s1,s1.bytesAvailable);    % emtpy the buffer (should be empty in the beginning)
end
pause(.1)
fprintf(s1,['c10',char(13)]);       % set to XID mode (i.e. 'XID0': rt mesurement delegated to the Response Pad)
pause(.1)
fprintf(s1,['_c1',char(13)]);       % query mode, just to be sure
pause(.1)
mode = fread(s1,s1.bytesAvailable); % receive mode report
if ~strcmp(char(mode(end)),'0')     % a string of 5 characters is delivered, it being "-XID0" (the last position is diagnostic) would mean success
    DrawFormattedText(data.prefs.screen.window1, 'Attempt to change Response Pad mode to XID not successful!\nConfirm (and continue) by pressing ''c'' or abort with ''escape''.', 'center', 'center', [255 0 0]);
    Screen('Flip', data.prefs.screen.window)
    beep
    pause(1)
    RestrictKeysForKbCheck([67;27]);
    [~, keyCode] = KbWait;
    RestrictKeysForKbCheck([]);
    Screen('Flip', data.prefs.screen.window)
    key = find(keyCode);
    if key==27, disp('User abort, data files incomplete!'), userAbort = 1; return, end
end
pause(.1)
fprintf(s1,['e1',char(13)]); %reset base timer, strictly taken this is not necessary here
pause(.1)
fprintf(s1,['e5',char(13)]); %reset rt timer

%to test that the RP does roughly, what it is supposed to do, execute the following line of code and then press any key of the pad
%if s1.bytesAvailable, fread(s1,s1.bytesAvailable); end, fprintf(s1,['e5',char(13)]), tic, while ~s1.bytesAvailable, WaitSecs(.001); end, toctime = toc, response = fread(s1,6); padtime = (response(3)+(response(4)*256)+(response(5)*65536) +(response(6)*(65536*256)))/1000, delta = toctime-padtime

userAbort = 0;


%%%%% IMPORTANTO FOR GOOD TIMING: 115200 Baudrate!!! %%%%%

%% And then get the response and RT with something like that
% %% RESPONSE and RT
% if ~data.prefs.input.UseOfCedrusResponsePad
%     [response, rt] = mfold_KbGetResponse(data.prefs.input.response_keys, data.prefs.input.response_waittime, data.prefs.input.KbResponse_restrictKeys);
%     if response==27, Screen('Flip', data.prefs.screen.window1); disp('User abort, data files incomplete!'), sessionCompleted = 0; return, end
% else
%     fprintf(s1,['e5',char(13)]);                            % reset RT timer first, for most accurate measurement
%     if s1.bytesAvailable, fread(s1,s1.bytesAvailable); end  % empty the buffer
%     RestrictKeysForKbCheck(27);                             % only "Escape" on the keyboard will be recognized
%     keyIsDown = 0;
%     while (~s1.bytesAvailable) && (~keyIsDown)
%         [keyIsDown, ~, keyCode] = KbCheck;
%     end
%     mfold_Markers(1,200,'reponse event');
%     RestrictKeysForKbCheck([]);
%     if s1.bytesAvailable
%         sixbytes = fread(s1,6);
%         button = (sixbytes(2));
%         switch button, case 144, response = 1; case 208, response = 2; otherwise, response = -1; end
%         rt = (sixbytes(3)+(sixbytes(4)*256)+(sixbytes(5)*65536) +(sixbytes(6)*(65536*256)));
%         mfold_Markers(1,200+response,'reponse code');
%     else
%         key = find(keyCode);
%         if key==27, Screen('Flip', data.prefs.screen.window1); disp('User abort, data files incomplete!'), sessionCompleted = 0; return, end
%     end
% end