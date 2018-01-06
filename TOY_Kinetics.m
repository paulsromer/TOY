function [delta_C] = TOY_Kinetics(t,C,k_vector,G1,G2,G,able_to_change,is_RO2,RO2_ind,fancy_k_data)
% %Gives the kinetics for this thing. There's a way to only initalize these
% %variables once isn't there? 

% Ok, now I have to figure out how to actually use this data. I think it's
% probably that we need to modify the k_vector here:
for fkInd = 1:size(fancy_k_data,1)
    cell_conc_data = num2cell(C(fancy_k_data{fkInd,3}));
    curr_func = fancy_k_data{fkInd,2};
    k_vector(fancy_k_data{fkInd,1}) = curr_func(cell_conc_data{:});
end

num_species = numel(able_to_change);
C = C(1:num_species);
C_forG12 = [C; 1]; %This unfornatuely needs to be there to be a null case. Should still be ok. 
eps = k_vector.*(G1*C_forG12).*(G2*C_forG12);
delta_C = G*eps;
delta_C(1:num_species) = delta_C(1:num_species).*able_to_change;
delta_C(RO2_ind) = sum(delta_C(is_RO2));
delta_C;
% if t > 3600*2
%     a = 17;
% end

