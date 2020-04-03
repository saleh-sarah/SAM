-- BDR 2018

--tme Jointure Répartie

-- exemple de fichier pour préparer le tme


-- ============================
-- SITE 1
-- ============================
connect E3670340/E3670340@ora11
SELECT sys_context('USERENV', 'INSTANCE_NAME') FROM dual; 

--créer les Clubs
CONNECT E3670340/E3670340@ora11
    @tableClub
    DESC Club




-- ============================
-- SITE 2
-- ============================
connect E3670340/E3670340@ora10
SELECT sys_context('USERENV', 'INSTANCE_NAME') FROM dual; 

--créer les Stagiaires


    CONNECT E3670340/E3670340@ora10
    @tableStagiaire
    DESC Stagiaire



-- ============================
-- SITE 1
-- ============================
connect E3670340/E3670340@ora11
SELECT sys_context('USERENV', 'INSTANCE_NAME') FROM dual; 

--créer le lien et la vue

 CONNECT E3670340/E3670340@ora11
    DROP DATABASE link site2;
    -- remplacer 1234567 par votre numéro d'étudiant
    CREATE DATABASE link site2 CONNECT TO E3670340 IDENTIFIED BY "E3670340" USING 'ora10';

 CONNECT E3670340/E3670340@ora11
 DESC Stagiaire@site2

 CONNECT  E3670340/E3670340@ora11
    CREATE VIEW Stagiaire AS
    SELECT *
    FROM Stagiaire@site2;

--R1
  CONNECT E3670340/E3670340@ora11
    EXPLAIN plan FOR
    SELECT s.prenom, s.profil, c.division
    FROM Stagiaire s, Club c
    WHERE s.cnum = c.cnum and s.prenom like 'a%';
    @p5
    
    set linesize 180

--R2
SET linesize 1000
    EXPLAIN plan FOR
    SELECT s.prenom, s.profil, c.division
    FROM Stagiaire s, Club c
    WHERE s.cnum = c.cnum
    AND s.salaire > 59000;
    @p5

--oui elle est poussée sur le site 2

--R3a
 EXPLAIN plan FOR
    SELECT s.prenom, s.profil, c.division
    FROM Stagiaire s, Club c
    WHERE s.cnum = c.cnum
    AND c.ville = 'ville7';
    @p5

--R3b

    EXPLAIN plan FOR
    SELECT /*+ driving_site(s) */ s.prenom, s.profil, c.division
    FROM Stagiaire s, Club c
    WHERE s.cnum = c.cnum
    AND c.ville = 'ville7';
    @p5

--R4
    CONNECT E3670340/E3670340@ora10
    CREATE INDEX index_cnum
    ON Stagiaire (cnum) ;
    @liste
    

    EXPLAIN plan FOR
    SELECT s.prenom, s.profil, c.division
    FROM Stagiaire s, Club c
    WHERE s.cnum = c.cnum
    AND c.ville = 'ville7';
    @p5
