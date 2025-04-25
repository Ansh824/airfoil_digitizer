% Description: This script updates the tag file for the new airfoil data
% being digitized.
% Author: Ansh Atul Mishra
%%-----------------------------------------------------------------------%%
clear all; close all; clc;

% Open file dialog for user to pick a JSON file
[filename, pathname] = uigetfile('*.json', 'Select the JSON file template');

% Check if the user actually selected a file
if isequal(filename, 0)
    disp('User canceled file selection.');
else
    % Full path to the selected file
    fullpath = fullfile(pathname, filename);

    % Read and decode the JSON file
    jsonText = fileread(fullpath);
    data = jsondecode(jsonText);
end

data.airfoil.name = input('Enter the airfoil name: ', 's');
data.airfoil.camber = input('Camber (Y/N): ', 's');
data.airfoil.supercritical = input('Supercritical (Y/N): ', 's');
data.flow_conditions.reynolds = input('Enter the Reynolds number/numbers: ', 's');
data.flow_conditions.mach = input('Enter the mach number/numbers: ', 's');
data.flow_conditions.alpha = input('Enter the AoAs: ', 's');
data.source.author = input('Enter Author names: ', 's');
data.source.name = input('Enter Paper title/name: ', 's');
data.source.type = input('Enter digitization type: ', 's');
data.source.url = input('Enter Paper url: ', 's');
data.meta.num_cases = input('Enter number of cases: ', 's');
data.meta.notes = input('Enter any additional notes (if any): ', 's');
data.uncertainty.alpha = input('Enter AOA uncertainty (if any): ', 's');
data.uncertainty.cp = input('Enter Cp uncertainty (if any): ', 's');
data.uncertainty.mach = input('Enter mach uncertainty (if any): ', 's');
data.uncertainty.x = input('Enter x uncertainty (if any): ', 's');
data.uncertainty.z = input('Enter z uncertainty (if any): ', 's');


% Convert the updated structure back to JSON text
newJsonText = jsonencode(data);

% Overwrite the same file
fid = fopen(fullpath, 'w');
if fid == -1
    error('Could not open file for writing.');
end

fwrite(fid, newJsonText, 'char');
fclose(fid);