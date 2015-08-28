function output_struct = Pad_Struct(input_struct,vector_size)

q = fieldnames(input_struct);
output_struct = input_struct;
for ind = 1:numel(q)
    curr_name = q{ind};
    curr_data = input_struct.(curr_name);
    if numel(curr_data) == vector_size
        output_struct.(curr_name) = curr_data;
    elseif numel(curr_data) == 1 %This should be everything else
        output_struct.(curr_name) = repmat(curr_data,1,vector_size);
    else
        disp('Something went wrong!')
        error('Error');
    end
end

        