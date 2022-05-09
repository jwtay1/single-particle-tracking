function simulateRandomWalk(outputFN, varargin)
%SIMULATERANDOMWALK  Generate simulated random walk data
%
%  SIMULATERANDOMWALK(XLSFILE, PARAMS) will generate data of single
%  particles undergoing a random walk to validate the MSD analysis code.
%  The data will be saved as an XLS file with similar headers to mimic test
%  data sets.
%
%  PARAMS is a struct that contains parameters of the simulation. The
%  following are parameters (default values in parentheses):
%      stepSize - Average step size in arb. units (2)
%      numParticles - Number of tracks to simulate (50)
%      timeStep - Time between frames (0.07)
%      trackLength - Length of each track (30)

%https://link.springer.com/protocol/10.1007/978-1-59745-519-0_20
%http://www.rpgroup.caltech.edu/ncbs_pboc/code/t03_stochastic_simulations.html

ip = inputParser;
%addParameter(ip, 'stepSize', 2);
addParameter(ip, 'numParticles', 50);
addParameter(ip, 'timeStep', 0.07);
addParameter(ip, 'trackLength', 30);
addParameter(ip, 'diffusionCoefficient', 2);
parse(ip, varargin{:})

%Columns needed: frame, timestamp, x(nm), y(nm), z(nm), x sigma [nm]	y sigma [nm]	z sigma [nm]	photons	bkg photons	track	track for matlab	track length

%Calculate step size:
stepSize = sqrt(ip.Results.diffusionCoefficient * (2 * ip.Results.timeStep));


particleData = cell(1, ip.Results.numParticles);

for iParticle = 1:ip.Results.numParticles

    %Generate a vector of random motion
    %vDirection = rand(ip.Results.trackLength - 1, 1) * 2 * pi;
    vDirection = [randsample([-1, 1], ip.Results.trackLength - 1, true)', ...
        randsample([-1, 1], ip.Results.trackLength - 1, true)'];

    %Generate step sizes using a normal distribution. Mean is the step
    %size. Currently assuming std = 1.
    %dStep = randn(ip.Results.trackLength - 1, 1) + ip.Results.stepSize;
    dStep = stepSize;

    %Convert the above into Cartesian coordinates
    %dStepXY = [dStep .* cos(vDirection), dStep .* sin(vDirection)];
    dStepXY = [dStep .* vDirection(:, 1), dStep .* vDirection(:, 2)];

    %Generate a random starting position
    dStepXY = [rand(1), rand(1); dStepXY];

    %Add the previous position to each to get the final vector of
    %displacements
    particlePos = cumsum(dStepXY, 1);

    %Generate the columns as matrices
    particleData{iParticle} = [(1:ip.Results.trackLength)', ...
        (1:ip.Results.trackLength)' * ip.Results.timeStep, ...
        particlePos(:, 1), particlePos(:, 2), zeros(ip.Results.trackLength, 1), ...
        zeros(ip.Results.trackLength, 1), zeros(ip.Results.trackLength, 1), zeros(ip.Results.trackLength, 1), ...
        zeros(ip.Results.trackLength, 1), zeros(ip.Results.trackLength, 1), ...
        ones(ip.Results.trackLength, 1) * iParticle, ones(ip.Results.trackLength, 1) * iParticle,...
        ones(ip.Results.trackLength, 1) * ip.Results.trackLength];

%         %Plot for verification
%     plot(particlePos(:, 1), particlePos(:, 2))
%     keyboard

end

%Generate the XLS output
headers = {'frame', 'timestamp', 'x [nm]', 'y [nm]', 'z [nm]', ...
    'x sigma [nm]', 'y sigma [nm]', 'z sigma [nm]', 'photons', ...
    'bkg photons', 'track', 'track for matlab', 'track length'};
writecell(headers, outputFN, 'FileType', 'spreadsheet', 'sheet', 'sim data');

for iPD = 1:numel(particleData)

    writematrix(particleData{iPD}, outputFN, 'FileType', 'spreadsheet', 'sheet', 'sim data', 'WriteMode', 'append')

end

end