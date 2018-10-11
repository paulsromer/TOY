function [G, G1, G2] = Build_Stoichometry(Rxn_Data,Rxn_Order,Species_Order)
%Uses the information in Rxn_Data to build up the stoichometry matrices G, G1, and G2.
%G1 and G2 are used to calculate the reaction rates, and G is used to determine the effects of reactions on species concentrations. 
	
all_rxn = fieldnames(Rxn_Order);
num_rxn = numel(all_rxn);

all_species = fieldnames(Species_Order);
num_species = numel(all_species);
G = zeros(num_species+num_rxn,num_rxn); %To put in my eps
G1 = zeros(num_rxn,num_species+1); 
G2 = zeros(num_rxn,num_species+1);
eps_system = 1;
for rInd = 1:num_rxn
    curr_rxn_name = all_rxn{rInd};
    curr_rxn = Rxn_Data.(curr_rxn_name);
    curr_loss_species = curr_rxn.loss;
    row_ind = Rxn_Order.(curr_rxn_name);
    for lsInd = 1:numel(curr_loss_species)
        if rInd == 10
            a = 17;
        end
        curr_spec = curr_loss_species{lsInd};
        G(Species_Order.(curr_spec),row_ind) = G(Species_Order.(curr_spec),row_ind) -1;
        if lsInd == 1
           G1(row_ind,Species_Order.(curr_spec)) = 1; 
        elseif lsInd == 2
           G2(row_ind,Species_Order.(curr_spec)) = 1;  
        else
            disp('TOY can currently only handle 2 kinetics species in a single basic reaction. Replace with a functional reaction.')
        end
    end
    if ~isempty(curr_rxn.gain)
        for crgInd = 1:numel(curr_rxn.gain)
            curr_spec = curr_rxn.gain(crgInd).name;
            curr_val = curr_rxn.gain(crgInd).value;
            G(Species_Order.(curr_spec),row_ind) = G(Species_Order.(curr_spec),row_ind) + curr_val;
        end
    end
    G(num_species+eps_system,row_ind) = 1; 
    eps_system = eps_system + 1;
end
no_second = find(sum(G2,2)==0);
G2(no_second,end) = 1;
no_first = find(sum(G1,2)==0);
G1(no_first,end) = 1;

return