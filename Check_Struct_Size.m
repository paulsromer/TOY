function [output_struct, do_sizes_match, vector_size] = Check_Struct_Size(input_struct,vector_size)

q = fieldnames(input_struct);
output_struct = input_struct;
do_sizes_match = true;
for ind = 1:numel(q)
    curr_field = q{ind};
    if strcmp(curr_field,'is_RO2')
        continue
    end
    curr_data = input_struct.(curr_field);
    sz = size(curr_data);
    if min(sz) > 1 %Make sure it's not a matrix
        disp('All inputs must either be scalars or vectors, not matrices');
        error('Bad Inputs');
    end
    if max(sz) == 1 %If its scalar
        continue
    end
    if sz(1) > 1
        curr_data = curr_data';
    end
    output_struct.(curr_field) = curr_data;
    curr_len = numel(curr_data);
    if isnan(vector_size)
        vector_size = curr_len;
    else
        do_sizes_match = do_sizes_match &&  curr_len == vector_size;
    end
end

