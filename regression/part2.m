clear;

%% DATA
tic
% load data 
data = table2array(readtable('train.csv'));

% split data 
[data_trn, data_val, data_test] = split_scale(data, 1);

features_number = [4, 6, 9, 12];
cluster_radius = [0.2, 0.3, 0.4, 0.5, 0.6];

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

comb_errors = zeros(length(features_number),length(cluster_radius));

% grid search
for i = 1:length(features_number)       % examine every combination between features number and cluster radius 
    
    features = idx(1:features_number(i));
    
    for j = 1:length(cluster_radius)   

        errors = zeros(fold,1);

        for k = 1:fold 
            trn_idx = partition.training(k);  % identify the observations that are in the training set
            test_idx = partition.test(k);     % identify the observations that are in the test set

            train_x = data_trn(trn_idx, features);
            train_y = data_trn(trn_idx, end);

            val_x = data_trn(test_idx, features);
            val_y = data_trn(test_idx, end);
                
            sugeno_fis = genfis2(train_x, train_y,  cluster_radius(j));

            anfis_opt = anfisOptions('InitialFIS', sugeno_fis,...
                                     'EpochNumber', 50,...
                                     'DisplayANFISInformation', 0,...
                                     'DisplayErrorValues', 0,...
                                     'DisplayStepSize', 0,...
                                     'DisplayFinalResults', 0,...
                                     'ValidationData', [val_x val_y]);
                                 
            [fis,trainError,stepSize,chkFIS,testError] = anfis([train_x train_y], anfis_opt);
            errors(k) = min(testError);
        end
        
        comb_errors(i,j) = sum(errors) / fold; % divide with fold = 5 in order to take the mean 

    end
end

toc