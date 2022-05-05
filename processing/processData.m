clearvars
clc

trackData = readDataFromXLS(...
    'D:\Projects\ALMC Tickets\TXXX-Upton\data\spt 1s dark interval data worksheet.xlsx', ...
    'MSC18 1s 2.0', 21);

%%

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