%% FUZZY SYSTEMS 2020 - 2021
% Satellite Control - Group 10 
% Stefanos Papadam 
% AEM: 8885

%% CLEAR 
clear 
clc

%% BEGIN
% choose zero 
c = 1.5;

% controlled system     
Gp = tf(10, [1, 10, 9]);

% PI controller 
Gc = tf([1, c], [1, 0]);
 
% open loop system 
Gh = tf([1, c], [1, 10, 9, 0]);

% choose gain 
K = 20;

% open loop system with gain applied 
Go = K * Gh;

% plot root locus 
figure(1);
rlocus(Go);

% closed loop system 
Gc = feedback(Go, 1, -1);

% plot step response and take info about the system   
figure(2);
step(Gc)
stepinfo(Gc)

% plot surface 
figure(3);
gensurf(readfis('satellite_8885'));