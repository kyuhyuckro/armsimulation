function [output, rsquare] = TuningLeastSquares(cell,ReachData,VISUALIZE)

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

VISUALIZE = 0;

%cell = 80;

targets = [];

thetas = [];

for index = 1 : size(ReachData,2)

    

    A = ReachData(index).A;

    target = ReachData(index).target';

    targets = [targets; target];

    

    [M,I] = max(A(:));

    [I_row, I_col] = ind2sub(size(A),I);

    

    %[max_firing_rate,I_col] = max(A(:));

    %plot(A(:,I_col));

    

    %center = [0.304432; -0.186052; 0.207766];

    center = [0.304432; 0.207766];

    target = [target.target_x, target.target_z];

    if(size(target,1) == 1)

        target = target';

    end

    target;

    r = norm(target - center);

    

    theta = acos((target(2)-center(2))/r);

    

    if(sign(target(1) - center(1))) < 0

        theta = 2*pi - theta;   

    end

    

     thetas = [thetas; theta];

    

    %for cell = 18 : 18

        max_cell_firing_rate = max(A(:,cell));

    %end

    

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

x = MA \ max_cell_firing_rates;

[angles, Index] = sort(angles);

max_cell_firing_rates = max_cell_firing_rates(Index);

if VISUALIZE

    plot(angles, max_cell_firing_rates, '*', 'MarkerSize', msz);

    hold on;

end

% decide how many angles

KNOTS = 8;

fitted_angles = zeros(KNOTS,1);

fitted_firing_rates = zeros(KNOTS,1);

for knot = 1 : KNOTS

    angle = knot/KNOTS * 2 * pi;

    fitted_angles(knot) = angle;

    fitted_firing_rates(knot) = [1, sin(angle), cos(angle)] * x;

end

if VISUALIZE

    h = plot(fitted_angles, fitted_firing_rates);

    set(h,  'LineWidth', 3.5, 'MarkerSize', 0.01);

    set(gca, 'FontSize', fsz, 'LineWidth', 2.5);

    xlim([0,2*pi]);

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

R2

[m,v]=max(fitted_firing_rates);

max_tuned_angle = fitted_angles(v);

rsquare = R2

output = max_tuned_angle

%s = spline(angles, firing_rates);

%cs = csapi(angles,firing_rates);

%fnplt(cs, 4);

%plot(angles, smooth(firing_rates), 'LineWidth', 2.5);

%s = spap2(5, 4, angles, smooth(firing_rates));

%{

options = fitoptions('Method','Smooth','SmoothingParam',0.95);

[f,gof] = fit(angles, firing_rates,'smoothingspline', options);

h = plot(f, angles, smooth(firing_rates));

set(h,  'LineWidth', 2.5, 'MarkerSize', 0.01);

hold on;

plot(angles, firing_rates, '*', 'MarkerSize', msz);

set(gca, 'FontSize', fsz, 'LineWidth', 2.5);

xlabel('Angle');

ylabel('Firing Rate');

xlim([0,2*pi]);

legend('off');

display('rsquare');

gof.rsquare

%}

%saveas(gcf,'Tuning6.fig');

%saveas(gcf,'Tuning6.eps', 'epsc');