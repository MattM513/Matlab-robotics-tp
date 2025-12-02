%% dynamic_model.m
% This script builds the Observation Matrix (W) and Torque Vector (Tau)
clear; close all; clc;

% 1. Load the processed data (from your first script)
load('qf.mat'); 
load('dqf.mat'); 
load('ddqf.mat'); 
load('tauf.mat'); 
load('q.mat', 't'); % Load time vector

% 2. Subsampling settings (One sample every 380 points)
n = 6;
factor = 380;
nn = floor((length(t)-1)/factor) + 1;

fprintf('Building Observation Matrix for %d samples...\n', nn);

t_start = tic;

% Initialize large matrices
W_total = [];   % The "Regressor"
Tau_total = []; % The "Measured Torque"



% 3. Loop through data
for k = 1:nn
    % Get index
    idx = (k-1)*factor + 1;
    
    % Prepare vectors for this instant
    % Note: Adjust q according to robot geometric offsets if needed (Page 17 of PDF)
    q_k = [qf(1,idx); qf(2,idx)-pi/2; qf(3,idx)+pi/2; qf(4,idx); qf(5,idx); qf(6,idx)];
    dq_k = dqf(:,idx);
    ddq_k = ddqf(:,idx);
    
    % Friction term helper (sign of velocity)
    sgn_dq_k = sign(dq_k);
    
    % --- CRITICAL STEP: Call your Python-generated function ---
    W_k = get_regressor(q_k, dq_k, ddq_k, sgn_dq_k);
    
    % Stack the matrices vertically
    W_total = [W_total; W_k];
    Tau_total = [Tau_total; tauf(:,idx)];
end

total_time = toc(t_start);
avg_time = total_time / nn;

fprintf('Calculation finished in %.4f seconds.\n', total_time);
fprintf('Average time per sample: %.6f seconds.\n', avg_time);

% 4. Save the result for the next step
fprintf('Saving observation_matrix.mat...\n');
save('observation_matrix.mat', 'W_total', 'Tau_total');
disp('Done! Ready for identification.');