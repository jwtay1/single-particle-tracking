
filename = 'spt data worksheet D Histogram.xlsx';

TimeInfo = readmatrix(filename,'Sheet','MSC18','Range','B22:B4162');
TrackCoordinates = readmatrix(filename,'Sheet','MSC18','Range','C22:E4162');
TrackInfo = readmatrix(filename,'Sheet','MSC18','Range','L22:M4162');

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

    %Only calculate if number of recorded timepoints >= 2
    if nnz(rowIdxsCurrTrack) < 2
        continue
    end

    %Particle coordinates in microns
    currX = x(rowIdxsCurrTrack) * 1e-3;
    currY = y(rowIdxsCurrTrack) * 1e-3;
    currZ = z(rowIdxsCurrTrack) * 1e-3;

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
%allSD(allSD>0.09)=[];

%Filter invalid particles
filtIdx = allSD > 10;
allSD(filtIdx) = [];
allLagTime(filtIdx) = [];

%Round lag time to the nearest thousandth to avoid inaccuracies
allLagTime = round(allLagTime, 5);

lt = unique(allLagTime);

MSD = zeros(1, numel(lt));

stdevSD = zeros(1, numel(lt));

for iT = 1:numel(lt)

    currSamples = allSD(allLagTime == lt(iT));

    MSD(iT) = mean(currSamples);
    stdevSD(iT) = std(currSamples);

    SEM(iT) = std(currSamples)/(sqrt(numel(currSamples)));

end

%store SINGLE SD values for single frame jumps (for complementary
%cumulative squared deviation calcs)
%SD_single=allSD(allLagTime == lt(1));

%individual D calculation from individual SD values plot
ratio=allSD./allLagTime
D_single=ratio./4
figure;
histogram(D_single);
%D_single(D_single>0.09)=[];
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

    if numel(trackData(iTrack).SD) >= 3

        diffCoeff(iTrack) = trackData(iTrack).SD(3) / (trackData(iTrack).LagTime(3) * 2 * 2);

    else

        diffCoeff(iTrack) = NaN;
    end

end
diffCoeff(diffCoeff>0.075)=[];

figure;
histogram(diffCoeff, 'BinWidth', 0.005)
xlabel('D (um^2/s)');
ylabel('Number of Tracks');

%Immobile after 4 frames
%Average Squared Localization Precision = ASLP
%ASLP=((13*0.001)^2+(27*0.001)^2+(40*0.001)^2)
%SD_4=(allSD(allLagTime == lt(4))./4;
%MSD_4=SD_4./4
%MSD_4_mobile=MSD_4(SD_4>ASLP);

% scatter(MSD, lt)
% xlabel('Lag time (s)')
% ylabel('Squared displacement (\mum^2)')


% %%
% %Filter particles that are too fast to be real
% D(D > 0.5) = [];
%
% histogram(D, 'BinWidth', 0.0005)
%

%Kruskal Wallis Test
%D=readmatrix(filename,'Sheet','Kruskal Wallis','Range','A1:A1878');
%name=readtable(filename,'Sheet','Kruskal Wallis','Range','B1:B1879');
%name=table2array(name);
%p=kruskalwallis(D,name);


