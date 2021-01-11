figure
% 3-d bar plot Mean square error, number of features and claster radius 
bar3(comb_errors)
title('Error for different number of features and cluster radius');
zlabel('MSE');
ylabel('Number of feature');
xlabel('Radius values');
yticklabels({'6', '10', '15', '20'});
xticklabels({'0.15', '0.3', '0.45', '0.6'});

figure
% 3-d bar plot rules, number of features and claster radius
bar3(rules)
title('Rules for different number of features and cluster radius');
zlabel('Number of rules');
ylabel('Number of feature');
xlabel('Radius values');
yticklabels({'6', '10', '15', '20'});
xticklabels({'0.15', '0.3', '0.45', '0.6'});

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

figure
% plot real and predicted values 
hold on 
y_real = testing_data(:, end);
samples_length = 1:length(testing_data);
plot(samples_length, y_predicted);
plot(samples_length, y_real);
xlabel('sample')
ylabel('value')
title('Predicted and real values') 
legend('real value','predicted value')
hold off 

figure
% plot initial membership functions
for j = 1:6
    [x,mf] = plotmf(initial_fis,'input',j);
    subplot(2,3,j)
    plot(x,mf);
    title(['Input ' num2str(j)])
    ylabel('Membership value');
    xlabel('Input value');
end

figure
% plot final membership functions
for j = 1:6
    [x,mf] = plotmf(chkFIS,'input',j);
    subplot(2,3,j)
    plot(x,mf);
    title(['Input ' num2str(j)])
    ylabel('Membership value');
    xlabel('Input value');
end

