function Cat_Rxn_Data = Build_Dilution(Rxn_Data,Species_Order,k_dil,mM,Bkgd_Conc_Orig)
%% Step 1: translate the Bkgd_Conc into all being in terms of molecular densities


Bkgd_Conc = struct();
fn = fieldnames(Bkgd_Conc_Orig);
for ind = 1:numel(fn)
    curr_name = fn{ind};
    if strncmp(curr_name,'ppb_',4)
        trim_name = curr_name(5:end);
        Bkgd_Conc.(trim_name) = Bkgd_Conc_Orig.(curr_name).*mM./1e9;
    elseif strncmp(curr_name,'ppt_',4)
        trim_name = curr_name(5:end);
        Bkgd_Conc.(trim_name) = Bkgd_Conc_Orig.(curr_name).*mM./1e12;
    elseif strncmp(curr_name,'m_',2)
        trim_name = curr_name(3:end);
        Bkgd_Conc.(trim_name) = Bkgd_Conc_Orig.(curr_name);
    else
        disp('Can''t parse the Bkdg_Conc inputs');
        error('Poor Inputs');     
    end
end


%% Step 2: Build the reactions!
species_names = fieldnames(Species_Order);
Cat_Rxn_Data = Rxn_Data;
for ind = 1:numel(species_names)
    curr_name = species_names{ind};
    curr_rxn = struct();
    curr_rxn.k = sprintf('%0.9e',k_dil); %There's got to be a better way to do this. 
    curr_rxn.loss = {curr_name};
    curr_rxn.gain = struct('name',{},'value',{});
    curr_rxn.ksource = 'dilution';
    
    rxn_name = strcat('r_d' ,curr_name);
    Cat_Rxn_Data.(rxn_name) = curr_rxn;
    if isfield(Bkgd_Conc,curr_name)
        bkgd_rxn = struct();
        bkgd_rxn.k = sprintf('%0.9e',k_dil.*Bkgd_Conc.(curr_name));
        bkgd_rxn.loss = {};
        bkgd_rxn.gain = struct('name',{curr_name},'value',{1});
        bkgd_rxn.ksource = 'dilution_bkgd';
        
        rxn_name = strcat('r_db',curr_name);
        Cat_Rxn_Data.(rxn_name) = bkgd_rxn;
    end     
end

a = 17;
