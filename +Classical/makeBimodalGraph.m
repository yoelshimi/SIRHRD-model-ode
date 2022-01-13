d=2;
[G,isregm] = RandomRegularGraph(nG, d);
if isregm==0
    [G,isregm] = RandomRegularGraph(nG, d);
end
rndprm=randperm(nG);
ind=rndprm(1:round(0.075*nG));
for k=1:length(ind)
    rndind=randperm(nG);
    rndind=setdiff(rndind,ind);
    G(ind(k),rndind(1:7))=1;
    G(rndind(1:7),ind(k))=1;
end
