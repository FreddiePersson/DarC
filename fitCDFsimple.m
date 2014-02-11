function [D1out,xAll, fAll] = fitCDFsimple(stepLengths, timeStep)
%% fitCDF: Function to calculate and plot the CDFs from a list of steplengths and samplingtime
% Inputs:
% stepLengths:      A nx1 array of steplengths in nm. A cell array of
%                  trajectories can also be used if the 1st and 2nd columns in each
%                  trajectory are X and Y respectively.
%
% timeStep:         The sampling timestep in seconds.
%
% makePlot:         Boolean stating if graphics output should be given.


% Settings
% CDF parameters
resolution = 1;    %nm

% Horizontal axis for CDF
maxVal = max(stepLengths);    % nm
xAll = resolution:resolution:maxVal;

% Distribution calculation
edges = 0:resolution:maxVal;
nElements = histc(stepLengths, edges);
nElements(end) = [];

% Cumulative distribution
fAll = cumsum(nElements);

% Remove values outside the range (comes from fredrik code, in principle,
% this shouldn't ever happen)
ind = find(xAll>maxVal);
xAll(ind) = [];
fAll(ind) = [];

% Normalize
fAll = fAll./max(fAll);

% Diffusion coeff initial value
D1_0 = 0.5 * 1e6; 
p0 = [D1_0];

% Fit CDF for 1 state
[D1out, r] = nlinfit(xAll, fAll, @CDFfitAll_1state, p0);

D1out = D1out * 1e-6;


% Fitting function
function y = CDFfitAll_1state(param, x)
% Only one state
y = 1-exp(-x.^2./(4*abs(param(1))*timeStep));
y=y';
end

end