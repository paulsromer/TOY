function [T_all,Y,Species_Order,Reaction_Order,Y_eps, S, R, R_inst] = TOY(kinetics_file,species_struct,other_inputs,hold_fixed,length_of_run,options)
%TOY.m
%A Simple shell for a box model that you manually put reactions into.
% INPUTS:
% kinetics_file: A .m file with reactions entered - this is where the
%   kinetics for the model run are stored. 
% species_file: Either a .m file, or a structure, with starting
%   concentrations
% other_inputs: A structure with any other variables necessary to evalute
%   the rate constants. This includes T, mM, and also possibly like TUV
%   things. 
% hold_fixed: A cell array of species that should be held at fixed
%   concentrations 
% length_of_run: time to run the model for, in hours
% ode_runner: What matlab should use to run the model. Current options are
%   ode45(slow and accurate) and ode15s(fast and less accurate)

%Names that are not allowed to be used in other_inputs:
forbidden_names = {'r_.*','all_rxns','curr_rxn','G','G1','G2','hold_fixed',...
    'k_cell','k_vector','kinetics_file','length_of_run','nInd','num_rxns',...
    'num_species','runner','Reaction_Order','rInd','Rxn_Data','SO',...
    'species_struct','Species_Order','x','ppb_.*','ppt_.*','m_.*','options'};
for ind = 1:numel(forbidden_names)
    forbidden_names{ind} = strcat('^',forbidden_names{ind},'$');
end


%% Zeroth: Unpack Options, and 

allowed_names = {'runner','want_to_plot','classes_of_interest','fixed_classes','k_dil','Bkgd_Conc','make_plots','silent','MCM_K'};
Extract_Struct(options,allowed_names,false);

%Options dealing with dilution -- currently optional. May become mandatory
%later
if ~exist('k_dil','var')
    k_dil = 1./86400;
end
if ~exist('Bkgd_Conc','var')
    Bkgd_Conc = struct();
end
%Other options
if ~exist('fixed_classes','var')
    fixed_classes = struct('name',{},'comp',{});
end
if ~exist('make_plots','var')
    make_plots = true;
end
if ~exist('silent','var')
    silent = false;
end
if ~exist('MCM_K','var')
    MCM_K = false;
end


%Do a size check on these things
%Things that can be vectors: species_struct, other_inputs, length_of_run
vector_size = nan;
[species_struct, do_sizes_match, vector_size] = Check_Struct_Size(species_struct,vector_size);
if ~do_sizes_match
    disp('Error when processing species_struct - some vectors are different lengths');
end
[other_inputs, do_sizes_match, vector_size] = Check_Struct_Size(other_inputs,vector_size);
if ~do_sizes_match
    disp('Error when processing other_inputs - some vectors are different lengths');
end
q = struct('length_of_run',length_of_run);
[~, do_sizes_match, vector_size] = Check_Struct_Size(q,vector_size);
if ~do_sizes_match
    disp('Error when processing length_of_run - some vectors are different lengths');
end

if isnan(vector_size)
    vector_size = 1;
end
    
%Now we are just going to make everything the same size:
species_struct = Pad_Struct(species_struct,vector_size);
other_inputs = Pad_Struct(other_inputs,vector_size);
length_of_run = repmat(length_of_run./vector_size,1,vector_size);
    

%% First use the provided kinetics and species to build up the framework for this run 

%I now also want to be able to unpack other_inputs to evaluate the reaction yields. So I unpack it,
%evaluate the k's, and then destroy it, just to cut down on the total mess
%that this system can make:
var_names = Extract_Struct(other_inputs,forbidden_names);
if iscell(kinetics_file)
    for ind = 1:numel(kinetics_file)
        curr_file = kinetics_file{ind};
        run(curr_file);
    end
else
    run(kinetics_file)
end

