REM  Script:   del_data.sql
REM  Purpose:  To remove rows, constraints, and code from the hr sample schema
REM  Created:  By Nancy Greenberg on 18-MAR-2001
REM            for the Introduction to Oracle9i:SQL course
REM  This script is invoked by the hr_main script

ALTER TABLE departments
DISABLE CONSTRAINT DEPT_MGR_FK;

ALTER TABLE job_history
DISABLE CONSTRAINT JHIST_EMP_FK;

DROP TRIGGER secure_employees;

DROP TRIGGER update_job_history;

DROP PROCEDURE add_job_history;

DROP PROCEDURE secure_dml;

DELETE FROM employees
WHERE manager_id IN (108, 114, 120, 121, 122, 123, 145, 146, 147, 148);

DELETE FROM employees
WHERE employee_id IN (114, 120, 121, 122, 123, 145, 146, 147, 148, 
                      196, 197, 198, 199, 105, 106, 108, 175, 177, 
                      179, 203, 204);

DELETE FROM locations
WHERE location_id NOT IN 
  (SELECT DISTINCT location_id
   FROM departments);

DELETE FROM countries
WHERE country_id NOT IN
  (SELECT country_id
   FROM locations);

DELETE FROM jobs
WHERE job_id NOT IN
  (SELECT job_id
   FROM employees);

DELETE FROM departments
WHERE department_id NOT IN 
  (SELECT DISTINCT department_id
   FROM employees
   WHERE department_id IS NOT NULL);

UPDATE departments
SET manager_id = 124
WHERE department_id = 50;

UPDATE departments
SET manager_id = 149
WHERE department_id = 80;

DELETE FROM locations
WHERE location_id IN (2700, 2400);

UPDATE locations
SET street_address = '460 Bloor St. W.', 
    postal_code = 'ON M5S 1X8'
WHERE location_id = 1800;

ALTER TABLE departments
ENABLE CONSTRAINT DEPT_MGR_FK;

CREATE TABLE job_grades
(grade_level VARCHAR2(3),
 lowest_sal  NUMBER,
 highest_sal NUMBER);

INSERT INTO job_grades
VALUES ('A', 1000, 2999);

INSERT INTO job_grades
VALUES ('B', 3000, 5999);

INSERT INTO job_grades
VALUES('C', 6000, 9999);

INSERT INTO job_grades
VALUES('D', 10000, 14999);

INSERT INTO job_grades
VALUES('E', 15000, 24999);

INSERT INTO job_grades
VALUES('F', 25000, 40000);

INSERT INTO departments VALUES 
        ( 190 
        , 'Contracting'
        , NULL
        , 1700
        );

COMMIT;

                                                                                                                                                                                                                                                                                                                                                                                   hold the employee personnel information for the company.

Prompt ******  Creating EMPLOYEES table ....

CREATE TABLE employees
    ( employee_id    NUMBER(6)
    , first_name     VARCHAR2(20)
    , last_name      VARCHAR2(25)
	 CONSTRAINT     emp_last_name_nn  NOT NULL
    , email          VARCHAR2(25)
	CONSTRAINT     emp_email_nn  NOT NULL
    , phone_number   VARCHAR2(20)
    , hire_date      DATE
	CONSTRAINT     emp_hire_date_nn  NOT NULL
    , job_id         VARCHAR2(10)
	CONSTRAINT     emp_job_nn  NOT NULL
    , salary         NUMBER(8,2)
    , commission_pct NUMBER(2,2)
    , manager_id     NUMBER(6)
    , department_id  NUMBER(4)
    , CONSTRAINT     emp_salary_min
                     CHECK (salary > 0) 
    , CONSTRAINT     emp_email_uk
                     UNIQUE (email)
    ) ;




ALTER TABLE employees
ADD ( CONSTRAINT     emp_emp_id_pk
                     PRIMARY KEY (employee_id)
    , CONSTRAINT     emp_dept_fk
                     FOREIGN KEY (department_id)
                      REFERENCES departments
    , CONSTRAINT     emp_job_fk
                     FOREIGN KEY (job_id)
                      REFERENCES jobs (job_id)
    , CONSTRAINT     emp_manager_fk
                     FOREIGN KEY (manager_id)
                      REFERENCES employees
    ) ;

ALTER TABLE departments
ADD ( CONSTRAINT dept_mgr_fk
      		 FOREIGN KEY (manager_id)
      		  REFERENCES employees (employee_id)
    ) ;





REM Create the JOB_HISTORY table to hold the history of jobs that employees have held in the past.

Prompt ******  Creating JOB_HISTORY table ....

CREATE TABLE job_history
    ( employee_id   NUMBER(6)
	 CONSTRAINT    jhist_employee_nn  NOT NULL
    , start_date    DATE
	CONSTRAINT    jhist_start_date_nn  NOT NULL
    , end_date      DATE
	CONSTRAINT    jhist_end_date_nn  NOT NULL
    , job_id        VARCHAR2(10)
	CONSTRAINT    jhist_job_nn  NOT NULL
    , department_id NUMBER(4)
    , CONSTRAINT    jhist_date_interval
                    CHECK (end_date > start_date)
    ) ;


ALTER TABLE job_history
ADD ( CONSTRAINT jhist_emp_id_st_date_pk
      PRIMARY KEY (employee_id, start_date)
    , CONSTRAINT     jhist_job_fk
                     FOREIGN KEY (job_id)
                     REFERENCES jobs
    , CONSTRAINT     jhist_emp_fk
                     FOREIGN KEY (employee_id)
                     REFERENCES employees
    , CONSTRAINT     jhist_dept_fk
                     FOREIGN KEY (department_id)
                     REFERENCES departments
    ) ;


COMMIT;
