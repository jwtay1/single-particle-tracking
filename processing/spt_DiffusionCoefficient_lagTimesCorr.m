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
%%
% %Constants for diffusion calculation
% q = 4; %Twice the number of diffusable dimensions
% dT = 0.07; %70 ms per frame

%Final track data is stored in a structure
trackData = struct;

for iTrack = 1:max(TrackInfo(:,1))

    %Read current track information
    rowIdxsCurrTrack = trackNumbers == iTrack;

    %Particle coordinates in microns
    currX = x(rowIdxsCurrTrack) * 1e-3;
    currY = y(rowIdxsCurrTrack) * 1e-3;
    currZ = z(rowIdxsCurrTrack) * 1e-3;

    currTime = TimeInfo(rowIdxsCurrTrack);

    trackData(iTrack).Pos = [currX currY currZ];
    trackData(iTrack).Timestamps = currTime;
    trackData(iTrack).Frames = FrameInfo(rowIdxsCurrTrack);

    %Only calculate if number of recorded timepoints >= 2
    if nnz(rowIdxsCurrTrack) < 2
        continue
    end

    %Compute a matrix of square displacements and time lags for each pair
    %of positions
    matLagTimes = NaN(nnz(rowIdxsCurrTrack));
    matSD = NaN(nnz(rowIdxsCurrTrack));

    for iData = 1:numel(currTime)

        for jj = (iData + 1):numel(currTime)

            matLagTimes(iData, jj) = currTime(jj) - currTime(iData);
            matSD(iData, jj) = ...
                (currX(iData) - currX(jj)).^2 + ...
                (currY(iData) - currY(jj)).^2 + ...
                (currZ(iData) - currZ(jj)).^2;

        end

    end

    trackData(iTrack).matLagTimes = matLagTimes;
    trackData(iTrack).matSD = matSD;

    %Remove Nans and vectorize
    trackData(iTrack).matLagTimesVec = round(matLagTimes(~isnan(matLagTimes)), 5);
    trackData(iTrack).matSDVec = matSD(~isnan(matSD));

    %Compute the MSD for each lag time
    lagTimes = unique(trackData(iTrack).matLagTimesVec);

    trackData(iTrack).lagTimes = lagTimes;

    MSD = zeros(1, numel(lagTimes));
    for iT = 1:numel(lagTimes)
            
        MSD(iT) = mean(trackData(iTrack).matSDVec(trackData(iTrack).matLagTimesVec == lagTimes(iT)));

    end

    trackData(iTrack).MSD = MSD';

end


%% Compute ensemble averages

%Concatenate data from tracks
allMSD = cat(1, trackData.MSD);
allLagTime = cat(1, trackData.lagTimes);

lt = unique(allLagTime);

for ii = 1:numel(lt)

    medianMSD(ii) = mean(allMSD(allLagTime == lt(ii)));

end

plot(lt, medianMSD * 1000)


%% Plotting

scatter(allLagTime, allMSD)
% hold on
% errorbar(lt, MSD, SEM, 'LineStyle', 'none')
% hold off

xlabel('Lag time (s)')
ylabel('Mean squared displacement (\mum^2)')
