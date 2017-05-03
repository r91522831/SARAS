function [ Data ] = TangentialVelocity( Data )
%TangentialVelocity Computes Tangential Velocity

X = Data.X_Cursor; 
Y = Data.Y_Cursor; 

% differentiation
dX = gradient(X, Data.SamplingPeriod);
dY = gradient(X, Data.SamplingPeriod);

% tengential velocity
Data.TgVel = sqrt(dX .* dX + dY .* dY);

end

