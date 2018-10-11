function [Reaction_Order, k_cell, is_func, func_inputs] = Build_Reaction_Order(Wanted_Rxns)
%Build_Reaction_Order.m
%Processes the kinetics strucutre Wanted_Rxns	
	
reaction_names = fieldnames(Wanted_Rxns);
Reaction_Order = struct();
k_cell = cell(numel(reaction_names),1);
is_func = false(numel(reaction_names),1);
func_inputs = cell(numel(reaction_names),1);

for rnInd = 1:numel(reaction_names)
    curr_rxn_name = reaction_names{rnInd};
    Reaction_Order(1).(curr_rxn_name) = rnInd;
    curr_rxn = Wanted_Rxns.(curr_rxn_name);
    encapsulated = {curr_rxn.k};
    k_cell(rnInd) = encapsulated; %Matlab is stupid. 
    
    if isfield(curr_rxn,'func_inputs')
        is_func(rnInd) = 1;
        func_inputs{rnInd} = curr_rxn.func_inputs;
    end
    
end