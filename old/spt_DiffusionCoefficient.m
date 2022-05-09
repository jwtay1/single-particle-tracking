clearvars

%filename = '6 10 2021 PALM 12 SPT 0nm 5plus trax.xlsx';
filename = 'spt 1s dark interval data worksheet.xlsx';

% TimeInfo = readmatrix(filename, 'Range', 'B22:B444');
% TrackCoordinates = readmatrix(filename,'Range','C22:E444');
% TrackInfo = readmatrix(filename, 'Range','L22:M444');

FrameInfo = readmatrix(filename,'Sheet','MSC18 1s 2.0','Range','A22:A2783');

TimeInfo = readmatrix(filename,'Sheet','MSC18 1s 2.0','Range','B22:B2783');
TrackCoordinates = readmatrix(filename,'Sheet','MSC18 1s 2.0','Range','C22:E2783');
TrackInfo = readmatrix(filename,'Sheet','MSC18 1s 2.0','Range','L22:M2783');

x=TrackCoordinates(:,1);
y=TrackCoordinates(:,2);
z=TrackCoordinates(:,3);

trackNumbers = TrackInfo(:, 1);

% --No longer used--
% %Constants for diffusion calculation
% q = 4; %Twice the number of diffusable dimensions
% dT = 0.07; %70 ms per frame

%Final track data is stored in a structure
trackData = struct;

for iTrack = 1:max(TrackInfo(:,1))

    rowIdxsCurrTrack = trackNumbers == iTrack;

    %Particle coordinates in microns
    currX = x(rowIdxsCurrTrack) * 1e-3;
    currY = y(rowIdxsCurrTrack) * 1e-3;
    currZ = z(rowIdxsCurrTrack) * 1e-3;

    trackData(iTrack).Pos = [currX currY currZ];
    trackData(iTrack).Timestamps = TimeInfo(rowIdxsCurrTrack);
    trackData(iTrack).Frames = FrameInfo(rowIdxsCurrTrack);

    %Only calculate if number of recorded timepoints >= 2
    if nnz(rowIdxsCurrTrack) < 2
        continue
    end

    %Compute the change in position at each recorded timepoint
    dX = diff(currX);
    dY = diff(currY);
    dZ = diff(currZ);

    dT = diff(TimeInfo(rowIdxsCurrTrack));  %in seconds

    %Calculate lag time
    lagTime = cumsum(dT);

    %For each timepoint, compute the squared displacement (SD)
    SD = cumsum(dX.^2 + dY.^2 + dZ.^2);

    trackData(iTrack).SD = SD;
    trackData(iTrack).LagTime = lagTime;

    %     N = numel(currX);
    %
    %     MSD(iTrack) = (1/(N-1)) * sum(dX.^2 + dY.^2 + dZ.^2);
    %
    %     %Compute diffusion coefficient (in microns^2/sec)
    %     D(iTrack) = MSD(iTrack)/(q * (N-1) * dT);

end

%% Compute ensemble averages

%Collect all data
allSD = cat(1, trackData.SD);
allLagTime = cat(1, trackData.LagTime);

%Filter invalid particles
filtIdx = allSD > 10;
allSD(filtIdx) = [];
allLagTime(filtIdx) = [];

%Round lag time to the nearest thousandth to avoid inaccuracies
allLagTime = round(allLagTime, 5);

lt = unique(allLagTime);

MSD = zeros(1, numel(lt));
stdevSD = zeros(1, numel(lt));
SEM = zeros(1, numel(lt));

for iT = 1:numel(lt)

    currSamples = allSD(allLagTime == lt(iT));

    MSD(iT) = mean(currSamples);
    stdevSD(iT) = std(currSamples);

    SEM(iT) = std(currSamples)/(sqrt(numel(currSamples)));

end


%% Plotting

scatter(lt, MSD)
hold on
errorbar(lt, MSD, SEM, 'LineStyle', 'none')
hold off

xlabel('Lag time (s)')
ylabel('Squared displacement (\mum^2)')


%% Compare diffusion constants

fitData = fit(lt(1:4), MSD(1:4)', 'poly1');

slope = fitData.p1;
diffusion = slope / (2 * 2);

diffCoeff = [];
for iTrack = 1:numel(trackData)

    if numel(trackData(iTrack).SD) >= 4

        %Might need to only include 0.28 lag time

        diffCoeff(iTrack) = trackData(iTrack).SD(4) / (trackData(iTrack).LagTime(4) * 2 * 2);

    else

        diffCoeff(iTrack) = NaN;
    end

end

histogram(diffCoeff, 'BinWidth', 0.005)

%%
%Make a plot of each track vs frame.

for ii = 1:numel(trackData)

    if numel(trackData(ii).SD) > 1

        plot(trackData(ii).Frames(1:end - 1), trackData(ii).SD)
        hold on

    end

end
hold off

figure;
for ii = 1:numel(trackData)

    if numel(trackData(ii).SD) > 1

        plot(trackData(ii).LagTime, trackData(ii).SD)
        hold on

    end

end
hold off


% scatter(MSD, lt)
% xlabel('Lag time (s)')
% ylabel('Squared displacement (\mum^2)')


% %%
% %Filter particles that are too fast to be real
% D(D > 0.5) = [];
%
% histogram(D, 'BinWidth', 0.0005)
%



