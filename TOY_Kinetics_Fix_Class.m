function [delta_C] = TOY_Kinetics_Fix_Class(t,C,k_vector,G1,G2,G,able_to_change,is_RO2,RO2_ind,fixed_classes,adj_as,fancy_k_data)
	% TOY_Kinetics_Fix_Class.m
	% Sub-function which handles acutally evaluating the differential equations. 
  % Includes an extra check to handle fixed clases. 

num_species = numel(able_to_change);
C = C(1:num_species);
C_forG12 = [C; 1]; %This unfornatuely needs to be there to be a null case. Should still be ok. 
eps = k_vector.*(G1*C_forG12).*(G2*C_forG12);
delta_C = G*eps;
delta_C(1:num_species) = delta_C(1:num_species).*able_to_change;
delta_C(RO2_ind) = sum(delta_C(is_RO2));
delta_C;
species_delta = delta_C(1:num_species);
for ind = 1:size(fixed_classes,2)
    total_adj = sum(species_delta(fixed_classes(:,ind)==1));
    distributed_adj = total_adj.*adj_as(:,ind).*-1;
    new_species_delta = species_delta + distributed_adj;
    delta_C(1:num_species) = new_species_delta;
    if sum(new_species_delta(fixed_classes(:,ind)==1)) > 1e-8
        sum(new_species_delta(fixed_classes(:,ind)==1))
    end
end


