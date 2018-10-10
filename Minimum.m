function [mini, Minima]=Minimum(I,s)

ind=find(I==0);
I(ind)=max(I(:))*1.1;
%Minima = imregionalmin(I);
Minima = imextendedmin(I,s);

figure(3),imagesc(Minima);

mini=find(Minima);



