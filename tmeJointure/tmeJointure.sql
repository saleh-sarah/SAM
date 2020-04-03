-- NOM: 
-- Prénom: 

-- NOM: 
-- Prénom: 

-- ==========================
--      TME Jointure
-- ========================== 


-- Préparation
-- ===========

-- construire la base contenant les tables J, C et F
@vider
purge recyclebin;
@baseJCF

@liste


-- schéma des tables
desc J
desc C
desc F
desc BigJoueur



--afficher les cardinalités
select count(*) as nb_Joueurs from J;
select count(*) as nb_Clubs from C;
select count(*) as nb_Finances from F;
select count(*) as nb_BigJoueurs from BigJoueur;





-- =====================
-- Exercice préparatoire
-- =====================

explain plan for select * from J;
@p4

cout(r)=a*page(r)+b
28=a*244+b
a=0.3

explain plan for select * from C;
@p4

explain plan for select * from F;
@p4

explain plan for select * from BigJoueur;
@p4


   SELECT TABLE_NAME, num_rows AS cardinalite, blocks AS nb_pages 
    FROM user_tables;

    SELECT TABLE_NAME, num_rows AS cardinalite, blocks AS nb_pages 
    FROM all_tables
    WHERE TABLE_NAME='BIGJOUEUR';
-- ============================================
--    Exercice 1: Jointure entre 2 relations
-- ============================================

-- Question 1
--===========

explain plan for
  select J.licence, C.nom
  from J, C
  where J.cnum = C.cnum
  and salaire >1000;
@p4

--La licence des joueurs et le nom des clubs qui ont ont des salaires supérieurs à 1000
--operateur hash join
--c lue en premier
--cout 78 : somme des couts des deux tables


-- Question 2)
-- ===========

explain plan for
  select J.licence, C.nom
  from C, J
  where J.cnum = C.cnum
  and salaire < 11000;
@p4
--c lue en premier car plus petite que j dans ce cas la
--cout 78
explain plan for
SELECT /*+ ordered */ *
FROM C, BigJoueur j
WHERE j.cnum = c.cnum;
@p4

explain plan for
SELECT /*+ ordered */ *
FROM BigJoueur j, C
WHERE j.cnum = c.cnum;
@p4
--cout total jointure  = 23372-13798-9 = 9565 (mai comprend aussi la construction de la hashmap)

explain plan for
SELECT *
FROM BigJoueur j, C
WHERE j.cnum = c.cnum;
@p4

-- Question 3)
-- ===========
explain plan for
  select J.licence, C.division
  from C, J
  where J.cnum = C.cnum
  and C.nom in ('PSG', 'Barca');
@p4
--operateur : nested loop
--pour chaque joueur on regarde s'il est au barca ou au psg
--cout total = 31 = 2*(1+9)+11 car il y a deux clubs
--cout index = 1
--cout lecture table = 9



-- Question 4)
-- ===========
explain plan for
  select J.licence, C.division
  from C, J
  where J.cnum = C.cnum
  and J.salaire between 10000 and 10001;
@p4
--on commence par lire la table joueur avec l'index puis celle des clubs et on fait la jointure par un nested loops
--cout = 8 = 5 (cout table joueurs) + 2 (index salaire) + 1 (index club rowid)




-- ============================================================
-- EXERCICE 2: Directives USE_NL et USE_HASH pour une jointure
-- ============================================================



-- Question 1
--===========

explain plan for
  select /*+ USE_NL(J,C) */ J.licence, C.nom
  from J, C
  where J.cnum = C.cnum
  and salaire >1000;
@p4

--on force un nested loops : le cout devient 50083 au lieu de 78 avec une table de hachage


-- Question 2)
-- ===========

explain plan for
  select /*+ USE_NL(J,C) */ J.licence, C.nom
  from C, J
  where J.cnum = C.cnum
  and salaire < 11000;
@p4
explain plan for
  select  J.licence, C.nom
  from C, J
  where J.cnum = C.cnum
  and salaire < 11000;
@p4

--cout = 1069 > 78 (table de hachage)

-- Question 3)
-- ===========

explain plan for
  select /*+ USE_HASH(J,C) */ J.licence, C.division
  from C, J
  where J.cnum = C.cnum
  and C.nom in ('PSG', 'Barca');
@p4

explain plan for
  select J.licence, C.division
  from C, J
  where J.cnum = C.cnum
  and C.nom in ('PSG', 'Barca');
@p4

--cout = 78 > 31 (nested loops)

-- Question 4)
-- ===========
explain plan for
  select /*+ USE_HASH(J,C) */ J.licence, C.division
  from C, J
  where J.cnum = C.cnum
  and J.salaire between 10000 and 10001;
@p4


explain plan for
  select J.licence, C.division
  from C, J
  where J.cnum = C.cnum
  and J.salaire between 10000 and 10001;
@p4

--cout = 15






-- =====================================================
--   EXERCICE 3 : Ordre des jointures entre 3 relations 
-- =====================================================


-- ordre1 : CFJ
explain plan for
    select /*+ ORDERED */ C.nom, F.budget 
    from C, F, J
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4


-- ordre2 : CJF
explain plan for
    select /*+ ORDERED */ C.nom, F.budget 
    from C, J, F
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4


-- ordre3 : FCJ
explain plan for
    select /*+ ORDERED */ C.nom, F.budget 
    from F, C, J
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4


-- ordre4 : FJC
explain plan for
    select /*+ ORDERED */ C.nom, F.budget 
    from F, J, C
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
--    where J.cnum = F.cnum and C.cnum = J.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4


-- ordre5 : JCF
explain plan for
    select /*+ ORDERED */ C.nom, F.budget 
    from J, C, F
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4


-- ordre6 : JFC
explain plan for
    select /*+ ORDERED */ C.nom, F.budget 
    from J, F, C
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4


--ordre		1ere jointure	2eme jointure	cout
--CFJ		HASH 		HASH 		84
--CJF		HASH		NESTED		83
--FCJ		HASH		HASH		84
--FJC		HASH		NESTED		79
--JCF		NESTED		NESTED		78
--JFC		NESTED		NESTED		78


--Pour avoir un cout minimum, on doit commencer par parcourir en premier la table J car la selection permet de réduire le nombre d'entrées.


-- SANS directive ORDERED
explain plan for
    select  C.nom, F.budget 
    from J, C, F
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4
--quand on utilise nested pour les deux jointures en particulier JFC, c'est bien celle choisi sans ordered



-- avec directive index(J I_J_salaire)

explain plan for
    select /*+ index(J I_J_salaire) */  C.nom, F.budget 
    from J, C, F
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4

-- On lit d'abord la table J comme précédemment, mais cettte fois-ci on utilise l'index pour le salaire car on a forcé la directive.
--On lit ensuite la table F avec l'index pour faire la jointure avec la table J (on la lit avant la table C car il y a moins de bytes)
-- On lit ensuite la table C aussi avec l'index et on fait la jointure avec le résultat précédent
-- Force à utiliser l'index sur le salaire fait augmenter grandement le cout.


-- avec directive  index(C I_C_division)

explain plan for
    select /*+ index(C I_C_division) */  C.nom, F.budget 
    from J, C, F
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4

--on lit J,C,F
-- on commence par J car il y a moins de n uplets du fait de la selection sur le sport et le salaire
--ensuite comme on a force l'utilisation de l'index sur la division donc on lit la table club
-- puis on lit F

