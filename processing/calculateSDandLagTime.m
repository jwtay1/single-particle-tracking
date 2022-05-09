function [T, SD, dR] = calculateSDandLagTime(trackData)
%CALCULATESDANDLAGTIME  Calculate SD and lag times
%
%  [T, SD] = CALCULATESDANDLAGTIME returns the time lag T and square
%  distance SD as vectors.

T = [];
SD = [];
dR = [];

for iTrack = 1:numel(trackData)

    %Skip tracks if less than two frames of data
    if numel(trackData(iTrack).Frame) < 2
        continue;
    end

    %Recondition track data to fill in missing frames
    startFrame = trackData(iTrack).Frame(1);
    endFrame = trackData(iTrack).Frame(end);

    newTrackData(iTrack).Frame = startFrame:endFrame;

    frames = trackData(iTrack).Frame - startFrame + 1;

    newTrackData(iTrack).Timestamp = nan(1, numel(newTrackData(iTrack).Frame));
    newTrackData(iTrack).Timestamp(frames) = trackData(iTrack).Timestamp;

    newTrackData(iTrack).x = nan(1, numel(newTrackData(iTrack).Frame));
    newTrackData(iTrack).x(frames) = trackData(iTrack).x;

    newTrackData(iTrack).y = nan(1, numel(newTrackData(iTrack).Frame));
    newTrackData(iTrack).y(frames) = trackData(iTrack).y;

    newTrackData(iTrack).z = nan(1, numel(newTrackData(iTrack).Frame));
    newTrackData(iTrack).z(frames) = trackData(iTrack).z;

    %Compute the lag times and square distancesz
    numDetections = numel(newTrackData(iTrack).x);

    for nn = 1:(numDetections - 1)

        currSD = [];
        currLagTimes = [];
        currdR = [];

        for ii = 1:(numDetections - nn)

            dx = newTrackData(iTrack).x(ii + nn) - newTrackData(iTrack).x(ii);
            dy = newTrackData(iTrack).y(ii + nn) - newTrackData(iTrack).y(ii);
            dz = newTrackData(iTrack).z(ii + nn) - newTrackData(iTrack).z(ii);
            
            currDR(ii, :) = [dx, dy, dz];
            currSD(ii) = dx.^2 + dy.^2 + dz.^2;
            currLagTimes(ii) = newTrackData(iTrack).Timestamp(ii + nn) - newTrackData(iTrack).Timestamp(ii);

        end

        %Remove any nans
        currLagTimes(isnan(currSD)) = [];
        currDR(isnan(currSD), :) = [];
        currSD(isnan(currSD)) = [];

        T = [T currLagTimes];
        SD = [SD currSD];
        try
        dR = [dR; currDR];
        catch
            keyboard
        end

    end

    

    
    
end

%Round up T
T = round(T, 5, 'significant');

end



















