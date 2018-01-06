%TOY_NOx_Setup.m


kinetics_dir = strcat(pwd, '/Kinetics/');
kinetics_fn = 'Basic_NOx_VOC_Kinetics.m'; 
kinetics_full_fn = strcat(kinetics_dir,kinetics_fn);

classes = struct();
fixed_classes = struct();
fixed_classes.comp = {};
fixed_classes.adjust_as = {};


hold_fixed = {'rVOC','OVOC','H2O','OH'};


hours_of_run = 0.5;

S = struct();
S.ppb_NO = 10;
S.m_OH = 6e6;
S.ppb_O3 = 40;
S.ppb_rVOC = 15;
S.ppb_OVOC = 10;
S.ppb_H2O = 1e9*0.01; %H2O is about 1% of the rest of the concentration of air


options = struct('runner','ode15s',...
                'k_dil',0,...
                'make_plots',false);

other_inputs = struct();
other_inputs.jNO2 = 0.009; %Typical summertime value
other_inputs.jO3  = 2e-5;
other_inputs.T = 298;
other_inputs.alpha = 0.05;
% other_inputs.PHOx = 

curr_dir = pwd;
cd ~/CohenResearch/Models/Toy_Framework/
[t,Y,Species_Order,Reaction_Order,Y_eps,curr_S,R_new] = TOY(kinetics_full_fn,S,other_inputs,hold_fixed, hours_of_run,options);

%%
figure(1); clf; hold on;
plot(t,curr_S.NO);



