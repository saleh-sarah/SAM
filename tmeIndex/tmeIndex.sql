

-- ===================
-- 3I009 2017
-- ===================

-- Compte rendu du TME 4-5 sur les plan d'exécution
-- ================================================

-- NOM, Prénom 1 :
-- NOM, Prénom 2 :


-- Préparation : création de la relation Annuaire
-- ===========
@vider
@annuaire

@liste

-- schéma des relations :
desc Annuaire
desc BigAnnuaire


select count(*) as nb_personnes from BigAnnuaire;


--ordre des operations :
-- - on commence par un ACCESS(index range scan, table access full)
-- - on peut continuer par un filter

-- Question préliminaire: Statistiques sur les tables
-- ==================================================

explain plan for
    select * from Annuaire;
@p3


explain plan for
    select * from BigAnnuaire;
@p3


explain plan for
    select distinct nom from BigAnnuaire;
@p3


explain plan for
    select distinct prenom from BigAnnuaire;
@p3


explain plan for
    select distinct age from BigAnnuaire;
@p3


explain plan for
    select distinct cp from BigAnnuaire;
@p3


select min(population), max(population)
from Ville;


-- =================================
-- Exercice 1 : Sélection avec index
-- =================================

-- a)
explain plan for
    select a.nom, a.prenom
    from BigAnnuaire a
    where a.age = 18;
@p3


-- b)
explain plan for
    select a.nom, a.prenom
    from BigAnnuaire a
    where a.age between 20 and 29;
@p3


-- c)
explain plan for
   select a.nom, a.prenom
   from BigAnnuaire a
   where a.age < 70 and (a.cp = 93000 or a.cp = 75000);
@p3


-- d)
explain plan for
    select a.nom, a.prenom
    from BigAnnuaire a
    where a.age = 20 and a.cp = 13000 and a.nom like 'T%';
@p3


-- Exercice 2: Sélection AVEC/SANS index
-- =====================================

-- a)
explain plan for
    select a.nom, a.prenom
    from BigAnnuaire a
    where a.age <= 100;
@p4

--Prédicat	Rows	Index utilisé	Cout
--age<=10	22852	age   		46
--age <=20	43901	age		87
--age <=30	65980	age		130
--age <= 40	87623	non		70893
--age <= 60	129K	non		70893
--age <= 100	220K	non		70893

--b) Le prédicat préfère évaluer la requête dans utiliser l'indexAge quand l'age devient trop grand (à partir de 40) , le cout devient trop important et ce n'est alors plus intéressant.



--COMPLETER




-- c)
explain plan for
    select a.nom, a.prenom
    from BigAnnuaire a
    where a.cp BETWEEN 50000 AND 50150;
@p4
explain plan for
    select a.nom, a.prenom
    from BigAnnuaire a
    where a.cp BETWEEN 50000 AND 90000;
@p4




-- Exercice 3. Comparaison de plans d'exécutions équivalents
-- =========================================================
explain plan for
   SELECT /* + index( a IndexAge)*/   a.nom, a.prenom 
   FROM BigAnnuaire a WHERE a.age < 7;
@p4


explain plan for
   SELECT /*+  no_index(a IndexAge) */   a.nom, a.prenom
   FROM BigAnnuaire a WHERE a.age < 7;
@p4

explain plan for
   SELECT a.nom, a.prenom
   FROM BigAnnuaire a WHERE a.age < 7;
@p4

-- b)

explain plan for
   SELECT /* + index( a IndexAge)*/   a.nom, a.prenom 
   FROM BigAnnuaire a WHERE a.age >19 ;
@p4


explain plan for
   SELECT /*+  no_index(a IndexAge) */   a.nom, a.prenom
   FROM BigAnnuaire a WHERE a.age > 19 ;
@p4

explain plan for
   SELECT a.nom, a.prenom
   FROM BigAnnuaire a WHERE a.age > 19;
@p4



--c)
explain plan for
    select /*+ index(a IndexAge) no_index(a IndexCp)  */  a.nom, a.prenom 
    from BigAnnuaire a where a.age = 18 and a.cp = 75000;
@p4

explain plan for
    select /*+ index(a IndexAge) index(a IndexCp)  */  a.nom, a.prenom 
    from BigAnnuaire a where a.age = 18 and a.cp = 75000;
@p4

explain plan for
    select /*+ no_index(a IndexAge) index(a IndexCp)  */  a.nom, a.prenom 
    from BigAnnuaire a where a.age = 18 and a.cp = 75000;
