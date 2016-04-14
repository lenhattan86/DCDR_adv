function [Hour_End,COAST,EAST,FAR_WEST,NORTH,NORTH_C,SOUTHERN,SOUTH_C,WEST,ERCOT] = import_grid_load_mac(workbookFile,sheetName,startRow,endRow)
%% Import data from spreadsheet
% Script for importing data from the following spreadsheet:
%
%    Workbook: /Users/jieliang/Desktop/DCDR_adv/simulation/traces/ecort_load_2016.xls
%    Worksheet: native_Load_2016
%
% To extend the code for use with different selected data or a different
% spreadsheet, generate a function instead of a script.

% Auto-generated by MATLAB on 2016/04/14 11:58:15

%% Import the data
[~, ~, raw] = xlsread('/Users/jieliang/Desktop/DCDR_adv/simulation/traces/ecort_load_2016.xls','native_Load_2016');
raw = raw(2:end,:);

%% Create output variable
data = reshape([raw{:}],size(raw));

%% Allocate imported array to column variable names
Hour_End = data(:,1);
COAST = data(:,2);
EAST = data(:,3);
FAR_WEST = data(:,4);
NORTH = data(:,5);
NORTH_C = data(:,6);
SOUTHERN = data(:,7);
SOUTH_C = data(:,8);
WEST = data(:,9);
ERCOT = data(:,10);

%% Clear temporary variables
clearvars data raw;