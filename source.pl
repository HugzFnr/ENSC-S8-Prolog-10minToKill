%  CASES DU PLATEAU

case(t11,l1,c1,s,[a,b,c]).
case(t21,l2,c1,n,[]).
case(t12,l1,c2,n,[d]).

%faut balancer ça au début : dynamic(case/5). on sait pas si on peut lem ettre dans le source code
%ça permet de utiliser les assert et retract pour supprimer et ajouter des prédicats

%Soit prédicats dynamiques
%soit des listes qui se baladent de prédicat en prédicat, avec des gros états et des accesseurs, un peu type orienté objet


%plateau([case(1,1,s,L),(1,2,n))

%Fin de fichier