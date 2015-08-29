function old_format_r = Translate_Rxn_Inputs(new_format_r,starting_name)

%%


% r_OH_Isoprene = struct('k','1e-10',...
%     'scheme','1*OH + C5H8 -> 0.31*ci1 + 0.31*tr1 + 0.22*ci2 + 0.09*tr2',... 
%     'ksource','LIM1');
% new_format_r = r_OH_Isoprene;

old_format_r = struct();
old_format_r.k = new_format_r.k; %That's easy.

%Ok, now we have to do string processing in matlab :(
C = strsplit(new_format_r.scheme,'->');
loses = C{1}; gains = C{2};
reactants = strsplit(loses,'+');
products = strsplit(gains,'+');
[loss_name, loss_num] = Process_Reaction_Side(reactants,true);
[gain_name, gain_num] = Process_Reaction_Side(products,false);
old_format_r.loss = loss_name;
old_format_r.gain = struct('name',gain_name,'value',gain_num);


old_format_r.ksource = new_format_r.ksource; %That's also easy

%The old format I want to match:
% r_OH_Isoprene = struct('k','1e-10','loss',{{'OH','C5H8'}},...
%     'gain',struct('name',{'ci1','tr1','ci2','tr2'},'value',{0.31,0.31,0.22,0.09}),...
%     'ksource','LIM1');



return


function [names, nums] = Process_Reaction_Side(scheme_input,is_reac)
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