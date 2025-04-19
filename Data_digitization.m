%% Airfoil Data Digitizer
% This code digitizes the airfoil data using image from the paper you want
% to digitize the airfoil from
% Author: Ansh Atul Mishra
%-------------------------------------------------------------------------%

clear all; close all; clc;

% Load the image of the airfoil
[filename, pathname] = uigetfile('*.png;*.jpg;*.jpeg;*.bmp', 'Select the file that needs to be digitized');
if filename == 0
    disp('No file selected, exiting.');
    return;
end

img = imread(fullfile(pathname, filename));
figure('Name', 'Airfoil Digitizer');
imshow(img);
title('Select 2 points along the X-axis (start and end)');
hold on;

% Select X-axis points
[x1, x2] = ginput(2);
plot(x1, x2, 'ro-', 'LineWidth', 1.5);
for i = 1:2
    plot(x1(i), x2(i), 'ro', 'MarkerFaceColor', 'r');
    text(x1(i)+5, x2(i), sprintf('X-%d', i), 'Color', 'r', 'FontSize', 10);
end
x_val1 = input('Enter value for X-1: ');
x_val2 = input('Enter value for X-2: ');

% Select Y-axis points
title('Select 2 points along the Y-axis (start and end)');
[y1, y2] = ginput(2);
plot(y1, y2, 'go-', 'LineWidth', 1.5);
for i = 1:2
    plot(y1(i), y2(i), 'go', 'MarkerFaceColor', 'g');
    text(y1(i)+5, y2(i), sprintf('Y-%d', i), 'Color', 'g', 'FontSize', 10);
end
y_val1 = input('Enter value for Y-1: ');
y_val2 = input('Enter value for Y-2: ');

% Define coordinate system
x_axis_vec = [x1(2) - x1(1), x2(2) - x2(1)];
x_pixel_dist = norm(x_axis_vec);
x_unit_vec = x_axis_vec / x_pixel_dist;
x_scale = (x_val2 - x_val1) / x_pixel_dist;

y_axis_vec = [y1(2) - y1(1), y2(2) - y2(1)];
y_pixel_dist = norm(y_axis_vec);
y_unit_vec = y_axis_vec / y_pixel_dist;
y_scale = (y_val2 - y_val1) / y_pixel_dist;

origin = [x1(1); x2(1)];
x_origin_val = x_val1;
y_origin_val = y_val1;

% Digitize points
title('Digitize airfoil points: Click to add, press Enter to finish');
x_pts = [];
y_pts = [];
pt_index = 1;

while true
    [x_temp, y_temp, button] = ginput(1);
    if isempty(button)
        break;
    end
    x_pts(end+1) = x_temp;
    y_pts(end+1) = y_temp;
    plot(x_temp, y_temp, 'ro', 'MarkerFaceColor', 'r');
    text(x_temp + 5, y_temp, sprintf('%d', pt_index), 'Color', 'b', 'FontSize', 9);
    pt_index = pt_index + 1;
end

n_pts = length(x_pts);
X_real = zeros(n_pts, 1);
Y_real = zeros(n_pts, 1);

% Convert to real-world
for i = 1:n_pts
    vec = [x_pts(i); y_pts(i)] - origin;
    X_real(i) = x_origin_val + dot(vec, x_unit_vec') * x_scale;
    Y_real(i) = y_origin_val + dot(vec, y_unit_vec') * y_scale;
end

% --- Get Mach number and metadata for file naming ---
airfoil_name = input('Enter airfoil name: ', 's');
angle_attack = input('Enter angle of attack: ');
mach_number = input('Enter the Mach number: ');
reynolds_number = input('Enter Reynolds number: ', 's');


mach_label = sprintf('%.3f', mach_number);

% Find index of point closest to x = 0
[~, idx_closest_zero] = min(abs(X_real));
% Repeat that point directly below itself
X_real = [X_real(1:idx_closest_zero); X_real(idx_closest_zero); X_real(idx_closest_zero+1:end)];
Y_real = [Y_real(1:idx_closest_zero); Y_real(idx_closest_zero); Y_real(idx_closest_zero+1:end)];

% Repeat first point at end
X_real(end+1) = X_real(1);
Y_real(end+1) = Y_real(1);

% Create data cell (header + data)
data_cell = cell(length(X_real)+1, 2);
data_cell{1,1} = '';  % no label for X
data_cell{1,2} = mach_label;  % label for Y

for i = 1:length(X_real)
    data_cell{i+1, 1} = X_real(i);
    data_cell{i+1, 2} = Y_real(i);
end

% Generate filename
csv_file_name = sprintf('%s_A%d_M%.3f_Re%s_A.csv', ...
    airfoil_name, angle_attack, mach_number, reynolds_number);

% Save file
folderpath_loc = uigetdir('', 'Select the folder where you want to save the csv file');
output_file = fullfile(folderpath_loc, csv_file_name);
writecell(data_cell, output_file);

disp(['File saved as: ', csv_file_name]);