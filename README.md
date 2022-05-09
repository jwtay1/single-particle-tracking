# Measuring Diffusion using Single Particle Tracking 

Welcome to the single particle tracking project which is being developed in
collaboration with Stephen Upton and the Sousa Lab at CU Boulder. 

This project has two goals:
1. Import single particle tracking data from an Excel spreadsheet, then use
   this data to compute the diffusion coefficient using mean square 
   distance measurements.
2. Validate the processing code through simulations of random walks.

## Installation and Usage

1. **Download** the code by clicking on the blue Code button above, then 
   selecting "Download ZIP".
2. **Extract** the ZIP file into a directory accessible by MATLAB (e.g.
   in Documents/MATLAB). Navigate to this folder in MATLAB.
3. **Add the processing folder to the MATLAB path** by right-clicking on
   the ``processing`` folder, then select "Add to Path" > "Selected Folders
   and Subfolders".

### Processing data

**Note:** Example code is provided in `processing\processData.m`.

To process data:
1. Read in data using the function readDataFromXLS:
```matlab
trackData = readDataFromXLS(file, sheet, headerRow);
```

Note: The header row should be the row number that contains the data column 
headings (e.g., frame, x, y, z etc). You no longer need to specify the cell
range containing data to process, the code will automatically identify
datasets using the header "frame".

2. Use the function ``calculateSDandLagTime`` to compute the square 
   distances and time lags:
```matlab
[timeLag, squareDistances] = calculateSDandLagTime(trackData);
```

3. You can use the information collected to compute the mean square 
   distances (MSD):
```matlab
%Find unique time lags in the data
lt = unique(timeLag);

%Compute the MSD
for ii = 1:numel(lt)
    MSD(ii) = mean(squareDistances(timeLag == lt(ii)));
end
```

4. Finally, to obtain the diffusion coefficient, fit the first four MSD 
   points to a line:
```matlab
%Fit MSD data to a line
fitData = fit(lt(1:4)', MSD(1:4)', 'poly1');

%Compute the diffusion coefficient
D = (1/(2 * 2)) * fitData.p1;
```

### Simulation

To validate the processing scripts, code to simulate a random walk is 
provided in `simulation\simulatRandomWalk.m`. This code will simulate a 
number of particles walking along a diagonal grid.

1. To generate an spreadsheet (XLS) file that is compatible with the 
   processing code, run the function `simualteRandomWalk`:
```matlab
simulateRandomWalk(outputFile)
```

By default, the script will simulate 50 particles moving for 30 timesteps 
with a diffusion coefficient of 2 nm/s.

2. To change simulation parameters, simply add parameter/value pairs after
   the output filename, e.g.:
```matlab
simulateRandomWalk(outputFile, 'diffusionCoefficient', 5)
```

Valid paramters are:
* `numParticles` - Number of particles to simulate
* `timeStep` - Time between each measurement/frame
* `trackLength` - Number of timepoints to simulate
* `diffusionCoefficient` - Expected diffusion coefficient.

**Note:** The step size is computed from the input diffusion coefficient as
&delta;R = (D * 2 * dT)^(1/2)

