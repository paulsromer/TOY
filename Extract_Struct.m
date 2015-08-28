function [var_names] = Extract_Struct(input_struct,forbidden_names,is_forbidden)
%input_struct: Structure you want extracted
%forbidden_names: Names that can't be variables in the caller workspace.
%   These can be reg-ex's

if ~exist('forbidden_names','var')
    forbidden_names = {};
end
if ~exist('is_forbidden','var')
    is_forbidden = true;
end

q = fieldnames(input_struct);
is_bad = zeros(1,numel(q));
for ind = 1:numel(forbidden_names)
    m = ~cellfun(@isempty,regexp(q,forbidden_names{ind}));
    is_bad(m) = 1;
end

if is_forbidden %Using this variable, we can either run it as a white list or a black list
    is_bad = is_bad == 1;
else
    is_bad = is_bad == 0;
end

if sum(is_bad == 1) > 0
    disp('The following variable names are not allowed:')
    i = find(is_bad);
    for ind = i
        disp(q{ind})
    end
    error('Bad Inputs');
end



for ind = 1:numel(q)
    curr_name = q{ind};
    curr_data = input_struct.(curr_name);
    assignin('caller',curr_name,curr_data);
end

var_names = q;