function [G, G1, G2] = Build_Stoichometry(Rxn_Data,Rxn_Order,Species_Order)
disp('Building Stoichometry')
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
            disp('Problem with my system! More than two reactants in a step')
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
%G1 = G1'; G2 = G2'; 
%Needs to be this way to multiply well...because we're looking for
%something different than with G. 
%Now this part is a little sketchy..modification to G2 to take into account
%when we don't care about a thing. 
return