% figures for several simulation examples
addpath ../Library/libsvm/
addpath ../Library/libs/
set(0, 'RecursionLimit', 5000);

filepath = '../';
datapath = strcat(filepath, 'Data/Example/');
localpath = strcat(filepath, 'Local/Example/');
resultpath = strcat(filepath, 'Results/Example/');
set(0, 'RecursionLimit', 5000);

% % % % % % % % % % % % % % % % % % % % %
% Example: step 1
% uniform data
% % % % % % % % % % % % % % % % % % % % %
dataname = 'uniform';
load(strcat(datapath, dataname, '.mat'));

% kernel density estimation
Data_ts = (-0.25:0.01:1.25)';
Paras.type = 'Gaussian';
Paras.bandwidth = 0.1;
density = KDE(Data, Data_ts, Paras);

figure;
hold on;
axis([-0.1 1.1 -0.25 9]);
set(gca, 'FontSize', 10, 'LineWidth', 2);
set(gca, 'XTick', 0:0.2:1);
set(gca, 'YTick', 0:2:8);
hold on;
plot(Data_ts, density, 'k-.', 'LineWidth', 2);
legend('density', 'Location', 'Best');
xlabel(dataname);
ylabel('pdf');
hold off;

% mass estimation
numh = 3;
mass = zeros(size(Data, 1), numh);
for h = 1:numh
    mass(:, h) = MassEstimate(Data, h);
end

figure;
hold on;
axis([-0.1 1.1 -0.5 18]);
set(gca, 'FontSize', 10, 'LineWidth', 2);
set(gca, 'XTick', 0:0.2:1);
set(gca, 'YTick', 0:4:16);
hold on;
plot(Data, mass(:, 1), 'ro-', 'LineWidth', 2, 'MarkerEdgeColor', 'r', 'MarkerSize', 10);
plot(Data, mass(:, 2), 'g^--', 'LineWidth', 2, 'MarkerEdgeColor', 'g', 'MarkerSize', 10);
plot(Data, mass(:, 3), 'b+:', 'LineWidth', 2, 'MarkerEdgeColor', 'b', 'MarkerSize', 10);
legend('mass h=1', 'mass h=2', 'mass h=3', 'Location', 'Best', 'Orientation', 'horizontal');
xlabel(dataname);
ylabel('mass');
hold off;


% % % % % % % % % % % % % % % % % % % % %
% Example: step 1
% trimodal data
% % % % % % % % % % % % % % % % % % % % %
dataname = 'trimodal';
load(strcat(datapath, dataname, '.mat'));

% kernel density estimation
Data_ts = (-0.25:0.01:1.25)';
Paras.type = 'Gaussian';
Paras.bandwidth = 0.1;
density = KDE(Data, Data_ts, Paras);

figure;
hold on;
axis([-0.25 1.25 -0.5 14]);
set(gca, 'FontSize', 10, 'LineWidth', 2);
set(gca, 'XTick', 0:0.5:1);
set(gca, 'YTick', 0:2:12);
hold on;
plot(Data_ts, density, 'k-.', 'LineWidth', 2);
legend('density', 'Location', 'Best');
xlabel(dataname);
ylabel('pdf');
hold off;

% mass estimation
numh = 3;
mass = zeros(size(Data, 1), numh);
for h = 1:numh
    mass(:, h) = MassEstimate(Data, h);
end

figure;
hold on;
axis([-0.25 1.25 -0.5 14]);
set(gca, 'FontSize', 10, 'LineWidth', 2);
set(gca, 'XTick', 0:0.5:1);
set(gca, 'YTick', 0:2:12);
hold on;
plot(Data, mass(:, 1), 'ro-', 'LineWidth', 2, 'MarkerEdgeColor', 'r', 'MarkerSize', 10);
plot(Data, mass(:, 2), 'g^--', 'LineWidth', 2, 'MarkerEdgeColor', 'g', 'MarkerSize', 10);
plot(Data, mass(:, 3), 'b+:', 'LineWidth', 2, 'MarkerEdgeColor', 'b', 'MarkerSize', 10);
legend('mass h=1', 'mass h=2', 'mass h=3', 'Location', 'Best');
xlabel(dataname);
ylabel('mass');
hold off;


% % % % % % % % % % % % % % % % % % % % %
% Example: step 1
% skew data
% % % % % % % % % % % % % % % % % % % % %
dataname = 'skew';
load(strcat(datapath, dataname, '.mat'));

% kernel density estimation
Data_ts = (-0.25:0.01:1.25)';
Paras.type = 'Gaussian';
Paras.bandwidth = 0.1;
density = KDE(Data, Data_ts, Paras);

figure;
hold on;
axis([-0.1 1.1 -0.25 8.5]);
set(gca, 'FontSize', 10, 'LineWidth', 2);
set(gca, 'XTick', 0:0.2:1);
set(gca, 'YTick', 0:2.5:7.5);
hold on;
plot(Data_ts, density, 'k-.', 'LineWidth', 2);
legend('density', 'Location', 'Best');
xlabel(dataname);
ylabel('pdf');
hold off;

% mass estimation
numh = 3;
mass = zeros(size(Data, 1), numh);
for h = 1:numh
    mass(:, h) = MassEstimate(Data, h);
end

figure;
hold on;
axis([-0.1 1.1 -0.5 17]);
set(gca, 'FontSize', 10, 'LineWidth', 2);
set(gca, 'XTick', 0:0.2:1);
set(gca, 'YTick', 0:5:15);
hold on;
plot(Data, mass(:, 1), 'ro-', 'LineWidth', 2, 'MarkerEdgeColor', 'r', 'MarkerSize', 10);
plot(Data, mass(:, 2), 'g^--', 'LineWidth', 2, 'MarkerEdgeColor', 'g', 'MarkerSize', 10);
plot(Data, mass(:, 3), 'b+:', 'LineWidth', 2, 'MarkerEdgeColor', 'b', 'MarkerSize', 10);
legend('mass h=1', 'mass h=2', 'mass h=3', 'Location', 'Best');
xlabel(dataname);
ylabel('mass');
hold off;