function sessionCompleted = mfold_Core

global data

% response 1 : match
% response 2 : mismatch
% stim match 0 : match
% stim match 1 : mismatch

%% settings
if data.prefs.input.UseOfCedrusResponsePad
    s1 = data.prefs.input.s1;                   %get a shortcut
end

%short handles for stimulus presentation...
center = data.prefs.screen.center;
ish = data.prefs.present.ish;
hdisloc = data.prefs.present.hdisloc;

cw = data.prefs.present.cross_halfwidth;
pw = data.prefs.present.cross_penwidth;

%and trial structure parameters
nTrialsInBlock = data.prefs.present.nconds;

if ~data.input.experiment                       %if demo run,
    nblocks = 1;                                %speed up things for demo or debugging purposes
    break_duration = 1;
else
    nblocks = data.prefs.present.nblocks;
    break_duration = data.prefs.present.break_duration;
end

%markers    
response_labels = {'resp_match','resp_mismatch','n_a'};  
correct_labels = {'false','correct','n_a'};
m = data.markers;

% wait for keypress before start 
Screen('CopyWindow', data.stimuli.screen.welcomestring, data.prefs.screen.window1);
Screen(data.prefs.screen.window1, 'Flip');
if ~data.prefs.input.UseOfCedrusResponsePad
    KbWait;
else
    mfold_waitForCedrusKey(data.prefs.input.s1,'center');
end
Screen(data.prefs.screen.window1, 'Flip');
pause(1);


%% central routine
lcount              = 0; % initialize trial number counter

