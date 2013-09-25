%TOY_Shell.m
%Simple Shell Program used to run TOY. All the parameters thought to change
%from run to run are included here. 
cd ~/Berkeley/CohenGroup/SOAS/Analysis_SOAS/Toy_Framework/
close all

kinetics_file_to_use = 'Peroxy_Rxn'; 
species_file = 'Peroxy_Conc';
T = 298; %Temp in K
mM = 2.45e19; %Number of molec/cc
hold_fixed = {'O3','ISOP'};
hours_of_run = 4;


[T,Y,Species_Order,Reaction_Order,Y_eps] = TOY(kinetics_file_to_use,species_file,T,mM,hold_fixed, hours_of_run);