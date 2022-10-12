function [output, rsquare] = TuningLeastSquares(cell,ReachData,VISUALIZE,center)
% LEAST SQUARES FIT.
% SOLVE for cosine tuning parameters [b0, b1, b2] in Georgopolous 82. 

width = 3;     % Width in inches
height = 3;    % Height in inchesRMSE = sqrt(mean((y - yhat).^2)); 
alw = 1.75;    % AxesLineWidth
fsz = 26;      % Fontsize
lw = 2.5;      % LineWidth
msz = 8;       % MarkerSizeC()

angles = [];
max_cell_firing_rates = [];
MA = [];

%VISUALIZE = 1;
%cell = 80;
targets = [];
thetas = [];

%%
for index = 1 : size(ReachData,2)
    
    A = ReachData(index).A;
    target = ReachData(index).target';
    
    [M,I] = max(A(:));
    [I_row, I_col] = ind2sub(size(A),I);
    
    %[max_firing_rate,I_col] = max(A(:));
    %plot(A(:,I_col));
    
    %center = [0.304432; -0.186052; 0.207766];
%     center = [0.29707; -0.217857]; 
    f = fields(target);
    target = [target.(f{1}) target.(f{2})];
    targets = [targets; target];
    if(size(target,1) == 1)
        target = target';
    end
    target;
    r = norm(target - center);
    
    theta = acos((target(2)-center(2))/r);
    
    if(sign(target(1) - center(1))) < 0
        theta = 2*pi - theta;   
    end

    deltaX = target(1) - center(1);
    deltaY = target(2) - center(2);
    rad = atan2(deltaY, deltaX); 

    theta = rad;
    
    thetas = [thetas; theta];
    
    max_cell_firing_rate = max(A(:,cell));
    
    if VISUALIZE
        subplot(1,3,1)
        scatter(target(1),target(2),50,max_cell_firing_rate,'filled')
        scatter(center(1),center(2),25,'k','filled')
        colorbar()
        hold on
    end
    
    angles = [angles; theta];
    max_cell_firing_rates = [max_cell_firing_rates; max_cell_firing_rate];
    MA = [MA; 1, sin(theta), cos(theta)];
    
    %display('the max firing rate ')
    %max_firing_rate
    %display('for angle:')
    %theta
    %display('for cell:')
    %cell
end
%%
x = MA \ max_cell_firing_rates;

angles(angles < 0) = angles(angles < 0)+(2*pi);
[angles, Index] = sort(angles);
max_cell_firing_rates = max_cell_firing_rates(Index);

if VISUALIZE 
    subplot(1,3,2)
    plot(angles, max_cell_firing_rates, '*', 'MarkerSize', msz);
    hold on;
end

% decide how many angles

KNOTS = round((2*pi)/min(gradient(angles)));
fitted_angles = zeros(KNOTS,1);
fitted_firing_rates = zeros(KNOTS,1);
for knot = 1 : KNOTS
    angle = knot/KNOTS * 2 * pi;
    fitted_angles(knot) = angle;
    fitted_firing_rates(knot) = [1, sin(angle), cos(angle)] * x;
end

if VISUALIZE
    subplot(1,3,3)
    h = plot(fitted_angles, fitted_firing_rates);
    set(h,  'LineWidth', 3.5, 'MarkerSize', 0.01);
    set(gca, 'FontSize', fsz, 'LineWidth', 2.5);
    hold on
    plot(angles, max_cell_firing_rates, '*', 'MarkerSize', msz);
%     xlim([0,2*pi]);
end

m = mean(max_cell_firing_rates);
ss_res = 0;
ss_tot = 0;

for k = 1 : size(angles)
   diff = [1, sin(angles(k)), cos(angles(k))] * x - max_cell_firing_rates(k);
   ss_res = ss_res + diff^2; 
   ss_tot = ss_tot + (max_cell_firing_rates(k) - m) ^2;
end

R2 = 1 - ss_res/ss_tot;


[m,v]=max(fitted_firing_rates);
max_tuned_angle = fitted_angles(v);

rsquare = R2;
output = max_tuned_angle;