for ind = 1:numel(var_names)
    if strcmp(var_names{ind},'mM')
        continue
    end
    if strcmp(var_names{ind},'T');
        continue
    end
    clear(var_names{ind});
end

%Add in a section to translate my new reaction format into the old reaction
%format
all_new_rxns = who('r2_*');
for nInd = 1:numel(all_new_rxns)
    translated_rxn = Translate_Rxn_Inputs(eval(all_new_rxns{nInd}),other_inputs);
    curr_name = all_new_rxns{nInd};
    new_name = strcat('r_',curr_name(4:end));
    str_to_eval = strcat(new_name,' = translated_rxn;');
    eval(str_to_eval);
end
clear('-regexp', '^r2_.*');

all_rxns = who('r_*');
num_rxns = numel(all_rxns);
Rxn_Data = struct([]);
for nInd = 1:num_rxns
    curr_rxn = all_rxns{nInd};
    Rxn_Data(1).(curr_rxn) = eval(curr_rxn);
end

Species_Order = Build_Species_List(Rxn_Data);
if ~isfield(Species_Order,'RO2')
    x = numel(fieldnames(Species_Order)) + 1;
    Species_Order.RO2 = x;
end

% Add in the dilution reactions:
if isfield(other_inputs,'mM')
    mM = other_inputs.mM;
else
    mM = 2.45e19;
    disp('Using a default molecular density of air of 2.45e19 molec/cc');
end
if k_dil > 0    
    if ~silent,disp('Adding Dilution'); end

    [New_Rxn_Data] = Build_Dilution(Rxn_Data,Species_Order,k_dil,mM,Bkgd_Conc);
else
    New_Rxn_Data = Rxn_Data;
end
clear mM

Rxn_Data = New_Rxn_Data;
num_rxns = numel(fieldnames(Rxn_Data));

[Reaction_Order k_cell is_func func_inputs] = Build_Reaction_Order(Rxn_Data);

if ~silent, disp('Building Stoichometry'); end
[G, G1, G2] = Build_Stoichometry(Rxn_Data,Reaction_Order,Species_Order);
SO = Species_Order;
num_species = numel(fieldnames(Species_Order));

    
clear('-regexp', '^r_.*');
%We need to unpack other_inputs to evaluate the k_vectors. So I unpack it,
%evaluate the k's, and then destroy it, just to cut down on the total mess
%that this system can make:
var_names = Extract_Struct(other_inputs,forbidden_names);
if ~exist('mM','var')
    mM = 2.45e19;
    disp('Using a default molecular density of air of 2.45e19 molec/cc');
end
if MCM_K
    Knames = Calc_MCMv331_K(T,mM);
    %Ok, need to rotate all of these rate constants
    for ind = 1:numel(Knames)
        cx = Knames{ind};
        str = [cx,'= transpose(',cx,');'];
        eval(str);
    end
end


%now evaluate the k's
%k_vector = zeros(num_rxns,1);
[new_k_cell, fancy_ks_cell] = Build_Fancy_Kinetics(k_cell,is_func,func_inputs,Species_Order,other_inputs,vector_size);
k_cell = new_k_cell;
k_matrix = zeros(num_rxns,vector_size);
for rInd = 1:numel(k_cell)
    curr_data = eval(k_cell{rInd});
    if numel(curr_data) == 1    
        k_matrix(rInd,:) = repmat(curr_data,1,vector_size);
    else
        k_matrix(rInd,:) = curr_data;
    end
end
%Clean up:
clear curr_rxn nInd rInd k_cell curr_data
for ind = 1:numel(var_names)
    if strcmp(var_names{ind},'mM')
        continue
    end
    if strcmp(var_names{ind},'T');
        continue
    end
    clear(var_names{ind});
end
if MCM_K
    for ind = 1:numel(Knames)
        clear(Knames{ind});
    end
end

if ~silent,disp('Loaded Reactions'); end

%% Then use the species file to build up the concentrations. We recognize ppb_, ppt_
% and m_

