%% Initialisations of SARAS processing

% clear before set global, so one can call init more than once 

% PATHS
clear PRG_PATH DAT_PATH RES_PATH
global PRG_PATH ; PRG_PATH = fileparts(mfilename('fullpath'));  % get path of current script
global DAT_PATH ; DAT_PATH = fullfile(PRG_PATH, '..', 'DAT');
global RES_PATH ; RES_PATH = fullfile(PRG_PATH, '..', 'RES');


% CURSOR
clear CURSOR_RADIUS
global CURSOR_RADIUS ; CURSOR_RADIUS = 10;     % radius of cursor (pixels) 

% SCALING
clear PIXEL_TO_CM
global PIXEL_TO_CM ; PIXEL_TO_CM = 20/798; 


% PARTICIPANTS
clear CONTROL_NB CONTROL_L CONTROL_R
global CONTROL_NB; CONTROL_NB   = [1 : 19];
global CONTROL_L ; CONTROL_L    = [6 8 ];                                   % control using L hand
global CONTROL_R ; CONTROL_R    = setdiff(CONTROL_NB, CONTROL_L);           % control using R hand

clear PATIENT_NB PATIENT_R PATIENT_L
global PATIENT_NB; PATIENT_NB   = [1 3 4 5 6 7 9 10 11 12 13 14 16 20 21 22 23 25 29];
global PATIENT_R ; PATIENT_R    = [  3 4   6 7   10 12 13       16 20          25   ];    % patient using R hand (Left CVA)
global PATIENT_L ; PATIENT_L    = setdiff(PATIENT_NB, PATIENT_R);                         % patient using L hand

clear AGED_NB AGED_L AGED_R
global AGED_L  ; AGED_L    = [ ];                       % using L hand
global AGED_NB ; AGED_NB   = [1:11 91:92];              % high number are experienced persons in such a task (Denis, etc...)

FNAME_GROUP_LABEL = {'ap', 'cp', 'pp'};


