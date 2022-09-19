% Run code: ReadReachData in this folder.
% Uncomment code below.
% Run StatsTuningPlot.m

angles = [];
firing_rates = [];
AT = [];

for index = 1 : size(ReachData,2)
    
    A = ReachData(index).A;
    %A = A.*0;
%     for q = 1:size(A,1)
%         A(q,:) = cos(1:length(A(q,:)));
%     end
    AT = [AT; A];
    target = ReachData(index).target;
    
    %[~,I] = max(A(:));
    %[~, cell] = ind2sub(size(A),I);   
    %[max_firing_rate,I_col] = max(A(:,cell));
    %plot(A(:,I_col));
    center = [0.304432; 0.207766];
    target = [target.x, target.z];
    r = norm(target - center);
   
    theta = acos(abs(target(1)-center(1))/r);

    x_dir = sign(target(1) - center(1));
    y_dir = sign(target(2) - center(2));
    
    if x_dir < 0 && y_dir > 0
        theta = pi - theta;
    elseif  y_dir < 0 && x_dir > 0
        theta = 2*pi - theta;   
    elseif  y_dir < 0 && x_dir < 0
        theta = pi + theta;
    end
    
    angles = [angles; theta];
    %firing_rates = [firing_rates; max_firing_rate]; 
end

width = 3;     % Width in inches
height = 3;    % Height in inches
alw = 2.75;    % AxesLineWidth
fsz = 18;      % Fontsize
lw = 4.5;      % LineWidth
msz = 8;       % MarkerSize

initPos_X = 0.304432; 
initPos_Y = 0.207766; 

factor = 1000;

r = 0.15;

x = [0.539 - initPos_X, 0.3887 - initPos_X, 0.2387 - initPos_X, 0.3887- initPos_X, r * cos(0.875 * 2 * pi), ...
    r * cos(0.125 * 2 * pi), r * cos(0.3750 * 2 * pi), r * cos(5/8 * 2 * pi)];

y = [0.233 - initPos_Y,0.3835 - initPos_Y,  0.2335 - initPos_Y, 0.0835 - initPos_Y, r * sin(0.875 * 2 * pi), ...
    r * sin(0.125 * 2 * pi), r * sin(0.3750 * 2 * pi), r * sin(5/8 * 2 * pi)];

a = 1000 * ones(8,1);

scatter(factor*x,factor*y,a,'MarkerFaceColor','b','MarkerEdgeColor','b',...
    'MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2)

hold on;
set(gca, 'LineWidth', lw)
set(gca,'FontSize', fsz);

xlabel('x (mm)')
ylabel('y (mm)')

set(gca,'Ytick',-200:50:200);
set(gca,'Xtick',-200:50:200);

xlim([-275, 275]);
ylim([-275, 275]);

dimReach = size(A,1);
nbr_cells = size(A,2);

cell_pd = -1*ones(nbr_cells,1); %each cell's preferred direction 
cell_ai = -1*ones(nbr_cells,2);

for cell = 1 : nbr_cells
    [~,row] = max(AT(:, cell));
    reach = floor(row/dimReach) + 1;
    if reach <= size(angles,1)
        cell_pd(cell) = angles(reach);
    end
end


r = 0.15;
theta_targets = [0; pi/2; pi; 3*pi/2; 0.125 * 2*pi; 0.8750 * 2*pi; ...         
    0.375*2*pi; 5/8*2*pi];

sum_diff = 0;

for theta_idx = 1 : size(theta_targets,1)
    
    reach_direction = [r * cos(theta_targets(theta_idx)), r * sin(theta_targets(theta_idx))];

    %theta = acos((reach_direction(1))/r);    
    theta = acos(abs((reach_direction(1)))/r);

    x_dir = sign(reach_direction(1));
    y_dir = sign(reach_direction(2));
    
    if x_dir < 0 && y_dir > 0
        theta = pi - theta;
    elseif  y_dir < 0 && x_dir > 0
        theta = 2*pi - theta;   
    elseif  y_dir < 0 && x_dir < 0
        theta = pi + theta;
    end
    
    %if(sign(reach_direction(2))) < 0
    %    theta = 2*pi - theta;   
    %end

    for cell = 1 : nbr_cells
        ei = [cos(cell_pd(cell)); sin(cell_pd(cell))];
        cell_ai(cell,:) = (cos(theta - cell_pd(cell)) * ei)';   
    end

    %reach_direction = [target(1) - center(1),target(3) - center(3)];

    h_reach_dir = plot(factor*(reach_direction(1) + 0.1*1/(norm(reach_direction))*[0;reach_direction(1)]), factor*(reach_direction(2) ...
        + 0.1*1/(norm(reach_direction))*[0;reach_direction(2)]), ...
        'LineWidth', 3.5, 'Color', 'Yellow');
    hold on;

    sum_pop = [0;0];
    
    for cell = 1 : nbr_cells
        sum_pop = sum_pop + cell_ai(cell,:)';
    end

    sum_pop = sum_pop/norm(sum_pop);
    h_sum_pop = plot(factor * (reach_direction(1) + 0.1*[0;sum_pop(1)]), ...
    factor*(reach_direction(2) + 0.1*[0;sum_pop(2)]), ...
    'LineWidth', 3.5, 'Color', 'Blue');
    hold on;

    for cell = 1 : nbr_cells
        v = cell_ai(cell,:)';
        plot(factor*(reach_direction(1) + 0.1*[0;v(1)]), ...
        factor*(reach_direction(2) + 0.1*[0;v(2)]), 'Color', 'Red');
        hold on;
    end
    
    diff = acos(reach_direction * sum_pop)/(norm(reach_direction) * norm(sum_pop));
    sum_diff = sum_diff + diff;

end

avg_diff = sum_diff/(size(theta_targets,1));

%saveas(gcf,'Pop0.fig');
%saveas(gcf,'Pop0.eps', 'epsc');
%legend([h_reach_dir h_sum_pop], {'Movement Direction','Population Vector'});