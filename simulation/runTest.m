clearvars
clc

simulateRandomWalk('test.xls', ...
    'numParticles', 100, ...
    'diffusionCoefficient', 5)

%%
trackData = readDataFromXLS(...
    'test.xls', ...
    'sim data', 1);

%%
[T, SD, dR] = calculateSDandLagTime(trackData);

lagTimes = unique(T);

dX = dR(:, 1);

histogram(dX(T == lagTimes(1)), 'binWidth', 0.001);


% %Plot histogram of 1, 2, 3, 4 deltaT
% for ii = 1:5
% 
%     histogram(SD(T == lagTimes(ii)), 'binWidth', 0.0001)
%     hold on
% 
% end
% 
% hold off

%%

%Compute the MSD
for ii = 1:numel(lagTimes)

    MSD(ii) = mean(SD(T == lagTimes(ii)));

end

plot(lagTimes, MSD)
xlabel('Time (s)')
ylabel('MSD (arb units)')

%Fit the MSD to calculate the diffusion coefficient
%MSD = 2nDt
%MSD/t = 2nD
%D = 1/2n * MSD/t
fitData = fit(lagTimes(1:4)', MSD(1:4)', 'poly1');

D = (1/(2 * 2)) * fitData.p1; %Correct based on reference 2 below

%Note: The import function converts cell distances to microns




%http://web.mit.edu/savin/Public/.Tutorial_v1.2/
% https://docs.mdanalysis.org/2.0.0/documentation_pages/analysis/msd.html
% (See computing self-diffusivity)
%There are a few tests we can run
%1. Fitting the histogram of the displacement of one of the axes. The
%variance of the distribution is the MSD.
%2. For particles with different motion characteristics, the distributions
%at a given time lag can give different populations


