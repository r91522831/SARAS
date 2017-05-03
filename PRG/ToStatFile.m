function [ Txt, Hdr ] = ToStatFile( P, VarName )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

NbVar = length(VarName);
Val     = []; 
TxtValLine = []; 

for i = 1:NbVar
    if isfield(P, VarName{i} )
        Val(i) = getfield(P, VarName{i} ); 
    else
        warning(sprintf('%s does not exist..', VarName{i} ));
    end
end

if ~isempty(Val) 
    TxtValLine = sprintf(' %f', Val );
    HdrValLine = sprintf(' %s', VarName{:} );
end

G = P.Protocol.GROUP;
S = P.Protocol.SUBJ;
T = P.Protocol.TRIAL;
O = P.Protocol.ORI;
D = P.Protocol.DIR;
I = P.Protocol.ID;
R = P.Protocol.REP;

Gl = 'GROUP';
Sl = 'SUBJ';
Tl = 'TRIAL';
Ol = 'ORI';
Dl = 'DIR';
Il = 'ID';
Rl = 'REP';


TxtLine = sprintf('%s %s %s %s %s %s %s', G , S , T , O , D , I , R  ); 
HdrLine = sprintf('%s %s %s %s %s %s %s', Gl, Sl, Tl, Ol, Dl, Il, Rl ); 


Txt = sprintf('%s%s\n', TxtLine, TxtValLine);
Hdr = sprintf('%s%s\n', HdrLine, HdrValLine);



end

