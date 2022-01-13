a=1;b=1.05;c=1.1;
M=[a,c,b;b a c;c b a];
M2=M+rand(3);
%M3=M+0.5*randn(3);
eig(M2./max(M2(:)))

