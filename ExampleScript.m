clear all
close all

data_dir = dir();
data_dir = data_dir(3:end-3);
layer_count = [];
for j = 1 : length(data_dir)
    layer_count(j) = str2num(regexprep(regexprep(data_dir(j).name,'[^- 0-9.E(,)/]',''), ' \D* ',' ')) ;
end

[~,ixx]= sort(layer_count);
data_dir = data_dir(ixx);
layer_count = layer_count(ixx)

store_r2 = [];

ZZ = ceil(length(data_dir)/5);

for j = 1 : length(data_dir)
    disp(string((j/length(data_dir))*100) + "% done...")
    ReachData = ReadReachDataFunction(string(data_dir(j).name)+'/');
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
    rawCT = sum(R2 > .75);
    [a,b] = corr(angle');
    c1 = a(:,1);
    [ix,iy] = sort(c1);

%     figure()
%     title('cosine tuned cells with R2 over .75','FontSize',12)
%     hold on
%     Vis = 1
%     iter = 1
%     for i = 1 : ncells
%         if R2(i) >= .75 && iter < 10
%             CellTuning(i, ReachData,Vis)
%             iter = iter + 1
%         end
%     end

    angle(R2<.75) = [];
    R2(R2<.75) = [];
%     figure(1)
%     subplot(ZZ,5,j)
%     sgtitle('center reachout movement preference','FontSize',28)
%     title(layer_count(j))
%     xlabel('x','FontSize',14)
%     ylabel('y','FontSize',14)
%     hold on
%     uniquefrs = unique(angle)
%     for i = 1 : length(uniquefrs)
%         count(i) = sum(angle == uniquefrs(i))
%     end
%     %normalize
%     count = count/max(count)
%     [ii,ix] = max(count)
%     for i = 1 : length(uniquefrs)
%         if i == ix
%             plot([0,count(i)*cos(uniquefrs(i))],[0,count(i)*sin(uniquefrs(i))],'r',"LineWidth",3)
%         else
%             plot([0,count(i)*cos(uniquefrs(i))],[0,count(i)*sin(uniquefrs(i))],'k',"LineWidth",3)
%         end
%     end
    store_r2(j) = pctCT; 
    store_raw(j) = rawCT;
end

%%
% 
% figure();
% bar(layer_count, store_r2);
% title('cosine tuning by network layers','FontSize',28)
% xlabel('number of layers in network','FontSize',14)
% ylabel('cosine tuned percentage','FontSize',14)
figure();
bar(layer_count, store_raw);
title('total neurons cosine tuned','FontSize',28)
xlabel('number of layers in network','FontSize',14)
ylabel('cosine tuned neurons','FontSize',14)


figure();
scatter(layer_count+256+15, store_r2);
title('cosine tuning by network layers','FontSize',28)
xlabel('number of layers in network','FontSize',14)
ylabel('cosine tuned percentage','FontSize',14)
figure();
scatter(layer_count+256+15, store_raw);
title('total neurons cosine tuned','FontSize',28)
xlabel('number of layers in network','FontSize',14)
ylabel('cosine tuned neurons','FontSize',14)