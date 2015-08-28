function [T,Y,Species_Order,Reaction_Order,Y_eps, S] = TOY(kinetics_file,species_file,other_inputs,hold_fixed,length_of_run,ode_runner)
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
    'num_species','ode_runner','Reaction_Order','rInd','Rxn_Data','SO',...
    'species_file','Species_Order','x','ppb_.*','ppt_.*','m_.*'};
for ind = 1:numel(forbidden_names)
    forbidden_names{ind} = strcat('^',forbidden_names{ind},'$');
end

%% First use the provided kinetics and species to build up the framework for this run 



run(kinetics_file)

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

[Reaction_Order k_cell] = Build_Reaction_Order(Rxn_Data);
[G, G1, G2] = Build_Stoichometry(Rxn_Data,Reaction_Order,Species_Order);
SO = Species_Order;
num_species = numel(fieldnames(Species_Order));

    
clear('-regexp', '^r_*');
%We need to unpack other_inputs to evaluate the k_vectors. So I unpack it,
%evaluate the k's, and then destroy it, just to cut down on the total mess
%that this system can make:
var_names = Extract_Struct(other_inputs,forbidden_names);

%now evaluate the k's
k_vector = zeros(num_rxns,1);
for rInd = 1:numel(k_cell)
    k_vector(rInd) = eval(k_cell{rInd});
end
%Clean up:
clear curr_rxn nInd rInd k_cell
for ind = 1:numel(var_names)
    clear(var_names{ind});
end

disp('Loaded Reactions');


%% Then use the species file to build up the concentrations. We recognize ppb_, ppt_
% and m_

c_vector =  zeros(num_species,1);
if isstruct(species_file)
    Extract_Struct(species_file)
else
    run(species_file)
end

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
    c_vector(curr_order) = q.*2.45e10;
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
    c_vector(curr_order) = q./1000.*2.45e10;
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
    c_vector(curr_order) = q;
end
clear all_m
clear('-regexp', '^m_*');
disp('Loaded Species');
if ~exist('want_to_plot','var')
    want_to_plot = fieldnames(Species_Order);
end
want_to_plot = want_to_plot(isfield(Species_Order,want_to_plot));


%% Now do the last manipulations needs to run the system
C = c_vector;
able_to_change = ones(numel(C),1);
all_able_to_change = able_to_change;
for hfInd = 1:numel(hold_fixed)
    curr_species = hold_fixed{hfInd};
    csInd = Species_Order.(curr_species);
    able_to_change(csInd) = 0;
end


if ~exist('is_RO2','var')
    is_RO2 = {};
end


is_RO2_vector = zeros(numel(C),1);
for irInd = 1:numel(is_RO2)
    curr_species = is_RO2{irInd};
    csInd = Species_Order.(curr_species);
    is_RO2_vector(csInd) = 1;
end
is_RO2_vector = logical(is_RO2_vector);

RO2_ind = Species_Order.('RO2');
C(RO2_ind) = sum(C(is_RO2_vector));
Co = zeros(num_species + num_rxns,1);
Co(1:num_species) =  C;


%%
%Now do the actual run of the differential equation. We use ode15s, even
%though it's slightly less accurate because it is faster. I currently don't
%have any sort of instantaneous cutoff thing. Maybe that's for the future.
% disp('Five Minute Spin Up');
% [a,b] = ode45(@(t,C) TOY_Kinetics(t,C,k_vector,G1,G2,G,all_able_to_change,is_RO2_vector,RO2_ind),...
%     [0, 5*60],Co);
% Co(1:num_species) = b(end,1:num_species);
disp('Starting to run the diffeq');
tic
if strcmp(ode_runner,'ode45')
    disp('Using ode45. May be slow');
    [T,Y_both] = ode45(@(t,C) TOY_Kinetics(t,C,k_vector,G1,G2,G,able_to_change,is_RO2_vector,RO2_ind),...
        [0, 3600*length_of_run],Co); %I'm going to regret this, aren't I?
else
    [T,Y_both] = ode15s(@(t,C) TOY_Kinetics(t,C,k_vector,G1,G2,G,able_to_change,is_RO2_vector,RO2_ind),...
        [0, 3600*length_of_run],Co); %I'm going to regret this, aren't I?
end
q = T+5*60;
%T = [a; q];
%Y_both = [b; Y_both];
Y_eps = Y_both(:,num_species+1:end);
Y = Y_both(:,1:num_species);
%%
%Now we plot the results over time. 
a = 17;
plot_mask = zeros(1,num_species);
for wtpInd = 1:numel(want_to_plot)
    plot_mask(Species_Order.(want_to_plot{wtpInd})) = true;
end
plot_mask = plot_mask & max(Y) >= 0;
time_mask = T>5; %We give it 5 seconds to spin up :P
plot(T(time_mask),Y(time_mask,plot_mask));
set(gca,'FontSize',18);
xlabel('Time(s)'); ylabel('C molec/cc');
sn = fieldnames(Species_Order);
sn = strrep(sn,'_',' ');
legend(sn(plot_mask),'FontSize',14,'location','EastOutside');

%Now we plot the sub-classes of things that are relevant to us
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
    plot(T(time_mask),Y(time_mask,plot_mask));
    hold on;
    conserved_sum = sum(Y(time_mask,plot_mask),2);
    if sum(plot_mask) > 1
        plot(T(time_mask),conserved_sum,'-r*');
    end
    set(gca,'FontSize',18);
    xlabel('Time(s)'); ylabel('C (molec/cc)');
    title(curr_name);
    legend(sn(plot_mask),'FontSize',14,'location','EastOutside');
end

%Now we plot the epsilons:
integrated_throughput = sum(Y_eps,1);
cumul_throughput = cumsum(Y_eps,1);
[c,IX] = sort(integrated_throughput,'descend');
figure;
plot(T,cumul_throughput(:,IX))
all_names = fieldnames(Reaction_Order);
all_names = strrep(all_names,'_',' ');
legend(all_names(IX),'Fontsize',14,'location','EastOutside')
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
    
a = 17; 
