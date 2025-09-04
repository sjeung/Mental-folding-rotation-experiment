%prep
sca

%screen properties
whichScreen = 0;
scrsz = get(whichScreen,'ScreenSize');
center = scrsz(3:4)/2;

%open window
win = Screen(whichScreen, 'OpenWindow');

%set colors
white = WhiteIndex(win);
black = BlackIndex(win);
stdBgCol = black;
stdTxtCol = white;
Screen(win, 'FillRect', stdBgCol); 
Screen(win, 'Flip');

%text settings
hsize = 72;
bsize = 48;
fsize = 36;
vSpacing = 1;
winRect = [100 150 1820 980];
boffset = 100;
%global ptb_drawformattedtext_disableClipping;
%ptb_drawformattedtext_disableClipping = 1;

%image settings
icenter = center + [0 200];

%read instructions
fid = fopen('instructions.txt','r');
ins = textscan(fid,'%s%s%s','Delimiter',';'); 
fclose(fid);


%display
for i = 1:length(ins{1})
    
    %[nx, ny, textbounds, wordbounds] = DrawFormattedText(win, tstring [, sx][, sy][, color][, wrapat][, flipHorizontal][, flipVertical][, vSpacing][, righttoleft][, winRect])
     
    %headline
    Screen('TextSize',  win, hsize);
    [nx, ny, bbox] = DrawFormattedText(win, ins{1}{i}, 'justifytomax', winRect(RectTop), stdTxtCol, [], [], [], vSpacing, [], winRect);
%     Screen('FrameRect', win, 255, bbox);
%     Screen('FrameRect', win, 255, winRect);
    

    %body
    Screen('TextSize',  win, bsize);
    [nx, ny, bbox] = DrawFormattedText(win, ins{2}{i}, 'justifytomax', winRect(RectTop)+boffset, stdTxtCol, [], [], [], vSpacing, [], winRect);
%     Screen('FrameRect', win, 255, bbox);
%     Screen('FrameRect', win, 255, winRect);
     

    %image
    imname = ins{3}{i};
    img = imread(imname); 
    is_rev = size(img);
    ish = is_rev([2 1])*.5;
    tex = Screen('MakeTexture', win, double(img));
    Screen('DrawTexture',win,tex,[],[icenter(1)-ish(1) icenter(2)-ish(2) icenter(1)+ish(1) icenter(2)+ish(2)]);
    
    
    %advance
    Screen('TextSize',  win, fsize);
    [nx, ny, bbox] = DrawFormattedText(win, 'bitte eine Taste drücken', 1450, 1000, stdTxtCol);
    
    
    %show
    Screen('Flip', win );
    KbWait;  
    
end


sca;