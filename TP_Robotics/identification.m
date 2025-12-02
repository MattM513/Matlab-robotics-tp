%% identification.m
% Solves Tau = W * Phi to find robot parameters
clear; close all; clc;

% 1. Load the matrices generated in Step 1
load('observation_matrix.mat'); 

% 2. Solve using Least Squares (The "\" operator)
fprintf('Estimating parameters...\n');
Phi_estimated = W_total \ Tau_total;

% 3. Validate the model
% Recompute torque using estimated parameters: Tau_est = W * Phi_est
Tau_estimated = W_total * Phi_estimated;

% 4. Plot comparison
figure('Name', 'Model Validation');
samples = 1:length(Tau_total);
for i = 1:6
    % Extract indices for joint i (every 6th row)
    idx = i:6:length(Tau_total);
    
    subplot(3,2,i);
    plot(Tau_total(idx), 'b', 'LineWidth', 1.5); hold on;
    plot(Tau_estimated(idx), 'r--', 'LineWidth', 1.5);
    grid on;
    title(['Joint ' num2str(i)]);
    legend('Measured Torque', 'Estimated Torque');
    xlabel('Sample'); ylabel('Torque (Nm)');
end

% 5. Calculate Error (RMSE)
rmse = sqrt(mean((Tau_total - Tau_estimated).^2));
fprintf('Identification finished. Global RMSE: %.4f\n', rmse);