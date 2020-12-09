figure
% 3-d bar plot Mean square error, number of features and claster radius 
bar3(comb_errors)
title('Error for different number of features and cluster radius');
zlabel('MSE');
ylabel('Number of feature');
xlabel('Radius values');
yticklabels({'3','9','15','21'});
xticklabels({'1st','2nd','3rd','4th'});

figure
% 3-d bar plot rules, number of features and claster radius
bar3(rules)
title('Rules for different number of features and cluster radius');
zlabel('Number of rules');
ylabel('Number of feature');
xlabel('Radius values');
yticklabels({'3','9','15','21'});
xticklabels({'1st','2nd','3rd','4th'});

% plot training and validation error
figure
hold on 
epochs = 1:length(trainError);
plot(epochs, trainError);
plot(epochs, testError);
title('Learning curves') 
xlabel('epochs')
ylabel('MSE')
legend('MSE for Training data','MSE for Testing data')
hold off 

% plot real and predicted values 
samples_length = 1:length(data_test);
plot(samples_length, y_predicted);
plot(samples_length, y_real);
xlabel('sample')
ylabel('value')
title('Predicted and real values') 
legend('real value','predicted value')

% plot initial membership functions
for j = 1:5
    [x,mf] = plotmf(sugeno_fis,'input',j);
    subplot(2,3,j)
    plot(x,mf);
    title(['Input ' num2str(j)])
    ylabel('Membership value');
    xlabel('Input value');
end

% plot final membership functions
for j = 1:5
    [x,mf] = plotmf(chkFIS,'input',j);
    subplot(2,3,j)
    plot(x,mf);
    title(['Input ' num2str(j)])
    ylabel('Membership value');
    xlabel('Input value');
end