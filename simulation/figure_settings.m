close all; clear all; clc;

% is_printed = true;
is_printed = false;

strBJDeandline = 'Batch job deadlines (hours)';
strDataCenter = 'Data center';
strViolationFreq = 'Violation frequency';

fontAxis = 14;
fontLegend = 14;

lineWitdth = 4;

patternDC = '-ok';
patternES = '--b';

fig_path = '../../../figs/';

figure_size = [0.0 0 4.0 3.5];