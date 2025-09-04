function mfold_Eventlist(name,userdata)

global data

% iterate running event counter
data.output.eventcounter = data.output.eventcounter +1;
i = data.output.eventcounter;

% prepare eventlist output parameters
data.output.events.event(i).nid       = i;                                          %running counter
data.output.events.event(i).time      = GetSecs - data.output.startMeasurement;     %time since experiment start
data.output.events.event(i).name      = num2str(name);                              %numerical event code
data.output.events.event(i).userdata  = userdata;                                   %string descriptor

% output those parameters to the already open (-> mfold_Markers) eventlist file
fprintf(data.output.eventFid, '%3d\t',      data.output.events.event(i).nid);
fprintf(data.output.eventFid, '%8.3f\t',    data.output.events.event(i).time);
fprintf(data.output.eventFid, '%s\t',       data.output.events.event(i).name);
fprintf(data.output.eventFid, '%s\n',       data.output.events.event(i).userdata);