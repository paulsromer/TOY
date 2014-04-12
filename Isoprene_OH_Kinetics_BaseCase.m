%Isoprene_OH_Kinetics.m

%Alright, let's work on this. We've got a lot of options here. 
%I think we are going to try to put in a fully resolved 6-isomer split,
%including the alyl radicals, so I can add the RO2 isomerizations if I want
%to. 

%Step 1: Form the Rdot radicals
r_ISOP_OH = struct('k','(2.7e-11).*exp(390./T)','loss', {{'ISOP','OH'}},...
    'gain',struct('name',{'Itrans1','Icis1','Itrans4','Icis4'},'value',{.3,.3,.12,.28}),'ksource','PeetersVeecken_Fudged');


%Step 2: React with O2. Rates adjusted to match the MCM distribution of RO2
r_Itrans1_O2_a = struct('k','1.5e6','loss',{{'Itrans1'}},...
    'gain',struct('name',{'ISO2dE14'},'value',{1}),'ksource','PeetersVeecken');

r_Itrans1_O2_b = struct('k','7.5e6','loss',{{'Itrans1'}},...
    'gain',struct('name',{'ISO2b12'},'value',{1}),'ksource','PeetersVeecken');

r_Icis1_O2_a = struct('k','7.5e6','loss',{{'Icis1'}},...
    'gain',struct('name',{'ISO2b12'},'value',{1}),'ksource','PeetersVeecken');

r_Icis1_O2_b = struct('k','4.0e6','loss',{{'Icis1'}},... 
    'gain',struct('name',{'ISO2dZ14'},'value',{1}),'ksource','PeetersVeecken_Fudged');



r_Itrans4_O2_a = struct('k','1.5e6','loss',{{'Itrans4'}},...
    'gain',struct('name',{'ISO2dE41'},'value',{1}),'ksource','PeetersVeecken');

r_Itrans4_O2_b = struct('k','7.5e6','loss',{{'Itrans4'}},...
    'gain',struct('name',{'ISO2b43'},'value',{1}),'ksource','PeetersVeecken');

r_Icis4_O2_a = struct('k','7.5e6','loss',{{'Icis4'}},...
    'gain',struct('name',{'ISO2b43'},'value',{1}),'ksource','PeetersVeecken');

r_Icis4_O2_b = struct('k','2.75e6','loss',{{'Icis4'}},...
    'gain',struct('name',{'ISO2dZ41'},'value',{1}),'ksource','PeetersVeecken_Fudged');

%Step 3: Reactions of each of these isomers. For the MCM base case, we say
%kRO2HO2 = 2.91e-13.*exp(1300./T); kRO2NO = 2.7e-12.*exp(360./T); k_isom =
%0; kRO2RO2 = 2.40D-12

%3a: RO2 + HO2
r_ISO2dE41_HO2 = struct('k','2.91e-13.*exp(1300./T)','loss',{{'ISO2dE41','HO2'}},...
    'gain',struct('name',{'ISOPOOH'},'value',{1}),'ksource','MCM');

r_ISO2dZ41_HO2 = struct('k','2.91e-13.*exp(1300./T)','loss',{{'ISO2dZ41','HO2'}},...
    'gain',struct('name',{'ISOPOOH'},'value',{1}),'ksource','MCM');

r_ISO2b43_HO2 = struct('k','2.91e-13.*exp(1300./T)','loss',{{'ISO2b43','HO2'}},...
    'gain',struct('name',{'ISOPOOH'},'value',{1}),'ksource','MCM');

r_ISO2dE14_HO2 = struct('k','2.91e-13.*exp(1300./T)','loss',{{'ISO2dE14','HO2'}},...
    'gain',struct('name',{'ISOPOOH'},'value',{1}),'ksource','MCM');

r_ISO2dZ14_HO2 = struct('k','2.91e-13.*exp(1300./T)','loss',{{'ISO2dZ14','HO2'}},...
    'gain',struct('name',{'ISOPOOH'},'value',{1}),'ksource','MCM');

r_ISO2b12_HO2 = struct('k','2.91e-13.*exp(1300./T)','loss',{{'ISO2b12','HO2'}},...
    'gain',struct('name',{'ISOPOOH'},'value',{1}),'ksource','MCM');


%3b: RO2 + NO
r_ISO2dE41_NO = struct('k','2.7e-12.*exp(360./T)','loss',{{'ISO2dE41','NO'}},...
    'gain',struct('name',{'ISONO'},'value',{1}),'ksource','MCM');

