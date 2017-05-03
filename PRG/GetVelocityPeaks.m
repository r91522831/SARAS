function [ P ] = GetVelocityPeak( P , NoFigVerificationPlot)
%GetVelocityPeak Computes the velocity peaks for the pointing P
%   Input :
%       P: a pointing given by GetPointing
%   Output :
%       P : same as the input, whith VP added
%       [, DoVerificationPlot] : if 1, then plot is made in figure

if nargin < 2
    NoFigVerificationPlot = 0;
end

X = P.Trajectory.X;
Y = P.Trajectory.Y;
I = P.Trajectory.I;
% tengential velocity
TgVel = P.Trajectory.V;

% velocity peaks from filtered data (only positive peaks)
iVelPeaks = find(diff(TgVel(1:end-1)) >= 0 & diff(TgVel(2:end)) < 0) + 1;    % index of velocity peaks (filtered data)

iVelPeaks = [ 2 ; iVelPeaks ];              % 1 overlapps previous pointing => start at 2
iVelPeaks = [iVelPeaks; length(TgVel)-1];   % last is sometimes found "out of target" => end at end - 1
iVelPeaks = unique(iVelPeaks);              % to avoid repetitions if one peak is at 1 or end
iVelPeaks = iVelPeaks';                     % looks better in a struct

% Get min between peaks
iVelMin = [];
for i = 1:length(iVelPeaks)-1
    [TheMin, iMin] = min(TgVel(iVelPeaks(i) : iVelPeaks(i+1)));
    iVelMin(i) = iMin + iVelPeaks(i) - 1;
end

% store all peaks for verification plot
if NoFigVerificationPlot > 0
    iAllVelPeaks = iVelPeaks;
    iAllVelMin   = iVelMin;
end


%% Movement BEG is the last velocity min inside previous target
Distance2PreviousTarget = sqrt((X - P.PreviousTarget.X).^2 + (Y - P.PreviousTarget.Y).^2);
iFirstOutPreviousTarget = find(Distance2PreviousTarget  >= P.PreviousTarget.r, 1, 'first');
iLastVelMinInsideTarget = find(iVelMin < iFirstOutPreviousTarget, 1, 'last');
if ~isempty(iLastVelMinInsideTarget)
    iVelMin = iVelMin(iLastVelMinInsideTarget:end);
else
    warning('Movement BEG is out previous target...')
end
iVelPeaks = iVelPeaks (find( iVelPeaks >= iVelMin(1)));

%% Sometines, the last P.Trajectory.I is false... whihc is impossible
% Reason : this is not verifed in the display program. But "this should not
% happen, or very rarely" says the programmer ;-)
if P.Trajectory.I(end) == false
    P.Trajectory.I(end-1:end) = true; % indeed, it happens for 2 last (once)
end

%% Movement END is the firt velocity minimun in the validation period
% Validation = the (last) period when cursor is inside  target
% Step 1 : get the last period where the cursor is inside target
iBegValid = find(P.Trajectory.I == 0, 1, 'last') + 1;   % last outside + 1
iEndValid = find(P.Trajectory.I == 1, 1, 'last');       % last inside
iValidation = iBegValid : iEndValid;
% Step 2 : get the first velocity minimum inside the validation period
iLastValidVelMin = find(iVelMin > iBegValid, 1, 'first');
if ~isempty(iLastValidVelMin)
    iVelMin = iVelMin(1:iLastValidVelMin);
else
    warning('Movement END is out of the validation circle...');
    disp(P.Protocol)
end

% Step 3 : suppress the peaks after
iValidVelPeak = find(iVelPeaks < iVelMin(end));
iVelPeaks = iVelPeaks(iValidVelPeak);

%% Set the movement time
iBegMT = iVelMin(1);       % first velocity minimum before getting out of the previous target
iEndMT = iVelMin(end);     % first velocity minimum after entering the target validation time
P.MovementTime = P.Trajectory.T(iEndMT) - P.Trajectory.T(iBegMT) ;

% %% cancel too low peaks
% BadPeak = find(TgVel(iVelPeaks) < 5);
% iVelMin   (BadPeak) = [];
% iVelPeaks (BadPeak) = [];

%% store in output
P.TgVel      = TgVel;
P.iVelPeaks  = iVelPeaks;
P.iVelMin    = iVelMin;
P.NbVelPeaks = length(iVelPeaks);

%% Verificaiton plot
if NoFigVerificationPlot > 0
    
    figure (NoFigVerificationPlot); clf; hold on
    T = P.Trajectory.T;
    X = P.Trajectory.X;
    Y = P.Trajectory.Y;
    
    % get when the cursor is inside the target (an nan for the rest)
    iOutTarget = find(P.Trajectory.I == 0);
    VelIn = TgVel;
    VelIn(iOutTarget) = nan; % nan ar not plotted
    
    % plot tangential velocity and highligh inside the target
    plot(T, TgVel, '-b')
    plot(T, VelIn, '-b', 'linewidth', 3)
    
    % plot peaks
    plot(T(iAllVelPeaks), TgVel(iAllVelPeaks), 'sqr')
    plot(T(iAllVelMin),   TgVel(iAllVelMin),   'sqc')
    plot(T(iVelPeaks), TgVel(iVelPeaks), 'sqr', 'MarkerFaceColor','r')
    plot(T(iVelMin),   TgVel(iVelMin),   'sqc', 'MarkerFaceColor','b')
    
    % plot MT limits
    plot([T(iBegMT), T(iBegMT)], [0, max(TgVel)], '-r') % Beg MT
    plot([T(iEndMT), T(iEndMT)], [0, max(TgVel)], '-r') % End MT
    
    legend('OutsideTarget', 'InsideTarget', 'Cancelled peak', 'Cancelled Min', 'VelPeak', 'VelMin')
    
    % plot the trajectory and higlight MT limits
    PlotPointing(P, NoFigVerificationPlot+1);
    %     plot(X(iBegMT), Y(iBegMT), 'sqr', 'MarkerFaceColor','r')
    %     plot(X(iEndMT), Y(iEndMT), 'sqr', 'MarkerFaceColor','r')
    
    
    plot(X(iAllVelPeaks), Y(iAllVelPeaks), 'sqr')
    plot(X(iAllVelMin),   Y(iAllVelMin),   'sqc')
    plot(X(iVelPeaks), Y(iVelPeaks), 'sqr', 'MarkerFaceColor','r')
    plot(X(iVelMin),   Y(iVelMin),   'sqc', 'MarkerFaceColor','b')
    
end

end
