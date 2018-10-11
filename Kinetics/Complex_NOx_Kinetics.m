%A simplified set of VOC and NOx kinetics to compare my observed HNO3 to
%NOx ratios to. 
%Has to have:
%-NO, NO2 cycling
%-HOx production, cylcing, and loss
%+Some mechanism for VOC oxidation (maybe two components, a reactive
%component that goes away and a backgroudn component (1 s-1?) that remains
%fixed. 
%+NOx loss
%-HNO3 Deposition and Photolysis (including partitioning just as frac_g). 
%-2BN Clock Reactions
%Ideally, eventually PAN (not sure how to include that yet...I've thought a
%fair amount through it here). 
%The NOx Cycle:
%====================
r2_j_NO2 = struct('k','jNO2',... %Given as an imput parameter, to include in the model
    'scheme','NO2 -> 1*NO + 1*O3',...
    'ksource','CAFS observations');

r2_NO_O3 = struct('k','3.0e-12.*exp(-1500./T)',...
    'scheme','NO + O3 -> NO2',...
    'ksource','S&P');


%HOx-NOx Loss:
%==================
r2_OH_NO2 = struct('k','ThreeBodyK(1.49e-30.*( (T./300).^-1.8 ),2.58e-11,mM)',...
    'scheme','OH + NO2 ->  HNO3' ,...
    'ksource','Mollner');



%Creating two VOCs: rVOC, and oVOC,  
%respectively. 
%================
r2_rVOC_OH = struct('k','3e-11',...
    'scheme','rVOC + OH -> 1*rVOCRO2',...
    'ksource','Made Up');

r2_rVOCRO2_NO_hox = struct('k','2.7e-12.*exp(360./T).*(1-alpha)',...
    'scheme','rVOCRO2 + NO -> 1*NO2 + 1*HO2', ...
    'ksource','MCM');

r2_rVOCRO2_NO_RONO2 = struct('k','2.7e-12.*exp(360./T).*alpha',...
    'scheme','rVOCRO2 + NO -> RONO2',...
    'ksource','MCM');


r2_rVOCRO2_HO2 = struct('k', '2.9e-13.*exp(1300./T)',...
    'scheme','rVOCRO2 + HO2 -> ROOH',...
    'ksource','Sally/MCM');

r2_rVOCRO2_RO2 = struct('k','2.4e-12',...
    'scheme','rVOCRO2 + RO2 -> ROOH', ...
    'ksource','Sally/MCM');

%% OVOCs (for PAN) - modeling this on acetal. Will try to compare to the observations

% ko = ;
% kinf = ;
% k_dissoc = ;
% k_PA_NO = ;
% k_PA_HO2 = ;
% ko = ;
% kinf = ;
% k_PA_NO2 = ;

r2_OVOC_OH = struct('k','4.7e-12.*exp(345./T)',...
    'scheme','OVOC + OH -> OVOCRO2',...
    'ksource','LaFranchi');

r2_OVOCRO2_NO = struct('k','8.1e-12.*exp(270./T)',...
    'scheme','OVOCRO2 + NO -> 1*NO2 + 1*HO2',...
    'ksource','LaFranchi');

r2_OVOCRO2_HO2 = struct('k','4.3e-13.*exp(1040./T)',...
    'scheme','OVOCRO2 + HO2 -> ROOH',...
    'ksource','LaFranchi');

r2_OVOCRO2_RO2 = struct('k','2.0e-12.*exp(500./T)',...
    'scheme','OVOCRO2 + RO2 -> ROOH',...
    'ksource','LaFranchi');


r2_OVOCRO2_NO2 = struct('k','ThreeBodyK_LH(2.7e-28.* ((T./300).^-7.1),1.2e-11 .* ((T./300).^-0.9),mM,0.3,1)',...
    'scheme','OVOCRO2 + NO2 -> PAN',...
    'ksource','LaFranchi');

r2_PAN = struct('k','ThreeBodyK_LH(4.9e-3.*exp(-12100./T),4.0e16.*exp(-13600./T),mM,0.3,1.41)',...
    'scheme','PAN -> OVOCRO2 + NO2',...
    'ksource','LaFranchi');

%Reactions of HO2
%===============

r2_HO2_NO = struct('k','3.5e-12.*exp(250./T)',...
    'scheme','HO2 + NO -> 1*OH + 1*NO2',...
    'ksource','S&P');


r2_HO2_HO2 = struct('k','2.2e-13.*exp(266./T)',...
    'scheme','HO2 + HO2 -> H2O2',...
    'ksource','Sally, citing Atkinson');


%HOx Production
% %==============
% r2_PHOx = struct('k','P_HOx',...
%     'scheme', '-> .5*OH + .5*HO2',...
%     'ksource','As Used in Farmer 2011');

r2_jO3 = struct('k','jO3',...
    'scheme','O3 -> 2*OH',...
    'ksource','Given as Input');


r2_O1D_O2_O3 = struct('k','3.2e-11.*exp(67./T).*.21.*mM',...
    'scheme','O1D -> O3',...
    'ksource','MCM');

r2_O1D_N2_O3 =  struct('k',' 2.0e-11.*exp(130./T).*.78.*mM',...
    'scheme','O1D -> O3',...
    'ksource','MCM');

r2_O1D_H2O = struct('k','2.14e-10',...
    'scheme','O1D + H2O -> 2*OH',...
    'ksource','MCM');