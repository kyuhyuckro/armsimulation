data_dir = ['1'] 

layer_count = [1];

store_r2 = [];

for j = 1 : length(data_dir)

    ReadReachDataFunction(data_dir(j));

    ReachData = ReadReachDataFunction(data_dir(j));

    ncells = size(ReachData(1).A,2);

    angle = [];

    R2 = [];

    FR = [];

    Vis = 0;

    for cells = 1 : ncells

        [angle(cells,:), R2(cells)] = TuningLeastSquares(cells, ReachData,Vis);

        [FR(cells,:), ~] = CellTuning(cells, ReachData,Vis);

    end

    pctCT = sum(R2 > .75)/ncells;

    [a,b] = corr(angle');

    c1 = a(:,1);

    [ix,iy] = sort(c1)

    figure()

    title('cosine tuned cells with R2 over .75','FontSize',12)

    hold on

    Vis = 1

    iter = 1

    for i = 1 : ncells

        if R2(i) >= .75 && iter < 10

            CellTuning(i, ReachData,Vis)

            iter = iter + 1

        end

    end

    angle(R2<.75) = []

    R2(R2<.75) = []

    figure()

    title('center reachout movement preference','FontSize',28)

    xlabel('x','FontSize',14)

    ylabel('y','FontSize',14)

    hold on

    uniquefrs = unique(angle)

    for i = 1 : length(uniquefrs)

        count(i) = sum(angle == uniquefrs(i))

    end

    %normalize

    count = count/max(count)

    [ii,ix] = max(count)

    for i = 1 : length(uniquefrs)

        if i == ix

            plot([0,count(i)*cos(uniquefrs(i))],[0,count(i)*sin(uniquefrs(i))],'r',"LineWidth",3)

        else

            plot([0,count(i)*cos(uniquefrs(i))],[0,count(i)*sin(uniquefrs(i))],'k',"LineWidth",3)

        end

    end

    store_r2(j) = pctCT;

end

figure();

plot(layer_count, store_r2);