%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%   Author[s]: Benjamin Hagenau, Caleb Inglis                                %
%   Date Created: 02/15/17                                                %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%   Purpose: Uses data matrices for each model and calculates required    %
%   values from lab document, including: minimum landing speed, static    %
%   longitudinal stability at zero angle of attack, and static margin.    %
%   Additionally, computes minimum landing speed for full scale clean     %
%   F-16 and B787. Last, compares lift to drag ratios (with plot) and     %
%   longitudinal stability for each aircraft.                             %
%                                                                         %
%   @input: Data matrices per model and average air density               %
%   @output: Printed statements regarding the questions in the lab        %
%   objectives section as mentioned in purpose                            %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = analysis(DATA,rho)
global WF16_loaded WF16_clean W787

g = 9.80766;
C_F16 = 1.2;
C_787 = 1.3;
sF16 = .0121;
s787 = .0064;

%define Vstall equation
Vstall = @(C,W,S,clMAX,rho) C*sqrt((2*W)/(rho*S*clMAX));

%minimal landing speed (clean and dirty)
%determine cL max
%F16 CLEAN
cLMAX = max(DATA.cL(:,1));
Vland(1,1) = Vstall(C_F16,WF16_clean,sF16,cLMAX,rho);
fprintf('Cl max F16 Clean: %3.3f \n',cLMAX)


%F16 DIRTY
cLMAX = max(DATA.cL(:,2));
fprintf('Cl max F16 Loaded: %3.3f \n',cLMAX)
Vland(1,2) = Vstall(C_F16,WF16_loaded,sF16,cLMAX,rho);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%minimum landing speed for full scale F16 clean
cLMAX = max(DATA.cL(:,1));
Wfull = 133446.6; %[N]
rhoB = 0.977853; %[kg/m^3]
Vland(2,1) = Vstall(C_F16,Wfull,sF16*48^2,cLMAX,rhoB);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%static longitudanal stability at AoA = 0 and, static margin F16 clean
dcMdAoA = (DATA.cM(10,1) - DATA.cM(8,1))/(DATA.AoA(10,1) - DATA.AoA(8,1));
dcLdAoA = (DATA.cL(10,1) - DATA.cL(8,1))/(DATA.AoA(10,1) - DATA.AoA(8,1));
staticMargin(1) = -dcMdAoA/dcLdAoA;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%minimum landing speed for 787 modle
cLMAX = max(DATA.cL(:,3));
fprintf('Cl max 787: %3.3f \n\n',cLMAX)
Vland(1,3) = Vstall(C_787,W787,s787,cLMAX,rho);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%minimum landing speed 787 full scale
WFull = 1601359.8; %[N]
Vland(2,3) = Vstall(C_787,WFull,s787*225^2,cLMAX,rhoB);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%static longitudinal at AoA = 0 and static margin 787
dcMdAoA = (DATA.cM(10,3) - DATA.cM(8,3))/(DATA.AoA(10,3) - DATA.AoA(8,3));
dcLdAoA = (DATA.cL(10,3) - DATA.cL(8,3))/(DATA.AoA(10,3) - DATA.AoA(8,3));
staticMargin(2) = -dcMdAoA/dcLdAoA;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Lift to drag ratio comparison for all planes and configurations and output
%calculated values
F16LD = DATA.cL(:,1)/DATA.cD(:,1);
M787LD = DATA.cL(:,3)/DATA.cD(:,3);
figure
hold on
plot(DATA.AoA(:,1),F16LD)
plot(DATA.AoA(:,3),M787LD)
plot([-10 max(max(DATA.AoA))],[0 0],'k')
title('787 L/D vs F16 Clean L/D')
xlabel('Angle of Attack, degrees')
ylabel('L/D')
legend('F16','787','Location','Best')
hold off

fprintf('Minimum landing speed model F16 clean: %3.3f [m/s]\n',Vland(1,1))
fprintf('Minimum landing speed model F16 loaded: %3.3f [m/s]\n',Vland(1,2))
fprintf('Minimum landing speed model 787: %3.3f [m/s]\n\n',Vland(1,3))

fprintf('Minimum landing speed full scale F16 clean: %3.3f [m/s]\n',Vland(2,1))
fprintf('Minimum landing speed full scale 787: %3.3f [m/s]\n\n',Vland(2,3))

fprintf('Static Margin for F16 Clean: %3.3f\n',staticMargin(1))
fprintf('dcm F16 Clean: %3.3f\n',dcMdAoA)
fprintf('dcl F16 Clean: %3.3f\n\n',dcLdAoA)

fprintf('Static Margin for 787: %3.3f\n',staticMargin(2))
fprintf('dcm 787: %3.3f\n',dcMdAoA)
fprintf('dcl 787: %3.3f\n\n',dcLdAoA)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%which modle is most longitudinally stable
if staticMargin(1) > staticMargin(2)
    disp('F16 Clean has a higher static margin than the 787')
else
    disp('787 has a higher static margin than the F16 Clean')
end


