# TOY
A framework for running simple chemical reaction schemes in MATLAB

## Overview
TOY is designed to be a framework for running simple chemical reaction schemes in MATLAB. It is not designed to run large-scale chemical simulations, with hundreds or thousands of reactions. Instead, it is meant to simplify the process of understanding the effects of individual reactions and simulating situations where only a handful of reactions are important. 

### Features
- Human-friendly scheme for entering reactions

  Enter reactions as you would write them out by hand, e.g., NO + O3 -> NO2 + O2, and TOY effectively translates that into the stoichometry it needs to run the equations

- Constrain classes of compounds

  Several chemical box models can hold individual species fixed. However, it's often the case that what we really want to do is to hold *classes* of compounds fixed, but let the components of the classes be partitioned freely. TOY makes this possible for any user-defined compound classes. 
  
- Non-linear kinetics

  TOY can easily handle reactions that are non-linear functions of reaction concentrations, and allows kinetic rate constants to be arbitrary functions chemical species. This feature is especially useful for simulating heterogeneous or particle phase reactions that depend on particle-phase concentrations in non-linear ways. 
  
 ## Setting up and using TOY
 TOY is written in MATLAB and requires MATLAB to run. The contents of this repository should be clones/downloaded and the entire folder added to the MATLAB search path. The core program, and the one to call to initialize a run is called `TOY.m`. 
 
```[T_all,Y,Species_Order,Reaction_Order,Y_eps, S] = TOY(kinetics_file,species_struct,other_inputs,hold_fixed,length_of_run,options)```
An extremely simple TOY setup example is given in `TOY_Shell.m`, additional setups are given in the `Examples` directory. Examples of the kinetic file setups can be found in the `Kinetics` directory. 

 
 
