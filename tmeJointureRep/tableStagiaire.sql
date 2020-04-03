
--tme 2018

prompt creation de la table Stagiaire


@vider

create table Stagiaire (
  licence number(10), 
  cnum number(10) not null, 
  prenom varchar2(30) not null, 
  salaire number(10)  not null, 
  sport varchar2(30),
  profil varchar2(4000)
) nocache nologging;




-- procedure pour ajouter plusieurs Personnes
create or replace procedure ajoutStagiaire(n number) is
 cnum integer;
 prenom varchar2(30);
 salaire integer;
 sport varchar2(30);
 profil varchar(4000);
--
begin
 DBMS_RANDOM.INITIALIZE(1);
   FOR i in 1 .. n LOOP
     -- générer des valeurs aléatoires pour une personne
     cnum := (abs(DBMS_RANDOM.RANDOM) mod 100) + 1;
     prenom := 'pn' || i;
     salaire := (abs(DBMS_RANDOM.RANDOM) mod 50000) + 10000;
     sport := 'sport' || (abs(DBMS_RANDOM.RANDOM) mod 200);
     profil := rpad('p' || abs(DBMS_RANDOM.RANDOM) mod 2000000, 4000, '.');
     --insérer un nuplet
     insert into Stagiaire values(i, cnum, prenom, salaire, sport, profil);
   END LOOP;
   -- valider les insertions
   commit;
   DBMS_RANDOM.TERMINATE;
end;
/
sho err

begin
 ajoutStagiaire(1000);
end;
/


-- STAT sur les données
-- ====================

declare 
utilisateur varchar2(30);
begin
select sys_context('USERENV', 'SESSION_USER')
into utilisateur
from dual;
dbms_stats.gather_table_stats(utilisateur, 'STAGIAIRE');
end;
/

prompt les tables analysées :
column table_name format A30
select table_name, global_stats as analysé from user_tables;
