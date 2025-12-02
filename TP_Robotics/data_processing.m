clear; close all; clc;

%%1. Load data

load("C:\Users\Matis\Documents\MATLAB\q.mat");     
load("C:\Users\Matis\Documents\MATLAB\tau.mat");   

q = q_meas * pi/100;   
tau = Tau;             
                
fc = 10;              
Ts = t(2) - t(1);     
fs = 1/Ts;            

%% 2. Butterworth
[b,a] = butter(1, fc/(fs/2), 'low');

%% 3. Filtering
qf = filtfilt(b, a, q')';     
tauf = filtfilt(b, a, tau')'; 

%% 4. Derivation
function df = derive(t,f)
df = [ f(1,2) - f(1,1) , (f(1,3:end) - f(1,1:end-2))/2 , f(1,end)-f(1,end-1)]/(t(1,2)-t(1,1));
end


%% 5. Speed
nq = size(qf,1);
dqf = zeros(size(qf));
for i = 1:nq
    dqf(i,:) = derive(t,qf(i,:));
end
dqf = filtfilt(b, a, dqf')'; 

%% 6. Accel
ddqf = zeros(size(qf));
for i = 1:nq
    ddqf(i,:) = derive(t,dqf(i,:));
end
ddqf = filtfilt(b, a, ddqf')';

%% 7. Saving
save('qf.mat','qf');
save('dqf.mat','dqf');
save('ddqf.mat','ddqf');
save('tauf.mat','tauf');

%% 8. Plotting
signals = {'Position (rad)','Vitesse (rad/s)','Accélération (rad/s²)','Couple (N·m)'};
data_raw = {q, dqf, ddqf, tau};
data_filt = {qf, dqf, ddqf, tauf};

for j = 1:6  
    figure('Name', ['Joint ', num2str(j)]);
    for k = 1:4
        subplot(2,2,k);
        plot(t, data_raw{k}(j,:), 'r--'); hold on;
        plot(t, data_filt{k}(j,:), 'b');
        grid on;
        xlabel('Temps (s)');
        ylabel(signals{k});
        legend('Avant filtrage','Après filtrage');
        title(['Articulation ', num2str(j), ' - ', signals{k}]);
    end
end

disp('Traintement terminé et données sauvegardées.');


