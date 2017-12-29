% Script for testing the oiPlot routine
%
% Description:
%   Exercises various plot options available for the optical image
%   structure, via routine oiPlot.

%% Initialize isetbio
ieInit

%% Initialize the oi structure
scene = sceneCreate; 
scene = sceneSet(scene,'fov',4);
oi = oiCreate; oi = oiCompute(oi,scene);

%% Irradiadiance along a vertical line
% 
% Plotted as a function of position and wavelength.
% If I knew why we need two positional arguments, I would
% tell you here.
[uData, g] = oiPlot(oi,'irradiance vline',[20 20]);

%% Irradiadiance along a horizontal line
% 
% Plotted as a function of position and wavelength.
[uData, g] = oiPlot(oi,'irradiance hline',[20 20]);

%% Retinal illuminance along a horiztonal line
[uData, g] = oiPlot(oi,'illuminance hline',[20 20]);

%% 
rows = round(oiGet(oi,'rows')/2);
uData = oiPlot(oi,' irradiance hline',[1,rows]);

%%
uData = oiPlot(oi,'illuminance fft hline',[1,rows]);

%%
uData = oiPlot(oi,'contrast hline',[1,rows]);

%%
uData = oiPlot(oi,'irradiance image with grid',[],40);

%%
uData = oiPlot(oi,'irradiance image wave',[],500,40);

%%
uData = oiPlot(oi,'irradiance fft',[],450);

%%
uData = oiPlot(oi,'illuminance fft');

%%  Get some roiLocs
% uData = oiPlot(oi,'irradiance energy roi');

%%
uData = oiPlot(oi,'psf 550','um');

%%
uData = oiPlot(oi,'otf 550','um');

%%
uData = oiPlot(oi,'ls wavelength');

%% End