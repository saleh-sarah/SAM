

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

--Utilise l'index sur l'age, puis accède a la table grace au rowid retourné par l'index et ensuite on fait un select


-- b)
explain plan for
    select a.nom, a.prenom
    from BigAnnuaire a
    where a.age between 20 and 29;
@p3
--Pareil que précédemment, on utilise l'index, la premiere page que l'on accède est celle qui possède le premier prenom et nom dans l'ordre lexicographique qui possède 20 ans et la dernière page est celle qui possède le dernier prenom et nom dans l'ordre lexicographique qui possède 29 ans.


-- c)
explain plan for
   select a.nom, a.prenom
   from BigAnnuaire a
   where a.age < 70 and (a.cp = 93000 or a.cp = 75000);
@p3
-- Utilisation de l'index sur l'age et ensuite on applique un filtre sur les ROWID retournés par l'index et on fait un select


-- d)
explain plan for
    select a.nom, a.prenom
    from BigAnnuaire a
    where a.age = 20 and a.cp = 13000 and a.nom like 'T%';
@p3
--On utilise en premier l'index sur age, puis celui sur le code postal, on y accède par bitmap(plus rapide ?) et ensuite le select.


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

--Puis, on accède à la table Annuaire avec l'index sur l'age pour trouver les rowid qui ont un age de 18
--On accède aux pages
--On accède en premier à la table Ville en plein accès
--On fait ensuite un hash join sur ces deux tables par le code postal
--Enfin, on fait un select pour afficher le nom, le prenom et le code postal 

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
--On accède aux villes qui ont une population supérieure à 985000
--On utilise l'index sur le code postal
--Puis on accède à la table BigAnnuaire en faisant une jointure : pour chaque ville, on accède aux pages correspondantes dans BigAnnuaire (17*220)
--On fait un select.




-- Exercice 5: Autres Requetes 
-- ===========================

-- voir les requetes sur l'énoncé en ligne
--a)
EXPLAIN plan FOR
    SELECT age, COUNT(*)
    FROM BigAnnuaire a
    GROUP BY age;
@p3
--Groupe les résultats suivant une table de hachage. Cette opération a besoin de grandes quantités de mémoire pour matérialiser le résultat intermédiaire

--Index fast full scan : Lit l'index en entier (toutes les lignes) comme stocké sur le disque.
--On utilise l'index fast full scan(avec l'index age), on lit donc toutes les lignes de la table BigAnnuaire.
--On regroupe (group by) ensuite avec une table de hachage pour chaque age, il y en a 100
--On fait ensuite le select dans chaque de ces tables de hachage, on accède donc à 100 pages et on compte le nombre de personnes qui sont dans la table.

--b)
EXPLAIN plan FOR
    SELECT age, COUNT(*)
    FROM BigAnnuaire a
    GROUP BY age
    HAVING COUNT(*) > 200;
@p3
----Lit l'index en entier (toutes les lignes) comme stocké sur disque et groupe les résultats suivant une table de hachage et filtre
--On fait comme précédemment avec l'index fast full scan
--On regroupe (hash group by) mais cette fois-ci, quand plus de 200 personnes ont le même aĝe, on utilise donc un filtre avant de regrouper
--On fait le select


--c)
EXPLAIN plan FOR
    SELECT MIN(cp), MAX(cp)
    FROM BigAnnuaire a;
@p3
--On utilise index fast full scan encore
--On utilise une fonction d'aggrégation pour trier et obtenir le min et le max



--d)
EXPLAIN plan FOR
    SELECT a.nom, a.prenom
    FROM BigAnnuaire a
    WHERE a.prenom NOT IN ( SELECT b.prenom
                        FROM BigAnnuaire b
			WHERE b.age<=7);
