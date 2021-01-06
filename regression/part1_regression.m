%% FUZZY SYSTEMS 2020 - 2021
% Regression 
% Stefanos Papadam 
% AEM: 8885

%% CLEAR 
clear 
clc

%% DATA PROCESS 
% load data 
data = load('airfoil_self_noise.dat');

% split data

% better split with implemented function split_data
[data_trn, data_val, data_test] = split_scale(data, 1);
 
y_real = data_test(:, 6);

% calculate average of y in order to use it in SS metric
average_y = mean(y_real);

%% TSK MODELS
% save each model to array 'm' in order to access and train it 
m(1) = genfis1(data_trn, 2, 'gbellmf', 'constant');
m(2) = genfis1(data_trn, 3, 'gbellmf', 'constant');
m(3) = genfis1(data_trn, 2, 'gbellmf', 'linear');
m(4) = genfis1(data_trn, 3, 'gbellmf', 'linear');

%% TRAINING PROCESS

MSE = zeros(4,1);
SStot = zeros(4,1);
RMSE = zeros(4,1);
R_square = zeros(4,1);
NMSE = zeros(4,1);
SSres = zeros(4,1);
NDEI = zeros(4,1);

for i = 1:4
    tic
    % train 
    options = anfisOptions('InitialFIS', m(i), 'EpochNumber', 100, 'DisplayANFISInformation', 0, 'DisplayErrorValues', 0, 'ValidationData', data_val);
    [fis,trainError,stepSize,chkFIS,testError] = anfis(data_trn, options); 
    %[fis,trainError,stepSize,chkFIS,testError] = anfis(data_trn, model(i), [100, 0], 0, valData);

    % predict the result
    y_predicted = evalfis(data_test(:,1:5), chkFIS);

    % metrics 
    MSE(i) = sum((y_real - y_predicted).^2) / length(data_test);
    RMSE(i) = sqrt(MSE(i));
    SSres(i) = sum((y_real - y_predicted).^2);
    SStot(i) = sum((y_real - average_y).^2);
    R_square(i) = 1 - SSres(i) / SStot(i);
    NMSE(i) = SSres(i) / SStot(i);
    NDEI(i) = sqrt(NMSE(i));
    toc
    
    % plot membership function for each input 
    figure(1)
    for j = 1:5
        [x,mf] = plotmf(chkFIS,'input',j);
        subplot(2,3,j)
        plot(x,mf);
        if j == 1
            xlabel('Frequency (Hz)');
        elseif j == 2
            xlabel('Angle of attack (degrees)');
        elseif j == 3
            xlabel('Chord length (meters)');
        elseif j == 4
            xlabel('Free stream velocity (m/s)');
        else
            xlabel('Suction side displacement thickness (m)');
        end
        title(['Input ' num2str(j)])
        ylabel('Membership value');
    end
    
    % plot training and validation error
    figure(2)
    hold on 
    epochs = 1:length(trainError);
    plot(epochs, trainError);
    plot(epochs, testError);
    title(['Learning curves - Model ' num2str(i)]) 
    xlabel('epochs')
    ylabel('MSE')
    legend('MSE for Training data','MSE for Testing data')
    hold off 
    
    % plot error between real and predicted data 
    figure(3)
    error = y_predicted - y_real;
    samples_length = 1:length(error);
    plot(samples_length, error);
    xlabel('sample')
    ylabel('Error')
    title(['Prediction error - Model ' num2str(i)]) 

end
    
    