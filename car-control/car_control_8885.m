%% FUZZY SYSTEMS 2020 - 2021
% Car Control - Group 1 
% Stefanos Papadam 
% AEM: 8885

%% CLEAR 
clear 
clc

%% INITIALIZATION
% initial coordinates 
x_initial = 4.1;
y_initial = 0.3;

% initial orientation 
thetas = [0 -45 -90];

% initial velocity
u = 0.05;

% x position's error 
error = 0.03; 

% desired coordinates  
x_desired = 10; 
y_desired = 3.2; 

% initial distance from the obstacle 
dh = 5 - x_initial;
dv= y_initial;

%% FUZZY MODEL 
% load model
%fuzzy_system = readfis('car_fuzzy_controller_8885');
fuzzy_system = readfis('car_fuzzy_controller_8885_opt');

%% PLOT INITIAL FUNCTIONS
figure;
plotmf(fuzzy_system, 'input',1);
title('Membership function of input "dv"');
xlim([0 1])
xticks([0 0.5 1]);

figure;
plotmf(fuzzy_system, 'input',2);
title('Membership function of input "dh"');
xlim([0 1])
xticks([0 0.5 1]);

figure;
plotmf(fuzzy_system, 'input',3);
title('Membership function of input "theta"');
xlim([-180 180])
xticks([-180 0 180]);

figure;
plotmf(fuzzy_system, 'output',1);
title('Membership function of output "dtheta"');
xlim([-130 130])
xticks([-130 0 130]);

%% START
% for each initial state 
for i = 1:3
    
    theta = thetas(i);
    x_values = x_initial;
    y_values = y_initial;
    
    x = x_initial;
    y = y_initial;
    while abs(x - x_desired) > error
        % limit to range [0 1] (acceptable inputs)
        if dh >= 1
            dh = 1;
        elseif dh <= 0
            dh = 0;
        end
        if dv >= 1
            dv = 1;
        elseif dv <= 0
            dv = 0;
        end
        % calculate delta theta from the fuzzy system 
        dtheta = evalfis([dv dh theta], fuzzy_system);
        theta = theta + dtheta;
        
        % calculate car's position 
        x = x + u * cosd(theta);
        y = y + u * sind(theta);
        
        % save all x and y values (car's trajectory)
        x_values = [x_values x];
        y_values = [y_values y];
        
        if y <=1
            dh = 5 - x;
            dv = y;
        elseif y <= 2 
            dh = 6 - x;
            if x >= 5
                dv = y - 1;
            else 
                dv = y;
            end
        elseif y <= 3
            dh = 7 - x;
            if x >= 6
                dv = y - 2;
            elseif x >=5 
                dv = y - 1;
            else
                dv = y;
            end
        else
            dh = 1;
            if x >= 7
                dv = y - 3;
            elseif x >= 6
                dv = y - 2;
            elseif x >= 5
                dv = y - 1;
            else 
                dv = y;
            end
        end 
    end
    
    fprintf('x: %s, y: %s \n',x,y);
    fprintf('dif_x: %s\n', ((x - x_desired) / x_desired) * 100);
    fprintf('dif_y: %s\n\n', ((y - y_desired) / y_desired) * 100);
    
    figure
    hold on
    
    % obstacle plot as rectangles 
    rectangle('Position',[5,0,1,1],'FaceColor',[0.5 0.5 0.5], 'EdgeColor', [0.5 0.5 0.5])
    rectangle('Position',[6,0,1,2],'FaceColor',[0.5 0.5 0.5], 'EdgeColor', [0.5 0.5 0.5])
    rectangle('Position',[7,0,3,3],'FaceColor',[0.5 0.5 0.5], 'EdgeColor', [0.5 0.5 0.5])
    
    % plot trajectory, final and desired position 
    title(['Starting angle: ', num2str(thetas(i))]);
    
    plot(x_values,y_values, 'r')
    plot(x_desired,y_desired,'b*')
    plot(x,y,'r*')
    
end