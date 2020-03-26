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
personnage(loup,innocent,none,vivant). % tueur j1
personnage(chat,innocent,none,vivant). %tueur j2

personnage(panda,innocent,none,vivant). % cible j1
personnage(tortue,innocent,none,vivant). % cible j1
personnage(ours,innocent,none,vivant). % cible j1

personnage(pigeon,innocent,none,vivant). % cible j2
personnage(renard,innocent,none,vivant). % cible j2
personnage(croco,innocent,none,vivant). % cible j2

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

joueur(j1,0,attente,0,j2). %nom du joueur, score, état, actions restantes pour le tour, joueur suivant
joueur(j2,0,attente,0,j1).
% persos = [loup,ours,tigre,canard,chat,pigeon,poulpe,singe,panda,renard,belette,rhino,tortue,croc,koala,tatou]


%--- Prédicats de manipulation de liste ---
dans(X,[X|_]).
dans(X,[T|Q]):- X\==T,dans(X,Q).

supprimer(E,[E|Q],QT):-supprimer(E,Q,QT). % si l'élément à supprimer est le premier élément de la liste.
supprimer(E,[T|Q],[T|QT]):- E \== T, supprimer(E,Q,QT),!.
supprimer(_,[],[]).

conc([E],L,[E|L]).
conc([T,Q],L2,[T|QL]):- conc(Q,L2,QL).

%ajouter(E,L,LR):- conc(L,[E],LR).
ajouter(E,L,LR):- conc([E],L,LR).
ajouter(E,[],[E]).

%--- Prédicats de jeu---

% - Initialisation -
lancerJeu :- dynamic(case/5),
            dynamic(personnage/4),
            dynamic(joueur/5),
            tour(j1),
            use_module(library(random)),
            % on attribue un tueur au joueur 1            
            random_member(Tueur1, [loup,ours,tigre,canard,chat,pigeon,poulpe,singe,panda,renard,belette,rhino,tortue,croc,koala,tatou]),
            supprimer(Tueur1,[loup,ours,tigre,canard,chat,pigeon,poulpe,singe,panda,renard,belette,rhino,tortue,croc,koala,tatou],Persos1),
            assert(personnage(Tueur1,tueur,j1,vivant)),
            retract(personnage(Tueur1,innocent,none,vivant)),
            % on attribue ses cibles au joueur 1
            %      Cible 1 du joueur 1
            random_member(Cible11,Persos1),
            supprimer(Cible11,Persos1,Persos2),
            assert(personnage(Cible11,cible,j1,vivant)),
            retract(personnage(Cible11,innocent,none,vivant)),
            %      Cible 2 du joueur 1
            random_member(Cible12,Persos2),
            supprimer(Cible12,Persos2,Persos3),
            assert(personnage(Cible12,cible,j1,vivant)),
            retract(personnage(Cible12,innocent,none,vivant)),
            %      Cible 3 du joueur 1
            random_member(Cible13,Persos3),
            supprimer(Cible13,Persos3,Persos4),
            assert(personnage(Cible13,cible,j1,vivant)),
            retract(personnage(Cible13,innocent,none,vivant)),
            % on attribue un tueur au joueur 2
            random_member(Tueur2,Persos4),
            supprimer(Tueur2,Persos4,Persos5),
            assert(personnage(Tueur2,tueur,j2,vivant)),
            retract(personnage(Tueur2,innocent,none,vivant)),
            % on attribue ses cibles au joueur 2
            %      Cible 1 du joueur 2
            random_member(Cible21,Persos5),
            supprimer(Cible21,Persos5,Persos6),
            assert(personnage(Cible21,cible,j2,vivant)),
            retract(personnage(Cible21,innocent,none,vivant)),
             
            %      Cible 2 du joueur 2
            random_member(Cible22,Persos6),
            supprimer(Cible22,Persos6,Persos7),
            assert(personnage(Cible22,cible,j2,vivant)),
            retract(personnage(Cible22,innocent,none,vivant)),
                       
            %      Cible 3 du joueur 2
            random_member(Cible23,Persos7),
            supprimer(Cible23,Persos7,_),
            assert(personnage(Cible23,cible,j2,vivant)),
            retract(personnage(Cible23,innocent,none,vivant)).


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
                                    \+ dansCase(Policier,_),
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
gagnerPoints(Joueur,Valeur) :- joueur(Joueur,Score,Tour,A,JS),Somme is (Score+Valeur),assert(joueur(Joueur,Somme,Tour,A,JS)),retract(joueur(Joueur,Score,Tour,A,JS)).

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

getJoueurActif(JoueurActif) :- joueur(JoueurActif,_,actif,_,_).

prochainJoueur(JoueurActif,JoueurSuivant) :- joueur(JoueurActif,_,_,_,JoueurSuivant).

changerTour :- getJoueurActif(JoueurActif),prochainJoueur(JoueurActif,JoueurSuivant),tour(JoueurSuivant).

tour(Joueur):- print('A ton tour,'),print(Joueur),print('Tu as 2 actions, tu peux : deplacer(Perso,IdCaseArrivee), tuer(JoueurActif,Cible) ou controleIdentite(Perso,JoueurCible). Tu peux egalement consulter, sans que cela te coute une action : joueur(Nom,Score,Etat,ActionsRestantes),case(Id,Ligne,Colonne,Sniper,Personnages), personnage(Nom,Role,JoueurAssocie,Etat)'),
retract(joueur(Joueur,S,E,A)),assert(joueur(Joueur,S,actif,2)).

%Vérif de fin de jeu


%Fin de fichier