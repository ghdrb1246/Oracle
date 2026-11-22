-- 9-1
SET SERVEROUTPUT ON
DECLARE
    vn_base_num NUMBER := 3;
BEGIN
    FOR i IN REVERSE 9..1 LOOP
        DBMS_OUTPUT.PUT_LINE (vn_base_num || '*' || i || '= ' || vn_base_num * i);
    END LOOP;
END;
/

/*  
 FOR 루프의 범위는 REVERSE 를 쓰더라도 항상 '하한값..상한값' 순서로 적습니다.
 9..1 은 9이 1보다 커서 빈 범위이므로 루프 본문이 한 번도 실행되지 않습니다.
*/

-- 9-2
CREATE OR REPLACE FUNCTION my_initcap ( ps_str IN VARCHAR2 )
RETURN VARCHAR2
IS
    vs_rest    VARCHAR2(4000) := ps_str;
    vs_word    VARCHAR2(4000);
    vs_result  VARCHAR2(4000);
    vn_pos     NUMBER;
BEGIN
    IF ps_str IS NULL THEN
        RETURN NULL;
    END IF;

    LOOP
        vn_pos := NVL(INSTR(vs_rest, ' '), 0);

        IF vn_pos = 0 THEN
            vs_word := vs_rest;
        ELSE
            vs_word := SUBSTR(vs_rest, 1, vn_pos - 1);
        END IF;

        vs_result := vs_result || UPPER(SUBSTR(vs_word, 1, 1)) || LOWER(SUBSTR(vs_word, 2));

        EXIT WHEN vn_pos = 0;

        vs_result := vs_result || ' ';
        vs_rest   := SUBSTR(vs_rest, vn_pos + 1);
    END LOOP;

    RETURN vs_result;
END;
/
SELECT my_initcap('hello oRACLE world') AS my_initcap,
       INITCAP   ('hello oRACLE world') AS initcap
  FROM dual;
SELECT emp_name, my_initcap(LOWER(emp_name)) FROM employees WHERE ROWNUM <= 5;

-- 9-3
CREATE OR REPLACE FUNCTION my_last_day ( ps_date IN VARCHAR2 )
RETURN VARCHAR2
IS
    vd_date  DATE;
BEGIN
    vd_date := TO_DATE(ps_date, 'YYYYMMDD');
   
    RETURN TO_CHAR(ADD_MONTHS(TRUNC(vd_date, 'MM'), 1) - 1, 'YYYYMMDD');
END;
/
SELECT 
    my_last_day('20261122') AS my_func,
    TO_CHAR(LAST_DAY(TO_DATE('20261122','YYYYMMDD')),'YYYYMMDD') AS last_day,
    my_last_day('20240210') AS leap_feb
FROM dual;

-- 9-4
CREATE TABLE ch09_dept (
    department_id NUMBER,
    department_name VARCHAR2(100),
    levels NUMBER
);

CREATE OR REPLACE PROCEDURE my_hier_dept_proc
IS
BEGIN
    DELETE ch09_dept;

    INSERT INTO ch09_dept (department_id, department_name, levels)
    SELECT department_id,
           LPAD(' ', 3 * (LEVEL - 1)) || department_name,
           LEVEL
      FROM departments
     START WITH parent_id IS NULL
   CONNECT BY PRIOR department_id = parent_id;

    COMMIT;
END;
/
EXEC my_hier_dept_proc;
EXEC my_hier_dept_proc; -- 2번 실행해도 건수가 늘지 않아야 함.
SELECT COUNT(*) FROM ch09_dept;
SELECT * FROM ch09_dept;


-- 9-5
CREATE OR REPLACE PROCEDURE my_new_job_proc2 (
    p_job_id     IN JOBS.JOB_ID%TYPE,
    p_job_title  IN JOBS.JOB_TITLE%TYPE,
    p_min_sal    IN JOBS.MIN_SALARY%TYPE,
    p_max_sal    IN JOBS.MAX_SALARY%TYPE
)
IS
BEGIN
    MERGE INTO jobs a
    USING (
        SELECT p_job_id AS job_id,
            p_job_title AS job_title,
            p_min_sal AS min_sal,
            p_max_sal AS max_sal
        FROM dual) b
       ON (a.job_id = b.job_id)
    WHEN MATCHED THEN
    UPDATE SET 
        a.job_title = b.job_title,
        a.min_salary = b.min_sal,
        a.max_salary = b.max_sal,
        a.update_date = SYSDATE
    WHEN NOT MATCHED THEN
        INSERT (a.job_id, a.job_title, a.min_salary, a.max_salary, a.create_date, a.update_date)
        VALUES (b.job_id, b.job_title, b.min_sal, b.max_sal, SYSDATE, SYSDATE);
    COMMIT;
END;
/

EXEC my_new_job_proc2('SM_JOB2', 'Sample JOB2', 1000, 5000);
SELECT * FROM jobs WHERE job_id = 'SM_JOB2';
EXEC my_new_job_proc2('SM_JOB2', 'Sample JOB2-수정', 2000, 6000);


-- 9-6
CREATE TABLE ch09_departments AS
SELECT department_id, department_name, parent_id
FROM departments;

CREATE OR REPLACE PROCEDURE my_dept_manage_proc ( 
    p_department_id    IN ch09_departments.department_id%TYPE,
    p_department_name  IN ch09_departments.department_name%TYPE,
    p_parent_id        IN ch09_departments.parent_id%TYPE,
    p_flag             IN VARCHAR2
)
IS
    vn_cnt  NUMBER := 0;
BEGIN
    IF LOWER(p_flag) = 'upsert' THEN
        SELECT COUNT(*) INTO vn_cnt
        FROM ch09_departments
        WHERE department_id = p_department_id;

        IF vn_cnt = 0 THEN
            INSERT INTO ch09_departments (department_id, department_name, parent_id)
            VALUES (p_department_id, p_department_name, p_parent_id);
        ELSE
            UPDATE ch09_departments
            SET department_name = p_department_name, parent_id = p_parent_id
            WHERE department_id = p_department_id;
        END IF;

    ELSIF LOWER(p_flag) = 'delete' THEN
        SELECT COUNT(*) INTO vn_cnt
        FROM employees
        WHERE department_id = p_department_id;

        IF vn_cnt > 0 THEN
            DBMS_OUTPUT.PUT_LINE('경고: ' || p_department_id || '번 부서에 사원이 '|| vn_cnt || '명 있어 삭제하지 않습니다.');
            RETURN;
        END IF;

        DELETE ch09_departments WHERE department_id = p_department_id;
    ELSE
        DBMS_OUTPUT.PUT_LINE('flag 는 upsert 또는 delete 만 가능합니다.');
        RETURN;
    END IF;

    COMMIT;
END;
/

SET SERVEROUTPUT ON
EXEC my_dept_manage_proc(300, '과제부서', 10, 'upsert');
EXEC my_dept_manage_proc(300, '과제부서-수정', 10, 'upsert');
SELECT * FROM ch09_departments WHERE department_id = 300;
EXEC my_dept_manage_proc(10,  NULL, NULL, 'delete');
EXEC my_dept_manage_proc(300, NULL, NULL, 'delete');
SELECT * FROM ch09_departments WHERE department_id IN (10, 300);


