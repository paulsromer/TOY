function [species_list] = Build_Species_List(Wanted_Rxns)
%Takes the structure of structure Wanted_Rxns and uses it to build a list
%of species that we are going to need to keep track of. I hope it works the
%way I want it to. I really wish that there was a simple in command for
%MATLAB. Well, this seems to be working at least. 

rxn_names = fieldnames(Wanted_Rxns);
all_species = {};
for rnInd = 1:numel(rxn_names)
    curr_rxn_name = rxn_names{rnInd};
    curr_struct = Wanted_Rxns.(curr_rxn_name);
    if ~isempty(curr_struct.gain)
        q = {curr_struct.gain(:).name};
        curr_species = unique({q{:} curr_struct.loss{:}});
    else
        curr_species = unique({curr_struct.loss{:}});
    end
       
    all_species = {all_species{:} curr_species{:}};
end
species_names = unique(all_species);
species_list = struct();
for slInd = 1:numel(species_names)
    curr_species_name = species_names{slInd};
    species_list(1).(curr_species_name) = slInd;
end