r_ISO2dZ41_NO = struct('k','2.7e-12.*exp(360./T)','loss',{{'ISO2dZ41','NO'}},...
    'gain',struct('name',{'ISONO'},'value',{1}),'ksource','MCM');

r_ISO2b43_NO = struct('k','2.7e-12.*exp(360./T)','loss',{{'ISO2b43','NO'}},...
    'gain',struct('name',{'ISONO'},'value',{1}),'ksource','MCM');

r_ISO2dE14_NO = struct('k','2.7e-12.*exp(360./T)','loss',{{'ISO2dE14','NO'}},...
    'gain',struct('name',{'ISONO'},'value',{1}),'ksource','MCM');

r_ISO2dZ14_NO = struct('k','2.7e-12.*exp(360./T)','loss',{{'ISO2dZ14','NO'}},...
    'gain',struct('name',{'ISONO'},'value',{1}),'ksource','MCM');

r_ISO2b43_NO = struct('k','2.7e-12.*exp(360./T)','loss',{{'ISO2b43','NO'}},...
    'gain',struct('name',{'ISONO'},'value',{1}),'ksource','MCM');

%3c: RO2 + RO2
%I don't know how to do this. It'll require some work with the TOY model to make it work.  
r_ISO2dE41_RO2 = struct('k','2.40e-12','loss',{{'ISO2dE41','RO2'}},...
    'gain',struct('name',{'ISORO2'},'value',{1}),'ksource','MCM');

r_ISO2dZ41_RO2 = struct('k','2.40e-12','loss',{{'ISO2dZ41','RO2'}},...
    'gain',struct('name',{'ISORO2'},'value',{1}),'ksource','MCM');

r_ISO2b43_RO2 = struct('k','2.40e-12','loss',{{'ISO2b43','RO2'}},...
    'gain',struct('name',{'ISORO2'},'value',{1}),'ksource','MCM');

r_ISO2dE14_RO2 = struct('k','2.40e-12','loss',{{'ISO2dE14','RO2'}},...
    'gain',struct('name',{'ISORO2'},'value',{1}),'ksource','MCM');

r_ISO2dZ14_RO2 = struct('k','2.40e-12','loss',{{'ISO2dZ14','RO2'}},...
    'gain',struct('name',{'ISORO2'},'value',{1}),'ksource','MCM');

r_ISO2b12_RO2 = struct('k','2.40e-12','loss',{{'ISO2b12','RO2'}},...
    'gain',struct('name',{'ISORO2'},'value',{1}),'ksource','MCM');


%3d: Isomerization
r_ISO2dE41_isom = struct('k','0','loss',{{'ISO2dE41'}},...
    'gain',struct('name',{'ISOisom'},'value',{1}),'ksource','MCM');

r_ISO2dZ41_isom = struct('k','0','loss',{{'ISO2dZ41'}},...
    'gain',struct('name',{'ISOisom'},'value',{1}),'ksource','MCM');

r_ISO2b43_isom = struct('k','0','loss',{{'ISO2b43'}},...
    'gain',struct('name',{'ISOisom'},'value',{1}),'ksource','MCM');

r_ISO2dE14_isom = struct('k','0','loss',{{'ISO2dE14'}},...
    'gain',struct('name',{'ISOisom'},'value',{1}),'ksource','MCM');

r_ISO2dZ14_isom = struct('k','0','loss',{{'ISO2dZ14'}},...
    'gain',struct('name',{'ISOisom'},'value',{1}),'ksource','MCM');

r_ISO2b12_isom = struct('k','0','loss',{{'ISO2b12'}},...
    'gain',struct('name',{'ISOisom'},'value',{1}),'ksource','MCM');


%4: Include the other VOCs to get RO2 stuff. 
r_VOCR_OH = struct('k','1','loss',{{'VOCR'}},...
    'gain',struct('name',{'RO2g'},'value',{1}),'ksource','none');

r_RO2g_HO2 = struct('k','2.91e-13.*exp(1300./T)','loss',{{'RO2g','HO2'}},...
    'gain',struct('name',{'RgOOH'},'value',{1}),'ksource','MCM');

r_RO2g_NO = struct('k','2.7e-12.*exp(360./T)','loss',{{'RO2g','NO'}},...
    'gain',struct('name',{'RgNO'},'value',{1}),'ksource','MCM');

r_RO2g_RO2 = struct('k','2.40e-12','loss',{{'RO2g','RO2'}},...
    'gain',struct('name',{'RO2gRO2'},'value',{1}),'ksource','MCM');

    
