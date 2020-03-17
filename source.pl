% ---case(id,ligne,colonne,sniper,liste des persos) ---
case(t11,1,1,s,[loup]).
case(t21,2,1,n,[chat]).
case(t31,3,1,s,[panda]).
case(t41,4,1,n,[tortue]).

case(t12,1,2,n,[ours]).
case(t22,2,2,n,[pigeon]).
case(t32,3,2,s,[renard]).
case(t42,4,2,n,[croco]).

case(t13,1,3,s,[tigre]).
case(t23,2,3,s,[poulpe]).
case(t33,3,3,n,[fouine]).
case(t43,4,3,s,[koala]).

case(t14,1,4,n,[canard]).
case(t24,2,4,s,[singe]).
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
personnage(belette,innocent,none,vivant).
personnage(koala,innocent,none,vivant).
personnage(canard,innocent,none,vivant).
personnage(singe,innocent,none,vivant).
personnage(rhino,innocent,none,vivant).
personnage(tatou,innocent,none,vivant).

personnage(police1,police,none,vivant).
personnage(police2,police,none,vivant).
personnage(police3,police,none,vivant).

joueur(j1,0,attente,0). %nom du joueur, score, état, actions restantes pour le tour
joueur(j2,0,attente,0).
% persos = [loup,ours,tigre,canard,chat,pigeon,poulpe,singe,panda,renard,belette,rhino,tortue,croc,koala,tatou]


%--- Prédicats de manipulation de liste ---
dans(X,[X|_]).
dans(X,[T|Q]):- X\==T,dans(X,Q).

supprimer(E,[E|Q],QT):-supprimer(E,Q,QT). % si l'élément à supprimer est le premier élément de la liste.
supprimer(E,[T|Q],[T|QT]):- E \== T, supprimer(E,Q,QT).
supprimer(_,[],[]).

conc([E],L,[E|L]).
conc([T,Q],L2,[T|QL]):- conc(Q,L2,QL).

%ajouter(E,L,LR):- conc(L,[E],LR).
ajouter(E,L,LR):- conc([E],L,LR).
ajouter(E,[],[E]).

%--- Prédicats de jeu---

% - Initialisation -
lancerJeu :- dynamic(case/5),dynamic(personnage/4),dynamic(joueur/4), tour(j1).

% - Tuer -
tuer(Joueur,PersoCible):- personnage(PersoTueur,tueur,Joueur,vivant),
case(CaseCible,_,_,_,X),dans(PersoCible,X),
(pistolet(PersoTueur,CaseCible);sniper(PersoTueur,CaseCible);couteau(PersoTueur,CaseCible)),
mourir(PersoCible,CaseCible),consequencesScore(Joueur,PersoCible),!.
%faudra aussi voir si c'est la victime pour le score
%fix le suicide

mourir(PersoCible,CaseCadavre):- personnage(PersoCible,_,_,vivant),
retract(personnage(PersoCible,Role,Joueur,vivant)),
assert(personnage(PersoCible,Role,Joueur,mort)),
case(CaseCadavre,L,C,S,Temoins),
supprimer(PersoCible,Temoins,TemoinsVivants),retract(case(CaseCadavre,L,C,S,Temoins)),assert(case(CaseCadavre,L,C,S,TemoinsVivants)). 
%gérer les témoins ici?

pistolet(PersoTueur,CaseCible) :- case(_,LT,CT,_,[X|Q]),X==PersoTueur,case(CaseCible,LC,CC,_,PersosCibles),Q==[], %pas possible si ya un policier sur la case
((CT is CC,LT is LC+1);(CT is CC,LC is LT+1);(CT is CC+1,LC is LT);(CC is CT+1,LC is LT)),\+dans(police1,PersosCibles),\+dans(police2,PersosCibles),\+dans(police3,PersosCibles).
sniper(PersoTueur,CaseCible) :- case(_,LT,CT,s,[X|Q]),X==PersoTueur,case(CaseCible,LC,CC,_,_),Q==[],(CT is CC;LT is LC).
couteau(PersoTueur,CaseCible) :- case(CaseTueur,_,_,_,X),dans(PersoTueur,X), CaseTueur==CaseCible,\+dans(police1,X),\+dans(police2,X),\+dans(police3,X). %pas possible si ya un policier sur la case

