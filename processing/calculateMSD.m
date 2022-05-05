function newTrackData = calculateMSD(trackData)

newTrackData = struct;

for iTrack = 1:numel(trackData)

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

    %Compute MSD
    numDetections = numel(newTrackData(iTrack).x);
    MSD = nan(1, numDetections - 1);
    for nn = 1:(numDetections - 1)

        SD = [];

        for ii = 1:(numDetections - nn)

            dx = newTrackData(iTrack).x(ii + nn) - newTrackData(iTrack).x(ii);
            dy = newTrackData(iTrack).y(ii + nn) - newTrackData(iTrack).y(ii);
            dz = newTrackData(iTrack).z(ii + nn) - newTrackData(iTrack).z(ii);
            
            SD(ii) = dx.^2 + dy.^2 + dz.^2;

        end

        MSD(nn) = 1/(numDetections - nn) * sum(SD, 'omitnan');

    end
    
    newTrackData(iTrack).MSD = MSD;

    %Compute diffusion coefficient
    tt = (1:4) * 0.07;
    if numel(MSD) > 4

        fitData = fit(tt', MSD(1:4)', 'poly1');
        newTrackData(iTrack).DiffusionCoeff = fitData.p1;

    end



end

end



















