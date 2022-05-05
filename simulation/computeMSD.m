% function computeMSD(pos)

%Compute MSD
numDetections = size(pos, 1);

MSD = nan(1, numDetections - 1);

for nn = 1:(numDetections - 1)

    SD = [];

    for ii = 1:(numDetections - nn)

        dx = pos(ii + nn, 1) - pos(ii, 1);
        dy = pos(ii + nn, 2) - pos(ii, 2);

        SD(ii) = dx.^2 + dy.^2;

    end

    MSD(nn) = 1/(numDetections - nn) * sum(SD);

end

plot(1:numel(MSD), MSD)

