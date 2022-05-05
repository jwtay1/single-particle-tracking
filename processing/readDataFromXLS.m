function trackData = readDataFromXLS(file, sheet, headerRow)

if ~exist('headerRow', 'var')
    headerRow = 21;
end

%Read in data starting from the headerRow
rawData = readcell(file, 'Sheet', sheet, 'Range', sprintf('A%.0f', headerRow));

%Assume that data columns will always be frame, timestemp, x, y, z,
%x sigma, y sigma, z sigma, photons, bkg photons, track, track number,
%track length

%Determine the first column for each dataset using header data
dsFirstCol = find(cellfun(@(x) strcmpi('frame', x), rawData(1, :)));
numDatasets = numel(dsFirstCol);

%Collect track data into a struct
trackData = struct('Frame', {}, 'Timestamp', {}, 'x', {}, 'y', {}, 'z', {});

for iCol = dsFirstCol
    for iRow = 2:size(rawData, 1)

        trackNumber = rawData{iRow, iCol + 11};

        if ismissing(trackNumber)
            break;
        end

        if trackNumber > numel(trackData)
           
            trackData(trackNumber).Frame = rawData{iRow, iCol};
            trackData(trackNumber).Timestamp = rawData{iRow, iCol + 1};
            trackData(trackNumber).x = rawData{iRow, iCol + 2} * 1e-3;
            trackData(trackNumber).y = rawData{iRow, iCol + 3} * 1e-3;
            trackData(trackNumber).z = rawData{iRow, iCol + 4} * 1e-3;

        else

            trackData(trackNumber).Frame(end + 1) = rawData{iRow, iCol};
            trackData(trackNumber).Timestamp(end + 1) = rawData{iRow, iCol + 1};
            trackData(trackNumber).x(end + 1) = rawData{iRow, iCol + 2} * 1e-3;
            trackData(trackNumber).y(end + 1) = rawData{iRow, iCol + 3} * 1e-3;
            trackData(trackNumber).z(end + 1) = rawData{iRow, iCol + 4} * 1e-3;

        end

    end
end


