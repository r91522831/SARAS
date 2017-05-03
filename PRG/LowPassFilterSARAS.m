function [ Data ] = LowPassFilterSARAS( Data )
%LowPassFilterSARAS Low pass filtering of SARAS data
%   Detailed explanation goes here

SamplingFreq = 1 ./ Data.SamplingPeriod; 

% low pass filtering at 10 or 15 Hz
CutFreq = 15;                   % 10 Hz + dual pass = 8.4 Hz
Wn = CutFreq ./ (2 * SamplingFreq);
[fb,fa]=butter(2,Wn,'low');

% kee the orignal one... 
Data.X_Cursor_Raw = Data.X_Cursor; 
Data.Y_Cursor_Raw = Data.Y_Cursor; 

% use original name for filtered data
Data.X_Cursor   = filtfilt(fb,fa, Data.X_Cursor);
Data.Y_Cursor   = filtfilt(fb,fa, Data.Y_Cursor);

% inform 
Data.LowPassFilered = CutFreq; 


end

