function D=Distance(I,s);

[H W]=size(I);
ind= find(I==s);

Ib=zeros(H,W);
Ib(ind)=1;

D = bwdist(~Ib);
ind=find(D);
D(ind)=1./D(ind);