function [ output ] = Save2Results( fname, Txt2File )
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here


%% Build a unique file name (with time stamp)
global RES_PATH
[Path,Name,Ext] = fileparts(fname);
if isempty(Path) 
    Path = RES_PATH;
end
TimeStamp = datestr(clock, 30);      
Name = [Name '-' TimeStamp Ext];      %unique name identifier (I hope...)
fullname = fullfile(RES_PATH, fname);

%% Save the text into this file 
% file operations can fail, and I donot want wandering fid... 
try 
fid = fopen(fullname, 'w'); 

fprintf(fid, '%s', Txt2File); 

fclose(fid); 

output = true;

catch err
    if fid > 2      % success in fopen gives only fid higher than 2 
        fclose(fid); 
        rethrow(err); 
    end
    output = false;
end

