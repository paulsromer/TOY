function [] = Extract_Struct(input_struct)

q = fieldnames(input_struct);
for ind = 1:numel(q)
    curr_name = q{ind};
    curr_data = input_struct.(curr_name);
    assignin('caller',curr_name,curr_data);
end