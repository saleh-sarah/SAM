
-- tme 2018

prompt creation de la table C 


@vider

create table Club (  
  cnum number(10)  not null, 
  nom varchar2(30)  not null,
  division number(1)  not null, 
  ville varchar2(30),
  constraint I_C_cnum primary key(cnum)
);

--- ==================== DONNEES ================

-- definition de la procedure 
-- pour ajouter des tuples dans C 

create or replace procedure ajouterClub(n number) is
 prenom varchar2(30);
 n_salaire integer;
 nom varchar2(30);
 ville varchar2(30);
 n_sport integer;
 n_division integer;
--
begin
 DBMS_RANDOM.INITIALIZE(123456);
 FOR i in 1 .. n LOOP
   nom := 'nomC' || i;
   ville := 'ville' || (abs(DBMS_RANDOM.RANDOM) mod 10);
   n_division := abs(DBMS_RANDOM.RANDOM) mod 2;
   insert into Club values( i, nom, n_division + 1, ville);
 END LOOP;
 DBMS_RANDOM.TERMINATE;
 commit;
end;
/
sho err


-- remplir les relations:
prompt insertion des nuplets, patientez ...

begin
 ajouterClub(100);
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
dbms_stats.gather_table_stats(utilisateur, 'CLUB');
end;
/

prompt les tables analysées :
column table_name format A30
select table_name, global_stats as analysé from user_tables;

