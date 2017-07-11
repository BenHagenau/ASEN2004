function [ C_drag ] = dragCoeff( filename )
%{
This function calculates the coefficient of drag on a given bottle rocket
using wind tunnel and sting balance data.


Created: 4/11/17 - Connor Ott
Last Modified:  4/11/17 - Connor Ott
%}
% C = 13.875 in (circumference measured for cross-sectional area)
A_b = pi * (0.0560832)^2 ; % m^2
data = csvread(filename,1,0);
[r, c] = size(data);
dataMean = zeros(5, c);
for i = 1:5
    dataMean(i,  :) = mean(data(20*(i-1)+1:20*i, :));
end

normalF = dataMean(:, 24);
axialF = dataMean(:, 25);
attack = dataMean(:, 23);
q_inf = dataMean(:, 7);


% Calculating lift and drag based on normal and axial forces.
drag = normalF .* sind(attack) + axialF .* cosd(attack);


% Calculating coefficient of drag.
C_drag = drag ./ (q_inf .* A_b);

end

