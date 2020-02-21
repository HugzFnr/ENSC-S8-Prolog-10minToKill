%  CASES DU PLATEAU
% case(id,ligne,colonne,sniper,liste des persos)

case(t11,l1,c1,s,[loup]).
case(t21,l2,c1,n,[chat]).
case(t31,l3,c1,n,[panda]).
case(t41,l4,c1,n,[tortue]).

case(t12,l1,c2,n,[ours]).
case(t22,l2,c2,n,[pigeon]).
case(t32,l3,c2,n,[renard]).
case(t42,l4,c2,n,[croco]).

case(t13,l1,c3,n,[tigre]).
case(t23,l2,c3,n,[poulpe]).
case(t33,l3,c3,n,[fouine]).
case(t43,l4,c3,n,[koala]).

case(t14,l1,c4,n,[canard]).
case(t24,l2,c4,n,[singe]).
case(t34,l3,c4,n,[rhino]).
case(t44,l4,c4,n,[tatou]).

% personnage(nom,role(tueur/cible/innocent/police),joueur(j1,j2,none),etat(vivant/mort/arrete)).
personnage(loup,innocent,none,vivant).
personnage(chat,innocent,none,vivant).
personnage(panda,innocent,none,vivant).
personnage(tortue,innocent,none,vivant).
personnage(ours,innocent,none,vivant).
personnage(pigeon,innocent,none,vivant).
personnage(renard,innocent,none,vivant).
personnage(croco,innocent,none,vivant).
personnage(tigre,innocent,none,vivant).
personnage(poulpe,innocent,none,vivant).
personnage(fouine,innocent,none,vivant).
personnage(koala,innocent,none,vivant).
personnage(canard,innocent,none,vivant).
personnage(singe,innocent,none,vivant).
personnage(rhino,innocent,none,vivant).
personnage(tatou,innocent,none,vivant).

personnage(police1,police,none,vivant).
personnage(police2,police,none,vivant).
personnage(police3,police,none,vivant).



%faut balancer ça au début : dynamic(case/5). on sait pas si on peut le mettre dans le code source
%ça permet de utiliser les assert et retract pour supprimer et ajouter des prédicats

%Soit prédicats dynamiques
%soit des listes qui se baladent de prédicat en prédicat, avec des gros états et des accesseurs, un peu type orienté objet

supprimer(E,[E|Q],QT):-supprimer(E,Q,QT). % si l'élément à supprimer est le premier élément de la liste.
supprimer(E,[T|Q],[T|QT]):- E \== T, supprimer(E,Q,QT).
supprimer(_,[],[]).

conc([E],L,[E|L]).
conc([T,Q],L,[T|QL]):- conc(Q,L,QL).
ajouter(E,L,LR):- conc(L,[E],LR).
ajouter(E,[],[E]).

dans(X,[X|_]).
dans(X,[T|Q]):- X \== T, dans(X,Q).

deplacer(Perso,IdDepart,IdArrivee):- case(IdDepart,LigneD,ColonneD,SniperD,LD),case(IdArrivee,LigneA,ColonneA,SniperA,LA),
                                    supprimer(Perso,LD,NLD),retract(case(IdDepart,LigneD,ColonneD,SniperD,LD)),assert(case(IdDepart,LigneD,ColonneD,SniperD,NLD)),
                                    ajouter(Perso,LA,NLA),retract(case(IdArrivee,LigneA,ColonneA,SniperA,LA)),assert(case(IdArrivee,LigneA,ColonneA,SniperA,NLA)), !.

ajouterPolicier(Policier,IdCase):- case(IdCase,LigneC,ColonneC,SniperC,LC),ajouter(Policier,LC,NLC),retract(case(IdCase,LigneC,ColonneC,SniperC,LC)),assert(case(IdCase,LigneC,ColonneC,SniperC,NLC)), !.

dansCase(Perso,Id):- case(Id,_,_,_,L),dans(Perso,L),!.

controleIdentite(Perso,JoueurCible):- dansCase(Perso,Id),case(Id,_,_,_,L),dans(personnage(_,police,_,vivant),L),personnage(Perso,tueur,JoueurCible,_),!.

%Fin de fichier