-- 10-1
CREATE TABLE ch10_departments AS
SELECT department_id, department_name
FROM departments;

ALTER TABLE ch10_departments ADD CONSTRAINTS pk_ch10_departments PRIMARY KEY (department_id);

CREATE OR REPLACE PROCEDURE ch10_iud_dep_proc (
    p_department_id IN ch10_departments.department_id%TYPE,
    p_department_name IN ch10_departments.department_name%TYPE,
    p_flag IN VARCHAR2
)
IS
BEGIN
    IF p_flag = 'I' THEN
        INSERT INTO ch10_departments (department_id, department_name)
        VALUES (p_department_id, p_department_name);
    ELSIF p_flag = 'U' THEN
        UPDATE ch10_departments
        SET department_name = p_department_name
        WHERE department_id = p_department_id;
    ELSIF p_flag = 'D' THEN
        DELETE ch10_departments
        WHERE department_id = p_department_id;
    END IF;
    COMMIT;
END;
/

-- 10-2
EXEC ch10_iud_dep_proc (10, '총무기획부', 'I');

/*
 ch10_departments에는 departments를 복사했으므로 10번 부서가 이미 입니다.
 department_id에 기본키가 있어 같은 번호를 또 INSERT 하면, ORA-00001 이 발생합니다.
 예외처리가 없으므로 오류가 그대로 호출자에게 전달됩니다.
*/

-- 10-3
CREATE OR REPLACE PROCEDURE ch10_iud_dep_proc (
    p_department_id IN ch10_departments.department_id%TYPE,
    p_department_name IN ch10_departments.department_name%TYPE,
    p_flag IN VARCHAR2
)
IS
BEGIN
    IF p_flag = 'I' THEN
        INSERT INTO ch10_departments (department_id, department_name)
        VALUES (p_department_id, p_department_name);
    ELSIF p_flag = 'U' THEN
        UPDATE ch10_departments SET department_name = p_department_name
        WHERE department_id = p_department_id;
    ELSIF p_flag = 'D' THEN
        DELETE ch10_departments WHERE department_id = p_department_id;
    END IF;
    COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('이미 존재하는 부서번호입니다 : ' || p_department_id);
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLCODE || ' : ' || SQLERRM);
        ROLLBACK;
END;
/

SET SERVEROUTPUT ON
EXEC ch10_iud_dep_proc (10, '총무기획부', 'I');

-- 10-4
CREATE OR REPLACE PROCEDURE ch10_iud_dep_proc (
    p_department_id IN ch10_departments.department_id%TYPE,
    p_department_name IN ch10_departments.department_name%TYPE,
    p_flag IN VARCHAR2
)
IS
    e_has_emp EXCEPTION;
    vn_cnt NUMBER := 0;
BEGIN
    IF p_flag = 'I' THEN
        INSERT INTO ch10_departments (department_id, department_name)
        VALUES (p_department_id, p_department_name);
    ELSIF p_flag = 'U' THEN
        UPDATE ch10_departments SET department_name = p_department_name
        WHERE department_id = p_department_id;
    ELSIF p_flag = 'D' THEN
        SELECT COUNT(*) INTO vn_cnt
        FROM employees
        WHERE department_id = p_department_id;

        IF vn_cnt > 0 THEN
            RAISE e_has_emp;
        END IF;

        DELETE ch10_departments WHERE department_id = p_department_id;
    END IF;
    COMMIT;

EXCEPTION
    WHEN e_has_emp THEN
        DBMS_OUTPUT.PUT_LINE('해당 부서에 속한 사원이 존재해 삭제할 수 없습니다.');
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLCODE || ' : ' || SQLERRM);
        ROLLBACK;
END;
/

SET SERVEROUTPUT ON
EXEC ch10_iud_dep_proc (10, NULL, 'D');

-- 10-5
CREATE OR REPLACE PROCEDURE ch10_iud_dep_proc (
    p_department_id IN ch10_departments.department_id%TYPE,
    p_department_name IN ch10_departments.department_name%TYPE,
    p_flag IN VARCHAR2
)
IS
    e_has_emp  EXCEPTION;
    PRAGMA EXCEPTION_INIT (e_has_emp, -20000);
    vn_cnt     NUMBER := 0;
BEGIN
    IF p_flag = 'I' THEN
        INSERT INTO ch10_departments (department_id, department_name)
        VALUES (p_department_id, p_department_name);
    ELSIF p_flag = 'U' THEN
        UPDATE ch10_departments SET department_name = p_department_name
        WHERE department_id = p_department_id;
    ELSIF p_flag = 'D' THEN
        SELECT COUNT(*) INTO vn_cnt FROM employees WHERE department_id = p_department_id;
        IF vn_cnt > 0 THEN
            RAISE e_has_emp;
        END IF;
        DELETE ch10_departments WHERE department_id = p_department_id;
    END IF;
    COMMIT;
EXCEPTION
    WHEN e_has_emp THEN
        DBMS_OUTPUT.PUT_LINE('예외코드 ' || SQLCODE || ' : 해당 부서에 사원이 있어 삭제 불가');
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLCODE || ' : ' || SQLERRM);
        ROLLBACK;
END;
/

SET SERVEROUTPUT ON
EXEC ch10_iud_dep_proc (10, NULL, 'D');


-- 1-6
CREATE OR REPLACE PROCEDURE ch10_iud_dep_proc (
    p_department_id IN ch10_departments.department_id%TYPE,
    p_department_name IN ch10_departments.department_name%TYPE,
    p_flag IN VARCHAR2 )
IS
    e_has_emp  EXCEPTION;
    PRAGMA EXCEPTION_INIT (e_has_emp, -20000);
    vn_cnt NUMBER := 0;
BEGIN
    IF p_flag = 'I' THEN
        INSERT INTO ch10_departments (department_id, department_name)
        VALUES (p_department_id, p_department_name);
    ELSIF p_flag = 'U' THEN
        UPDATE ch10_departments SET department_name = p_department_name
        WHERE department_id = p_department_id;
    ELSIF p_flag = 'D' THEN
        SELECT COUNT(*) INTO vn_cnt FROM employees WHERE department_id = p_department_id;
        IF vn_cnt > 0 THEN
            RAISE_APPLICATION_ERROR(
                -20000,
                '부서번호 ' || p_department_id || ' 에 사원이 ' || vn_cnt || '명 있어 삭제할 수 없습니다.'
            );
        END IF;
        DELETE ch10_departments WHERE department_id = p_department_id;
    END IF;
    COMMIT;
EXCEPTION
    WHEN e_has_emp THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLCODE || ' : ' || SQLERRM);
        ROLLBACK;
END;
/

SET SERVEROUTPUT ON
EXEC ch10_iud_dep_proc (10, NULL, 'D');