%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%   Author[s]: Benjamin Hagenau, Caleb Inglis                             %
%   Date Created: 02/01/17                                                %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%   Purpose: Reads in / extracts necessary data from Experimental Lab 1   %
%   data for the LOADED F-16. Data is averaged from all groups' results   %
%   at each angle of attack.                                              %
%                                                                         %
%   @input: Data matrices for each model aircraft
%   @output: Data matrices for aircraft at 0 and 25 m/s airspeed,         %
%   air density (averaged)                                                %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [q,DATA,STATS] = LiftDrag(F16_clean,F16_loaded,M787)
%location,AoA,cD,cL,cM,cL_std,cD_std,cM_std,AoA_std
%This functions calculates the lift and drag for each configuration and
%each angle of attack based on the sting measurements.

%preallocate
cLraw = zeros(3600,3);
cDraw = zeros(3600,3);
cMraw = zeros(3600,3);
q = zeros(3600,3);
AoAraw = zeros(3600,3);
cD_std = zeros(29,1);
cL_std = zeros(29,1);
cM_std = zeros(29,1);
AoA_std = zeros(29,1);
cD = zeros(29,1);
cL = zeros(29,1);
cM = zeros(29,1);
AoA = zeros(29,1);
location = cell(3,29);
mat = [];

for i = 1:3
    if i == 1
        data = F16_clean;
        cord = 15.03/48;
        s = .0121;
        d = .0144;
        Title = sprintf('F16 Clean Model');
    elseif i == 2
        data = F16_loaded;
        cord = 15.03/48;
        s = .0121;
        d = .0155;
        Title = sprintf('F16 Loaded Model');
    elseif i == 3
       data = M787; 
       cord = 56.72/225;
       s = .0064;
       d = .063;
       Title = sprintf('787 Model');
    end
    for j = 1:length(data)
        q(j,i) = (1/2)*data(j,1)*data(j,2)^2;
        cDraw(j,i) = (data(j,4)*sin(data(j,3)*(pi/180)) + data(j,5)*cos(data(j,3)*(pi/180)))/...
            (q(j,i)*s);
        cLraw(j,i) = (data(j,4)*cos(data(j,3)*(pi/180)) - data(j,5)*sin(data(j,3)*(pi/180)))/...
            (q(j,i)*s);
        cMraw(j,i) = (data(j,6) - d*data(j,4))/(q(j,i)*s*cord);
    end
    AoAraw(:,i) = data(:,3);
    
%AVERAGE DATA
%determine locations of each angle of attack
    for a = -8:20
        for m = 1:length(AoAraw)
            if AoAraw(m,i) > a - 0.3 && AoAraw(m,i) < a + 0.3...
                    && cDraw(m,i) ~= -inf && cDraw(m,i) ~= inf...
                    && cLraw(m,i) ~= -inf && cLraw(m,i) ~= inf...
                    && cMraw(m,i) ~= -inf && cMraw(m,i) ~= inf
                 mat = [mat m];
            end
        end
        location{i,a+9} = mat;
        mat = [];
    end

%average rows of locations in the cD, cM, and cL calculations and determine
%standard deviation. and uncertainty in angle of attack.
    for a = 1:29
        ind = location{i,a};
        cD_std(a,i) = std(cDraw(ind,i));
        cL_std(a,i) = std(cLraw(ind,i));
        cM_std(a,i) = std(cMraw(ind,i));
        AoA_std(a,i) = std(AoAraw(ind,i));
        cD(a,i) = mean(cDraw(ind,i));
        cL(a,i) = mean(cLraw(ind,i));
        cM(a,i) = mean(cMraw(ind,i));
        AoA(a,i) = mean(AoAraw(ind,i));
    end
  
%PLOT
figure
%AoA vs cL
subplot(2,2,1)
errorbar(AoA(:,i),cL(:,i),cL_std(:,1),'b');
hold on
herrorbar(AoA(:,i),cL(:,i),AoA_std(:,i),'b');
plot(AoA(:,i),cL(:,i),'k')
xlabel('Angle of Attack, degrees')
ylabel('Coefficient of Lift')
title('Angle of Attack v.s. Coefficient of Lift')
hold off

%AoA vs cD
subplot(2,2,2)
errorbar(AoA(:,i),cD(:,i),cD_std(:,i),'b');
hold on
herrorbar(AoA(:,i),cD(:,i),AoA_std(:,i),'b');
plot(AoA(:,i),cD(:,i),'k')
xlabel('Angle of Attack, degrees')
ylabel('Coefficient of Drag')
title('Angle of Attack v.s. Coefficient of Drag')
hold off

%AoA vs cM
subplot(2,2,3)
errorbar(AoA(:,i),cM(:,i),cM_std(:,i),'b');
hold on
herrorbar(AoA(:,i),cM(:,i),AoA_std(:,i),'b');
plot(AoA(:,i),cM(:,i),'k')
xlabel('Angle of Attack, degrees')
ylabel('Coefficient of Pitching Moment')
title('Angle of Attack v.s. Coefficient of Pitching Moment')
hold off

%cD vs cL
subplot(2,2,4)
errorbar(cD(:,i),cL(:,i),cL_std(:,i),'b');
hold on
herrorbar(cD(:,i),cL(:,i),cD_std(:,i),'b');
plot(cD(:,i),cL(:,i),'k')
xlabel('Coefficient of Drag')
ylabel('Coefficient of Lift')
title('Drag Polar')
hold off

annotation('textbox', [0 0.9 1 0.1], ...
    'String', Title, ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center')
end

DATA = struct('AoA',AoA,'cD',cD,'cL',cL,'cM',cM);
STATS = struct2table(struct('cD',mean(cD_std),'cL',mean(cL_std),'cM',mean(cM_std),'AoA',mean(AoA_std)));
end

