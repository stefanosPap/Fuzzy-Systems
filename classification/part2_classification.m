%% FUZZY SYSTEMS 2020 - 2021
% Classification 
% Stefanos Papadam 
% AEM: 8885

%% CLEAR 
clear 
clc

%% DATA
tic
% load data 
data = csvread('data.csv',1,1, [1, 1, 11500, 179]);

% split data 
[train_split, val_split, test_split] = dividerand(length(data), 0.6, 0.2, 0.2);

% specify training, testing and validation data 
training_data = data(train_split, :);
validation_data = data(val_split, :);
testing_data = data(test_split, :);

% shuffle the data 
training_data = training_data(randperm(length(training_data)), :);
validation_data = validation_data(randperm(length(validation_data)), :);
testing_data = testing_data(randperm(length(testing_data)), :);

% specify features number and cluster radius in two arrays 
features_number = [6, 10, 15, 20];
cluster_radius = [0.15, 0.3, 0.45, 0.6];

% 5-fold cross validation 
n = length(training_data);
k = 5;
partition = cvpartition(n,'KFold',k);

% feature extraction with Relief algorithm and k = 10
X = training_data(:,1:end-1);
y = training_data(:,end);
k = 10;
[idx,weights] = relieff(X,y,k);         % idx contains the indices of the most important features 
                                        % and weights contains the corresponding weight of each index 

fold = 5;                               % 5-fold

rules = zeros(length(features_number),length(cluster_radius));
comb_errors = zeros(length(features_number),length(cluster_radius));

%% GRID SEARCH
N = length(testing_data);
tic 
for f = 1:length(features_number)       % examine every combination between features number and cluster radius 
    f
    features = idx(1:features_number(f));
    
    for r = 1:length(cluster_radius)   
        r
        errors = zeros(fold,1);         % initialize errors array with zeros 

        for k = 1:fold 
            k
            trn_idx = partition.training(k);  % identify the observations that are in the training set
            test_idx = partition.test(k);     % identify the observations that are in the test set

            train_x = training_data(trn_idx, features);
            train_y = training_data(trn_idx, end);
            train = [train_x, train_y];
            
            val_x = training_data(test_idx, features);
            val_y = training_data(test_idx, end);
            val = [val_x, val_y];
            
            initial_fis = genfis2(training_data(trn_idx==1,features),training_data(trn_idx==1,179), cluster_radius(r));
            rules = length(initial_fis.rule);
            for t=1:rules
               initial_fis.output(1).mf(t).type='constant'; 
               initial_fis.output(1).mf(t).params = initial_fis.output(1).mf(t).params(end); 
            end
             
%            fis = classDep2(train, cluster_radius(r));

            anfis_opt = anfisOptions('InitialFIS', initial_fis,...          % choose options 
                                     'EpochNumber', 1,...
                                     'InitialStepSize', 0.1,...
                                     'DisplayANFISInformation', 0,...
                                     'DisplayErrorValues', 0,...
                                     'DisplayStepSize', 0,...
                                     'DisplayFinalResults', 0,...
                                     'ValidationData', val);
            % train                      
            [initial_fis,trainError,stepSize,chkFIS,testError] = anfis(train, anfis_opt);
            errors(k) = min(testError);
        end
        rules(f, r) = length(initial_fis.rule);
        comb_errors(f, r) = sum(errors) / fold; % divide with fold = 5 in order to take the mean 

    end
end
toc
%% OPTIMAL 
% find minimum error 
minimum_error = min(comb_errors(:));

% find features with minimum error 
[features, radius] = find(comb_errors==minimum_error);

% optimal features 
attr = idx(1:features_number(features));

% optimal model
train = [training_data(:, attr), training_data(:, end)];
initial_fis = classDep2(train, cluster_radius(radius));
% initial_fis = genfis2(training_data(:, attr), training_data(:, end), cluster_radius(r));
% nuofrules = length(initial_fis.rule);
% for t=1:nuofrules
%     initial_fis.output(1).mf(t).type='constant'; 
%     initial_fis.output(1).mf(t).params = initial_fis.output(1).mf(t).params(end); 
% end
anfis_opt = anfisOptions('InitialFIS', initial_fis,...
                         'EpochNumber', 100,...
                         'InitialStepSize', 0.05,...
                         'DisplayANFISInformation', 0,...
                         'DisplayErrorValues', 0,...
                         'DisplayStepSize', 0,...
                         'DisplayFinalResults', 0,...
                         'ValidationData',  validation_data(:,[attr, end]));
% train optimal model                      
[fis,trainError,stepSize,chkFIS,testError] = anfis(train, anfis_opt);

% predict the result
y_predicted = evalfis(testing_data(:,attr), chkFIS);
y_predicted = round(y_predicted);

error_matrix = confusionmat(testing_data(:,179) ,y_predicted)';
% calculate OA metric
OA = sum(diag(error_matrix)) / N;
    
% calculate PA, UA metrics
sum_r_c = 0;
for k = 1:length(error_matrix)
   PA(k) = error_matrix(k,k) / sum(error_matrix(:,k));
   UA(k) = error_matrix(k,k) / sum(error_matrix(k,:));
   sum_r_c = sum_r_c + sum(error_matrix(:,k)) * sum(error_matrix(k,:));
end
 
% calculate khat metric
khat = (N * sum(diag(error_matrix)) - sum_r_c) / (N ^ 2 - sum_r_c);


    