% - Déplacer -
deplacer(Perso,IdArrivee):- dansCase(Perso,IdDepart),
                                    case(IdDepart,LiD,CD,SD,LD),
                                    case(IdArrivee,LiA,CA,SA,LA),
                                    supprimer(Perso,LD,NLD),
                                    retract(case(IdDepart,LiD,CD,SD,LD)),
                                    assert(case(IdDepart,LiD,CD,SD,NLD)),
                                    ajouter(Perso,LA,NLA),
                                    retract(case(IdArrivee,LiA,CA,SA,LA)),
                                    assert(case(IdArrivee,LiA,CA,SA,NLA)), !.
                                    
% - Police -
ajouterPolicier(Policier,IdCase):- personnage(Policier,police,_,vivant),
                                    \+ dansCase(Policier,Id),
                                    case(IdCase,LiC,C,S,LC),
                                    ajouter(Policier,LC,NLC),
                                    retract(case(IdCase,LiC,C,S,LC)),
                                    assert(case(IdCase,LiC,C,S,NLC)), !.

dansCase(Perso,Id):- case(Id,_,_,_,L),dans(Perso,L). % fonctionne bien

controleIdentite(Perso,JoueurCible):- dansCase(Perso,IdCase),
                                        dansCase(AutrePerso,IdCase),
                                        personnage(AutrePerso,police,_,vivant),
                                        personnage(Perso,tueur,JoueurCible,_),!.

%Score
gagnerPoints(Joueur,Valeur) :- joueur(Joueur,Score,Tour,A),Somme is (Score+Valeur),assert(joueur(Joueur,Somme,Tour,A)),retract(joueur(Joueur,Score,Tour,A)).

%cas 1 : c'est sa cible
consequencesScore(Joueur,PersoMort) :- personnage(PersoMort,cible,Joueur,mort),gagnerPoints(Joueur,1).
%cas 2 : c'est un tueur adverse
consequencesScore(Joueur,PersoMort) :- personnage(PersoMort,tueur,AutreJoueur,mort),AutreJoueur\==Joueur,gagnerPoints(Joueur,3).
%cas 3 : c'est un innocent
consequencesScore(Joueur,PersoMort) :- personnage(PersoMort,innocent,_,mort),gagnerPoints(Joueur,-1).
%cas 3 bis : c'est la cible d'un autre joueur
consequencesScore(Joueur,PersoMort) :- personnage(PersoMort,cible,AutreJoueur,mort),AutreJoueur\==Joueur,gagnerPoints(Joueur,-1).
%cas 4 : c'est un policier
consequencesScore(Joueur,PersoMort) :- personnage(PersoMort,police,_,mort),gagnerPoints(Joueur,-1337).

%Affichage

%afficherPlateau :-case(NumeroCase,_,_,Sniper,Personnages).
%à réecrire avec les trucs de méta prédicats pour que ça soit utile

%Gestion des tours

tour(Joueur):- print('A ton tour,'),print(Joueur),print('Tu as 2 actions, tu peux : deplacer(Perso,IdCaseArrivee), tuer(JoueurActif,Cible) ou controleIdentite(Perso,JoueurCible). Tu peux egalement consulter, sans que cela te coute une action : joueur(Nom,Score,Etat,ActionsRestantes),case(Id,Ligne,Colonne,Sniper,Personnages),personnage(Nom,Role,JoueurAssocie,Etat)'),
retract(joueur(Joueur,S,E,A)),assert(joueur(Joueur,S,actif,2)).

%Fin de fichier