function [ output_args ] = PlotPointing( P, FigNumber )
%PlotPointing Plot a pointing given in P
%Input :
%   P : a pointing structure given by GetPointing
%
%Output :
%   Plot in a figure

if nargin < 2
    FigNumber = 1;
end

figure(FigNumber); clf; hold on

% set the scaling identical along X and Y (to look good)
axis equal

% plot the Target (as visible by the particpant)
LeftX    = P.Target.X - P.Target.r;
BottomY  = P.Target.Y - P.Target.r;
Diameter = 2 * P.Target.r;
rectangle('Position',[ LeftX, BottomY, Diameter, Diameter ] ,'Curvature',[1 1], 'EdgeColor', 'm');


% plot the Tolerance (Target visible - cursor size)
% Because of integer approximations, add half a pixel to tolerance
global CURSOR_RADIUS
ToleranceRadius = 0.5 + P.Target.r - CURSOR_RADIUS;
LeftX    = P.Target.X - ToleranceRadius;
BottomY  = P.Target.Y - ToleranceRadius;
Diameter = 2 * ToleranceRadius ;
rectangle('Position',[ LeftX, BottomY, Diameter, Diameter ] ,'Curvature',[1 1], 'FaceColor', 'y');


% plot the Previous target with rectangle('Position', [x y w h])
LeftX    = P.PreviousTarget.X - P.PreviousTarget.r;
BottomY  = P.PreviousTarget.Y - P.PreviousTarget.r;
Diameter = 2 * P.PreviousTarget.r;
rectangle('Position',[ LeftX, BottomY, Diameter, Diameter ] ,'Curvature',[1 1], 'EdgeColor', 'black');

%legend('Start', 'Target')

% plot the trajectory
plot(P.Trajectory.X, P.Trajectory.Y)
xlabel('X (pixel)')
ylabel('Y (pixel)')
title('trajectory')

iIn = find(P.Trajectory.I);
plot(P.Trajectory.X(iIn), P.Trajectory.Y(iIn), '*g')


% plot the limit values (to ensure the scale is identical everywhere)
if P.Protocol.Hand == 'L'
    MinX = -1500;
    MaxX = 0;
else
    MinX = 0;
    MaxX = 1500;
end

plot(MinX, 0)
plot(MaxX, -900)

% spit out some information in the console
if true
    txt = sprintf('%3d : Target (%d,%d ±%0.2f) to (%d,%d ±%0.2f), ID %0.2f, D %0.2f, W %0.2f', ...
        P.Number,...
        P.PreviousTarget.X, P.PreviousTarget.Y, P.PreviousTarget.r, ...
        P.Target.X, P.Target.Y, P.Target.r, ...
        P.Fitts.ID, P.Fitts.D, P.Fitts.W);
    disp(txt)
    
    txt = sprintf('%3d : Protocol %s %s %s, %s %s %s %s, %s', ...
        P.Number,...
        P.Protocol.GROUP, P.Protocol.SUBJ, P.Protocol.TRIAL, ...
        P.Protocol.ORI, P.Protocol.DIR, P.Protocol.ID, P.Protocol.REP, ...
        P.Protocol.Angle );
    disp(txt)
end
end

