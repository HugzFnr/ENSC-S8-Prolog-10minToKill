% ---case(id,ligne,colonne,sniper,liste des persos) ---
case(t11,1,1,s,[loup]).
case(t21,2,1,n,[chat]).
case(t31,3,1,n,[panda]).
case(t41,4,1,n,[tortue]).

case(t12,1,2,n,[ours]).
case(t22,2,2,n,[pigeon]).
case(t32,3,2,s,[renard]).
case(t42,4,2,n,[croco]).

case(t13,1,3,n,[tigre]).
case(t23,2,3,s,[poulpe]).
case(t33,3,3,n,[fouine]).
case(t43,4,3,n,[koala]).

case(t14,1,4,n,[canard]).
case(t24,2,4,n,[singe]).
case(t34,3,4,n,[rhino]).
case(t44,4,4,s,[tatou]).

% --- personnage(nom,role(tueur/cible/innocent/police),joueur(j1,j2,none),etat(vivant/mort/arrete)). ---
personnage(loup,tueur,j1,vivant).
personnage(chat,tueur,j2,vivant).

personnage(panda,cible,j1,vivant).
personnage(tortue,cible,j1,vivant).
personnage(ours,cible,j1,vivant).

personnage(pigeon,cible,j2,vivant).
personnage(renard,cible,j2,vivant).
personnage(croco,cible,j2,vivant).

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

%--- Prédicats de manipulation de liste ---
dans(X,[X|_]).
dans(X,[T|Q]):- X\==T,dans(X,Q).

supprimer(E,[E|Q],QT):-supprimer(E,Q,QT). % si l'élément à supprimer est le premier élément de la liste.
supprimer(E,[T|Q],[T|QT]):- E \== T, supprimer(E,Q,QT).
supprimer(_,[],[]).

conc([E],L,[E|L]).
conc([T,Q],L,[T|QL]):- conc(Q,L,QL).
ajouter(E,L,LR):- conc(L,[E],LR).
ajouter(E,[],[E]).

%--- Prédicats de jeu---

% - Initialisation -
lancerJeu :- dynamic(case/5),dynamic(personnage/4). %

% - Tuer -
tuer(Joueur,PersoCible):- personnage(PersoTueur,tueur,Joueur,vivant),
case(CaseCible,_,_,_,X),dans(PersoCible,X),
(pistolet(PersoTueur,CaseCible);sniper(PersoTueur,CaseCible);couteau(PersoTueur,CaseCible)),
mourir(PersoCible,CaseCible).

mourir(PersoCible,CaseCadavre):- personnage(PersoCible,_,_,vivant),
retract(personnage(PersoCible,Role,Joueur,vivant)),
assert(personnage(PersoCible,Role,Joueur,mort)),
case(CaseCadavre,_,_,_,Temoins),
supprimer(PersoCible,Temoins,TemoinsVivants),retract(case(CaseCadavre,C,L,S,Temoins)),assert(case(CaseCadavre,C,L,S,TemoinsVivants)). %puis l'enlever de la case 
%faudra aussi voir si c'est la victime pour le score

pistolet(PersoTueur,CaseCible) :- 1==2. %temp
sniper(PersoTueur,CaseCible) :- 1==2. %d'abord on test le couteau hein
couteau(PersoTueur,CaseCible) :- case(CaseTueur,_,_,_,X),dans(PersoTueur,X), CaseTueur==CaseCible.

% - Déplacer -
deplacer(Perso,IdDepart,IdArrivee):- case(IdDepart,_,_,_,LD),case(IdArrivee,_,_,_,LA),
                                    supprimer(Perso,LD,NLD),
                                    retract(case(IdDepart,_,_,_,LD)),
                                    assert(case(IdDepart,_,_,_,NLD)),
                                    ajouter(Perso,LA,NLA),
                                    retract(case(IdArrivee,_,_,_,LA)),
                                    assert(case(IdArrivee,_,_,_,NLA)), !.
                                    
% - Police -
ajouterPolicier(Policier,IdCase):- personnage(Policier,police,_,vivant),
                                    case(IdCase,_,_,_,LC),
                                    ajouter(Policier,LC,NLC),
                                    retract(case(IdCase,_,_,_,LC)),
                                    assert(case(IdCase,_,_,_,NLC)), !.

dansCase(Perso,Id):- case(Id,_,_,_,L),dans(Perso,L),!. % fonctionne bien

controleIdentite(Perso,IdCase,JoueurCible):- dansCase(Perso,IdCase),
                                            case(IdCase,_,_,_,L),
                                            dans(personnage(Policier,police,_,vivant),L),
                                            personnage(Perso,tueur,JoueurCible,_),!.

%Fin de fichier