@p3
--HASH JOIN RIGHT ANTI pour requete not in : enleve les cardinalités couteuses
--On accède rapidement à toutes les entrées de BigAnnuaire(index fast full scan)
--Puis, on accède une seconde fois à cette table, mais en utilisant l'index sur l'age cette fois-ci pour trouver les personnes qui ont un âge inférieur ou égal à 7
--On fait ensuite une jointure anti pour obtenir toutes les personnes qui ne sont pas dans les résultats
--Finalement, on fait un select.

--e)
EXPLAIN plan FOR
    SELECT a.nom, a.prenom
    FROM BigAnnuaire a
    WHERE NOT EXISTS ( SELECT *
                       FROM BigAnnuaire b
		       WHERE b.prenom = a.prenom
		       AND b.age < a.age);
@p3
--fait un hash join anti à droite avec un double acces à bigannuaire. Une table accede au prenom et filtre sur l'age.


--On fait appel deux fois à la table BigAnnuaire
--Puis on fait une jointure anti avec un filtre sur l'age pour obtenir les personnes qui ont le plus petit âge => La jointure anti prend les personnes pour lesquelles le filtre est vérifié.
--On fait un select pour obtenir les attributs souhaités.




--f)
EXPLAIN plan FOR
  SELECT cp
  FROM BigAnnuaire a
  minus
   SELECT cp
   FROM BigAnnuaire b
   WHERE b.age>=100;
@p3
--un index sur le cp en prenant les unique et minus un index sur le cp en full scan pour lire toutes l'index et un sur l'age avec le predicat en range scan en prenant les lignes unique

--On fait un accès rapide à toutes les entrées de la table Ville en fonction des codes postaux
--On accède ensuite à la table BigAnnuaire avec l'index sur age pour n'obtenir que les personnes qui ont un âge supérieur ou égal à 100
--On fait une jointure sur ces deux tables
--On trie pour n'obtenir que des valeurs uniques
--On accède encore une fois à toutes les entrées de la table Ville en fonction des codes postaux (index fast full scan)
--Puis on fait un minus sur toutes les entrées obtenues précédemment avec les entrées obtenues pour la jointure, on enlève donc les entrées de la jointure
--On fait un select.


--g)
EXPLAIN plan FOR
    SELECT a.nom, a.prenom
    FROM BigAnnuaire a
    WHERE a.age >= ALL (SELECT b.age 
                       FROM BigAnnuaire b
		       WHERE b.cp = 75000);
@p3
--On commence par la requête à côté du all => On acccède aux entrées des personnes qui ont pour code postal 7500 dans la table BigAnnuaire avec l'index sur le cp
--On trie pour n'obtenir pas deux fois le même âge et pour obtenir par la même occasion l'age le plus grand.
--On accède ensuite aux entrées du BigAnnuaire et on trie
--On fait un merge join anti pour n'obtenir que les entrées qui ont été obtenues en 3, mais pas en 2
--On fait le select

--un index sur l'age où on prend chaque age une fois 

-- Exercice 6: Documentation et Requetes sur le catalogue
-- ======================================================
COLUMN TABLE_NAME format A20
SELECT TABLE_NAME, blocks, num_rows 
FROM user_tables;


SELECT index_name AS nom, blevel AS profondeur, distinct_keys AS nb_valeurs, leaf_blocks AS pages_de_Rowids
FROM user_indexes;
--indexcp de profondeur 1 avec 855 valeurs réparties sur 5 pages


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


    COLUMN nom format A20
    SELECT TABLE_NAME AS nom, num_rows AS cardinalite, blocks AS nb_pages 
    FROM user_tables;
 
    SELECT TABLE_NAME AS nom, num_rows AS cardinalite, blocks AS nb_pages 
    FROM all_tables
    WHERE TABLE_NAME = 'BIGANNUAIRE';
    

    COLUMN TABLE_NAME format A20
    COLUMN column_name format A20
    SELECT TABLE_NAME, column_name, utl_raw.cast_to_number(low_value) AS borneInf,  utl_raw.cast_to_number(high_value) AS borneSup, num_distinct, histogram
    FROM user_tab_cols
    WHERE data_type = 'NUMBER';
