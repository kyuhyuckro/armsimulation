nbr_cells = size(cell_numbers,2);

var_cells = zeros(nbr_cells,1);
mean_cells = zeros(nbr_cells,1);

for i = 1 : nbr_cells
   cell = cell_numbers(i);
   TuningPlot;
   var_cells(i) = var(firing_rates);
   mean_cells(i) = mean(firing_rates);
end

