close all; clear all; clc;

is_printed = true;
% is_printed = false;

strBJDeandline = 'Batch job deadlines (hours)';
strDataCenter = 'Data center';
strViolationFreq = 'Violation frequency';
strPeakDemand = 'Peak demand (MWh)';
strDelayFlexibility = 'Delay flexibility (%)';
strRelaxTemperature = sprintf('Relaxed temperature (%cF)', char(176));
strTemperature = sprintf('Temperature (%cF)', char(176));
strPeakReduction = 'Peak reduction (%)';

peak_reduction_max = 30;

fontAxis = 14;
fontLegend = 14;

lineWitdth = 2;

patternDC = '-ok';
patternES = '--b';
patternPeakShaving = '-xb';
patternCooling = '-b';
patternCost = '--';
patternVoltageFreq = '-';
patterndot = ':';
patterntemp = '-.';

%  fig_path = 'figs/';
fig_path = 'C:/Users/NhatTan/Dropbox/Papers/GreenMetrics16/DCDR_adv/figs/';

set(0, 'units', 'inches')
screensize = get(0, 'ScreenSize');
sz = [4.0 3.0]; % figure size

figure_size_scr = [(screensize(3)-sz(2))/2 (screensize(4)-sz(1))/2 sz(1) sz(2)];
figure_size = [0 0 sz(1) sz(2)];