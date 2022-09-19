% Tuning Plot for a given cell.  
% Plots the firing rate across the angles in a center-reach-out task 

width = 3;     % Width in inches
height = 3;    % Height in inchesRMSE = sqrt(mean((y - yhat).^2)); 
alw = 1.75;    % AxesLineWidth
fsz = 26;      % Fontsize
lw = 2.5;      % LineWidth
msz = 8;       % MarkerSize()

angles = [];
firing_rates = [];

% Choose cell number to visualize
%cell = 10;
VISUALIZE = 1;

for index = 1 : size(ReachData,2)
    
    A = ReachData(index).A;
    target = ReachData(index).target';
    
    [~,I] = max(A(:));
    %[~, cell] = ind2sub(size(A),I);
    
    [max_firing_rate,I_col] = max(A(:,cell));
   
    
    %center = [0.304432; -0.186052; 0.207766];
    center = [0.304432; 0.207766];
    target = [target.x, target.z];
    if(size(target,1) == 1)
        target = target';
    end
    target;
    r = norm(target - center);
    
    theta = acos((target(1)-center(1))/r);
    %theta = atan2((target(2)-center(2)),(target(1)-center(1)));
    if(sign(target(2) - center(2))) < 0
        theta = 2*pi - theta;   
    end
    
    angles = [angles; theta];
    firing_rates = [firing_rates; max_firing_rate];
   
end

[angles, Index] = sort(angles);
firing_rates = firing_rates(Index);

options = fitoptions('Method','Smooth','SmoothingParam',0.95);
[f,gof] = fit(angles, firing_rates,'smoothingspline', options);
%[f,gof] = fit(angles, firing_rates,'poly3');

gof.rsquare;

if VISUALIZE
    h = plot(f, angles, smooth(firing_rates));
    set(h,  'LineWidth', 2.5, 'MarkerSize', 0.01);
    
    hold on;
    plot(angles, firing_rates, '*', 'MarkerSize', msz);
    
    set(gca, 'FontSize', fsz, 'LineWidth', 2.5);
    xlabel('Angle');
    ylabel('Firing Rate');
    xlim([0,2*pi]);
    legend('off');
    
    %display('rsquare');
end

%saveas(gcf,'Tuning9.fig');
%saveas(gcf,'Tuning9.eps', 'epsc');
