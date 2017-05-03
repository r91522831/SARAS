function [ P ] = GetPointing( Nb, M  )
%GetPointing Get all information about one pointng movement in DATA
%Input :
%   Nb : number of the pointing
%   Data : Matrix obtained from ReadSARAS


if Nb > M.NbPointing
    msg = sprintf('Pointing %d does not exist (max %d)', Nb, M.NbPointing);
    error(msg);
end

iPointingBeg  = M.iNewTarget (Nb);             % beg of pointing
iPointingEnd  = M.iNewTarget (Nb + 1);         % end of pointing
iPointingZone = iPointingBeg : iPointingEnd;   % zone of poiting

% Trajectory
T = M.Time(iPointingZone);
X = M.X_Cursor(iPointingZone);
Y = M.Y_Cursor(iPointingZone);
I = M.InTarget(iPointingZone);
V = M.TgVel(iPointingZone);


% Target to reach
Target.X =  M.X_Target(iPointingEnd);
Target.Y =  M.Y_Target(iPointingEnd);
Target.r =  M.r_Target(iPointingEnd);

% Start target (previous one)
Start.X =  M.X_Target(iPointingBeg);
Start.Y =  M.Y_Target(iPointingBeg);
Start.r =  M.r_Target(iPointingBeg);

% Fitts task information : Distance
DeltaX = Target.X - Start.X;
DeltaY = Target.Y - Start.Y;
D = sqrt(DeltaX .* DeltaX + DeltaY .* DeltaY);

% Fitts task information : Tolerance
global CURSOR_RADIUS;
W = Target.r - CURSOR_RADIUS;

% Fitts task information : ID
ID = log(2 .* D ./ W) ./ log(2);  % log2(2D/W)

% Shannon ID 
IDs = log(D ./ W + 1 ) ./ log(2);

% From protocol informaation 
Protocol.ID = M.Protocol.ID(Nb);


% store all that in a structured fashion 
P.Trajectory.T = T; 
P.Trajectory.X = X; 
P.Trajectory.Y = Y; 
P.Trajectory.I = I; 
P.Trajectory.V = V; 

P.Target = Target; 
P.PreviousTarget = Start; 

P.Fitts.D = D;
P.Fitts.W = W;
P.Fitts.ID = ID; 
P.Fitts.ID_Shannon = IDs; 

P.Protocol.Hand  = M.Protocol.Hand; 
P.Protocol.GROUP = M.Protocol.GROUP; 
P.Protocol.SUBJ  = M.Protocol.SUBJ; 
P.Protocol.TRIAL = M.Protocol.TRIAL; 

P.Number = Nb;
P.Protocol.ORI   = M.Protocol.ORI   {Nb}; 
P.Protocol.DIR   = M.Protocol.DIR   {Nb}; 
P.Protocol.ID    = M.Protocol.ID    {Nb}; 
P.Protocol.REP   = M.Protocol.REP   {Nb}; 
P.Protocol.Angle = M.Protocol.Angle {Nb}; 

end

