function [ M ] = ReadSARAS( Group, SubjNb, TrialNb )
% ReadSARAS Read a SARAS data file
% Input : 
%   Group : the group label ('ap', 'cp', 'pp')
%   Subj  : subject number (not checked) 
%   Trial : trial number (1, 2) 
% Output :
%   M = A structure with (main) fields : 
%   Time     : time (sec)
%   X_Cursor : cursor position along X (pixel)
%   Y_Cursor : cursor position along Y (pixel)
%   InTarget : cursor inside target ? (boolean)
%   X_Target : target position along X (pixel)
%   Y_Target : target position along Y (pixel)
%   r_Target : target radius (pixel)
%   iNewTarget : index of a target switch

%   Denis Mottet -- Version 1.0 -- 25 04 2017


%% check input arguments 

switch Group 
    case {'ap', 'cp', 'pp'}
        ; % this is OK 
    otherwise
        error ('Group label should be one of : "ap", "cp", "pp".') 
end
if TrialNb > 2 | TrialNb < 1 
    error ('Trial should be one of : 1, 2.') 
end

%% import the data from the text file 
global DAT_PATH

fname     = sprintf('%s%02.0f-%1.0f.dat',  Group, SubjNb, TrialNb );
fullfname = fullfile(DAT_PATH, fname);

D    = importdata(fullfname);
DATA = D.data;

%% Get rid of the "useless" data 
% Nothing useful recorded before the first target switch
% Yet, we keep the record from entering first target (1 s prior switch) 
% So we have data to consume if border effects in filtering... 

InTarget = DATA(:,7);              % In target flag
beg  = find(InTarget, 1);          % first InTarget that is true

DATA = DATA(beg:end, :); 


%% Rename the data with more explicit names 
Time     = DATA(:,3);
Time     = (Time-Time(1))./1000; % Time in seconds 

% Most robust guess of sampling (supposed to be constant)
SamplingPeriod = median(diff(Time));

X_Cursor = DATA(:,1);
Y_Cursor = DATA(:,2);

X_Target = DATA(:,4);              % position in x of Target (in pixels)
Y_Target = DATA(:,5);              % position in y of Target (in pixels)

InTarget = DATA(:,7);              % In target flag
r_Target = DATA(:,6);              % radius of target

%% make axis sign similar to matlab 
% origin is bottom left for matlab plots 
% origin is top left for the display on the screen 

Y_Target  = - Y_Target; 
Y_Cursor  = - Y_Cursor; 

%% Define the series of pointing, based on target switch
% beg of pointing movement = as soon as new target arrives
% end of pointing movement = begining of next movement - 1
%(defined by change in xtarget or ytarget)

dxT = abs(diff(X_Target));
dyT = abs(diff(Y_Target)); 
iNewTarget  = find(dxT > 2 | dyT > 2) ;
iNewTarget  = [iNewTarget ; length(dxT)] ;      % last "new target" = the end of the record
NbPointing  = length(iNewTarget) - 1;           % pointing is between two "new targets"


%% iNewTarget  = iNewTarget + 1 ;   % to compensate for the diff
% NB : if not + 1, iNewTarget indicates the END of the target...
% and this is our choice !!
% Explanation :
% We want a Pointing to include the last sample of the previous
% ---------                     Pointing 1
%         ---------             Pointing 2
% The overlap allows for having 2 targets in the same Pointing
% hence, we do not compensate for diff


%% If the participant uses the left hand, then we reverse the X axis
% consequence : we must also reverse W and E in protocol description
global AGED_L CONTROL_L PATIENT_L
switch Group
    case 'ap'
        WithLeftHand = AGED_L;
    case 'cp'
        WithLeftHand = CONTROL_L;
    case 'pp'
        WithLeftHand = PATIENT_L;
end

if ismember(SubjNb, WithLeftHand)    
    ori = {'E'; 'NE'; 'N'; 'NW'; 'W'};
    X_Target  = - X_Target; 
    X_Cursor  = - X_Cursor; 
    Protocol.Hand = 'L';
else
    ori = {'W'; 'NW';'N'; 'NE'; 'E'};
    Protocol.Hand = 'R';
end


%% Get targets from real data (because various protocols were used...)

iPointingBeg = iNewTarget(1:end-1);
iPointingEnd = iNewTarget(2:end);

% Start target (previous one)
Start.X =  X_Target(iPointingBeg);
Start.Y =  Y_Target(iPointingBeg);
Start.r =  r_Target(iPointingBeg);

% Target to reach
Target.X =  X_Target(iPointingEnd);
Target.Y =  Y_Target(iPointingEnd);
Target.r =  r_Target(iPointingEnd);


