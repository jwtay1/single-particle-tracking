clearvars
clc

%diffCoeff = 

stepSize = 2;

numT = 100;

pos = zeros(numT + 1, 2);

for iT = 1:numT

    %Equal probability to diffuse in a given direction
    direction = rand(1) * 2 * pi;

    %Gaussian probability to move at step size L
    %stepSize = randn(1) 

    pos(iT + 1, :) = pos(iT, :) + [cos(direction), sin(direction)];

end

plot(pos(:, 1), pos(:, 2));
