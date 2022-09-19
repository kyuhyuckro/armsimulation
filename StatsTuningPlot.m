% loops over cells in network.
% call TuningPlot function to obtain the R2 error.

cells_R2 = [];

cells_fitted_angles = [];

for cell = 1 : size(ReachData(1).A,2)
   TuningPlot;
   
   %{
   if ~isnan(gof.rsquare)
       cells_R2 = [cells_R2; gof.rsquare];
    else
       cells_R2 = [cells_R2; 0];
   end
   %}
  
 
  
   %TuningLeastSquares;
   R2 = gof.rsquare;
   size(cells_R2);
   if ~isnan(R2)
       cells_R2 = [cells_R2; R2];
       %cells_fitted_angles = [cells_fitted_angles; max_tuned_angle];
       cells_fitted_angles = [cells_fitted_angles; I_col];

    else
       cells_R2 = [cells_R2; 0];
       cells_fitted_angles = [cells_fitted_angles; 0];
   end
   clear gof
end
%%
cell_numbers = 1 : 1: size(ReachData(1).A,2);

[scells_R2, I] = sort(cells_R2);

cell_numbers = cell_numbers(I);
cells_fitted_angles =  cells_fitted_angles(I);


[~,idx] = ismembertol([.5:.1:1], scells_R2, 1E-2);

nbr_cells = size(scells_R2,1);
sum(idx)
(nbr_cells - sum(idx))/(nbr_cells)
