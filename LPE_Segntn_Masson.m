%Segmentation par ligne de partage des eaux

close all
clear all
clc

tic
CQueue

num=2; %correspond à différentes images
switch num
    case 1
        I=[8 5 5 6 5 7
            6 3 3 5 4 5
            4 1 1 3 5 8
            8 4 3 4 6 4
            9 10 10 6 3 3
            9 10 10 5 4 4
            ];
        mini=[9, 15, 26, 29, 35];
        plateau=false; %pas de fond traité comme marqueur : toute l'image est partionnée
    case 2
        I0=imread('Image2.gif');
        figure(2),imagesc(I0),colormap gray, title('I0');
        I=Distance(I0,0); %ce sera l'image sur laquelle est effectuée la LPE
        [mini, Minima]=Minimum(I,0.012); %recherche des minima étendus
        
        I=im2uint8(I) + 1; %un indice de la FAH=un ng => on passe en entier non signé
        plateau=true; %Le fond n'est pas traité=un marqueur
    case 3
        I0=rgb2gray(imread('Image3.jpg'));
        figure(2);
        imagesc(I0),colormap gray, title('I0');
        
        I=Distance(I0,38.0); %ce sera l'image sur laquelle est effectuée la LPE (index 38 pour la "tache" noire)
        [mini, Minima]=Minimum(I,0.0065); %recherche des minima étendus
        
        I=im2uint8(I) + 1; %un indice de la FAH=un ng => on passe en entier non signé
        plateau=true; %Le fond n'est pas traité=un marqueur

end

[H W]=size(I);
figure(1),imagesc(I),colormap gray;

%Carte des minima = les marqueurs
L=zeros(H,W);
L(mini)=1;
[L n]=bwlabel(L);

%Ajout des pixels du fond aux marqueurs
if plateau
    ind=find(I==1);
    n=n+1;
    L(ind)=n;
end
figure(3),imagesc(L);

%Création du "tableau de queues" i.e. FAH
ng=I(:);
ng=unique(ng);
for i=1:length(ng)
    FAH(ng(i))=CQueue();
end

%Algorithme de LPE par FAH

% On empile les pixels marqueurs dans la FAH
for i=1:length(mini)    
    FAH(I(mini(i))).push(mini(i));
end


indice=min(I(mini));% On désigne la queue prioritaire cad le NG minimum
while indice<length(ng)
   jeton_crt= FAH(indice).pop(); %on extrait le jeton prioritaire
    
   [indice_i,indice_j]=ind2sub([H,W],jeton_crt);
   v=[indice_i-1,indice_j;
        indice_i+1,indice_j;
        indice_i,indice_j-1;
        indice_i,indice_j+1]; %création de la matrice avec les voisins V4 
    
    voisin=ones(4);%initialisation du vecteur contenant les voisins
    j=1;
    for i=1:4
        if ( (1<v(i,1) && v(i,1)<H) && (1<v(i,2) && v(i,2)<W) ) % Verification de l'appartenance du voisin a l image
            voisin(j)=sub2ind([H,W],v(i,1),v(i,2)); %conversion indices 2D en indice lineaire
            j=j+1;
        end
    end
    
    for m=1:4
        if L(voisin(m))==0 % On verifie si le voisin est marque
            L(voisin(m))=L(jeton_crt); % on le marque comme le jeton courant
            
            ng_courant=find(ng==I(voisin(m))); % le NG courant devient celui du voisin courant
            
            if ng_courant>=indice %si le NG du voisin est supérieur à celui du pixel courant
                FAH(ng_courant).push(voisin(m)); % on place le voisin courant dans la pile correspondante
            else                  %si le NG du voisin est inférieur à celui du pixel courant
                FAH(indice).push(voisin(m)); % le voisin courant est mis dans la pile prioritaire car il a le plus petit NG
            end
        end
    end
            
    while FAH(indice).isempty()==true %quand la queue prioritaire est vide, on passe à la suivante
        indice=indice+1; 
    end
end

figure(4)
imagesc(L);
title('Image segmentée par une LPE basée sur une FAH');

t=toc;
fprintf('\nRuning time %f s',t);






