fldr = 'C:\Users\yoel\Dropbox\SocialStructureGraph\';
data = readtable([fldr,'statistical materials\population structure.xlsx'],'Sheet', 'age distributions');

kids_age2 = zeros(100,1);
% mum is i+j years old
% gave birth at age j
% child is i years old
for i = 1:100
    for j = 1:100
        if i+j<100 
            kids_age2(i) = kids_age2(i) + data.houseowner_mum_(i+j)*data.agesOfBirth(j);
        end
    end
end
DAD_FACTOR = 10;
dads_age = zeros(100,1);
for i = 1:100
    for j = (1:length(data.dadsDelta)) - DAD_FACTOR
        if 0<i+j && i+j<100
            dads_age(i+j) = dads_age(i+j) + data.houseowner_mum_(i)*data.dadsDelta(j + DAD_FACTOR);
        end
    end
end

kids_age2 = kids_age2/sum(kids_age2);

figure; plot(1:100,data.houseowner_mum_,'b*-')
hold on; plot(1:100,data.agesOfBirth,'r.')
hold on; plot(1:100, kids_age2, 'ks')
xlabel('age')
ylabel('probability')
legend('mums age','birth age', 'kids age');