function out=makeGraphWithGivenDegreeDistribution(nG,OutDegree,EraseSelfLoopsYN)
%out=makeGraphWithGivenDegreeDistribution(nG,OutDegree,EraseSelfLoopsYN)
%creates a graph with nG nodes and a degree distribution which is
%approximatly equals to OutDegree = vector of length nG with entries that
%specify the degree distribution per node in the graph.
%set EraseSelfLoopsYN = 0 to avoid deleting self-loops 
%(which is also the default)
if exist('EraseSelfLoopsYN','var')==0%default answer is Yes
EraseSelfLoopsYN=1;
end
if rem(nG,2)~=0
    nG=nG+1;
end
G=zeros(nG);
stubs=ceil(OutDegree);
while sum(stubs)>0
    indtmp=find(stubs>0);
    i=unidrnd(length(indtmp));
    j=unidrnd(length(indtmp));
    if EraseSelfLoopsYN==1
        for kk=1:3%reduce probability to have self loops
            if j==i
                j=unidrnd(length(indtmp));
            end
        end
    end
    G(indtmp(i),indtmp(j))=G(indtmp(i),indtmp(j))+1;
    G(indtmp(j),indtmp(i))=G(indtmp(j),indtmp(i))+1;
    stubs(indtmp(i))=stubs(indtmp(i))-1;
    stubs(indtmp(j))=stubs(indtmp(j))-1;
end
G=(G>0);
if EraseSelfLoopsYN==1
    for k=1:nG%erase self loops
        G(k,k)=0;
    end
end
out=G;