c_matrix =  zeros(num_species,vector_size);
allowed_names = {'^ppb_','^ppt_','^m_','is_RO2'};
Extract_Struct(species_struct,allowed_names,false);

all_ppb = who('ppb_*');
for cInd = 1:numel(all_ppb)
    curr_sf = all_ppb{cInd};
    und = strfind(curr_sf,'_');
    curr_species_name = curr_sf(und+1:end);
    if ~isfield(Species_Order,curr_species_name)
        continue
    end
    curr_order = Species_Order.(curr_species_name);    
    q = eval(curr_sf);
    c_matrix(curr_order,:) = q.*mM./1e9;
end
clear all_ppb
clear('-regexp', '^ppb_*');


all_ppt = who('ppt_*');
for cInd = 1:numel(all_ppt)
    curr_sf = all_ppt{cInd};
    und = strfind(curr_sf,'_');
    curr_species_name = curr_sf(und+1:end);
    if ~isfield(Species_Order,curr_species_name)
        continue
    end
    curr_order = Species_Order.(curr_species_name);
    q = eval(curr_sf);
    c_matrix(curr_order,:) = q.*mM./1e12;
end
clear all_ppt
clear('-regexp', '^ppt_*');


all_m = who('m_*');
for cInd = 1:numel(all_m)
    curr_sf = all_m{cInd};
    und = strfind(curr_sf,'_');
    curr_species_name = curr_sf(und+1:end);
    if ~isfield(Species_Order,curr_species_name)
        continue
    end
    curr_order = Species_Order.(curr_species_name);
    q = eval(curr_sf);
    c_matrix(curr_order,:) = q;
end
clear all_m
clear('-regexp', '^m_.*');
if ~silent, disp('Loaded Species'); end
if ~exist('want_to_plot','var')%If want_to_plot is not a variable, want_to_plot just gets all the species
    want_to_plot = fieldnames(Species_Order);
end
want_to_plot = want_to_plot(isfield(Species_Order,want_to_plot));




able_to_change = ones(size(c_matrix,1),1);
all_able_to_change = able_to_change;
for hfInd = 1:numel(hold_fixed)
    curr_species = hold_fixed{hfInd};
    csInd = Species_Order.(curr_species);
    able_to_change(csInd) = 0;
end

%Process the classes that are fixed
if numel(fixed_classes) > 0
    matrix_fixed_classes = zeros(num_species,numel(fixed_classes));
    matrix_adj = zeros(num_species,numel(fixed_classes));
    for ind = 1:numel(fixed_classes)
        curr_comp = fixed_classes(ind).comp;
        for cInd = 1:numel(curr_comp)
            curr_species_name = curr_comp{cInd};
            matrix_fixed_classes(Species_Order.(curr_species_name),ind) = 1;
        end
        curr_adj = fixed_classes(ind).adjust_as;
        for cInd = 1:numel(curr_adj)
            curr_species_name = curr_adj{cInd};
            matrix_adj(Species_Order.(curr_species_name),ind) = 1;
        end
        matrix_adj(:,ind) = matrix_adj(:,ind)./sum(matrix_adj(:,ind));
    end
    if max(sum(matrix_fixed_classes,2)) > 1
        error('Can''t have overlapping fixed_classes');
    end
    a = 17;
end


if ~exist('is_RO2','var')
    is_RO2 = {};
end


is_RO2_vector = zeros(size(c_matrix,1),1);
for irInd = 1:numel(is_RO2)
    curr_species = is_RO2{irInd};
    csInd = Species_Order.(curr_species);
    is_RO2_vector(csInd) = 1;
end
is_RO2_vector = logical(is_RO2_vector);

RO2_ind = Species_Order.('RO2');
c_matrix(RO2_ind,:) = sum(c_matrix(is_RO2_vector,:));

Co = zeros(num_species + num_rxns,1);
Co(1:num_species) = c_matrix(:,1);

