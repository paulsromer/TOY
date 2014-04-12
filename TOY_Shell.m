%TOY_Shell.m
%Simple Shell Program used to run TOY. All the parameters thought to change
%from run to run are included here. 
cd ~/Berkeley/CohenGroup/SOAS/Analysis_SOAS/Toy_Framework/
close all

kinetics_file_to_use = 'Isoprene_OH_Kinetics_BaseCase'; 
species_file = 'Isop_Conc';
T = 298; %Temp in K
mM = 2.45e19; %Number of molec/cc
is_RO2 = {'ISO2b12','ISO2b43','ISO2dE14','ISO2dE41','ISO2dZ14','ISO2dZ41','RO2g'}
hold_fixed = {'ISOP','NO','HO2','OH'}; %Well, now I should spin it up first
hours_of_run = 16;


[T,Y,Species_Order,Reaction_Order,Y_eps] = TOY(kinetics_file_to_use,species_file,T,mM,hold_fixed, hours_of_run,is_RO2);

amount_RO2_with_NO = Y_eps(:,Reaction_Order.('r_ISOPOO_NO'));
amount_RO2_with_HO2 = Y_eps(:,Reaction_Order.('r_ISOPOO_HO2'));
mu = amount_RO2_with_NO./(amount_RO2_with_HO2 + amount_RO2_with_NO);
figure; plot(T,mu); title('mu');