fldr = 'C:\Users\yoel\Dropbox\SocialStructureGraph\';
data = readtable([fldr,'statistical materials\population structure.xlsx'],'Sheet', 'age distributions');

family_dist = readtable([fldr,'statistical materials\population structure.xlsx'],'Sheet', 'family dist','Range', 'A10:H16');

[num_parents,num_kids] = 