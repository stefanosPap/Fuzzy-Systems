%% FUZZY SYSTEMS 2020 - 2021
% Classification 
% Stefanos Papadam 
% AEM: 8885

%% CLEAR 
clear 
clc

%% DATA
% load data
data = load('haberman.data');

% separate data according to output 
output1_idx = (data(:,4) == 1);
output2_idx = (data(:,4) == 2);

output1 = data(output1_idx,:);
output2 = data(output2_idx,:);

% random division of each length 
[train_split_1, val_split_1, test_split_1] = dividerand(length(output1), 0.6, 0.2, 0.2);
[train_split_2, val_split_2, test_split_2] = dividerand(length(output2), 0.6, 0.2, 0.2);

% specify training, testing and validation data 
training_data = [output1(train_split_1, :); output2(train_split_2, :)];
validation_data = [output1(val_split_1, :); output2(val_split_2, :)];
testing_data = [output1(test_split_1, :); output2(test_split_2, :)];

% shuffle the data 
training_data = training_data(randperm(length(training_data)), :);
validation_data = validation_data(randperm(length(validation_data)), :);
testing_data = testing_data(randperm(length(testing_data)), :);

% proof that data have been splitted almost equally in each set 
count1 = sum(data(:,4) == 1);
count2 = sum(data(:,4) == 2);
percent1 = count2 / count1 * 100;

count1 = sum(training_data(:,4) == 1);
count2 = sum(training_data(:,4) == 2);
percent2 = count2 / count1 * 100;

count1 = sum(validation_data(:,4) == 1);
count2 = sum(validation_data(:,4) == 2);
percent3 = count2 / count1 * 100;

count1 = sum(testing_data(:,4) == 1);
count2 = sum(testing_data(:,4) == 2);
percent4 = count2 / count1 * 100;


%% TSK MODELS
% save each model to array 'm' in order to access and train it 

cluster_radius = [0.2, 0.6];

m(1) = genfis2(training_data(:,1:3), training_data(:,4), cluster_radius(1));
for i=1:length(m(1).output(1).mf(:))
    m(1).output(1).mf(i).type='constant'; 
    m(1).output(1).mf(i).params = m(1).output(1).mf(i).params(end); 
end

m(2) = genfis2(training_data(:,1:3), training_data(:,4), cluster_radius(2));
for i=1:length(m(2).output(1).mf(:))
    m(2).output(1).mf(i).type='constant'; 
    m(2).output(1).mf(i).params = m(2).output(1).mf(i).params(end); 
end

%% TRAINING PROCESS
N = length(testing_data);

for i = 1:2
    % train 
    options = anfisOptions('InitialFIS', m(i), 'EpochNumber', 100, 'InitialStepSize', 0.05, 'ValidationData', validation_data);
    [fis,trainError,stepSize,chkFIS,testError] = anfis(training_data, options); 
    
    % predict the result
    y_predicted = evalfis(testing_data(:,1:3), chkFIS);
    y_predicted = round(y_predicted);

    % calculate error matrix 
    error_matrix = zeros(2);
    for j = 1:length(testing_data)
        if testing_data(j,4) == y_predicted(j)
            if testing_data(j,4) == 1
                error_matrix(1,1) = error_matrix(1,1) + 1; 
            elseif testing_data(j,4) == 2
                error_matrix(2,2) = error_matrix(2,2) + 1; 
            end
        else
            if testing_data(j,4) == 1
               error_matrix(2,1) = error_matrix(2,1) + 1; 
            elseif testing_data(j,4) == 2
               error_matrix(1,2) = error_matrix(1,2) + 1; 
            end
        end
    end
    % calculate OA metric
    OA(i) = sum(diag(error_matrix)) / N;
    
    % calculate PA, UA metrics
    sum_r_c = 0;
    for k = 1:length(error_matrix)
        PA(i,k) = error_matrix(k,k) / sum(error_matrix(:,k));
        UA(i,k) = error_matrix(k,k) / sum(error_matrix(k,:));
        sum_r_c = sum_r_c + sum(error_matrix(:,k)) * sum(error_matrix(k,:));
    end
    
    % calculate khat metric
    khat(i) = (N * sum(diag(error_matrix)) - sum_r_c) / (N ^ 2 - sum_r_c);
    
    % membership function plot 
    figure;
    for j = 1:3
        [x,mf] = plotmf(chkFIS,'input',j);
        subplot(2,2,j)
        plot(x,mf);
        if j == 1
            xlabel('Age of patient at time of operation');
        elseif j == 2
            xlabel('Patient year of operation');
        elseif j == 3
            xlabel('Number of positive axillary nodes detected');
        end
        title(['Input ' num2str(j)])
        ylabel('Membership value');
    end
    
    % plot training and validation error
    figure;
    hold on 
    epochs = 1:length(trainError);
    plot(epochs, trainError);
    plot(epochs, testError);
    title(['Learning curves - Model ' num2str(i)]) 
    xlabel('epochs')
    ylabel('MSE')
    legend('MSE for Training data','MSE for Testing data')
    hold off 
    
%     inputs = 3;
%     result = y_predicted;
%     k = zeros(max(testing_data(:,inputs+1)));
%     checkLength = length(testing_data);
%     for q=1:checkLength
%         horizontal = result(q);
%         if horizontal < 1
%             horizontal = 1;
%         elseif horizontal > max(size(k))
%             horizontal = max(size(k));
%         end
%         vertical = testing_data(q, inputs+1);
%         k(horizontal,vertical) = k(horizontal,vertical) + 1;
%     end
%     
%     OA_(i) = sum(diag(k))/N;
%     p = 0;
%     for q=1:max(size(k))
%         PA_(i,q) = k(q,q)/sum(k(:,q));
%         UA_(i,q) = k(q,q)/sum(k(q,:));
%         p = p + sum(k(:,q))*sum(k(q,:));
%     end
%     
%     kest(i) = (N*sum(diag(k))-p)/(N^2-p);
    
end