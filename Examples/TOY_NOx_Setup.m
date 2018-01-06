%TOY_NOx_Setup.m


kinetics_dir = strcat(pwd, '/Kinetics/');
kinetics_fn = 'Basic_NOx_Kinetics.m'; 
kinetics_full_fn = strcat(kinetics_dir,kinetics_fn);

classes = struct();
fixed_classes = struct();
fixed_classes.comp = {};
fixed_classes.adjust_as = {};


hold_fixed = {'OH'};


hours_of_run = 0.5;

S = struct();
S.ppb_NO = 20;
S.m_OH = 6e8;
S.ppb_O3 = 40;

Bkgd_Conc = struct();
Bkgd_Conc.ppb_NO = 20;
Bkgd_Conc.ppb_NO2 = 10;

options = struct('runner','ode45',...
                'k_dil',1e-3,...
                'make_plots',false,...
                'Bkgd_Conc',Bkgd_Conc);

other_inputs = struct();
other_inputs.jNO2 = 0.009; %Typical summertime value
other_inputs.T = 298;

curr_dir = pwd;
cd ~/CohenResearch/Models/Toy_Framework/
[t,Y,Species_Order,Reaction_Order,Y_eps,curr_S,R_new] = TOY(kinetics_full_fn,S,other_inputs,hold_fixed, hours_of_run,options);

figure(1); clf; hold on;
plot(t,curr_S.NO./2.45e10);
plot(t,curr_S.NO2./2.45e10);
legend('NO','NO2');

figure(2); clf; hold on;
plot(diff(curr_S.NO),diff(curr_S.NO2),'o')
plot_fit_def(2);

