function old_format_r = Translate_Rxn_Inputs(new_format_r,other_inputs)
	%Translate_Rxn_Inputs.m
	%Convenience code that translates reactions from the new, revised format (much more human-friendly)
	%to the old format, which is easier for the computer to handle. 
	%Most of the work is from reading the input scheme (e.g., NO + O3 - NO2) and translating it into to species gained and lost. 

old_format_r = struct();
old_format_r.k = new_format_r.k; 

C = strsplit(new_format_r.scheme,'->');
loses = C{1}; gains = C{2};
reactants = strsplit(loses,'+');
products = strsplit(gains,'+');
[loss_name, loss_num] = Process_Reaction_Side(reactants,true,other_inputs);
[gain_name, gain_num] = Process_Reaction_Side(products,false,other_inputs);
old_format_r.loss = loss_name;
old_format_r.gain = struct('name',gain_name,'value',gain_num);


old_format_r.ksource = new_format_r.ksource; %That's also easy

%This section isn't part of the original format, but is added here to allow
%for functional k values. 
if isfield(new_format_r,'func_inputs') 
    old_format_r.func_inputs = new_format_r.func_inputs;
end


return


function [names, nums] = Process_Reaction_Side(scheme_input,is_reac,other_inputs)
    names = {};
    nums = {};
    for rInd = 1:numel(scheme_input)
        curr_part = scheme_input{rInd};
        if isempty(strtrim(curr_part))
            continue
        end
        i = strfind(curr_part,'*');
        if numel(i) == 0
            names = Cell_Append(names,strtrim(curr_part));
            nums = Cell_Append(nums, 1);
        elseif numel(i) == 1
            C = strsplit(curr_part,'*');
            elem_name = C{2};
            elem_stoicheometry = C{1};
            elem_stoicheometry = str2double(elem_stoicheometry);
            if isnan(elem_stoicheometry)
                var_names = Extract_Struct(other_inputs,{'^C$','^curr_part$','^elem_name$','elem_stoicheometry','^i$','^is_reac$','^names$','^nums$','^other_inputs$','^rInd$','scheme_input'});
                elem_stoicheometry = eval(C{1});
            end
            if elem_stoicheometry ~= 1 && is_reac
                disp('Unable to deal with inputs that aren''t 1*reactants yet')
                error('Bad Inputs');
            else
                names = Cell_Append(names,strtrim(elem_name));
                nums = Cell_Append(nums,elem_stoicheometry);
            end
        else
            disp('Can''t deal with multiple *''s in the reaction scheme')
            error('Bad Inputs');
        end
    end

return

function new_cell = Cell_Append(old_cell,to_add) 
    new_cell = {old_cell{:}, to_add};
return