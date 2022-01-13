function [b,p,h] = myhist(y,n)
if nargin==1
    n=round(sqrt(length(y)));
end
[h,b]=hist(y,n);
p=h./sum(h)./mean(diff(b));
