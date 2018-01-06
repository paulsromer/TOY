function [new_k_cell, fancy_ks_cell] = Build_Fancy_Kinetics(k_cell,is_func,func_inputs,Species_Order,other_inputs,vector_size)
%%
a = 17;
%Loop through all the reactions:
new_k_cell = cell(size(k_cell,1),size(k_cell,2));
fancy_ks_cell = cell(sum(is_func),3);
fk_ind = 0;

for rInd = 1:numel(k_cell)
    if ~is_func(rInd)
        new_k_cell{rInd} = k_cell{rInd};
        continue;
    end
    %If it is a function, then we have to start to get fancy
    
    new_k_cell{rInd} = '1';
    fk_ind = fk_ind + 1;
    fancy_ks_cell{fk_ind,1} = rInd;
    func_collection = cell(1,numel(vector_size));
    
    for cInd = 1:vector_size
        Extract_Struct_ind(other_inputs,cInd);
        func_collection{cInd} = eval(k_cell{rInd});
    end
    fancy_ks_cell{fk_ind,2} = func_collection;
    
    species_indices = nan(1,numel(func_inputs{rInd}));
    for sInd = 1:numel(func_inputs{rInd})
        curr_sp_name = func_inputs{rInd}{sInd};
        species_indices(sInd) = Species_Order.(curr_sp_name);
    end
    fancy_ks_cell{fk_ind,3} = species_indices;
       
    
    
    
end
        
a = 18;

return

function [var_names] = Extract_Struct_ind(input_struct,cInd)
%input_struct: Structure you want extracted
%forbidden_names: Names that can't be variables in the caller workspace.
%   These can be reg-ex's


q = fieldnames(input_struct);
for ind = 1:numel(q)
    curr_name = q{ind};
    curr_data = input_struct.(curr_name);
    assignin('caller',curr_name,curr_data(cInd));
end

var_names = q;
    