% Example of managing one SARAS file

clear all

% Allways initialize
init;

% define the file to read
GROUP = 'pp';
SUBJ  = 29;
TRIAL = 1;


Data = ReadSARAS( GROUP, SUBJ, TRIAL );
% Time, X_Cursor, Y_Cursor, InTarget, X_Target, Y_Target, r_Target, iNewTarget, Protocol 

% To avoid edge effect, filter once for all before the rest 
Data = LowPassFilterSARAS(Data); 

Data = TangentialVelocity(Data);

%% analyse the movements in the file


for GestNb = 1:Data.NbPointing
    P = GetPointing(GestNb, Data); 
    P = GetVelocityPeaks(P)
end



