function sessionCompleted = mfold_Core

global data


%% some settings

if data.prefs.input.UseOfCedrusResponsePad
    s1 = data.prefs.input.s1;                   %get a shortcut
end

%output preparation
lcount = 0;                                     %line of data matrix

%short handles for stimulus presentation...
center = data.prefs.screen.center;
ish = data.prefs.present.ish;
hdisloc = data.prefs.present.hdisloc;

cw = data.prefs.present.cross_halfwidth;
pw = data.prefs.present.cross_penwidth;

%and trial structure parameters
ntrials = data.prefs.present.ntrials;
nmatches = data.prefs.present.nmatches;

if ~data.input.experiment                       %if demo run,
    nblocks = 2;                                %speed up things for demo or debugging purposes
    break_duration = 5;
    %ntrials = 2;
else
    nblocks = data.prefs.present.nblocks;
    break_duration = data.prefs.present.break_duration;
end

%markers
side_labels = {'left','right'};                %stimulus side labels for lsl markers
mismatch_labels = {'match','mismatch'};
response_labels = {'same','different','n_a'};
correct_labels = {'false','correct','n_a'};
m = data.markers;


%% central routine

for j = 1:nblocks
    
    %mfold_Markers(1,101+j*10,'blockstart');     %code block start as 1x1 + block nr as second digit
    
    marker_str = [];
    marker_str = [marker_str, ['block_start:',num2str(j),';']];
    marker_code = m.experiment + m.block + m.start;         %see mfold_markers for coding
    mfold_Markers(1,marker_code,marker_str);
    
    % presentation sides for ref stimuli are balanced 50/50 but freely with no relationship to match/mismatch
    refsides = data.prefs.present.refsides*2-1;             %result is either -1 (left) or +1 (right)
    rand_refsides = refsides(randperm(length(refsides)));   %randomize order
    
    % elimination of 1/3 of mismatches per block (72 matches vs. 48 mismatches)
    relim = rem(j-1,3)+1;                                   %row eliminator (cycles thour [1,2,3])
    if relim==1                                             %re-randomize after each third block (i.e. also in the beginning)
        mismatch_table = mrand(data.prefs.present.mismatch_table);
    end
    rkeep = ones(3,1); rkeep(relim)=0;                      %column vector eliminating one row
    rkeepm = rkeep*ones(1,size(mismatch_table,2));          %make matrix of identical columns
    mismatches = mismatch_table(logical(rkeepm)) + 100;     %trials > 100 are mismatches
    
    %assemble all pairings per block
    if ~data.input.experiment                               %if demo run
        all_pairings = data.prefs.present.training_trials;  %pick demo trials
    else                                                    %else
        all_pairings = [1:nmatches, mismatches(:)'];        %concatenate matches and mismatches (row indicators for pairings list)
    end
    rand_pairings = all_pairings(randperm(ntrials));        %and randomize them

    
    rand_itis = data.prefs.present.iti_durations(randperm(ntrials)); %nicht mit demselben randomizer, sonst h?tten immer die gleichen Reize die kurzen/langen ITIs
    
    pause(1)
    
    for i = 1:ntrials
        
        lcount = lcount +1;                     %increment line/trial counter for output matrix
        
        %trial marker
        marker_str = [];
        marker_str = [marker_str,['trial_number_absolut:',num2str(lcount),';']];
        marker_str = [marker_str,['trial_number_block:',num2str(i),';']];
        marker_code = m.trial + m.start;
        mfold_Markers(1,marker_code,marker_str)
        
        %fixation marker
        marker_str = [];
        marker_str = [marker_str,['screen:fixation_cross;']];
        marker_code = m.trial + m.fixation + m.onset;
        
        %% Fixation and trial preparation
        % draw fixation cross on screen (actually on the back buffer; we have enough time for not using offscreen windows)
        Screen('DrawLine', data.prefs.screen.window1, data.prefs.screen.colors.standtextcol, data.prefs.screen.center(1)-cw, data.prefs.screen.center(2),    data.prefs.screen.center(1)+cw, data.prefs.screen.center(2),    pw);
        Screen('DrawLine', data.prefs.screen.window1, data.prefs.screen.colors.standtextcol, data.prefs.screen.center(1),    data.prefs.screen.center(2)-cw, data.prefs.screen.center(1),    data.prefs.screen.center(2)+cw, pw);
        %[VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip', windowPtr [, when] [, dontclear] [, dontsync] [, multiflip]);
        [ VBLTimestamp3,            ~ ] = Screen('Flip', data.prefs.screen.window1, [], 1, 0);    %use 'dontclear=1' so that the cross remains in the back buffer for adding the next stimulus 
                                                                                                        %output time stamps for having a reference point for the first ITI (blank screen)
        mfold_Markers(1,marker_code,marker_str);        %marker for fixation cross
        
        % determine stimuli and their screen positions
        rand_pairing = rand_pairings(i);        %get pairing from randomized list
        mfold_Eventlist(rand_pairing,'pairing_selection');
        mismatch = rand_pairing>100;            %separate mismatch and...
        pairing = rand_pairing-100*mismatch;    %pairing number info
        
        tarstim = data.prefs.present.pairings_list{1}{pairing};             %targets are in the 1st column
        refstim = data.prefs.present.pairings_list{2+mismatch}{pairing};    %reference stimuli in the 2nd (matches) or 3rd (mismatches)
        
        rside = rand_refsides(i);               %draw psudo-random reference...
        tside = rside*(-1);                     %and target side

        iti_dur = rand_itis(i);                 %draw psudo-random ITI duration
        
        
        %% REFSTIM (presented after ITI elapsed)
        %refstim: e.g. "1_000_x"
        %marker_str = ['refstim-',refstim,'-',side_labels{(rside+1)/2+1}];          %prepare refstim marker string for LSL
        
        marker_str = [];
        marker_str = [marker_str, ['reference_level:',refstim(1),';']];
        marker_str = [marker_str, ['reference_figure:',refstim(3:5),';']];
        marker_str = [marker_str, ['reference_arrow_position:',refstim(end),';']];
        marker_str = [marker_str, ['presentation_side:',side_labels{(rside+1)/2+1},';']];
        marker_code = m.trial + m.reference + m.(side_labels{(rside+1)/2+1}) + m.(mismatch_labels{mismatch+1}) + m.onset;

        refpath = [data.prefs.present.stimpath,refstim,'.JPG'];                     %assemble refstim path
        refimg = imread(refpath);                                                   %load refstim
        reftex = Screen('MakeTexture', data.prefs.screen.window1, double(refimg));  %draw stim to texture
        Screen('DrawTexture', data.prefs.screen.window1, reftex, [], [center(1)-ish(1) center(2)-ish(2) center(1)+ish(1) center(2)+ish(2)] + rside*hdisloc*[1 0 1 0]);  %draw texture on screen (with fixation cross)
        [ VBLTimestamp1, StimulusOnsetTime1 ] = Screen('Flip', data.prefs.screen.window1, VBLTimestamp3 + iti_dur, 1, 0);       %flip and keep content in back buffer
        %mfold_Markers(1,rand_pairing,marker_str);       %put out marker code and string descriptor
        mfold_Markers(1,marker_code,marker_str);

        
        %% TARGET
        %marker_str = ['tarstim-',tarstim,'-',side_labels{(tside+1)/2+1}];
        
        marker_str = [];
        marker_str = [marker_str, ['target_level:',tarstim(1),';']];
        marker_str = [marker_str, ['target_figure:',tarstim(3:5),';']];
        marker_str = [marker_str, ['target_arrow_position:',tarstim(end),';']];
        marker_str = [marker_str, ['presentation_side:',side_labels{(tside+1)/2+1},';']];
        marker_code = m.trial + m.target + m.(side_labels{(tside+1)/2+1}) + m.onset;
        
        tarpath = [data.prefs.present.stimpath,tarstim,'.JPG'];
        tarimg = imread(tarpath);
        tartex = Screen('MakeTexture', data.prefs.screen.window1, double(tarimg));
        Screen('DrawTexture', data.prefs.screen.window1, tartex, [], [center(1)-ish(1) center(2)-ish(2) center(1)+ish(1) center(2)+ish(2)] + tside*hdisloc*[1 0 1 0]);
        %if ~data.prefs.input.UseOfCedrusResponsePad
        %    DrawFormattedText(data.prefs.screen.window1, 'Gleich <OBEN> oder anders <UNTEN>?', 'center', center(2)+500, data.prefs.screen.colors.standtextcol);                %simultaneous instruction optional
        %else
        %    DrawFormattedText(data.prefs.screen.window1, 'Gleich <CENTER> oder anders <DOWN>?', 'center', center(2)+500, data.prefs.screen.colors.standtextcol);
        %end
        %Hint: 1000 ms are exactly 60 frames of 16.667 ms; to meat this deadline reliably, time the stimulus onset appr. half a frame backwards
        [ ~            , StimulusOnsetTime2 ] = Screen('Flip', data.prefs.screen.window1, VBLTimestamp1 + data.prefs.present.refstim_duration - 0.009, [], 0);      %flip but clear everything
        %mfold_Markers(1,rand_pairing,marker_str);
        mfold_Markers(1,marker_code,marker_str);
        
        
        %% RESPONSE and RT
        if ~data.prefs.input.UseOfCedrusResponsePad     %currently only keyboard as alternative, low latency wireless gaming mouse preferred (e.g. Logitech G305)
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
        correct = mismatch == (response-1);     %mismatch is '0' or '1', responses are '1' or '2' (in this case)
        if (response==-99) || (response==-1)    %in case of missed deadline or wrong or multiple key presses
                correct = response;             %the important trial outputs are...
                %rt = response;                  %declared as missing values
        end
        
        %send marker
        marker_str = [];
        marker_str = [marker_str, ['pairing:',mismatch_labels{mismatch+1},';']];
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
                    DrawFormattedText(data.prefs.screen.window1, 'Fehler, Zeit verstrichen.', 'center', 'center', [255 255 255]);
                case -1     %wrong or multiple keys pressed
                    DrawFormattedText(data.prefs.screen.window1, 'Fehler, falsche Taste.', 'center', 'center', [255 255 255]);
                case 0      %false response
                    DrawFormattedText(data.prefs.screen.window1, 'FALSCH!', 'center', 'center', [255 0 0]);
                case 1      %correct response
                    DrawFormattedText(data.prefs.screen.window1, 'RICHTIG!', 'center', 'center', [0 255 0]);
            end
            Screen('Flip', data.prefs.screen.window1);      %display feedback...
            pause(1)                                        %for x seconds
        end
        
        marker_str = [];
        marker_str = [marker_str, ['screen:blank;']];
        marker_code = m.trial + m.blank + m.onset;
        
        Screen('Flip', data.prefs.screen.window1);
        mfold_Markers(1,marker_code,marker_str);
        pause(1)
        
        
        %% OUTPUT
        refstim_duration_sot = StimulusOnsetTime2-StimulusOnsetTime1;       %get measured duration of refstim presentation
        tarstimcode = pairing + 1/10;                                       %code target as pairing number with a '1' as the first decimal
        refstimcode = pairing + (2+mismatch)/10;                            %code reference as pairing number with '2' or '3' as first decimal (corresponding to the paring list entry: row.column)
        %create the header string for the output section 'mfold_Save' (copy/paste it there):
        %headerString = 'Abs_trial_no\tBlock_number\tTrial_number\tIti_duration\tRef_stimSide\tTar_stimSide\tRef_stimulus\tTar_stimulus\tRespons_Code\tResp_Correct\tReactio_Time\tNom_refStDur\tAct_refStDur\n';
        data.output.results(lcount,:) = [lcount, j, i, iti_dur, rside, tside, refstimcode, tarstimcode, response, correct, rt, data.prefs.present.refstim_duration, refstim_duration_sot];
        
    end
    
    %mfold_Markers(1,102+j*10,'blockend');           %code block start as 1x2 + block nr as second digit
    
    marker_str = [];
    marker_str = [marker_str, ['block_end:',num2str(j),';']];
    marker_code = m.experiment + m.block + m.end;         %see mfold_markers for coding
    mfold_Markers(1,marker_code,marker_str);
    
    pause(1)
    
    %% Break handling
    if j < nblocks          %make a break after each block but the last one
        %if ~rem(j,2)       %optionally do this only after every second (or whatever count) block
            Screen('CopyWindow', data.stimuli.screen.pausestring, data.prefs.screen.window1);
            Screen(data.prefs.screen.window1, 'Flip');
            pause(break_duration);      %option to coninue after mandatory period in seconds
            Screen('CopyWindow', data.stimuli.screen.welcomestring, data.prefs.screen.window1);
            Screen(data.prefs.screen.window1, 'Flip');
            if ~data.prefs.input.UseOfCedrusResponsePad
                KbWait;
            else
                mfold_waitForCedrusKey(data.prefs.input.s1,'center');
            end
            Screen(data.prefs.screen.window1, 'Flip');
            pause(1);
        %end
    end
    
end

sessionCompleted = 1;