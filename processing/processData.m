clearvars
clc

trackData = readDataFromXLS(...
    '../../data/spt data worksheet D Histogram.xlsx', ...
    'MSC18', 21);

%Filter immobile particles
minDisplacement = 50.1032;

delInd = [];
for iTrack = 1:numel(trackData)
    
    displacement = sqrt((trackData(iTrack).x(1) - trackData(iTrack).x(end))^2 + ...
        (trackData(iTrack).y(1) - trackData(iTrack).y(end))^2 + ...
        (trackData(iTrack).z(1) - trackData(iTrack).z(end))^2);

    if displacement < (minDisplacement * 1e-3)
        delInd(end + 1) = iTrack;
    end

end
trackData(delInd) = [];

[timeLag, squareDistances] = calculateSDandLagTime(trackData);

%Find unique time lags in the data
lt = unique(timeLag);

%Compute the MSD
for ii = 1:numel(lt)
    MSD(ii) = mean(squareDistances(timeLag == lt(ii)));
    numTracks(ii) = nnz(timeLag == lt(ii));
end

%Fit MSD data to a line
fitData = fit(lt(1:4)', MSD(1:4)', 'poly1');

%Compute the diffusion coefficient
D = (1/(2 * 2)) * fitData.p1;

%Plots
figure(1)
yyaxis left
plot(lt, MSD)
xlabel('Lag Time (s)')
ylabel('MSD')
yyaxis right
plot(lt, numTracks)
ylabel('Number of tracks')

figure(2);
histogram(squareDistances(timeLag == lt(1)), 500)

