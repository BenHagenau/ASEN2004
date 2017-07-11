%given velocty output power required at specific elevation and plot power
%curve

%givens
%% 6.4 and 6.6
clear all
clc

w = 3000;
s = 181;
cd0 = .0027;
AR = 6.2;
e = .91;
np = .83;

%available power
Pa = np*345;

for j = 1:2 %change between altitude densities
    if j == 1;
        rho = .002377;
        el = 'zero';
    elseif j == 2
        rho = 1.648*10^-3;
        el = '1200';
    end
    k = 1;
    for i = 100:10:1000
        v(k) = i;
        %dynamic pressure
        q = .5*rho*v(k)^2;
        %coefficient of lift
        cl = w/(q*s);
        %coefficient of drag
        cd = cd0 + (cl^2)/(pi*AR*e);
        %Thrust required
        Tr = w/(cl/cd);
        %Power required
        Pr(k) = Tr*v(k)/550;
    %determine max excess power
    excessPower(k) = Pa - Pr(k);
            k = k+1;
    end
    %store data for reference
    data{j} = [v' Pr'];
    fprintf('Max Excess Power at %s ft: %3.3f \n',el, max(excessPower));
end


%plot data
data1 = data{1};
figure
hold on
plot(data1(:,1),data1(:,2),'k')
plot([0 1000],[Pa Pa],'b')
title('6.4: Power curve at sea level')
xlabel('Velocity, ft/s')
ylabel('Power, hp')
legend('Power at sea level','Power available')
hold off

data2 = data{2};
figure
hold on
plot(data2(:,1),data2(:,2),'k')
plot(data1(:,1),data1(:,2),'r.')
plot([0 1000],[Pa Pa])
legend('Power at 12,000 ft','Power at sea level','Power available')
title('6.4: Power curve at 12,000 ft')
xlabel('Velocity, ft/s')
ylabel('Power, hp')
hold off

%% 6.3 and 6.5
clear all
clc

s = 47;
AR = 6.5;
e = .87;
w = 103047;
cd0 = .032;
Ta = 80596;
%define iterater
k = 1;
for j = 1:2 %2 different elevations
    if j == 1
        rho = 1.225;
    elseif j == 2
        rho = .73643 ;
    end
    for i = 100:10:1000
        %velocity
        v(k) = i;
        %dynamic pressure
        q = (1/2)*rho*v(k)^2;
        %coefficient of lift
        cl = w/(q*s);
        %coefficient of drag
        cd = cd0 + cl^2/(e*AR*pi);
        %Thrust available
        Tr = w/(cl/cd);
        %Power available
        Pr(k) = Tr*v(k);
        %power available 
        Pa(k) = 80596*v(k);
        %iterate
        k = k+1;
    end
    %store data for reference
    data{j} = [v' Pr' Pa'];
end

%plot data
data1 = data{1};
figure
hold on
plot(data1(:,1),data1(:,2),'k')
plot(v(1:length(data1(:,3))),data1(:,3),'b')
title('6.3: Power curve at sea level')
xlabel('Velocity, m/s')
ylabel('Power, hp')
legend('Power at sea level','Power available')
xlim([100 500])
hold off

data2 = data{2};
data2 = data2(length(data2)/2+1:end,:);
figure
hold on
plot(data2(:,1),data2(:,2),'k')
plot(data1(:,1),data1(:,2),'r.')
plot(v(1:length(data2)),data2(:,3))
legend('Power at 5,000 meters','Power at sea level','Power available')
title('6.3: power curve at 5,000 meters')
xlabel('Velocity, m/s')
ylabel('Power, W')
xlim([100 500])
hold off

%determine max rate of climb
for i = 1:length(data1(:,2))
    exc = abs(data1(i,2) - data1(i,3));
end
maxExc = max(exc);
maxRC = maxExc/w;