@p4

explain plan for
    select /*+ no_index(a IndexAge) no_index(a IndexCp)  */  a.nom, a.prenom 
    from BigAnnuaire a where a.age = 18 and a.cp = 75000;
@p4

explain plan for
    select a.nom, a.prenom 
    from BigAnnuaire a where a.age = 18 and a.cp = 75000;
@p4



-- Exercice 4: Jointure avec index
-- ==================================

-- a) avec le "petit" Annuaire
explain plan for
    select a.nom, a.prenom, v.ville
    from Annuaire a, Ville v
    where a.cp = v.cp
    and a.age=18;
@p3


-- b) avec BigAnnuaire
explain plan for
    select a.nom, a.prenom, v.ville
    from BigAnnuaire a, Ville v
    where a.cp = v.cp
    and a.age=18;
@p3

--La table ville est lue avant l'annuaire car elle contient 1000 lignes tandis que le big annuaire en contient 1665, il est plus intéressant de la lire donc avant. En revanche, dans la requête précédente, l'annuaire ne contient que 20 personnes qui ont 18 ans donc pour minimiser le nombre de vues, on commence par l'annuaire.
    


--c)
explain plan for
    select a.nom, a.prenom, v.ville
    from BigAnnuaire a, Ville v
    where a.cp = v.cp
    and v.population >= 985000;
@p3




-- Exercice 5: Autres Requetes 
-- ===========================

-- voir les requetes sur l'énoncé en ligne
EXPLAIN plan FOR
    SELECT age, COUNT(*)
    FROM BigAnnuaire a
    GROUP BY age;
@p3
--Groupe les résultats suivant une table de hachage. Cette opération a besoin de grandes quantités de mémoire pour matérialiser le résultat intermédiaire

EXPLAIN plan FOR
    SELECT age, COUNT(*)
    FROM BigAnnuaire a
    GROUP BY age
    HAVING COUNT(*) > 200;
@p3
----Lit l'index en entier (toutes les lignes) comme stocké sur disque et groupe les résultats suivant une table de hachage et filtre

EXPLAIN plan FOR
    SELECT MIN(cp), MAX(cp)
    FROM BigAnnuaire a;
@p3


EXPLAIN plan FOR
    SELECT a.nom, a.prenom
    FROM BigAnnuaire a
    WHERE a.prenom NOT IN ( SELECT b.prenom
                        FROM BigAnnuaire b
			WHERE b.age<=7);
@p3
--HASH JOIN RIGHT ANTI pour requete not in : enleve les cardinalités couteuses 
EXPLAIN plan FOR
    SELECT a.nom, a.prenom
    FROM BigAnnuaire a
    WHERE NOT EXISTS ( SELECT *
                       FROM BigAnnuaire b
		       WHERE b.prenom = a.prenom
		       AND b.age < a.age);
@p3
--fait un hash join anti à droite avec un double acces à bigannuaire. Une table accede au prenom et filtre sur l'age.



EXPLAIN plan FOR
  SELECT cp
  FROM BigAnnuaire a
  minus
   SELECT cp
   FROM BigAnnuaire b
   WHERE b.age>=100;
@p3

--un index sur le cp en prenant les unique et minus un index sur le cp en full scan pour lire toutes l'index et un sur l'age avec le predicat en range scan en prenant les lignes unique

EXPLAIN plan FOR
    SELECT a.nom, a.prenom
    FROM BigAnnuaire a
    WHERE a.age >= ALL (SELECT b.age 
                       FROM BigAnnuaire b
		       WHERE b.cp = 75000);
@p3

--un index sur l'age où on prend chaque age une fois 

-- Exercice 6: Documentation et Requetes sur le catalogue
-- ======================================================
COLUMN TABLE_NAME format A20
SELECT TABLE_NAME, blocks, num_rows 
FROM user_tables;


-- info sur la taille des index
column table_name format A10
column index_name format A10
--
select table_name, index_name, blevel, distinct_keys, leaf_blocks,
avg_leaf_blocks_per_key, avg_data_blocks_per_key
from user_indexes
where table_name = 'ANNUAIRE';

select table_name, index_name, blevel, distinct_keys, leaf_blocks,
avg_leaf_blocks_per_key, avg_data_blocks_per_key
from all_indexes
where table_name = 'BIGANNUAIRE';

