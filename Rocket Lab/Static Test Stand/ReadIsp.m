%Author: Ben Hagenau
%Created: 4/17/17

%PURPOSE: Read data for ASEN 2004 static test stand lab. 

function [DATA] = ReadIsp 

for t = [8 10 2]            %loop through lap times
% ------------------------------------    
    if t == 8
        p = 'AM';           %define AM or PM
        for g = 1:10        %loop through lab groups
            field = sprintf('g%d',g);
            DATA.(field) = load(sprintf('Group%d_%d%s_statictest1',g,t,p));
        end
    end
% ------------------------------------    
    if t == 10
        p = 'AM';
        for g = 11:22
            field = sprintf('g%d',g);
            DATA.(field) = load(sprintf('Group%d_%d%s_statictest1',g,t,p));
        end
    end
% ------------------------------------    
    if t == 2
        p = 'PM';
        for g = 23:34
            field = sprintf('g%d',g);
            DATA.(field) = load(sprintf('Group%d_%d%s_statictest1',g,t,p));
        end
    end
end
    