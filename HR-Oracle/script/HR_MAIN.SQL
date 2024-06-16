REM   Script:   Hr_main.SQL
REM   Purpose:  To create users and initialise scripts that create schema objects.
REM   Created:  By Nagavalli Pataballa, on 16-MAR-2001 
REM		for the Introduction to Oracle9i: PL/SQL course.

REM   This script is invoked through CRESCHEM.SQL script.
REM   
REM   This script accepts 4 parameter - password for the accounts,
REM   name of default tablespace, name of temporary tablespace, 
REM   and password for user SYS 

--  Set the default tablespace and temporary tablespace for the user HR
--  Create the user HR and grant necessary privileges
/* CREATE TABLESPACE thr
DATAFILE 'D:\datos\datahr.dbf'
SIZE 100M;

CREATE TEMPORARY TABLESPACE temphr
TEMPFILE 'D:\datos\tempdatahr.dbf'
size 10M;

alter session set "_oracle_script"=true;

CREATE USER hr IDENTIFIED BY hr
DEFAULT TABLESPACE thr
TEMPORARY TABLESPACE temphr
QUOTA UNLIMITED ON thr;

GRANT connect, resource, create view TO hr;
GRANT create session, create table, create procedure, create sequence, create trigger TO hr;
 */

@@hr_cre
@@hr_popul
@@hr_idx
@@hr_code
@@hr_comnt
@@del_data


