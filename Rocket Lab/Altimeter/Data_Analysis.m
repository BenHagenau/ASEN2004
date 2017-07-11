%Author: Benjamin Hagenau 
%Created: 4/26/17

%This function does analysis on altimeter data and video collected during launch.

function [X,Y,max_alt] = Data_Analysis
%% Process altimeter data 
altdata = load('group13proc');
time = altdata(:,1);
pressure = altdata(:,2)*100; %[mbar to Pa]
alt = atmospalt(pressure)*3.28084; %[m to ft]

%zero altitude
alt0 = mean(alt(find(time < 9)));
alt = alt - alt0;

%trim data
t0 = find(time == 9.364); tf = find(time == 13.304);
alt = alt(t0:tf); time = time(t0:tf);
time = time - time(1); %zero time

%plot 
figure
plot(time,alt)
title('Altimeter Height')
ylabel('Height, [ft]')
xlabel('Time, [s]')
ylim([0 100])

%determine max altitude
max_alt = max(alt);
%write outputs
fprintf('Altimeter: max height: %.3f\n',max(alt))
fprintf('Altimeter: flight time: %.3f\n',max(time))

%% Process video data
load('rocket lab video data.mat');
X = data.x; Y = data.y;

%convert pixels to feet
scale = [X(end-1:end),Y(end-1:end)]; 
factor = (scale(4) - scale(3))/8; %[pixels/ft]
X = X/factor; Y = Y/factor;

X(end-2:end) = []; %eliminate referrence pole points
Y(end-2:end) = [];

%zero graph axes
X = abs(X - X(1));
Y = abs(Y - Y(1));

%plot
figure
plot(X,Y)
title('Video Trajectory')
xlabel('Down Range Distance, [ft]')
ylabel('Hight, [ft]')

%write outputs
fprintf('Video: max height: %.3f\n',max(Y))
fprintf('Video: downrange distance: %.3f\n',max(X))
