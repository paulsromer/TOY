
    %This is the initalization routine for this thing. Builds some
    %structures. k will have be calculated on every call. 
    %I'm keeping the kinetics and the concentrations seperate for now. 
    
    
    
    r_NO_O3 = struct('k','(3.0e-12).*exp(-1500./T)',...
        'loss',{{'NO','O3'}},'gain',{{'NO2'}},'ksource','S&P');
    r_NO_HO2 = struct('k', '(3.5e-12).*exp(250./T)',...
        'loss',{{'NO','HO2'}},'gain',{{'NO2','OH'}},'ksource','S&P'); 
    
    %Deal:

    r_O3_loss = struct('k', '(1.03e-14).*exp(-1995/T).*6.* 2.4500e10',...
        'loss', {{'O3'}}, 'gain', {{}}); %Extra VOC + O3 loss. 

    r_C5H8_OH = struct('k','(2.7e-11).*exp(390./T)',...
        'loss', {{'C5H8','OH'}},'gain',{{'C5H8OO'}},'ksource','MCM');
    r_C5H8OO_NO = struct('k', '2.54e-12.*exp(360./T).* 0.93',...
        'loss',{{'C5H8OO','NO'}},'gain',{{'NO2','HO2','OVOC'}},'ksource','LaFranchi');

    r_C5H8_O3 = struct('k','(1.03e-14).*exp(-1995./T)',...
        'loss', {{'C5H8','O3'}},'gain',{{'OVOC'}},'ksource','MCM');
    %Other loses of RO2, whatever that is. This method doesn't have a way to
    %deal with fractional yields. I guess I could change that. But it seems
    %easier to change k, at least for now.

    %Need to come up with a good VOC to use here...maybe look at some paper
    %on regional modelling? 
    r_VOC1_OH = struct('k','1.59e-17*T.^2*exp(478./T)',...
        'loss',{{'VOC1','OH'}},'gain',{{'VOC1OO'}});
    r_VOC1OO_NO = struct('k','(2.7e-12).*exp(360./T).*0.98',...
        'loss', {{'VOC1OO','NO'}},'gain',{{'NO2','HO2','OVOC'}});
   

    
    r_HO2_HO2 = struct('k', '((2.3e-13).*exp(600./T) + (1.7e-33).*exp(1000./T).*M)',...
        'loss',{{'HO2','HO2'}},'gain',{{}},'ksource','S&P'); %don't care about productions
    r_OH_NO2 = struct('k','ThreeBodyK((2.0e-30).*(T./300).^-3.0,(2.5e-11).*(T./300).^-0,M)',...
        'loss',{{'OH','NO2'}},'gain',{{}}); %don't care about products

    %rRO2_HO2 = struct('k',@(T,M) 17,'loss',{{'RO2','HO2'}},'gain',{{}});
    %rRO2_RO2 = struct('k',@(T,M) 17,'loss',{{'RO2','RO2'}},'gain',{{}});
    r_C5H8OO_HO2 = struct('k', '2.9e-13.*exp(1300./T)',...
        'loss',{{'C5H8OO','HO2'}},'gain',{{}},'ksrouce','LaFranchi');
    r_C5H8OO_C5H8OO = struct('k',' 2.4e-12',...
        'loss',{{'C5H8OO','C5H8OO'}},'gain',{{}},'ksrouce','LaFranchi');
    
    r_VOC1OO_HO2 = struct('k','2.9e-13.*exp(1300./T)',...
        'loss',{{'VOC1OO','HO2'}},'gain',{{}},'ksrouce','LaFranchi');
    r_VOC1OO_VOC1OO = struct('k','2.4e-12',...
        'loss',{{'VOC1OO','VOC1OO'}},'gain',{{}},'ksrouce','LaFranchi');
    
    r_OVOCOO_HO2 = struct('k','2.9e-13.*exp(1300./T)',...
        'loss',{{'OVOCOO','HO2'}},'gain',{{}},'ksrouce','LaFranchi');
    r_OVOCOO_OVOCOO = struct('k','2.4e-12',...
        'loss',{{'OVOCOO','OVOCOO'}},'gain',{{}},'ksrouce','LaFranchi');
    
    r_C5H8OO_VOC1OO = struct('k','2.4e-12',...
        'loss',{{'C5H8OO','VOC1OO'}},'gain',{{}},'ksrouce','LaFranchi');
    r_C5H8OO_OVOCOO = struct('k','2.4e-12',...
        'loss',{{'C5H8OO','OVOCOO'}},'gain',{{}},'ksrouce','LaFranchi');
    r_VOC1OO_OVOCOO = struct('k','2.4e-12',...
        'loss',{{'VOC1OO','OVOCOO'}},'gain',{{}},'ksrouce','LaFranchi');
    
    
    %Ok, so we need to know these PAN and AN kinetics stuff. 
    %HRM...PAN is going to be annoying. I guess we do have to work with OVOC :(
    %Ah well. 
    %But for ANs:
    %Deal:
    r_VOC1OO_NO_AN = struct('k','(2.7e-12).*exp(360./T).*0.02',...
        'loss',{{'VOC1OO','NO'}},'gain',{{'AN'}});
    
    r_C5H8OO_NO_AN = struct('k','2.54e-12.*exp(360./T).* 0.07',...
        'loss',{{'C5H8OO','NO'}},'gain',{{'AN'}});
    
    r_OVOCOO_NO_AN = struct('k','(8.1e-12).*exp(270./T).*0.15',...
        'loss',{{'OVOCOO','NO'}},'gain',{{'AN'}});

    %Hrm...also this OVOC thing...
    r_OVOC_OH = struct('k','(6.0e-12).*exp(380./T)',...
        'loss',{{'OVOC','OH'}},'gain',{{'OVOCOO'}},'ksource','LaFranchi'); %SImilar to MACR
    r_OVOCOO_NO = struct('k','(8.1e-12).*exp(270./T).*0.85',...
        'loss',{{'OVOCOO','NO'}},'gain',{{'NO2','HO2'}});
    
    r_OVOCOO_NO2 = struct('k','ThreeBodyK((9.7e-12).*(T./300).^-5.6,(9.3e-12).*(T./300).^-1.5,M)',...
        'loss',{{'OVOCOO','NO2'}},'gain',{{'PAN'}},'ksource','IUPAC??');
    r_PAN = struct('k','ThreeBodyK((9.7e-12).*(T./300).^-5.6,(9.3e-12).*(T./300).^-1.5,M)./((9.0e-29).*exp(14000./T))',...
        'loss',{{'PAN'}},'gain',{{'OVOCOO','NO2'}},'ksource','IUPAC??');

    
    %Ok, now the nighttime relevant ones...what is there? Well there's
    %going to be -NO2 + O3.
    %NO3 photolysis is another thing
    %We also need -OH + NO3 
    %I'm not going to worrry about HO2No2 at the moment. 
    %-HO2+NO3
    %-NO+NO3
    %-NO2+NO3
    %-NO2+NO3 -> N2O5
    %-N2O5 -> NO2 + NO3
    %-N2O5 loss? 
    %And NO3 + R -> AN
    %The two j's for NO3
    %I think that's probably a good place to start. 
    
    r_O3_NO2 = struct('k','(1.2e-13).*exp(-2450./T)',...
        'loss',{{'O3','NO2'}},'gain',{{'NO3'}},'ksource','S&P');
    r_OH_NO3 = struct('k','2.2e-11',...
        'loss',{{'OH','NO3'}},'gain',{{}},'ksource','IUPAC');
    r_HO2_NO3 = struct('k','3.5e-12',...
        'loss',{{'HO2','NO3'}},'gain',{{}},'ksource','IUPAC');
    r_NO_NO3 = struct('k','(1.5e-11).*exp(170./T)',...
        'loss',{{'NO','NO3'}},'gain',{{'NO2','NO2'}},'ksource','IUPAC');
    r_NO2_NO3 = struct('k','(4.5e-14).*exp(-1260./T)',...
        'loss',{{'NO2','NO3'}},'gain',{{'NO','NO2'}},'ksource','IUPAC'); %Debatable
    r_NO2_NO3_M = struct('k','ThreeBodyK((2.0e-30).*(T./300).^-4.4,1.4e-12 .* (T./300).^-0.7,M)',...
        'loss',{{'NO2','NO3'}},'gain',{{'N2O5'}},'ksource','IUPAC');
    r_N2O5 = struct('k','ThreeBodyK((2.0e-30).*(T./300).^-4.4,1.4e-12 .* (T./300).^-0.7,M)./((3.0e-27).*exp(10990./T))',...
        'loss',{{'N2O5'}},'gain',{{'NO2','NO3'}},'ksource','IUPAC,S&P');
    r_N2O5_Het = struct('k','8.33e-4',...
        'loss',{{'N2O5'}},'gain',{{}},'ksource','RevisedRates.m,%Riemer Vogel & Vogel');
   
    r_NO3_C5H8_AN = struct('k','(3.15e-12).*exp(-450./T)',...
        'loss',{{'NO3','C5H8'}},'gain',{{'AN'}},'ksource','MCM');
    r_NO3_OVOC = struct('k','(3.4e-15).*0.6',...
        'loss',{{'NO3','OVOC'}},'gain',{{}},'ksource','MCM'); %Put in branching just cuz
    r_NO3_OVOC_AN = struct('k','(3.4e-15).*0.4',...
        'loss',{{'NO3','OVOC'}},'gain',{{'AN'}},'ksource','MCM'); %Put in branching just cuz
    %NO3 does not react with alkanes