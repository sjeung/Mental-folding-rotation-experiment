function mfold_Markers(arg1,arg2,arg3)
% input arguments:
% arg1: run mode (initialization vs. marker sending)
% arg2: numerical marker code (know your markers, create a marker table)
% arg3: string marker description (see marker table)


global data

numericalMarkers = data.output.LSL.numericalMarkers;    %whether or not markers are numerical vs. string format

switch arg1     %run mode for this function
    
    
    %% initialization
    case 0
        
        % define marker codes:
        % a) segment markers
        data.markers.experiment = 100;
        data.markers.block = 10;        %gets multiplied by block number
        data.markers.start = 1;
        data.markers.end = 2;
        
        % b) trial markers
        data.markers.trial = 200;
        data.markers.fixation = 10;
        data.markers.target = 20;
        data.markers.reference = 30;
        data.markers.response = 40;
        data.markers.blank = 50;
        data.markers.onset = 1;
        data.markers.offset = 2;
        data.markers.resp_match = 0;
        data.markers.resp_mismatch = 2;
        data.markers.stim_match = 0;
        data.markers.stim_mismatch = 2;
        data.markers.left = 0;
        data.markers.right = 4;
        data.markers.false = 0;
        data.markers.correct = 1;
        data.markers.n_a = 2;
        
        % c) stimulus markers (careful: decimals not compatible with serial or parallel port!)
        % stimulus marker send during trial preparation corresponds to pairing list line number
        % reference vs. target and match vs. mismatch are integrated into the trial markers
        
        
        % set up serial port (for markers or special input hardware)
        %         delete(instrfind('Type','serial')); %remove all serial interfaces in case prior execution terminated prematurely; also relevant for Cedrus Response Pad
        %         data.output.serialport = serial('COM1','BaudRate',115200);   %create new interface; COM port and boud rate might habe to be adjusted (see device manager)
        %         fopen(data.output.serialport);    %open interface
        
        
        % set up event list
        data.output.eventFid = fopen(data.prefs.output.evntFilename, 'wt');     %open event list output file
        data.output.eventcounter = 0;                                           %reset event/line counter
        
        
        % set up parallel port (for markers or controlling special hardware)
        %         data.output.parport.ioObj = io64;         %needs the io64/inpoutx64.dll driver (freeware) - has to be installed and run as admin once
        %         status = io64(data.output.parport.ioObj); %initialize the inpoutx64 system driver; if status = 0, you are now ready to write and read to a hardware port
        %         %disp(status);
        %         data.output.parport.address = hex2dec('D010');    %can be a completely different address (see device manager, look for the first hardware address of the device)
        %         data.output.parport.impWidth = 0.005;     %impulse width for rectangular parport signal; has to be higher than '1/samplerate' of recording device
        
        
        % set up labstreaminglayer (lsl)
        disp('Loading LSL library...');
        lib = lsl_loadlib();                                                %for this to work, the Matlab LSL wrapper has to be on the path (with all sub-folders)
        
        if ~numericalMarkers
            data.output.LSL.MarkerStreamName = 'MentalFolding_Markers';     %helpful name known to the experimenter
            data.output.LSL.ContentType = 'Markers';                        %by convention, LSL markers are of type 'Marker'
            data.output.LSL.nChannels = 1;                                  %have 1 channel per experiemnt
            data.output.LSL.regularRate = 0;                                %are sampled irregularly; regular streams get special treatment on import which would greatly disrupt marker synchronicity
            data.output.LSL.dataFormat = 'cf_string';                       %and are of string format
            data.output.LSL.uniqueSourceID = 'myuniquesourceid23443';       %could be anything; might be used for continuing recording after PC or nework trouble
        else
            data.output.LSL.MarkerStreamName = 'MentalFolding_Markers';
            data.output.LSL.ContentType = 'numMarkers';
            data.output.LSL.nChannels = 1;
            data.output.LSL.regularRate = 0;
            data.output.LSL.dataFormat = 'cf_int16';                        %some analysts prefer numerical markers to work with
            data.output.LSL.uniqueSourceID = 'myuniquesourceid23443';
        end

        disp('Creating a new marker stream info...');                       %containing all the above settings
        info = lsl_streaminfo(lib,data.output.LSL.MarkerStreamName,data.output.LSL.ContentType,data.output.LSL.nChannels,data.output.LSL.regularRate,data.output.LSL.dataFormat,data.output.LSL.uniqueSourceID);
        
        disp('Opening an outlet...');
        data.output.LSL.outlet = lsl_outlet(info);                          %this is where markers are 'written' to
        disp('Done.')
        
        pause(1);
            
    %% regular marker sending
    case 1
        
        % lsl marker
        data.output.LSL.outlet.push_sample({arg3});
        
        % event list entry
        mfold_Eventlist(arg2,arg3);
        
    
    %% de-initialization
    case 2
        
        % log the experiment end time 
        data.output.endMeasurement = GetSecs;
        
        marker_str = [];
        marker_str = [marker_str, 'measurement:end;'];
        data.output.LSL.outlet.push_sample({marker_str});
         
        % create final event list entry
        marker_code = data.markers.experiment + data.markers.end;
        mfold_Eventlist(marker_code,marker_str);
        
        % shut down event pipes
        pause(1)        %give pipes time to process the last marker
        fclose(data.output.eventFid);

end