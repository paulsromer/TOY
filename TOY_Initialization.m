function [G,G1,G2,Reaction_Order,Rxn_Data,Species_Order,k_cell, num_rxns, num_species]...
    = TOY_Initialization(kinetics_file)
%TOY.m
run(kinetics_file)

all_rxns = who('r*');
num_rxns = numel(all_rxns);
Rxn_Data = struct([]);
for nInd = 1:num_rxns
    curr_rxn = all_rxns{nInd};
    Rxn_Data(1).(curr_rxn) = eval(curr_rxn);
end

Species_Order = Build_Species_List(Rxn_Data);


[Reaction_Order k_cell] = Build_Reaction_Order(Rxn_Data);
[G, G1, G2] = Build_Stoichometry(Rxn_Data,Reaction_Order,Species_Order);
SO = Species_Order;
num_species = numel(fieldnames(Species_Order));

a = 17;

    

k_vector = zeros(num_rxns,1);
%Still to do: Diffusion/Deposition rates for these things. I think S&P
%talks about both. ANd also figure out what to do about this k thing. 
prev_time_coord = 0; prev_space_coord = 0;
disp('Loaded Stuff');
a = 17;
