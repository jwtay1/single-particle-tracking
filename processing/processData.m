clearvars
clc

trackData = readDataFromXLS(...
    '../../data/spt 1s dark interval data worksheet.xlsx', ...
    'MSC18 1s 2.0', 21);

[timeLag, squareDistances] = calculateSDandLagTime(trackData);

%Find unique time lags in the data
lt = unique(timeLag);

%Compute the MSD
for ii = 1:numel(lt)
    MSD(ii) = mean(squareDistances(timeLag == lt(ii)));
end

%Fit MSD data to a line
fitData = fit(lt(1:4)', MSD(1:4)', 'poly1');

%Compute the diffusion coefficient
D = (1/(2 * 2)) * fitData.p1;