%% Each step in vector_size is its own set of independent constraints. 
%Here we build the vectors required to run the differential equations for one step. 
Y = zeros(0,num_species);
Y_eps = zeros(0,num_rxns);
T_all = zeros(0,1);
time_already_past = 0;
yInd = 1;

for vInd =1:vector_size
    k_vector = k_matrix(:,vInd); %Ok, that's easy. 
    
    fancy_k_data = fancy_ks_cell;
    for rInd = 1:size(fancy_ks_cell,1)
        fancy_k_data{rInd,2} = fancy_ks_cell{rInd,2}{vInd};
    end
    
    %%
    %Now do the actual run of the differential equation. We use ode15s by default, even
    %though it's slightly less accurate because it is faster. 
    if ~silent, disp('Starting to run the diffeq'); end
    
    
    time_points = [0:10: 3600*length_of_run(vInd)];
    if numel(time_points) > 5000
        time_points = linspace(0,3600*length_of_run(vInd),1000);
    end
    if numel(time_points) < 50
        time_points = linspace(0,3600*length_of_run(vInd),100);
    end
    
    if strcmp(runner,'ode45')
        disp('Using ode45. May be slow');
         if exist('matrix_fixed_classes','var')
            if ~silent,  disp('Using Fixed Classes'); end
            [T_curr,Y_curr] = ode45(@(t,C) TOY_Kinetics_Fix_Class(t,C,k_vector,G1,G2,G,able_to_change,is_RO2_vector,RO2_ind,matrix_fixed_classes,matrix_adj,fancy_k_data),...
                time_points,Co); 
        else
            [T_curr,Y_curr] = ode45(@(t,C) TOY_Kinetics(t,C,k_vector,G1,G2,G,able_to_change,is_RO2_vector,RO2_ind,fancy_k_data),...
                time_points,Co); 
         end
    else
        if exist('matrix_fixed_classes','var')
             if ~silent,  disp('Using Fixed Classes'); end
            [T_curr,Y_curr] = ode15s(@(t,C) TOY_Kinetics_Fix_Class(t,C,k_vector,G1,G2,G,able_to_change,is_RO2_vector,RO2_ind,matrix_fixed_classes,matrix_adj,fancy_k_data),...
                time_points,Co); 
        else
            [T_curr,Y_curr] = ode15s(@(t,C) TOY_Kinetics(t,C,k_vector,G1,G2,G,able_to_change,is_RO2_vector,RO2_ind,fancy_k_data),...
                time_points,Co); 
        end
    end
    q = T_curr+5*60;

    %Now I need to do two things:
    %1. Update was Co should be.
    %2. Combine Y_both
    Y_end = Y_curr(end,:)'; %These are the output concentrations
    if vInd < vector_size %Don't do this the last time
        new_Co = Y_end;
        new_Co(able_to_change == 0) = c_matrix(able_to_change == 0, vInd+1); %only fix the ones that arne't able to change. 
        Co = new_Co;
    end
    
    n_rows = size(Y_curr,1);
    Y_eps(yInd:yInd+n_rows-1,:) = Y_curr(:,num_species+1:end);
    Y(yInd:yInd+n_rows-1,:) = Y_curr(:,1:num_species);
    T_all(yInd:yInd+n_rows-1) = T_curr + time_already_past;
    
    yInd = yInd+n_rows;
    time_already_past = time_already_past + length_of_run(vInd)*3600;
    
