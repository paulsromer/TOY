
%This is the initalization routine for this thing. Builds some
%structures. k will have be calculated on every call. 
ppb_NO = 50/1000;
ppb_O3 = 38;
ppb_HO2 = 60/1000;
ppb_ISOP = 6;
ppb_OH = .08/1000; %I think this is correct. 
ppb_NO2 = 250/1000;
m_VOCR = 16;

want_to_plot = {'ISOP','ISOPOOH'};
classes_of_interest = struct();
% classes_of_interest(1).name = 'NOy'; classes_of_interest(1).comp = {'NO','NO2','AN','PAN'};
% classes_of_interest(2).name = 'HOx'; classes_of_interest(2).comp = {'OH','HO2'};
% classes_of_interest(3).name = 'HOxROx'; classes_of_interest(3).comp = {'OH','HO2','ISOPOO','ISOPOOH','IEPOXOO','OVOCOO'};
% classes_of_interest(4).name = 'OVOC'; classes_of_interest(4).comp = {'OVOC','OVOCOO','PAN'};