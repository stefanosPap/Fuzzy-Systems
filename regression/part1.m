clear 

%% DATA
% load data 
data = load('airfoil_self_noise.dat');

% split data
dim = size(data);
trn_end = round(0.6 * dim(1));
val_end = trn_end + round(0.2 * dim(1));

data_trn = data(1:trn_end,:);
data_val = data(trn_end + 1:val_end,:);
data_test = data(val_end + 1:end,:);

[data_trn, data_val, data_test] = split_scale(data, 1);
 
y_real = data_test(:, 6);

% calculate average of y in order to use it in SS metric
average_y = mean(y_real);
%% TSK models

% save each model to array 'model' in order to access and train it 
model(1) = genfis1(data_trn, 2, 'gbellmf', 'constant');
model(2) = genfis1(data_trn, 3, 'gbellmf', 'constant');
model(3) = genfis1(data_trn, 2, 'gbellmf', 'linear');
model(4) = genfis1(data_trn, 3, 'gbellmf', 'linear');

%% Training process

MSE = zeros(4,1);
SStot = zeros(4,1);
RMSE = zeros(4,1);
R_square = zeros(4,1);
NMSE = zeros(4,1);
SSres = zeros(4,1);
NDEI = zeros(4,1);

for i = 1:4
    if i == 4
        break
    end
    tic
    % train 
    options = anfisOptions('InitialFIS', model(i), 'EpochNumber', 100, 'DisplayANFISInformation', 0, 'DisplayErrorValues', 0, 'ValidationData', data_val);
    [fis,trainError,stepSize,chkFIS,testError] = anfis(data_trn, options); 
    
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
    iter = 1:length(trainError);
    plot(iter, trainError);
    plot(iter, testError);
    title(['Learning curves for model ' num2str(i)]) 
    xlabel('iterations')
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
    title(['Prediction error for model ' num2str(i)]) 

end
    
    