for j = 1:nblocks
    
    % randomisation
    if data.input.experiment
        rand_inds = randperm(nTrialsInBlock);
    else
        rand_inds       = [1,12,23,34,45,56,67,78,89,100]; % hardcode stimuli for practice trials 
        nTrialsInBlock  = numel(rand_inds); 
        correctTotal    = 0; 
    end
    rand_itis = data.prefs.present.iti_durations(randperm(nTrialsInBlock)); %nicht mit demselben randomizer, sonst h?tten immer die gleichen Reize die kurzen/langen ITIs
        
    % send block start marker
    marker_str = ['block_start:',num2str(j),';'];
    marker_code = m.experiment + m.block + m.start;        
    mfold_Markers(1,marker_code,marker_str);

    pause(1)
    
    % bgcolor
    imgpath = data.prefs.present.stimpaths{1};                      % path to image
    img = imread(imgpath);                                          % load stim
    img = img(:, size(img,2)*0.2:size(img,2)*0.8, :);
    leftEdge = img(:,1,:);       % all rows, first column
    bgColor = round(mean(reshape(leftEdge, [], 3), 1));  % average RGB
    
    for Ti = 1:nTrialsInBlock 
        
        lcount      = lcount +1;                     %increment line/trial counter for output matrix
        
        % take the randomised index  
        row_ind     = rand_inds(Ti); 
        design      = data.prefs.present.design; 
        fold        = design(row_ind,1); 
        angle       = design(row_ind,2); 
        parity      = design(row_ind,3); 
        netID       = design(row_ind,4);
        
        %trial marker
        marker_str = ['trial_number_absolut:',num2str(lcount),';',['trial_number_block:',num2str(Ti),';']];
        marker_code = m.trial + m.start;
        mfold_Markers(1,marker_code,marker_str)
        
        % background
        Screen('FillRect',data.prefs.screen.window1, bgColor);
        
        %fixation marker
        marker_str = 'screen:fixation_cross;';
        marker_code = m.trial + m.fixation + m.onset;
        
        %% Fixation and trial preparation
        % draw fixation cross on screen (actually on the back buffer; we have enough time for not using offscreen windows)
        Screen('DrawLine', data.prefs.screen.window1, data.prefs.screen.colors.standtextcol, data.prefs.screen.center(1)-cw, data.prefs.screen.center(2),    data.prefs.screen.center(1)+cw, data.prefs.screen.center(2),    pw);
        Screen('DrawLine', data.prefs.screen.window1, data.prefs.screen.colors.standtextcol, data.prefs.screen.center(1),    data.prefs.screen.center(2)-cw, data.prefs.screen.center(1),    data.prefs.screen.center(2)+cw, pw);
        
        [ VBLTimestamp3,            ~ ] = Screen('Flip', data.prefs.screen.window1, [], 1, 0);    %use 'dontclear=1' so that the cross remains in the back buffer for adding the next stimulus 
                                                                                                        %output time stamps for having a reference point for the first ITI (blank screen)
        mfold_Markers(1,marker_code,marker_str);        %marker for fixation cross
        
        % determine stimuli and their screen positions
        iti_dur = rand_itis(Ti);                 %draw psudo-random ITI duration
        
        %% Cube net image (presented after ITI elapsed)
        marker_str = ['fold:' num2str(fold), ';angle:', num2str(angle) ';meet:' data.prefs.present.paritystrings{parity+1}, ';net:' data.prefs.present.netIDstrings{netID} ';'];
        marker_code = m.trial + parity + m.onset;
        imgpath = data.prefs.present.stimpaths{row_ind};                      % path to image
        img = imread(imgpath);                                                % load stim
        img = img(:, size(img,2)*0.2:size(img,2)*0.8, :);
        [imgH, imgW, ~] = size(img);
        Screen('FillRect',data.prefs.screen.window1, bgColor);
        tex = Screen('MakeTexture', data.prefs.screen.window1, double(img));  % draw stim to texture
        
        % Compute destination rect using original size (or scale if needed)
        dstRect = [center(1)-imgW/2, center(2)-imgH/2, center(1)+imgW/2, center(2)+imgH/2] + hdisloc*[1 0 1 0];
        Screen('DrawTexture', data.prefs.screen.window1, tex, [], dstRect);

        [ VBLTimestamp1, StimulusOnsetTime1 ] = Screen('Flip', data.prefs.screen.window1, VBLTimestamp3 + iti_dur, 1, 0);       %flip and keep content in back buffer
        mfold_Markers(1,marker_code,marker_str);
        
        %% RESPONSE and RT
        if ~data.prefs.input.UseOfCedrusResponsePad  
            [response, rt] = KbGetResponse(data.prefs.input.kb_response_keys, data.prefs.input.response_waittime, data.prefs.input.KbResponse_restrictKeys);
            if response==27, Screen('Flip', data.prefs.screen.window1); disp('User abort, data files incomplete!'), sessionCompleted = 0; return, end   %'escape' immediately ends the core section and thereby the paradigm
        else
            %%% WARNING: the following code section has not been reviewed lately, might contain bugs or inconsistencies!
            fprintf(s1,['e5',char(13)]);                            % reset RT timer first, for most accurate measurement
            if s1.bytesAvailable, fread(s1,s1.bytesAvailable); end  % empty the buffer
            RestrictKeysForKbCheck(27);                             % only "Escape" on the keyboard will be recognized
            keyIsDown = 0;
            while (~s1.bytesAvailable) && (~keyIsDown)
                [keyIsDown, ~, keyCode] = KbCheck;
            end
            mfold_Markers(1,0,'response');
            RestrictKeysForKbCheck([]);
            if s1.bytesAvailable
                sixbytes = fread(s1,6);
                button = (sixbytes(2));
                switch button, case 144, response = 1; case 208, response = 2; otherwise, response = -1; end
                rt = (sixbytes(3)+(sixbytes(4)*256)+(sixbytes(5)*65536) +(sixbytes(6)*(65536*256)));
            else
                key = find(keyCode);
                if key==27, Screen('Flip', data.prefs.screen.window1); disp('User abort, data files incomplete!'), sessionCompleted = 0; return, end
            end
        end
        
        %% BLANK / Feedback
        %determine response correctness and assign additional values
        % response 1 : match 
        % response 2 : mismatch 
        % stim match 0 : match 
        % stim match 1 : mismatch 
        correct = parity == (response-1);       %mismatch is '0' or '1', responses are '1' or '2' (in this case)
        if (response==-99) || (response==-1)        %in case of missed deadline or wrong or multiple key presses
                correct = response;                 %the important trial outputs are...
        end
        
        %send marker
        marker_str = [];
        marker_str = [marker_str, ['parity:', data.prefs.present.paritystrings{parity+1}, ';']];
        if (correct == -99) || (correct == -1)
            response_str = response_labels{3};
            correct_str = correct_labels{3};
        else
            response_str = response_labels{response};
            correct_str = correct_labels{correct + 1};
        end
        marker_str = [marker_str, ['response:',response_str,';']];
        marker_str = [marker_str, ['response_evaluation:',correct_str,';']];
        marker_str = [marker_str, ['rt:',num2str(rt),';']];
        marker_code = m.trial + m.response + m.(correct_str);
        mfold_Markers(1,marker_code,marker_str);
        
        %provide feedback for demo runs
        if ~data.input.experiment
            switch correct
                case -99    %missed deadline (max rt elapsed)
                    DrawFormattedText(data.prefs.screen.window1, 'Timeout, response too late.', 'center', 'center', [255 255 255]);
                case -1     %wrong or multiple keys pressed
                    DrawFormattedText(data.prefs.screen.window1, 'Error, wrong key pressed.', 'center', 'center', [255 255 255]);
                case 0      %false response
                    DrawFormattedText(data.prefs.screen.window1, 'WRONG', 'center', data.prefs.screen.center(2) - 200, [240 50 50]); % 200 is the vertical offset from center
                case 1      %correct response
                    DrawFormattedText(data.prefs.screen.window1, 'CORRECT', 'center', data.prefs.screen.center(2) - 200, [50 240 50]);
                    correctTotal = correctTotal + 1; 
            end
            disp(['N correct trials = ' nume2str(correctTotal) ' out of ' num2str(Ti)])
            Screen('Flip', data.prefs.screen.window1);      %display feedback...
            pause(1)                                        %for x seconds
        end
        
        marker_str = 'screen:blank;';
        marker_code = m.trial + m.blank + m.onset;
        
        Screen('Flip', data.prefs.screen.window1);
        mfold_Markers(1,marker_code,marker_str);
        pause(1)
        
        
        %% OUTPUT
        refstim_duration_sot = NaN;  % StimulusOnsetTime2-StimulusOnsetTime1;         %get measured duration of refstim presentation (SJ : obsolete now?)
        data.output.results(lcount,:) = [lcount, j, Ti, iti_dur, row_ind,response, correct, rt, data.prefs.present.refstim_duration, refstim_duration_sot];
        
    end
    
    marker_str = ['block_end:',num2str(j),';'];
    marker_code = m.experiment + m.block + m.end;         
    mfold_Markers(1,marker_code,marker_str);
    
    pause(1)
    
    %% Break handling
    if j < nblocks % make a break after each block but the last one
        Screen('CopyWindow', data.stimuli.screen.pausestring, data.prefs.screen.window1);
        Screen(data.prefs.screen.window1, 'Flip');
        pause(break_duration);      % option to coninue after mandatory period in seconds
        Screen('CopyWindow', data.stimuli.screen.welcomestring, data.prefs.screen.window1);
        Screen(data.prefs.screen.window1, 'Flip');
        if ~data.prefs.input.UseOfCedrusResponsePad
            KbWait;
        else
            mfold_waitForCedrusKey(data.prefs.input.s1,'center');
        end
        Screen(data.prefs.screen.window1, 'Flip');
        pause(1);
    end
    
end

sessionCompleted = 1;