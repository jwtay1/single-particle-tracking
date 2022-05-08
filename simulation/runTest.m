clearvars
clc

simulateRandomWalk('test.xls')

%%
trackData = readDataFromXLS(...
    'test.xls', ...
    'sim data', 1);


[T, SD] = calculateSDandLagTime(trackData);

lagTimes = unique(T);

%Plot histogram of 1, 2, 3, 4 deltaT
for ii = 1:5

    histogram(SD(T == lagTimes(ii)), 'binWidth', 0.0001)
    hold on

end

hold off

%%

%Compute the MSD
for ii = 1:numel(lagTimes)

    MSD(ii) = mean(SD(T == lagTimes(ii)));

end

plot(lagTimes, MSD)

%Fit the MSD to calculate the diffusion coefficient
%MSD = 2nDt
fitData = fit(lagTimes(1:4)', MSD(1:4)', 'poly1');

D = fitData.p1, 


