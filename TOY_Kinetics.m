function [delta_C] = TOY_Kinetics(t,C,k_vector,G1,G2,G,able_to_change)
% %Gives the kinetics for this thing. There's a way to only initalizet hese
% %variables once isn't there? 
num_species = numel(able_to_change);
C = C(1:num_species);
C_forG12 = [C; 1]; %This unfornatuely needs to be there to be a null case. Should still be ok. 
eps = k_vector.*(G1*C_forG12).*(G2*C_forG12);
delta_C = G*eps;
delta_C(1:num_species) = delta_C(1:num_species).*able_to_change;
% if t > 3600*2
%     a = 17;
% end

