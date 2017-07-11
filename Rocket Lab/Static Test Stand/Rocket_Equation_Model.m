close all
clear all
clc
%% Import and manipulate the data
[DATA] = ReadIsp;
% Convert the data to newtons
fields = fieldnames(DATA);
for i = 1:34
    for j = 1:12000
        DATA.(fields{i})(j,3) = DATA.(fields{i})(j,3) * 4.44822;
    end
end
% Determine where the thrust phase begins and get rid of all the data
% before that point
for i = 1:34
    for j = 1:length(DATA.(fields{i}))
        if  DATA.(fields{i})(j,3) > 0.5
            DATA.(fields{i})(1:j-1,:) = [];
            break
        end
    end 
end
% % Determine the minimum value the thrust reaches so that all the data after
% % it can be removed
DATA.g1(477:end,:) = [];
DATA.g2(482:end,:) = [];
DATA.g3(2307:end,:) = [];
DATA.g4(548:end,:) = [];
DATA.g5(515:end,:) = [];
DATA.g6(576:end,:) = [];
DATA.g7(555:end,:) = [];
DATA.g8(500:end,:) = [];
DATA.g9(595:end,:) = [];
DATA.g10(487:end,:) = [];
DATA.g11(470:end,:) = [];
DATA.g12(578:end,:) = [];
DATA.g13(565:end,:) = [];
DATA.g14(485:end,:) = [];
DATA.g15(446:end,:) = [];
DATA.g16(700:end,:) = [];
DATA.g17(468:end,:) = [];
DATA.g18(734:end,:) = [];
DATA.g19(468:end,:) = [];
DATA.g20(565:end,:) = [];
DATA.g21(519:end,:) = [];
DATA.g22(792:end,:) = [];
DATA.g23(708:end,:) = [];
DATA.g24(732:end,:) = [];
DATA.g25(517:end,:) = [];
DATA.g26(444:end,:) = [];
DATA.g27(582:end,:) = [];
DATA.g28(623:end,:) = [];
DATA.g29(508:end,:) = [];
DATA.g30(551:end,:) = [];
DATA.g31(600:end,:) = [];
DATA.g32(527:end,:) = [];
DATA.g33(551:end,:) = [];
DATA.g34(694:end,:) = [];

%% Plot the trust data
% Define a time vector
for i = 1:34
    times = sprintf('t%d',i);
    time.(times) = linspace(0,(7 / 12000 * length(DATA.(fields{i}))),length(DATA.(fields{i}))); % Seconds
    % Plot the trust data
    figure (i)
    hold on
    plot(time.(times),DATA.(fields{i})(:,3));
end

% % Plot a line from the initial thrust value to the final
fields2 = fieldnames(time);
for i = 1:34
    lines = sprintf('l%d',i); 
    slope = (DATA.(fields{i})(end,3) - DATA.(fields{i})(1,3)) / (time.(fields2{i})(end) - time.(fields2{i})(1));
    line.(lines) = slope .* time.(fields2{i}) + DATA.(fields{i})(1,3);
    figure (i)
    plot(time.(fields2{i}),line.(lines));
    xlabel('Time [s]');
    ylabel('Thrust [N]');
    title('Thrust Produced by the Rocket over Time');
    legend('Trust Data','Lower Limit');
end

%% Calculate the Isp, Peak Thrust, and Avg Thrust
g = 9.80665; % Gravity [m/s]
m_prop = 1000; % mass of the water [kg]
m_dry = 79; % mass of the empty bottle [kg]
Isp = zeros(1,34);
PeakThrust = zeros(1,34);
AvgThrust = zeros(1,34);
fields3 = fieldnames(line);
for i = 1:34
    Isp(i) = (trapz((DATA.(fields{i})(:,3)' - line.(fields3{i}))) ) / (g * m_prop);
    PeakThrust(i) = max(DATA.(fields{i})(:,3)' - line.(fields3{i}));
end
AvgPeakThrust = sum(PeakThrust) / length(PeakThrust);
STDAvgPeakThrust = std(PeakThrust);
%% Calculate total time and avg time
TotalTime = zeros(1,34);
for i = 1:34
    TotalTime(i) = time.(fields2{i})(end);
end
AvgTime = sum(TotalTime) / length(TotalTime);
STDAvgTime = std(TotalTime);


%% Graph SEM versus N
SEM = zeros(1,33);
N = 2:34;
for i = 1:33
    SEM(i) = std(Isp(1:i+1)) / sqrt(i+1);
end
SEMIsp = std(Isp) / sqrt(34);
figure (35)
plot(N,SEM,'.');
xlabel('N, Number of Data Points Used');
ylabel('SEM, Standrad Error of the Mean');
title('SEM vs. N');
    
%% Determine N for 0.1 s confidence
X = 0.1;
s = std(Isp);
z95 = 1.96;
z975 = 2.24;
z99 = 2.58;

N_01_95 = (z95 * s / X)^2;
N_01_975 = (z975 * s / X)^2;
N_01_99 = (z99 * s / X)^2;

%% Determine N for 0.01 s confidence
X = 0.01;

N_001_95= (z95 * s / X)^2;
N_001_975 = (z975 * s / X)^2;
N_001_99 = (z99 * s / X)^2;



