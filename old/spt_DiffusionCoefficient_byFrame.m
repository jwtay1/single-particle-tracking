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
% --No longer used--
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

    %Compute lag time using frame data
    


    trackData(iTrack).matLagTimes = matLagTimes;
    trackData(iTrack).matSD = matSD;

    %Remove Nans
    trackData(iTrack).matLagTimesVec = matLagTimes(~isnan(matLagTimes));
    trackData(iTrack).matSDVec = matSD(~isnan(matSD));

end


%% Compute ensemble averages

%Concatenate data from tracks
allSD = cat(1, trackData.matSDVec);
allLagTime = cat(1, trackData.matLagTimesVec);


%%

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
ylabel('Mean squared displacement (\mum^2)')



