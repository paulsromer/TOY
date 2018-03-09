%TOY_Tracer_Setup.m

model_dir ='/Users/promer/CohenResearch/Models/Toy_Framework';
kinetics_dir = strcat(model_dir, '/Kinetics/');
kinetics_fn = 'Tracer_Kinetics.m'; 
kinetics_full_fn = strcat(kinetics_dir,kinetics_fn);

classes = struct();
fixed_classes = struct();
fixed_classes.comp = {};
fixed_classes.adjust_as = {};


hold_fixed = {};

hours_per_step = 1;
n_cycles = 7;
hours_of_run = hours_per_step.*24.*n_cycles;


S = struct();
S.ppb_TRACER = 400;

Bkgd_Conc = struct();
Bkgd_Conc.ppb_TRACER = 400;


options = struct('runner','ode15s',...
                'k_dil',1e-5,...
                'make_plots',false,...
                'Bkgd_Conc',Bkgd_Conc,...
                'silent',true);

other_inputs = struct();
other_inputs.T = 298;
other_inputs.E_Tracer = repmat([2,2,2,2,2,5,12,8,6.6,6,6,6,7,7,7,8,9,11,10,9,7,5,3,2]*3000000,1,n_cycles); %A made up diurnal cycle of emissions

curr_dir = pwd;
cd ~/CohenResearch/Models/Toy_Framework/
[t,Y,Species_Order,Reaction_Order,Y_eps,curr_S,R_new] = TOY(kinetics_full_fn,S,other_inputs,hold_fixed, hours_of_run,options);

figure(2); clf; hold on;
plot(t,curr_S.TRACER./2.45e10)