%% Compute Fitts task informations : Distance, Tolerance, ID...
% Distance (from target center to target center) 
DeltaX = Target.X - Start.X;
DeltaY = Target.Y - Start.Y;
D = sqrt(DeltaX .* DeltaX + DeltaY .* DeltaY);

% Tolerance (target size minus cursor size) 
global CURSOR_RADIUS;
W = Target.r - CURSOR_RADIUS;

% Fitts ID
IDf = log(2 .* D ./ W) ./ log(2);  % log2(2D/W)

% Shannon ID (used in the protocol values) 
IDs = log(D ./ W + 1 ) ./ log(2);

%% Guess the protocol 
% the order is (faster varying firt) 
% 2 DIR * 5 ORI * (2|3) ID * (2|3) REP

%% Set DIR constants 
dir = {'outward'; 'inward'};   % labels for DIR  
NbDir = size(dir, 1); 

%% Set ORI constants
% labels for ORI were set when processing Left hand users 
NbOri = size(ori, 1); 


%% Guess the ID in the protocol from real ID values 
% NB : IDp should only be one of 3, 4.5 and 6 (ID Shannon was used) 
%    IDp = 3 + 1.5 .* [0 1 2]
% Due to a bug in the experimental software, real ID is about 1 bit
% higher than expected... 
% we round IDs/1.5 to get 3 separate integer IDs values (then * 1.5) 
IDp = (round(IDs / 1.5) + 1) * 1.5 - 3; 

% Now, count the ID values that were used (should be 2 or 3) 
IDval    = unique(IDp); 
NbId  = size(IDval, 1); 
for i = 1:NbId
    id{i, 1} = sprintf('ID%d', i );
end

%% Guess the number of repetitions  
NbRep = NbPointing / (NbOri * NbDir * NbId);
for r = 1:NbRep
    rep{r, 1} = sprintf('R%d', r);
end

%% Compute the protocol 
% the order is (faster varying firt) 
% 2 DIR * 5 ORI * (2|3) ID * (2|3) REP
% Logic : 
%  use repmat to replicate "blocks" 
%  a block replicate a line 

% faster varying (no blocks) 
DIR = repmat(dir, NbPointing / NbDir, 1); 

% second faster vaying 
DxO = repmat(ori', NbDir, 1);                   % replicate ori (NbDir times) 
DxO = DxO(:);                                   % read as a vector 
ORI = repmat(DxO, NbPointing/numel(DxO), 1);    % replicate the vector  

% third faster varying
DxOxI = repmat(id', NbOri * NbDir, 1); 
DxOxI = DxOxI(:); 
ID    = repmat(DxOxI, NbPointing/numel(DxOxI), 1);

% fourth faster varying 
DxOxIxR = repmat(rep', NbOri * NbDir * NbId, 1);
DxOxIxR = DxOxIxR(:);
REP     = repmat(DxOxIxR, NbPointing/numel(DxOxIxR), 1);


% % %% Compute target radius from protocol info (and CURSOR_RADIUS)
% global CURSOR_RADIUS
% D  = ProtocolMatrix(:,6);       % Dist (center to center) 
% W  = ProtocolMatrix(:,7);       % This is likely wrong... need to check 
% ID = ProtocolMatrix(:,5);       % ID protocol (which is ID Shannon) 
% W  = (D+1) ./ 2.^ID;            % simple math from ID = log2(D ./ W + 1)
% ID_Fitts = log2(2 .* D ./ W);   % simple correspondance S --> F
% R  = W./2 + CURSOR_RADIUS;      % target size = tolerance + cursor 


%% Compute the angle of the point (for verification mainly) 
% Angle of this pointing (in radian) 
A  = atan2(Target.X - Start.X, Target.Y - Start.Y);


%% Write the protocol (all as string) 
% for the file (string) 
Protocol.Target         = Target;
Protocol.GROUP          = Group;
Protocol.SUBJ           = sprintf('S%0.2d', SubjNb);
Protocol.TRIAL          = sprintf('T%0.2d', TrialNb);
% for pointing (cell vectors of string) 
Protocol.ORI            = ORI;
Protocol.DIR            = DIR;
Protocol.ID             = ID;
Protocol.REP            = REP; 
Protocol.Angle          = cellstr(num2str(A*180/pi, 'A%+04.0f')); % A is a vector...

%% Output all in one single structure  
M.SamplingPeriod = SamplingPeriod; 
M.Time       = Time;
M.X_Cursor   = X_Cursor; 
M.Y_Cursor   = Y_Cursor; 
M.InTarget   = InTarget; 
M.X_Target   = X_Target;
M.Y_Target   = Y_Target; 
M.r_Target   = r_Target; 
M.iNewTarget = iNewTarget; 
M.NbPointing = NbPointing; 
M.Protocol   = Protocol;




end

