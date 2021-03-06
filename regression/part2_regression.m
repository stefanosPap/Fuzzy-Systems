%% FUZZY SYSTEMS 2020 - 2021
% Regression 
% Stefanos Papadam 
% AEM: 8885

%% DATA
tic
% load data 
data = table2array(readtable('train.csv'));

% split data 
[data_trn, data_val, data_test] = split_scale(data, 1);

% specify features number and cluster radius in two arrays 
features_number = [4, 6, 9 , 15];
cluster_radius = [0.2, 0.4, 0.6, 0.8];

% 5-fold cross validation 
n = length(data_trn);
k = 5;
partition = cvpartition(n,'KFold',k);

% feature extraction with Relief algorithm and k = 10
X = data_trn(:,1:end-1);
y = data_trn(:,end);
k = 10;
[idx,weights] = relieff(X,y,k);         % idx contains the indices of the most important features 
                                        % and weights contains the corresponding weight of each index 

fold = 5;                               % 5-fold

rules = zeros(length(features_number),length(cluster_radius));
comb_errors = zeros(length(features_number),length(cluster_radius));

%% GRID SEARCH
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

            train_x = data_trn(trn_idx, features);
            train_y = data_trn(trn_idx, end);

            val_x = data_trn(test_idx, features);
            val_y = data_trn(test_idx, end);
                
            sugeno_fis = genfis2(train_x, train_y,  cluster_radius(r));    % sugeno model 

            anfis_opt = anfisOptions('InitialFIS', sugeno_fis,...          % choose options 
                                     'EpochNumber', 50,...
                                     'DisplayANFISInformation', 0,...
                                     'DisplayErrorValues', 0,...
                                     'DisplayStepSize', 0,...
                                     'DisplayFinalResults', 0,...
                                     'ValidationData', [val_x val_y]);
            % train                      
            [fis,trainError,stepSize,chkFIS,testError] = anfis([train_x train_y], anfis_opt);
            errors(k) = min(testError);
        end
        rules(f, r) = length(sugeno_fis.rule);
        comb_errors(f, r) = sum(errors) / fold; % divide with fold = 5 in order to take the mean 

    end
end

%% OPTIMAL 
% find minimum error 
minimum_error = min(comb_errors(:));

% find features with minimum error 
[features, radius] = find(comb_errors==minimum_error);

% optimal features 
attr = idx(1:features_number(features));

% optimal model
sugeno_fis = genfis2(data_trn(:, attr), data_trn(:, end),  cluster_radius(radius));            

anfis_opt = anfisOptions('InitialFIS', sugeno_fis,...          % choose options 
                                     'EpochNumber', 100,...
                                     'DisplayANFISInformation', 0,...
                                     'DisplayErrorValues', 0,...
                                     'DisplayStepSize', 0,...
                                     'DisplayFinalResults', 0,...
                                     'ValidationData', data_val(:,[attr, end]));
% train optimal model                      
[fis,trainError,stepSize,chkFIS,testError] = anfis(data_trn(:, [attr, end]), anfis_opt);  

% ground truth 
y_real = data_test(:, end);
average_y = mean(y_real);

% predict the result
y_predicted = evalfis(data_test(:,attr), chkFIS);

% metrics 
MSE = sum((y_real - y_predicted).^2) / length(data_test);
RMSE = sqrt(MSE);
SSres = sum((y_real - y_predicted).^2);
SStot = sum((y_real - average_y).^2);
R_square = 1 - SSres / SStot;
NMSE = SSres / SStot;
NDEI = sqrt(NMSE);


toc