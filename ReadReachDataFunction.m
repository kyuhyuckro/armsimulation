function [return_data] = ReadReachDataFunction(data)

folder_name = data;  %'data11006'; %'data11005'; %nn_8_data %'rnn_data'; %'lstm_data', %'data1100'

%files = dir(fullfile (folder_name, '*.mat'));
files = dir(fullfile(folder_name, '*.mat'));
nbr_files = size(files,1);

max_nbr_timesteps = 0;

for i = 1 : nbr_files
    filename = folder_name + files(i).name;
    load(filename); 
    ReachData(i).A = C; 
    ReachData(i).target = target;
    nbr_timesteps = size(time,1);
    
    times = 0 : 0.35/nbr_timesteps : 0.35;
    ReachData(i).times = times(1:end-1);
    
    %ReachData(i).times = time;
    max_nbr_timesteps = max(size(C,1), max_nbr_timesteps);
end

splines = {};
for i = 1 : nbr_files
   splines{i} = spline(ReachData(i).times, ReachData(i).A'); 
end

times = 0 : 0.35/max_nbr_timesteps : 0.35;

for i = 1 : nbr_files
    ReachData(i).A = ppval(splines{i}, times(1:end-1))';
    ReachData(i).times = times(1:end-1)';
end

return_data = ReachData;

end