end
inst_change = [];
for ind = 1:size(Y,1)
    inst_change(ind,:) = TOY_Kinetics(T_all(ind),Y(ind,:)',k_vector,G1,G2,G,able_to_change,is_RO2_vector,RO2_ind,fancy_k_data);
end
inst_change = inst_change(:,num_species+1:end);
%%
%Now we plot the results over time. 
if make_plots
    plot_mask = zeros(1,num_species);
    for wtpInd = 1:numel(want_to_plot)
        plot_mask(Species_Order.(want_to_plot{wtpInd})) = true;
    end
    plot_mask = plot_mask & max(Y) >= 0;
    time_mask = T_all>5; %We give it 5 seconds to spin up :P
    plot(T_all(time_mask),Y(time_mask,plot_mask));
    set(gca,'FontSize',18);
    xlabel('Time(s)'); ylabel('C molec/cc');
    sn = fieldnames(Species_Order);
    sn = strrep(sn,'_',' ');
    legend(sn(plot_mask),'FontSize',14,'location','EastOutside');
end

%Now we plot the sub-classes of things that are relevant to us
if ~exist('classes_of_interest','var')
    classes_of_interest = struct('name',{},'comp',{});
end

if make_plots
    for sbcInd = 1:numel(classes_of_interest)
        curr_spec = classes_of_interest(sbcInd).comp;
        plot_mask = zeros(1,num_species);
        for wtpInd = 1:numel(curr_spec)
            if ~isfield(Species_Order,curr_spec{wtpInd}), continue; end
            plot_mask(Species_Order.(curr_spec{wtpInd})) = true;
        end
        if sum(plot_mask & max(Y) > 0) > 0    
            plot_mask = plot_mask & max(Y) > 0;
        else
            plot_mask = plot_mask & max(Y) >= 0;
        end
        curr_name = classes_of_interest(sbcInd).name;
        figure;
        plot(T_all(time_mask),Y(time_mask,plot_mask)./mM.*1e12);
        hold on;
        conserved_sum = sum(Y(time_mask,plot_mask),2);
        if sum(plot_mask) > 1
            plot(T_all(time_mask),conserved_sum./mM.*1e12,'-r*');
        end
        set(gca,'FontSize',18);
        xlabel('Time(s)'); ylabel('C (ppt)');
        title(curr_name);
        legend(sn(plot_mask),'FontSize',14,'location','EastOutside');
    end
end

%Now we plot the epsilons:
if make_plots
    integrated_throughput = sum(Y_eps,1);
    cumul_throughput = cumsum(Y_eps,1);
    [c,IX] = sort(integrated_throughput,'descend');
    figure;
    plot(T_all,cumul_throughput(:,IX))
    all_names = fieldnames(Reaction_Order);
    all_names = strrep(all_names,'_',' ');
    legend(all_names(IX),'Fontsize',14,'location','EastOutside')
end
%%
%Now we clean up and save
clear cInd csInd curr_order curr_rxn curr_sf curr_species curr_species_name
clear hfInd k_vector nInd num_rxns num_species q rInd und SO

dir_root = datestr(datevec(now),'yymmdd');
curr_dir = pwd;
cd ./Toy_runs/
if ~exist(dir_root,'dir')
    mkdir(dir_root)
end
cd(dir_root)
run_suff = 0;
run_name = strcat(dir_root,'_',sprintf('%02i',run_suff),'.mat');
while exist(run_name,'file')
    run_suff = run_suff + 1;
    run_name = strcat(dir_root,'_',sprintf('%02i',run_suff),'.mat');
end
save(run_name)
cd(curr_dir);

q = fieldnames(Species_Order);
S = struct();
for ind = 1:numel(q)
    curr_name = q{ind};
    curr_ind = Species_Order.(curr_name);
    S.(curr_name) = Y(:,curr_ind);
end

q = fieldnames(Reaction_Order);
R = struct();
for ind = 1:numel(q)
    curr_name = q{ind};
    curr_ind = Reaction_Order.(curr_name);
    R.(curr_name) = Y_eps(:,curr_ind);
end

q = fieldnames(Reaction_Order);
R_inst = struct();
for ind = 1:numel(q)
    curr_name = q{ind};
    curr_ind = Reaction_Order.(curr_name);
    R_inst.(curr_name) = inst_change(:,curr_ind);
end
